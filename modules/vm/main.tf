resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

resource "azurerm_public_ip" "pip" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_windows_virtual_machine" "win" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  zone                = var.availability_zone
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "linux" {
  count = var.os_type == "Linux" ? 1 : 0

  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  zone                  = var.availability_zone
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = var.admin_username
  disable_password_authentication = false
  admin_password        = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "bepool" {
  for_each = { for i, id in var.backend_pool_ids : i => id }
  network_interface_id     = azurerm_network_interface.nic.id
  ip_configuration_name    = "ipconfig1"
  backend_address_pool_id  = each.value
}

resource "azurerm_virtual_machine_extension" "iis_install" {
  count                = var.os_type == "Windows" ? 1 : 0
  name                 = "${var.name}-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.win[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    "commandToExecute" = <<EOT
      powershell -ExecutionPolicy Unrestricted -Command "
      # Install IIS
      Install-WindowsFeature -name Web-Server -IncludeManagementTools
      Set-Content -Path C:\\inetpub\\wwwroot\\index.html -Value '${var.custom_message}'
      
      # Mount File Share
      $connectTestResult = Test-NetConnection -ComputerName ${var.storage_account_name}.file.core.windows.net -Port 445
      if ($connectTestResult.TcpTestSucceeded) {
        cmd.exe /C 'cmdkey /add:${var.storage_account_name}.file.core.windows.net /user:localhost\\${var.storage_account_name} /pass:${var.storage_account_key}'
        New-Item -Path 'Z:' -ItemType Directory -Force
        net use Z: \\\\${var.storage_account_name}.file.core.windows.net\\${var.fileshare_name} /persistent:yes
      } else {
        Write-Error 'Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port.'
      }"
    EOT
  })
}

resource "azurerm_virtual_machine_extension" "apache_install" {
  count                = var.os_type == "Linux" ? 1 : 0
  name                 = "${var.name}-apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    script = base64encode(<<-EOF
#!/bin/bash
set -e

# Update package lists
sudo apt-get update

# Install Apache
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
echo "${var.custom_message2}" | sudo tee /var/www/html/index.html
sudo systemctl enable apache2
sudo systemctl start apache2

# Install CIFS utilities
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cifs-utils

# Create mount point
sudo mkdir -p /mnt/fileshare

# Mount file share
sudo mount -t cifs "//${var.storage_account_name}.file.core.windows.net/${var.fileshare_name}" /mnt/fileshare -o "vers=3.0,username=${var.storage_account_name},password=${var.storage_account_key},dir_mode=0777,file_mode=0777,serverino"

# Add to fstab if mount successful
if [ $? -eq 0 ]; then
    echo "File share mounted successfully"
    
    # Check if entry already exists in fstab
    if ! grep -q "${var.storage_account_name}.file.core.windows.net" /etc/fstab; then
        echo "//${var.storage_account_name}.file.core.windows.net/${var.fileshare_name} /mnt/fileshare cifs vers=3.0,username=${var.storage_account_name},password=${var.storage_account_key},dir_mode=0777,file_mode=0777,serverino 0 0" | sudo tee -a /etc/fstab
    fi
    
    # Create test file
    echo "Test file from ${var.name}" | sudo tee "/mnt/fileshare/test_${var.name}.txt"
else
    echo "Failed to mount file share"
    exit 1
fi
EOF
    )
  })
}


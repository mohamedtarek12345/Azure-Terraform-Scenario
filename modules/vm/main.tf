resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
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
  zone   = var.availability_zone
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
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

    custom_data = base64encode(templatefile("${path.module}/cloud-init-mount.tftpl", {
    storage_account_name = var.storage_account_name
    storage_account_key  = var.storage_account_key
    fileshare_name       = var.fileshare_name
  }))
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
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -name Web-Server -IncludeManagementTools; Set-Content -Path C:\\inetpub\\wwwroot\\index.html -Value '${var.custom_message}'\""
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
    commandToExecute = "bash -c 'sudo apt update && sudo apt install -y apache2 && echo ${var.custom_message2} | sudo tee /var/www/html/index.html && sudo systemctl enable apache2 && sudo systemctl start apache2'"
  })
}

resource "azurerm_virtual_machine_extension" "mount_fileshare" {
  count = var.os_type == "Linux" ? 1 : 0
  name                 = "${var.name}-mount-share-${count.index}"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    "fileUris" = []
    "commandToExecute" = <<-EOF
      sudo apt-get update
      sudo apt-get install -y cifs-utils
      sudo mkdir -p /mnt/fileshare
      sudo mount -t cifs //${var.storage_account_name}.file.core.windows.net/${var.fileshare_name} /mnt/fileshare -o vers=3.0,username=${var.storage_account_name},password=${var.storage_account_key},dir_mode=0777,file_mode=0777,serverino
      echo "//${var.storage_account_name}.file.core.windows.net/${var.fileshare_name} /mnt/fileshare cifs vers=3.0,username=${var.storage_account_name},password=${var.storage_account_key},dir_mode=0777,file_mode=0777,serverino 0 0" | sudo tee -a /etc/fstab
    EOF
  })
}


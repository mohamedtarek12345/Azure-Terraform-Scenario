resource "azurerm_virtual_machine_extension" "fileshare_mount_windows" {
  for_each = var.vm_id
  
  name                 = "mountFileShare-${each.key}"
  virtual_machine_id   = each.value
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -Command \"$connectTestResult = Test-NetConnection -ComputerName ${var.storage_account_name}.file.core.windows.net -Port 445; if ($connectTestResult.TcpTestSucceeded) { cmd.exe /C 'cmdkey /add:${var.storage_account_name}.file.core.windows.net /user:localhost\\${var.storage_account_name} /pass:${var.storage_account_key}'; New-Item -Path 'Z:' -ItemType Directory -Force; net use Z: \\\\${var.storage_account_name}.file.core.windows.net\\${var.name} /persistent:yes } else { Write-Error 'Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port.' }\""
  })
}

# Note: For Linux VMs, we don't create a separate extension here since it's handled in the VM module

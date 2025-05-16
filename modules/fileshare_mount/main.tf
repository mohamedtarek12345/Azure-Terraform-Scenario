resource "azurerm_virtual_machine_extension" "fileshare_mount" {
  name                 = var.name
  virtual_machine_id   = var.vm_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  

  settings = <<SETTINGS
    {
      "fileUris": ["${var.script_url}"],
      "commandToExecute": "bash install-fileshare.sh"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.storage_account_name}",
      "storageAccountKey": "${var.storage_account_key}"
    }
  PROTECTED_SETTINGS
}

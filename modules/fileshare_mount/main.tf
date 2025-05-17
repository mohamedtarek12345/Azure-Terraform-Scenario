resource "azurerm_virtual_machine_extension" "fileshare_mount" {
  for_each = toset(var.vm_id)
  name                 = "mountFileShare-${each.key}"
  virtual_machine_id   = each.value
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  

  settings = <<SETTINGS
    {
      "fileUris": ["${var.script_url}"],
      "commandToExecute": "bash install-fileshare.sh ${var.storage_account_name} ${var.storage_account_key} ${var.name}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.storage_account_name}",
      "storageAccountKey": "${var.storage_account_key}"
    }
  PROTECTED_SETTINGS
}

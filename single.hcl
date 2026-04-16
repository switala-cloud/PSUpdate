provisioner "powershell" {
  script = "scripts/windows-update.ps1"

  valid_exit_codes  = [0, 101]
  expect_disconnect = true
}

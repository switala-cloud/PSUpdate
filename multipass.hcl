# Pass 1
provisioner "powershell" {
  script = "scripts/windows-update.ps1"
  valid_exit_codes  = [0, 101]
  expect_disconnect = true
}

# Pass 2
provisioner "powershell" {
  script = "scripts/windows-update.ps1"
  valid_exit_codes  = [0, 101]
  expect_disconnect = true
}

# Optional Pass 3
provisioner "powershell" {
  script = "scripts/windows-update.ps1"
  valid_exit_codes  = [0, 101]
  expect_disconnect = true
}

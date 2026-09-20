terraform {
  required_version = ">= 1.7.0"
}

resource "terraform_data" "linux_network_lab" {
  triggers_replace = [
    filesha256("${path.module}/scripts/setup.sh"),
    filesha256("${path.module}/scripts/destroy.sh")
  ]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<-EOT
      $p = (wsl.exe wslpath -a '${path.module}/scripts/setup.sh').Trim()
      wsl.exe -u root -- bash $p
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue
    interpreter = ["PowerShell", "-Command"]
    command = <<-EOT
      $p = (wsl.exe wslpath -a '${path.module}/scripts/destroy.sh').Trim()
      wsl.exe -u root -- bash $p
    EOT
  }
}

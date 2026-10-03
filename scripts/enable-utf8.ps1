# Enable UTF-8 for the current PowerShell session.
# Works with Windows PowerShell 5.1 and PowerShell 7+.

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$global:OutputEncoding = $utf8NoBom

# Native Windows console programs may still consult the active code page.
# Switch it to UTF-8 when chcp is available.
if (Get-Command chcp.com -ErrorAction SilentlyContinue) {
    & chcp.com 65001 | Out-Null
}

Write-Host "UTF-8 mode enabled for this PowerShell session."
Write-Host ("Console input encoding : {0} (CP {1})" -f [Console]::InputEncoding.EncodingName, [Console]::InputEncoding.CodePage)
Write-Host ("Console output encoding: {0} (CP {1})" -f [Console]::OutputEncoding.EncodingName, [Console]::OutputEncoding.CodePage)
Write-Host ""
Write-Host "You can now run Terraform commands, for example:"
Write-Host "  terraform plan"
Write-Host "  terraform apply"
Write-Host "  terraform output"

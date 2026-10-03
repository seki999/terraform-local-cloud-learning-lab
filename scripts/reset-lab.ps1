param(
    [string]$Path = ".",
    [switch]$RemoveTfvars,
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path $Path).Path

Write-Host "Terraform lab reset target: $root"
Write-Host ""
Write-Host "This script removes local Terraform/runtime artifacts only."
Write-Host "It keeps source files and .terraform.lock.hcl."
Write-Host ""

function Remove-PathSafely {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    if (-not (Test-Path -LiteralPath $Target)) {
        return
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] Remove: $Target"
        return
    }

    Remove-Item -LiteralPath $Target -Recurse -Force
    Write-Host "Removed: $Target"
}

$directoriesToRemove = @(
    ".terraform",
    "generated"
)

foreach ($name in $directoriesToRemove) {
    Get-ChildItem -LiteralPath $root -Recurse -Force -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq $name } |
        Sort-Object FullName -Descending |
        ForEach-Object {
            Remove-PathSafely -Target $_.FullName
        }
}

$fileNamesToRemove = @(
    "terraform.tfstate",
    "terraform.tfstate.backup",
    "tfplan",
    "graph.dot",
    "graph.png",
    "graph.svg",
    "dependency.dot",
    "dependency.png",
    "dependency.svg"
)

Get-ChildItem -LiteralPath $root -Recurse -Force -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -in $fileNamesToRemove -or
        $_.Extension -eq ".tfplan"
    } |
    ForEach-Object {
        Remove-PathSafely -Target $_.FullName
    }

if ($RemoveTfvars) {
    Get-ChildItem -LiteralPath $root -Recurse -Force -File -Filter "terraform.tfvars" -ErrorAction SilentlyContinue |
        ForEach-Object {
            Remove-PathSafely -Target $_.FullName
        }
}

Write-Host ""
if ($WhatIf) {
    Write-Host "WhatIf completed. No files were changed."
}
else {
    Write-Host "Reset completed."
}
Write-Host "Preserved: *.tf, *.md, scripts, .terraform.lock.hcl, terraform.tfvars.example"

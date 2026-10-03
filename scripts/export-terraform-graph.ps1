param(
    [string]$DotFile = "graph.dot",
    [string]$PngFile = "graph.png",
    [switch]$NoPng
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "terraform command was not found in PATH."
}

# Capture Terraform stdout as text, then write UTF-8 without BOM.
# This avoids Windows PowerShell 5.1's '>' redirection, which writes UTF-16 LE.
$graph = (& terraform graph 2>&1 | Out-String)

if ($LASTEXITCODE -ne 0) {
    throw ("terraform graph failed:" + [Environment]::NewLine + $graph)
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$dotPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $DotFile))
[System.IO.File]::WriteAllText($dotPath, $graph, $utf8NoBom)

Write-Host "DOT file created (UTF-8 without BOM): $dotPath"

if ($NoPng) {
    exit 0
}

$dotCommand = Get-Command dot -ErrorAction SilentlyContinue
if (-not $dotCommand) {
    Write-Warning "Graphviz dot was not found. DOT file was created successfully, but PNG generation was skipped."
    Write-Host "Install Graphviz with: winget install Graphviz.Graphviz"
    exit 0
}

$pngPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $PngFile))
& dot -Tpng $dotPath -o $pngPath

if ($LASTEXITCODE -ne 0) {
    throw "Graphviz failed to generate PNG."
}

Write-Host "PNG file created: $pngPath"

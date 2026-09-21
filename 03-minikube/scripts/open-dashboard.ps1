param(
    [switch]$EnableMetrics
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    throw "minikube was not found in PATH. Install Minikube first."
}

Write-Host "Checking Minikube status..." -ForegroundColor Cyan
minikube status
if ($LASTEXITCODE -ne 0) {
    throw "Minikube is not running. Start it first with .\scripts\start-minikube.ps1"
}

if ($EnableMetrics) {
    Write-Host "Enabling metrics-server addon..." -ForegroundColor Cyan
    minikube addons enable metrics-server
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to enable metrics-server."
    }
}

Write-Host ""
Write-Host "Opening Kubernetes Dashboard..." -ForegroundColor Green
Write-Host "Tip: select namespace 'terraform-learning' in the Dashboard to view this chapter's resources."
Write-Host "Keep this PowerShell window open while using the Dashboard."
Write-Host "Press Ctrl+C here when you want to stop the local Dashboard proxy."
Write-Host ""

minikube dashboard

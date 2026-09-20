# Terraform Local Cloud Learning Lab - Local Preflight
# Run from repository root:
#   powershell -ExecutionPolicy Bypass -File .\scripts\preflight.ps1
#
# This script does not install or change anything. It only checks prerequisites.

$ErrorActionPreference = "Continue"
$script:Failures = 0
$script:Warnings = 0

function Write-Pass([string]$Message) {
    Write-Host "[PASS] $Message" -ForegroundColor Green
}
function Write-Warn([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
    $script:Warnings++
}
function Write-Fail([string]$Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:Failures++
}
function Test-Command([string]$Name, [bool]$Required = $true) {
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Pass "$Name found"
        return $true
    }
    if ($Required) { Write-Fail "$Name not found" } else { Write-Warn "$Name not found (optional)" }
    return $false
}

Write-Host ""
Write-Host "=== Terraform Local Cloud Learning Lab - Preflight ===" -ForegroundColor Cyan
Write-Host "This check is read-only. It will not install or modify your system."
Write-Host ""

Write-Host "--- Windows tools ---" -ForegroundColor Cyan
$hasTerraform = Test-Command "terraform"
$hasDocker    = Test-Command "docker"
$hasGit       = Test-Command "git"
$hasKubectl   = Test-Command "kubectl"
$hasMinikube  = Test-Command "minikube"
$hasKind      = Test-Command "kind"
$hasHelm      = Test-Command "helm"
$hasWsl       = Test-Command "wsl.exe"
$null         = Test-Command "curl.exe"
$null         = Test-Command "code" $false
$hasAws       = Test-Command "aws" $false

Write-Host ""
Write-Host "--- Versions ---" -ForegroundColor Cyan
if ($hasTerraform) { terraform version | Select-Object -First 1 }
if ($hasDocker)    { docker version --format "Docker Client={{.Client.Version}} Server={{.Server.Version}}" 2>$null }
if ($hasKubectl)   { kubectl version --client 2>$null | Select-Object -First 4 }
if ($hasMinikube)  { minikube version | Select-Object -First 1 }
if ($hasKind)      { kind version }
if ($hasHelm)      { helm version --short }
if ($hasWsl)       { wsl.exe --version 2>$null | Select-Object -First 3 }

Write-Host ""
Write-Host "--- Docker Desktop / Linux containers ---" -ForegroundColor Cyan
if ($hasDocker) {
    docker info *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "Docker daemon is running"
        $osType = docker info --format "{{.OSType}}" 2>$null
        if ($osType -eq "linux") {
            Write-Pass "Docker is using Linux containers"
        } else {
            Write-Fail "Docker OSType is '$osType'. Switch Docker Desktop to Linux containers."
        }
    } else {
        Write-Fail "Docker CLI exists, but Docker daemon is not reachable. Start Docker Desktop."
    }
}

Write-Host ""
Write-Host "--- WSL2 / default Linux distribution ---" -ForegroundColor Cyan
if ($hasWsl) {
    Write-Host "Installed distributions:"
    wsl.exe -l -v
    Write-Host ""

    wsl.exe -e sh -lc "exit 0" *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "The default WSL distribution cannot run a normal Linux shell. Install Ubuntu and make it the default distro."
    } else {
        $distroId = (wsl.exe -e sh -lc '. /etc/os-release 2>/dev/null; printf "%s" "${ID:-unknown}"' 2>$null).Trim()
        Write-Host "Default WSL distro ID: $distroId"
        if ($distroId -in @("ubuntu","debian","kali","fedora","arch")) {
            Write-Pass "Default WSL distro looks suitable for Linux networking labs"
        } else {
            Write-Warn "Default WSL distro '$distroId' is unusual. Ubuntu is recommended. If docker-desktop is default, run: wsl --set-default Ubuntu"
        }
    }

    Write-Host ""
    Write-Host "Required WSL commands:"
    $requiredLinux = @("sh","bash","ip","ping","curl","python3","openssl")
    foreach ($cmd in $requiredLinux) {
        wsl.exe -e sh -lc "command -v $cmd >/dev/null 2>&1"
        if ($LASTEXITCODE -eq 0) { Write-Pass "WSL: $cmd" } else { Write-Fail "WSL: $cmd missing" }
    }

    Write-Host ""
    Write-Host "Recommended WSL commands for networking/protocol labs:"
    $optionalLinux = @("tcpdump","dig","traceroute","nc","nft","iperf3","ss")
    foreach ($cmd in $optionalLinux) {
        wsl.exe -e sh -lc "command -v $cmd >/dev/null 2>&1"
        if ($LASTEXITCODE -eq 0) { Write-Pass "WSL: $cmd" } else { Write-Warn "WSL: $cmd missing" }
    }

    Write-Host ""
    Write-Host "Advanced optional commands:"
    $advancedLinux = @("wg","containerlab","vtysh","snmpwalk","snmptrap")
    foreach ($cmd in $advancedLinux) {
        wsl.exe -e sh -lc "command -v $cmd >/dev/null 2>&1"
        if ($LASTEXITCODE -eq 0) { Write-Pass "WSL: $cmd" } else { Write-Warn "WSL: $cmd missing (only needed by advanced labs)" }
    }
}

Write-Host ""
Write-Host "--- Kubernetes contexts ---" -ForegroundColor Cyan
if ($hasKubectl) {
    $contexts = kubectl config get-contexts -o name 2>$null
    if ($LASTEXITCODE -eq 0) {
        if ($contexts -contains "kind-terraform-lab") {
            Write-Pass "kubectl context kind-terraform-lab exists"
        } else {
            Write-Warn "kind-terraform-lab context does not exist yet. Run 04-kind\scripts\create-cluster.ps1 before Kind chapters."
        }
        if ($contexts -contains "minikube") {
            Write-Pass "kubectl context minikube exists"
        } else {
            Write-Warn "minikube context does not exist yet. Run 03-minikube\scripts\start-minikube.ps1 before Stage 3."
        }
    }
}

Write-Host ""
Write-Host "--- Common local ports ---" -ForegroundColor Cyan
$ports = @(3000, 4566, 8080, 8100, 8200, 8201)
foreach ($port in $ports) {
    $listener = Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue
    if ($listener) {
        Write-Warn "TCP port $port is already listening. This can conflict with one of the labs."
    } else {
        Write-Pass "TCP port $port is currently free"
    }
}

Write-Host ""
Write-Host "--- Optional LocalStack check ---" -ForegroundColor Cyan
if ($hasAws) {
    Write-Pass "AWS CLI is installed (useful only for optional 07-localstack verification)"
} else {
    Write-Warn "AWS CLI is not installed. Main learning path is still runnable; only some 07-localstack verification commands need it."
}

Write-Host ""
Write-Host "=== Result ===" -ForegroundColor Cyan
Write-Host "Failures: $script:Failures"
Write-Host "Warnings: $script:Warnings"

if ($script:Failures -gt 0) {
    Write-Host ""
    Write-Host "Preflight FAILED. Fix the red items before starting the full course." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Preflight PASSED. Yellow items are optional or chapter-specific." -ForegroundColor Green
Write-Host "Recommended first run: 01 -> 02 -> 03 -> 04, then continue with the roadmap."
exit 0

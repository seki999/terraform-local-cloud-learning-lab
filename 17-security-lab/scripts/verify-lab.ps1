param(
    [string]$ComposeFile = "docker-compose.yml"
)

$ErrorActionPreference = "Stop"

Write-Host "== Local Security Lab Verification =="

Write-Host "[1/6] Checking Docker..."
docker version --format '{{.Server.Version}}' | Out-Host

Write-Host "[2/6] Checking containers..."
docker compose -f $ComposeFile ps | Out-Host

Write-Host "[3/6] Checking host loopback service..."
$homeStatus = curl.exe -s -o NUL -w "%{http_code}" http://127.0.0.1:18080/
Write-Host "GET / => $homeStatus"

Write-Host "[4/6] Checking target from attacker..."
$adminStatus = docker compose -f $ComposeFile exec -T attacker sh -c 'curl -s -o /dev/null -w "%{http_code}" http://target/admin.txt'
Write-Host "GET /admin.txt => $adminStatus"

Write-Host "[5/6] Checking service enumeration..."
docker compose -f $ComposeFile exec -T attacker nmap -sT -Pn -p 80 target | Out-Host

Write-Host "[6/6] Showing recent target logs..."
docker compose -f $ComposeFile logs --tail 10 target | Out-Host

Write-Host ""
Write-Host "Interpretation:"
Write-Host "- Vulnerable state: / = 200 and /admin.txt = 200"
Write-Host "- Hardened state:   / = 200 and /admin.txt = 403"
Write-Host "- This script only targets the containers defined by this local lab."

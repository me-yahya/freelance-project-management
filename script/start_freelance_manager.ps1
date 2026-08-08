$WindowsProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Drive = $WindowsProjectPath.Substring(0, 1).ToLowerInvariant()
$ProjectPath = "/mnt/$Drive/" + $WindowsProjectPath.Substring(3).Replace("\", "/")
$LogPath = Join-Path $WindowsProjectPath "log\startup-server.log"
$ErrorLogPath = Join-Path $WindowsProjectPath "log\startup-server.err.log"
$ProxyLogPath = Join-Path $WindowsProjectPath "log\local-proxy.log"
$ProxyErrorLogPath = Join-Path $WindowsProjectPath "log\local-proxy.err.log"
$ProxyPidPath = Join-Path $WindowsProjectPath "tmp\pids\local-proxy.pid"

New-Item -ItemType Directory -Force -Path (Join-Path $WindowsProjectPath "log") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $WindowsProjectPath "tmp\pids") | Out-Null

Start-Process `
  -FilePath "wsl.exe" `
  -ArgumentList @("--cd", $ProjectPath, "bash", "-ic", "./script/start_freelance_manager.sh") `
  -WindowStyle Hidden `
  -RedirectStandardOutput $LogPath `
  -RedirectStandardError $ErrorLogPath

if (Test-Path -LiteralPath $ProxyPidPath) {
  $existingProxyPid = Get-Content -LiteralPath $ProxyPidPath -ErrorAction SilentlyContinue
  $existingProxy = Get-Process -Id $existingProxyPid -ErrorAction SilentlyContinue

  if (-not $existingProxy) {
    Remove-Item -LiteralPath $ProxyPidPath -ErrorAction SilentlyContinue
  }
}

if (-not (Test-Path -LiteralPath $ProxyPidPath)) {
  $nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue

  if ($env:NODE_EXE) {
    $nodePath = $env:NODE_EXE
  } elseif ($nodeCommand) {
    $nodePath = $nodeCommand.Source
  } elseif (Test-Path -LiteralPath "C:\nvm4w\nodejs\node.exe") {
    $nodePath = "C:\nvm4w\nodejs\node.exe"
  } else {
    Write-Error "Node.js was not found. Install Node.js or add node.exe to PATH."
    exit 1
  }

  $proxyProcess = Start-Process `
    -FilePath $nodePath `
    -ArgumentList @("script\local_domain_proxy.js") `
    -WorkingDirectory $WindowsProjectPath `
    -WindowStyle Hidden `
    -RedirectStandardOutput $ProxyLogPath `
    -RedirectStandardError $ProxyErrorLogPath `
    -PassThru

  Set-Content -LiteralPath $ProxyPidPath -Value $proxyProcess.Id
}

Write-Host "Starting Freelance Manager at http://work.local"
Write-Host "Logs: $LogPath"
Write-Host "Proxy logs: $ProxyLogPath"

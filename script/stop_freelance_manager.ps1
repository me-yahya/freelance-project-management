$WindowsProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Drive = $WindowsProjectPath.Substring(0, 1).ToLowerInvariant()
$ProjectPath = "/mnt/$Drive/" + $WindowsProjectPath.Substring(3).Replace("\", "/")
$ProxyPidPath = Join-Path $WindowsProjectPath "tmp\pids\local-proxy.pid"

if (Test-Path -LiteralPath $ProxyPidPath) {
  $proxyPid = Get-Content -LiteralPath $ProxyPidPath -ErrorAction SilentlyContinue
  $proxyProcess = Get-Process -Id $proxyPid -ErrorAction SilentlyContinue

  if ($proxyProcess) {
    Stop-Process -Id $proxyPid -Force
    Write-Host "Stopped local domain proxy PID $proxyPid."
  }

  Remove-Item -LiteralPath $ProxyPidPath -ErrorAction SilentlyContinue
}

wsl.exe --cd $ProjectPath bash -ic "./script/stop_freelance_manager.sh"

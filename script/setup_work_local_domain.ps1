$ErrorActionPreference = "Stop"

$WindowsProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Drive = $WindowsProjectPath.Substring(0, 1).ToLowerInvariant()
$ProjectPath = "/mnt/$Drive/" + $WindowsProjectPath.Substring(3).Replace("\", "/")
$HostsPath = Join-Path $env:SystemRoot "System32\drivers\etc\hosts"
$HostsEntry = "127.0.0.1 work.local"
$OldHostsPattern = "^\s*127\.0\.0\.1\s+freelance\.localhost\s*$"
$WorkHostsPattern = "^\s*127\.0\.0\.1\s+work\.local\s*$"

$hostsContent = Get-Content -LiteralPath $HostsPath
$nextHostsContent = $hostsContent | Where-Object {
  $_ -notmatch $OldHostsPattern -and $_ -notmatch $WorkHostsPattern
}
$nextHostsContent += $HostsEntry

Set-Content -LiteralPath $HostsPath -Value $nextHostsContent

wsl.exe --cd $ProjectPath bash -ic "bash ./script/generate_work_local_cert.sh"

Write-Host "work.local is ready for http://work.local"
Write-Host "Optional HTTPS certificate files were generated in script\certs."
Write-Host "Those certificate files are ignored by git and should not be committed."

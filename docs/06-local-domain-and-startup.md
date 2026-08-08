# Local Domain And Startup

## Goal

Use the app in your browser as:

```text
http://work.local
```

and start it automatically when Windows starts.

## Why WSL Still Matters

Ruby and Rails are installed inside WSL through `mise`, so the Rails server
must still run from WSL. Your Windows browser can use it normally.

## How The Clean Domain Works

There are two local processes:

- Rails runs inside WSL on `127.0.0.1:3000`.
- A small Node proxy runs on Windows on normal web port `80`.

Your browser opens:

```text
http://work.local
```

The proxy forwards that request to Rails behind the scenes.

## Step 1: One-Time Local Domain Setup

This script adds the Windows hosts entry and generates optional local HTTPS
certificate files:

```powershell
script\setup_work_local_domain.ps1
```

The hosts file should contain:

```text
127.0.0.1 work.local
```

Save the file.

Rails defaults to allowing only `work.local` in development. To use another
host while developing, set `LOCAL_APP_HOST` before starting Rails.

Note: `.local` can sometimes conflict with mDNS/Bonjour networking on some
systems. If that ever happens, `work.localhost` is the safer local-only version.

## Step 2: Start The App Without VS Code

From normal PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
script\start_freelance_manager.ps1
```

Open:

```text
http://work.local
```

To stop it:

```powershell
script\stop_freelance_manager.ps1
```

## Step 3: Start Automatically On Windows Login

The scheduled task has been created as:

```text
Freelance Manager Rails
```

It runs this script on Windows login:

```text
script\start_freelance_manager.ps1
```

To recreate it manually, open PowerShell and run:

```powershell
$taskName = "Freelance Manager Rails"
$powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$projectPath = (Resolve-Path ".").Path
$scriptPath = Join-Path $projectPath "script\start_freelance_manager.ps1"

$action = New-ScheduledTaskAction `
  -Execute $powershellPath `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" `
  -WorkingDirectory $projectPath

$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet `
  -StartWhenAvailable `
  -MultipleInstances IgnoreNew `
  -AllowStartIfOnBatteries

Register-ScheduledTask `
  -TaskName $taskName `
  -Action $action `
  -Trigger $trigger `
  -Settings $settings `
  -Description "Start local Freelance Manager Rails app and work.local proxy" `
  -Force
```

After the next login, Windows will start both the Rails server and the local
proxy.

## About `:3000`

You do not need to type `:3000` anymore.

Rails still runs on port `3000` internally because that is the normal Rails
development server port. The Node proxy hides that detail from the browser.

## About The Browser Security Label

`http://work.local` is local and private, but because it is HTTP, browsers may
still show a small "Not secure" label.

To remove that label completely, you need `https://work.local` with a trusted
local certificate authority. The project already generates certificate files
for that, but trusting a local CA in Windows is a security-sensitive operating
system change.

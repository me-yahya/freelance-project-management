# Freelance Manager

A Ruby on Rails learning application for managing freelance clients, projects,
tasks, invoices, and project files.

## Features

- Register, login, logout, edit profile, and change password
- Persistent signed session cookies
- Clients, projects, tasks, invoices, and file uploads
- Dashboard metrics for projects, tasks, billing, and deadlines
- Search, filters, validation errors, and flash messages
- Demo seed data and automated tests

## Requirements

- Ruby 3.4.10
- Rails 8.1.3.1
- SQLite
- Bundler

On Windows, use WSL/Ubuntu for Ruby and Rails commands.

## Standard Rails Setup

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
LOCAL_APP_HOST=localhost bin/rails server
```

Open:

```text
http://localhost:3000
```

Demo login after seeding:

```text
demo@example.com
password
```

## Optional Windows Local Domain

The app defaults to `work.local` in development because this project was built
as a local learning app.

From PowerShell:

```powershell
script\setup_work_local_domain.ps1
script\start_freelance_manager.ps1
```

Open:

```text
http://work.local
```

The PowerShell script starts Rails in WSL on port `3000` and a small local Node
proxy on port `80`, so the browser does not need `:3000`.

## Test

```bash
bin/rails test
```

## Learning Notes

Read the learning material in:

```text
docs/
```

For GitHub publishing steps, see:

```text
docs/github-publishing.md
```

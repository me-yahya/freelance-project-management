# Learning Roadmap

## App Goal

Build a local-only Freelance Project and Client Management System with
conventional Ruby on Rails.

The app now manages:

- Users and login sessions
- Clients
- Projects
- Tasks
- Invoices
- Project file attachments
- Dashboard metrics
- Search and filters
- Seed data
- Automated tests

## Stage Status

### Stage 1: Rails Project

Done.

Generated `freelance_manager` with SQLite and verified the server boots.

### Stage 2: Rails Structure And Database

Done.

Reviewed the Rails folders, database config, migrations, schema, and test
structure.

### Stage 3: Authentication

Done.

Implemented registration, login, logout, profile edit, password change, password
reset plumbing, sessions, flash messages, and protected routes.

### Stage 4: Clients

Done.

Implemented client CRUD, search, validations, ownership through `user_id`, and
authorization through `current_user.clients`.

### Stage 5: Projects

Done.

Implemented project CRUD, client association, project status values, status
filtering, budget validation, and deadline validation.

### Stage 6: Tasks

Done.

Implemented task CRUD, project association, priority/status values, filtering,
and a custom `complete` route.

### Stage 7: Invoices

Done.

Implemented invoice CRUD, project association, status values, amount validation,
and total invoiced/paid calculations.

### Stage 8: Dashboard

Done.

Implemented total clients, active projects, completed projects, pending tasks,
overdue tasks, total invoiced, total paid, recent projects, and upcoming
deadlines.

### Stage 9: Search And Filters

Done.

Implemented search/filter screens for clients, projects, tasks, and invoices.

### Stage 10: File Uploads

Done.

Implemented Active Storage project file attachments and file removal.

### Stage 11: Validation, Authorization, Errors

Done.

Added model validations, scoped controller lookups, strong parameters, shared
form errors, flash messages, and a consistent `404 Not Found` response.

### Stage 12: Seeds And Tests

Done.

Added demo seed data and a test suite covering authentication, CRUD,
authorization, validations, dashboard, and file removal.

### Stage 13: Architecture Review

Done.

See [Architecture Review](04-architecture-review.md).

## Final Data Model

```text
User
  has_many sessions
  has_many clients
  has_many projects, through: clients
  has_many tasks, through: projects
  has_many invoices, through: projects

Client
  belongs_to user
  has_many projects

Project
  belongs_to client
  has_many tasks
  has_many invoices
  has_many_attached files

Task
  belongs_to project

Invoice
  belongs_to project
```

## Ownership Rule

Every business record is reached from the logged-in user:

```text
current_user -> clients -> projects -> tasks/invoices/files
```

That is why controllers use code like:

```ruby
@client = current_user.clients.find(params[:id])
@project = current_user.projects.find(params[:id])
@task = current_user.tasks.find(params[:id])
@invoice = current_user.invoices.find(params[:id])
```

If a user tries to access a record they do not own, Rails returns `404 Not
Found`.

# Stage 1 And 2: Rails Project Basics

## What Was Implemented

The Rails app was generated here:

```text
freelance_manager/
```

It uses:

- Rails 8.1.3.1
- Ruby 3.4.10
- SQLite
- ERB views
- Propshaft for CSS assets
- Import maps, Turbo, and Stimulus from default Rails
- Minitest for tests

## Why The App Is In A Subfolder

The workspace root holds learning notes. The generated Rails app lives in:

```text
freelance_manager/
```

This keeps generated Rails files separate from tutorial notes.

## Main Rails Folders

### `app/models`

Models represent database-backed objects and business rules.

Current examples:

- `app/models/user.rb`
- `app/models/session.rb`
- `app/models/current.rb`

### `app/controllers`

Controllers receive requests, talk to models, and choose the response.

Current examples:

- `app/controllers/sessions_controller.rb`
- `app/controllers/registrations_controller.rb`
- `app/controllers/dashboard_controller.rb`

### `app/views`

Views are ERB templates. They produce HTML.

Current examples:

- `app/views/sessions/new.html.erb`
- `app/views/registrations/new.html.erb`
- `app/views/dashboard/index.html.erb`

### `config/routes.rb`

Routes map URLs to controller actions.

Current examples:

```ruby
root "dashboard#index"
resource :registration, only: %i[ new create edit update ]
resource :session
resources :passwords, param: :token
```

### `db/migrate`

Migrations change the database structure.

Current examples:

- `20260808192746_create_users.rb`
- `20260808192755_create_sessions.rb`
- `20260808192916_add_name_to_users.rb`

### `db/schema.rb`

This is Rails' current database snapshot after migrations run. Do not edit this
file by hand.

### `test`

Tests verify behavior.

Current examples:

- `test/controllers/sessions_controller_test.rb`
- `test/controllers/registrations_controller_test.rb`
- `test/controllers/dashboard_controller_test.rb`

## Request Flow

When a guest visits:

```text
GET /
```

Rails does this:

```text
Browser
  -> config/routes.rb
  -> DashboardController#index
  -> Authentication concern sees there is no session
  -> redirect to SessionsController#new
  -> app/views/sessions/new.html.erb
  -> HTML response
```

This is the Rails MVC loop:

- Route decides which controller action runs.
- Controller coordinates the request.
- Model handles data.
- View renders HTML.

## Commands Used

```bash
bin/rails db:prepare
bin/rails db:migrate
bin/rails routes
bin/rails test
bin/rails server
```

## Verification

The app was verified with:

```text
GET /                 -> 302 redirect to /session/new for guests
GET /session/new      -> 200
GET /registration/new -> 200
GET /up               -> 200
```

The test suite passed:

```text
20 runs, 76 assertions, 0 failures, 0 errors, 0 skips
```

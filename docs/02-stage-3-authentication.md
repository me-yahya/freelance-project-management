# Stage 3: Authentication

## What Was Implemented

Authentication now supports:

- Register
- Login
- Logout
- Edit profile
- Change password
- Protected dashboard
- Flash messages
- Form validation errors
- Automated tests

## Generated Rails Auth Files

Rails 8 includes an authentication generator:

```bash
bin/rails generate authentication
```

It created:

- `app/models/user.rb`
- `app/models/session.rb`
- `app/models/current.rb`
- `app/controllers/sessions_controller.rb`
- `app/controllers/passwords_controller.rb`
- `app/controllers/concerns/authentication.rb`
- `app/mailers/passwords_mailer.rb`
- password reset views
- user/session migrations
- tests and fixtures

## Files We Added Or Changed

Added:

- `app/controllers/dashboard_controller.rb`
- `app/controllers/registrations_controller.rb`
- `app/views/dashboard/index.html.erb`
- `app/views/registrations/new.html.erb`
- `app/views/registrations/edit.html.erb`
- `app/views/shared/_form_errors.html.erb`
- `test/controllers/dashboard_controller_test.rb`
- `test/controllers/registrations_controller_test.rb`

Changed:

- `config/routes.rb`
- `app/models/user.rb`
- `app/controllers/concerns/authentication.rb`
- `app/views/layouts/application.html.erb`
- `app/views/sessions/new.html.erb`
- `app/views/passwords/new.html.erb`
- `app/views/passwords/edit.html.erb`
- `app/assets/stylesheets/application.css`
- `test/fixtures/users.yml`
- `db/migrate/20260808192916_add_name_to_users.rb`

## User Model

File:

```text
app/models/user.rb
```

Important code:

```ruby
has_secure_password
has_many :sessions, dependent: :destroy

validates :name, presence: true
validates :email_address, presence: true,
  uniqueness: { case_sensitive: false },
  format: { with: URI::MailTo::EMAIL_REGEXP }
```

What this teaches:

- `has_secure_password` stores a password safely using `password_digest`.
- The real password is never stored.
- `validates` prevents bad data from being saved.
- `has_many :sessions` means one user can have many login sessions.

## Session Model

File:

```text
app/models/session.rb
```

Important code:

```ruby
belongs_to :user
```

Each login creates a `sessions` database row. The browser receives a signed
cookie containing that session id.

## Login Persistence

The app is already set up to keep you logged in:

```ruby
cookies.signed.permanent[:session_id] = {
  value: session.id,
  httponly: true,
  same_site: :lax
}
```

This line lives in:

```text
app/controllers/concerns/authentication.rb
```

What it means:

- `signed` means Rails protects the cookie from being tampered with.
- `permanent` means the cookie survives browser restarts.
- `httponly` means JavaScript cannot read the cookie.
- `same_site: :lax` helps protect against cross-site request attacks.

So the normal behavior is:

```text
Log in once
  -> browser stores signed permanent session_id cookie
  -> future visits use that cookie
  -> app finds the matching Session row
  -> you stay logged in
```

You should only be asked to log in again if you log out, clear browser cookies,
delete/reset the Rails database, or switch to a different browser/domain. For
example, a login cookie from `127.0.0.1` is different from one for
`work.local`.

## Authentication Concern

File:

```text
app/controllers/concerns/authentication.rb
```

This concern is included in:

```text
app/controllers/application_controller.rb
```

That means every controller is protected by default.

Important idea:

```ruby
before_action :require_authentication
```

A `before_action` runs before controller actions. Here, it checks if the user is
logged in. If not, it redirects them to the login page.

## Current User

File:

```text
app/models/current.rb
```

`Current.user` is the logged-in user for the current request.

We exposed it to controllers and views as:

```ruby
current_user
```

That is why the dashboard can say:

```erb
Welcome, <%= current_user.name %>
```

## Routes

File:

```text
config/routes.rb
```

Current auth routes:

```ruby
root "dashboard#index"

resource :registration, only: %i[ new create edit update ]
resource :session
resources :passwords, param: :token
```

Meaning:

- `/` goes to the dashboard.
- `/registration/new` shows signup.
- `POST /registration` creates an account.
- `/registration/edit` edits the current user's profile.
- `/session/new` shows login.
- `POST /session` logs in.
- `DELETE /session` logs out.

## Strong Parameters

File:

```text
app/controllers/registrations_controller.rb
```

Important code:

```ruby
params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
```

Strong parameters say which form fields Rails is allowed to accept. This keeps
users from submitting extra fields like `admin: true`.

## Forms And ERB

Example:

```text
app/views/registrations/new.html.erb
```

Rails form helpers create HTML forms connected to routes and models:

```erb
<%= form_with model: @user, url: registration_path do |form| %>
```

ERB syntax:

- `<%= ... %>` runs Ruby and prints the result.
- `<% ... %>` runs Ruby without printing.

## Shared Partial

File:

```text
app/views/shared/_form_errors.html.erb
```

The underscore means this is a partial. A partial is a reusable view piece.

Registration and profile edit both use:

```erb
<%= render "shared/form_errors", record: @user %>
```

## Flash Messages

File:

```text
app/views/layouts/application.html.erb
```

Flash messages show one-time notices after redirects:

```ruby
redirect_to root_path, notice: "Account created."
```

The layout renders them on the next page.

## Tests

Run:

```bash
bin/rails test
```

Current result:

```text
80 runs, 285 assertions, 0 failures, 0 errors, 0 skips
```

The tests check:

- Guests are redirected from the dashboard.
- Logged-in users can see the dashboard.
- Signup creates a user and starts a session.
- Invalid signup fails.
- Profile update works.
- Password change works.
- Login/logout behavior works.
- Login creates a permanent cookie and later requests stay authenticated.

## Beginner Mental Model

Authentication here is:

```text
User enters email/password
  -> SessionsController#create
  -> User.authenticate_by(...)
  -> create Session row
  -> store signed session_id cookie
  -> future requests load Current.session
  -> current_user becomes available
```

When logging out:

```text
DELETE /session
  -> SessionsController#destroy
  -> delete Session row
  -> delete browser cookie
  -> redirect to sign in
```

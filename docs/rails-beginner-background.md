# Beginner Rails Background

## Ruby Versus Rails

Ruby is the programming language.

Rails is a web framework written in Ruby. It gives you a project structure,
routing, database tools, forms, views, tests, and many conventions.

## Convention Over Configuration

Rails expects names to match.

Example:

```ruby
class User < ApplicationRecord
end
```

Rails connects this class to the `users` database table by convention.

Another example:

```ruby
class SessionsController < ApplicationController
end
```

Rails expects session views to live in:

```text
app/views/sessions/
```

This saves configuration, but beginners must learn the naming rules.

## MVC

Rails uses MVC:

- Model: data and rules
- View: HTML
- Controller: request handling

Example from this app:

```text
Model:      app/models/user.rb
Controller: app/controllers/registrations_controller.rb
View:       app/views/registrations/new.html.erb
```

## Active Record

Active Record is Rails' database layer.

Instead of writing SQL manually, you write Ruby:

```ruby
User.find_by(email_address: "one@example.com")
```

Rails turns that into SQL and returns a `User` object.

## Migrations

Migrations are Ruby files that change database structure.

Example:

```ruby
create_table :users do |t|
  t.string :email_address, null: false
  t.string :password_digest, null: false
  t.timestamps
end
```

Run migrations with:

```bash
bin/rails db:migrate
```

## Routes

Routes connect URLs to controller actions.

Example:

```ruby
resource :session
```

This creates login-related routes such as:

```text
GET    /session/new
POST   /session
DELETE /session
```

Check routes with:

```bash
bin/rails routes
```

## Controllers

Controllers are Ruby classes with action methods.

Example:

```ruby
def create
  @user = User.new(registration_params)

  if @user.save
    redirect_to root_path
  else
    render :new, status: :unprocessable_entity
  end
end
```

Common controller actions:

- `index`: list records
- `show`: show one record
- `new`: show a new form
- `create`: save a new record
- `edit`: show an edit form
- `update`: save changes
- `destroy`: delete a record

## Views And ERB

Views are HTML templates with Ruby inside.

Example:

```erb
<h1>Welcome, <%= current_user.name %></h1>
```

Rails renders this into plain HTML before sending it to the browser.

## Redirect Versus Render

`render` shows a template during the same request.

`redirect_to` tells the browser to make a new request.

Common pattern:

```ruby
if record.save
  redirect_to root_path, notice: "Saved."
else
  render :new, status: :unprocessable_entity
end
```

Use `render` when validation fails so the form can display errors.

Use `redirect_to` after success to avoid duplicate form submissions.

## Validations

Validations live in models.

Example:

```ruby
validates :name, presence: true
```

If a validation fails, `record.save` returns `false`, and
`record.errors.full_messages` contains user-friendly error messages.

## Helpers

Helpers are methods available in views.

In this app, the authentication concern exposes:

```ruby
helper_method :authenticated?, :current_user
```

That lets the layout ask:

```erb
<% if authenticated? %>
```

## Tests

Tests protect behavior as the app grows.

Example from this app:

```ruby
test "creates account and starts a session" do
  assert_difference "User.count", 1 do
    post registration_path, params: { user: { ... } }
  end
end
```

Run tests often:

```bash
bin/rails test
```

## What To Learn Before Stage 4

Make sure these ideas are clear:

- A route maps a URL to a controller action.
- A controller action prepares data and renders or redirects.
- A model talks to the database.
- A view turns data into HTML.
- A migration changes the database structure.
- A validation protects data quality.
- A session keeps a user logged in.

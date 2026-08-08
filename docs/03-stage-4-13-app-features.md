# Stages 4-13: App Features

## Stage 4: Clients

Main files:

- `app/models/client.rb`
- `app/controllers/clients_controller.rb`
- `app/views/clients/`
- `db/migrate/*_create_clients.rb`
- `test/controllers/clients_controller_test.rb`
- `test/models/client_test.rb`

Important model code:

```ruby
belongs_to :user
validates :name, presence: true
validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
```

Important controller idea:

```ruby
@client = current_user.clients.find(params[:id])
```

This is authorization. The controller only looks inside the current user's
clients, so another user's client id returns `404 Not Found`.

## Stage 5: Projects

Main files:

- `app/models/project.rb`
- `app/controllers/projects_controller.rb`
- `app/views/projects/`
- `db/migrate/*_create_projects.rb`

Association:

```ruby
class Client < ApplicationRecord
  has_many :projects, dependent: :destroy
end

class Project < ApplicationRecord
  belongs_to :client
end
```

Project status values are stored as strings:

```ruby
planned
active
on_hold
completed
cancelled
```

The index page uses query params:

```text
/projects?status=active
```

The controller reads that with:

```ruby
params[:status]
```

## Stage 6: Tasks

Main files:

- `app/models/task.rb`
- `app/controllers/tasks_controller.rb`
- `app/views/tasks/`
- `db/migrate/*_create_tasks.rb`

Tasks belong to projects:

```ruby
class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
end
```

The custom route:

```ruby
resources :tasks do
  patch :complete, on: :member
end
```

creates:

```text
PATCH /tasks/:id/complete
```

That route lets a user mark one task completed without editing the full form.

## Stage 7: Invoices

Main files:

- `app/models/invoice.rb`
- `app/controllers/invoices_controller.rb`
- `app/views/invoices/`
- `db/migrate/*_create_invoices.rb`

Important validations:

```ruby
validates :invoice_number, presence: true, uniqueness: { scope: :project_id }
validates :amount, numericality: { greater_than: 0 }
```

Totals use Active Record aggregate queries:

```ruby
current_user.invoices.sum(:amount)
current_user.invoices.where(status: "paid").sum(:amount)
```

## Stage 8: Dashboard

Main files:

- `app/controllers/dashboard_controller.rb`
- `app/views/dashboard/index.html.erb`

The dashboard uses database queries to calculate:

- Total clients
- Active projects
- Completed projects
- Pending tasks
- Overdue tasks
- Total invoiced
- Total paid
- Recent projects
- Upcoming deadlines

Example:

```ruby
@pending_task_count = current_user.tasks.where.not(status: "completed").count
```

The controller prepares data. The view displays it.

## Stage 9: Search And Filters

Search is implemented with model class methods and GET forms.

Example from `Client`:

```ruby
def self.search(term)
  return all if term.blank?

  query = "%#{sanitize_sql_like(term.to_s.downcase)}%"
  where(
    "LOWER(name) LIKE :query OR LOWER(company) LIKE :query OR LOWER(email) LIKE :query",
    query:
  )
end
```

Why GET forms?

Search does not change data. It should create URLs that can be refreshed,
bookmarked, and shared.

Example:

```text
/clients?query=acme
/tasks?status=to_do&priority=high
```

## Stage 10: Active Storage File Uploads

Installed with:

```bash
bin/rails active_storage:install
bin/rails db:migrate
```

Main files:

- `app/models/project.rb`
- `app/controllers/project_files_controller.rb`
- `app/views/projects/_form.html.erb`
- `app/views/projects/show.html.erb`
- Active Storage migrations

Model code:

```ruby
has_many_attached :files
```

Form code:

```erb
<%= form.file_field :files, multiple: true %>
```

This lets a project have many attached files without manually creating a
`project_files` table.

## Stage 11: Validation, Authorization, Errors

Validation lives in models.

Authorization happens in controllers by loading through `current_user`.

Errors are displayed with a shared partial:

```text
app/views/shared/_form_errors.html.erb
```

Missing or unauthorized records are handled in:

```text
app/controllers/application_controller.rb
```

Code:

```ruby
rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
```

## Stage 12: Seeds And Tests

Seed file:

```text
db/seeds.rb
```

Run:

```bash
bin/rails db:seed
```

Demo account:

```text
demo@example.com
password
```

Test command:

```bash
bin/rails test
```

Current result:

```text
78 runs, 273 assertions, 0 failures, 0 errors, 0 skips
```

The tests cover:

- Authentication
- Controller access
- CRUD actions
- Cross-user authorization
- Model validations
- Search helpers
- Dashboard rendering
- Active Storage file removal

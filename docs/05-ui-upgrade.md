# UI Upgrade Notes

## What Changed

The app now has a more complete freelancer workspace UI:

- Sidebar navigation for authenticated users
- Cleaner login/register layout for guests
- Better system font stack
- Dashboard quick actions
- Dashboard panels for projects, tasks, deadlines, and invoices
- Status-specific badges
- Priority badges for tasks
- More polished tables, forms, empty states, and detail panels
- Project detail pages now show related tasks and invoices

## Main Files

Layout:

```text
freelance_manager/app/views/layouts/application.html.erb
```

Styles:

```text
freelance_manager/app/assets/stylesheets/application.css
```

View helpers:

```text
freelance_manager/app/helpers/application_helper.rb
```

Dashboard:

```text
freelance_manager/app/controllers/dashboard_controller.rb
freelance_manager/app/views/dashboard/index.html.erb
```

Project workflow:

```text
freelance_manager/app/controllers/projects_controller.rb
freelance_manager/app/views/projects/show.html.erb
```

## Rails Concepts

### Layout

The layout wraps every page. That is why navigation, flash messages, and the
app shell live in one file instead of being repeated in every view.

### Helper

Helpers keep view logic readable.

Examples:

```ruby
status_badge(project)
priority_badge(task)
app_nav_link("Projects", projects_path, "projects")
```

Instead of writing badge CSS classes manually in every ERB file, the helper
builds the HTML consistently.

### CSS

Rails serves CSS from:

```text
app/assets/stylesheets/application.css
```

This project keeps CSS simple and local. There is no frontend build system or
separate JavaScript app.

## Verification

After the UI pass:

```text
78 runs, 273 assertions, 0 failures, 0 errors, 0 skips
```

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
demo = User.find_or_initialize_by(email_address: "demo@example.com")
demo.name = "Demo Freelancer"
demo.password = "password" if demo.new_record?
demo.password_confirmation = "password" if demo.new_record?
demo.save!

acme = demo.clients.find_or_create_by!(name: "Acme Design") do |client|
  client.company = "Acme Co"
  client.email = "hello@acme.example"
  client.phone = "555-0100"
  client.address = "123 Market Street"
  client.notes = "Long-term design client."
end

beta = demo.clients.find_or_create_by!(name: "Beta Systems") do |client|
  client.company = "Beta LLC"
  client.email = "contact@beta.example"
  client.phone = "555-0200"
  client.address = "456 Broadway"
  client.notes = "Software consulting lead."
end

website = acme.projects.find_or_create_by!(name: "Website Redesign") do |project|
  project.description = "Redesign the marketing website and improve conversion flows."
  project.start_date = Date.current
  project.deadline = Date.current + 21.days
  project.budget = 2500
  project.status = "active"
end

portal = beta.projects.find_or_create_by!(name: "Internal Portal") do |project|
  project.description = "Build an internal dashboard for operations reporting."
  project.start_date = Date.current + 3.days
  project.deadline = Date.current + 45.days
  project.budget = 5000
  project.status = "planned"
end

website.tasks.find_or_create_by!(title: "Draft homepage") do |task|
  task.description = "Create the first homepage layout and copy structure."
  task.due_date = Date.current + 7.days
  task.priority = "high"
  task.status = "in_progress"
end

website.tasks.find_or_create_by!(title: "Review brand assets") do |task|
  task.description = "Collect logos, typography, and image requirements."
  task.due_date = Date.current + 4.days
  task.priority = "medium"
  task.status = "to_do"
end

portal.tasks.find_or_create_by!(title: "Define reports") do |task|
  task.description = "List the reports needed for the first dashboard version."
  task.due_date = Date.current + 14.days
  task.priority = "medium"
  task.status = "to_do"
end

website.invoices.find_or_create_by!(invoice_number: "INV-001") do |invoice|
  invoice.amount = 1500
  invoice.issue_date = Date.current
  invoice.due_date = Date.current + 14.days
  invoice.status = "sent"
end

portal.invoices.find_or_create_by!(invoice_number: "INV-002") do |invoice|
  invoice.amount = 2500
  invoice.issue_date = Date.current
  invoice.due_date = Date.current + 30.days
  invoice.status = "draft"
end

puts "Seeded demo@example.com with password: password"

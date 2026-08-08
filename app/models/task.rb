class Task < ApplicationRecord
  PRIORITIES = {
    "low" => "Low",
    "medium" => "Medium",
    "high" => "High"
  }.freeze

  STATUSES = {
    "to_do" => "To Do",
    "in_progress" => "In Progress",
    "completed" => "Completed"
  }.freeze

  belongs_to :project

  validates :title, presence: true
  validates :priority, inclusion: { in: PRIORITIES.keys }
  validates :status, inclusion: { in: STATUSES.keys }

  scope :with_status, ->(status) { status.present? ? where(status:) : all }
  scope :with_priority, ->(priority) { priority.present? ? where(priority:) : all }
  scope :overdue, -> { where("tasks.due_date < ? AND tasks.status != ?", Date.current, "completed") }

  def self.search(term)
    return all if term.blank?

    query = "%#{sanitize_sql_like(term.to_s.downcase)}%"
    where("LOWER(tasks.title) LIKE :query OR LOWER(tasks.description) LIKE :query", query:)
  end

  def self.priority_options
    PRIORITIES.map { |value, label| [ label, value ] }
  end

  def self.status_options
    STATUSES.map { |value, label| [ label, value ] }
  end

  def priority_label
    PRIORITIES.fetch(priority, priority.to_s.humanize)
  end

  def status_label
    STATUSES.fetch(status, status.to_s.humanize)
  end

  def completed?
    status == "completed"
  end
end

class Project < ApplicationRecord
  STATUSES = {
    "planned" => "Planned",
    "active" => "Active",
    "on_hold" => "On Hold",
    "completed" => "Completed",
    "cancelled" => "Cancelled"
  }.freeze

  belongs_to :client
  has_many :tasks, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many_attached :files

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES.keys }
  validates :budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :deadline_not_before_start_date

  scope :with_status, ->(status) { status.present? ? where(status:) : all }

  def self.search(term)
    return all if term.blank?

    query = "%#{sanitize_sql_like(term.to_s.downcase)}%"
    where("LOWER(projects.name) LIKE :query OR LOWER(projects.description) LIKE :query", query:)
  end

  def self.status_options
    STATUSES.map { |value, label| [ label, value ] }
  end

  def status_label
    STATUSES.fetch(status, status.to_s.humanize)
  end

  private
    def deadline_not_before_start_date
      return if start_date.blank? || deadline.blank?

      errors.add(:deadline, "must be after the start date") if deadline < start_date
    end
end

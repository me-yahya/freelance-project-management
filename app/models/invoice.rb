class Invoice < ApplicationRecord
  STATUSES = {
    "draft" => "Draft",
    "sent" => "Sent",
    "paid" => "Paid",
    "overdue" => "Overdue"
  }.freeze

  belongs_to :project

  validates :invoice_number, presence: true, uniqueness: { scope: :project_id }
  validates :amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES.keys }
  validate :due_date_not_before_issue_date

  scope :with_status, ->(status) { status.present? ? where(status:) : all }

  def self.search(term)
    return all if term.blank?

    query = "%#{sanitize_sql_like(term.to_s.downcase)}%"
    where("LOWER(invoices.invoice_number) LIKE :query", query:)
  end

  def self.status_options
    STATUSES.map { |value, label| [ label, value ] }
  end

  def status_label
    STATUSES.fetch(status, status.to_s.humanize)
  end

  private
    def due_date_not_before_issue_date
      return if issue_date.blank? || due_date.blank?

      errors.add(:due_date, "must be after the issue date") if due_date < issue_date
    end
end

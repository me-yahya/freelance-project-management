class Client < ApplicationRecord
  belongs_to :user
  has_many :projects, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def self.search(term)
    return all if term.blank?

    query = "%#{sanitize_sql_like(term.to_s.downcase)}%"
    where(
      "LOWER(name) LIKE :query OR LOWER(company) LIKE :query OR LOWER(email) LIKE :query",
      query:
    )
  end
end

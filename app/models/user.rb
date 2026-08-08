class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :projects, through: :clients
  has_many :tasks, through: :projects
  has_many :invoices, through: :projects

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
end

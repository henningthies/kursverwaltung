class User < ApplicationRecord
  ROLES = %w[learner admin].freeze

  has_secure_password
  has_many :participants, dependent: :nullify

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def learner?
    role == "learner"
  end
end

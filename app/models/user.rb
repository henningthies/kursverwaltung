class User < ApplicationRecord
  ROLES = %w[learner admin].freeze

  has_secure_password
  has_many :participants, dependent: :nullify
  has_many :enrollments, through: :participants
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy

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

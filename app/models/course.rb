class Course < ApplicationRecord
  STATUSES = %w[draft active done].freeze

  has_many :sessions, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:title) }
end

class Course < ApplicationRecord
  STATUSES = %w[draft active done].freeze

  has_many :sessions, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :participants, through: :enrollments

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :capacity, numericality: { greater_than: 0, allow_nil: true }

  scope :ordered, -> { order(:title) }

  def confirmed_count
    enrollments.confirmed.count
  end

  def full?
    capacity.present? && confirmed_count >= capacity
  end

  def enroll(participant)
    status = full? ? "waitlisted" : "confirmed"
    enrollments.create!(participant: participant, status: status)
  end

  def promote_next_waitlisted
    next_one = enrollments.waitlisted.oldest_first.first
    next_one&.update!(status: "confirmed")
  end
end

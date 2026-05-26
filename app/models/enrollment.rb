class Enrollment < ApplicationRecord
  STATUSES = %w[confirmed waitlisted cancelled].freeze

  belongs_to :course
  belongs_to :participant

  validates :status, inclusion: { in: STATUSES }
  validates :participant_id, uniqueness: { scope: :course_id }

  scope :confirmed,    -> { where(status: "confirmed") }
  scope :waitlisted,   -> { where(status: "waitlisted") }
  scope :oldest_first, -> { order(:created_at) }

  def cancel
    update!(status: "cancelled")
    course.promote_next_waitlisted
  end
end

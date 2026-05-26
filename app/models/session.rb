class Session < ApplicationRecord
  belongs_to :course

  validates :title, presence: true

  scope :ordered, -> { order(:starts_at) }
end

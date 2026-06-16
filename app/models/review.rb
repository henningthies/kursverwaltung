class Review < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :course_id, message: "hat diesen Kurs bereits bewertet" }

  scope :visible, -> { where(visible: true) }

  def display_name
    anonymous? ? "Anonym" : user.name
  end
end

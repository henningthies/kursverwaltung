class Category < ApplicationRecord
  has_many :courses, dependent: :nullify

  before_validation :set_slug

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }

  def to_param
    slug
  end

  private
    def set_slug
      self.slug = name.to_s.parameterize if slug.blank? && name.present?
    end
end

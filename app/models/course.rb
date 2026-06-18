class Course < ApplicationRecord
  STATUSES = %w[draft active done].freeze

  belongs_to :category, optional: true
  has_many :sessions,     dependent: :destroy
  has_many :enrollments,  dependent: :destroy
  has_many :participants, through: :enrollments
  has_many :reviews,      dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :capacity, numericality: { greater_than: 0, allow_nil: true }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :ordered, -> { order(:title) }
  # Preis-Sortierung mit Titel als stabilem Zweit-Kriterium bei Preisgleichheit.
  scope :by_price_asc, -> { order(:price_cents, :title) }
  scope :by_price_desc, -> { order(price_cents: :desc).order(:title) }
  # Öffentlich sichtbar im Marketplace sind nur aktive Kurse.
  scope :published, -> { where(status: "active") }
  scope :in_category, ->(category) { category ? where(category: category) : all }

  def free?
    price_cents.zero?
  end

  # Restplätze, falls eine Kapazität gesetzt ist (für "Fast ausgebucht"-Badge).
  def remaining_seats
    return nil if capacity.nil?

    [ capacity - confirmed_count, 0 ].max
  end

  def almost_full?
    return false if capacity.nil? || full?

    remaining_seats <= [ (capacity * 0.2).ceil, 3 ].min
  end

  def confirmed_count
    enrollments.confirmed.count
  end

  def full?
    capacity.present? && confirmed_count >= capacity
  end

  def enroll(participant)
    new_status = full? ? "waitlisted" : "confirmed"
    existing = enrollments.find_by(participant: participant)

    # Eine früher stornierte Anmeldung wird reaktiviert statt doppelt angelegt.
    # Eine noch aktive Anmeldung läuft bewusst in den Uniqueness-Fehler (Doppel-Anmeldung).
    if existing&.status == "cancelled"
      existing.update!(status: new_status)
      existing
    else
      enrollments.create!(participant: participant, status: new_status)
    end
  end

  def promote_next_waitlisted
    next_one = enrollments.waitlisted.oldest_first.first
    next_one&.update!(status: "confirmed")
  end

  # Nur sichtbare (visible: true) Bewertungen zählen für den öffentlichen Durchschnitt.
  def average_rating
    reviews.visible.average(:rating)
  end

  def reviews_count
    reviews.visible.count
  end

  # Gibt true zurück, wenn der User diesen Kurs bereits bewertet hat.
  def reviewed_by?(user)
    user.present? && reviews.exists?(user_id: user.id)
  end
end

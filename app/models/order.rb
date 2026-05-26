class Order < ApplicationRecord
  STATUSES = %w[pending paid failed].freeze

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :courses, through: :order_items

  validates :status, inclusion: { in: STATUSES }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :stripe_session_id, uniqueness: true, allow_nil: true

  scope :paid, -> { where(status: "paid") }

  def paid?
    status == "paid"
  end

  # Legt OrderItems mit Preis-Snapshot an und setzt die Summe.
  def add_courses(courses)
    courses.each { |course| order_items.build(course: course, price_cents: course.price_cents) }
    self.total_cents = order_items.sum(&:price_cents)
  end

  # Idempotent: ein bereits bezahlter Order bleibt unverändert (doppelter Webhook).
  def mark_paid!
    return if paid?

    update!(status: "paid", paid_at: Time.current)
    book_enrollments!
  end

  private
    # Bucht den User nach bestätigter Zahlung über die VORHANDENE Course#enroll-Logik
    # (inkl. Kapazität/Warteliste). Bei vollem Kurs landet die Buchung auf der Warteliste
    # (kein Auto-Refund). Idempotent: bereits aktive Anmeldungen werden übersprungen.
    def book_enrollments!
      participant = Participant.find_or_create_by!(email: user.email) do |p|
        p.name = user.name
        p.user = user
      end
      participant.update!(user: user) if participant.user_id.nil?

      courses.each do |course|
        existing = course.enrollments.find_by(participant: participant)
        next if existing && existing.status != "cancelled"

        course.enroll(participant)
      end
    end
end

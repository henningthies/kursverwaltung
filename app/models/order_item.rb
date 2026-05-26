class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :course

  # price_cents ist ein Snapshot zum Kaufzeitpunkt (spätere Preisänderungen verfälschen
  # alte Bestellungen nicht).
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
end

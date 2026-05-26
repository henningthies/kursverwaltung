class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :total_cents, null: false, default: 0
      t.string :stripe_session_id
      t.datetime :paid_at

      t.timestamps
    end
    # Idempotenz: ein Stripe-Checkout entspricht genau einem Order.
    add_index :orders, :stripe_session_id, unique: true
  end
end

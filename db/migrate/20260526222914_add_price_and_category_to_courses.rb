class AddPriceAndCategoryToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :price_cents, :integer, null: false, default: 0
    add_reference :courses, :category, null: true, foreign_key: true
  end
end

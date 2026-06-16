class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment
      t.boolean :anonymous, null: false, default: false
      t.boolean :visible, null: false, default: true

      t.timestamps
    end

    # Unique index: one review per user per course
    add_index :reviews, [ :user_id, :course_id ], unique: true

    # Index for listing/aggregating visible reviews by course
    add_index :reviews, [ :course_id, :visible ]
  end
end

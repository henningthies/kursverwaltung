class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :rating,    null: false
      t.text    :comment
      t.boolean :anonymous, null: false, default: false
      t.boolean :visible,   null: false, default: true

      t.timestamps
    end

    # Eine Bewertung pro Person pro Kurs (unique constraint)
    add_index :reviews, %i[user_id course_id], unique: true
    # Für Listen-/Durchschnitts-Abfragen (course + visible)
    add_index :reviews, %i[course_id visible]
  end
end

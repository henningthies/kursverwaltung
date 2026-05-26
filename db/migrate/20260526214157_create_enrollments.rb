class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :course, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.string :status, null: false, default: "confirmed"

      t.timestamps
    end

    add_index :enrollments, %i[course_id participant_id], unique: true
  end
end

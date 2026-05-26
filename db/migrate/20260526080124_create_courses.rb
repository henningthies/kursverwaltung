class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.string :status, null: false, default: "draft"
      t.text :description
      t.string :instructor

      t.timestamps
    end
  end
end

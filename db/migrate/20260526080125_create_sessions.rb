class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :starts_at

      t.timestamps
    end
  end
end

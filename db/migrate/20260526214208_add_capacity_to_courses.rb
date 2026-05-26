class AddCapacityToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :capacity, :integer
  end
end

class CreateMeals < ActiveRecord::Migration[8.1]
  def change
    create_table :meals do |t|
      t.string :name
      t.integer :target_kcal
      t.string :strategy, default: "proportional", null: false

      t.timestamps
    end
  end
end

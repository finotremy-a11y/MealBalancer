class CreateMealIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_ingredients do |t|
      t.references :meal, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.integer :grams, default: 100, null: false
      t.boolean :locked, default: false, null: false

      t.timestamps
    end
  end
end

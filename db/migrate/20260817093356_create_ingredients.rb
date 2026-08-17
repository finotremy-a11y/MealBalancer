class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name
      t.integer :kcal_per_100g
      t.string :category

      t.timestamps
    end
  end
end

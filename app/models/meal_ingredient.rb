class MealIngredient < ApplicationRecord
  belongs_to :meal
  belongs_to :ingredient

  validates :grams, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def kcal
    return 0 unless grams && ingredient&.kcal_per_100g
    (grams.to_f * ingredient.kcal_per_100g / 100.0).round
  end
end

class Meal < ApplicationRecord
  has_many :meal_ingredients, dependent: :destroy
  has_many :ingredients, through: :meal_ingredients

  validates :name, presence: true
  validates :target_kcal, presence: true, numericality: { greater_than_or_equal_to: 50 }
  validates :strategy, inclusion: { in: %w[proportional balanced priority] }

  def total_kcal
    meal_ingredients.sum(&:kcal).round
  end

  def remaining_kcal
    target_kcal - total_kcal
  end

  def exceeded?
    total_kcal > target_kcal
  end

  def percentage_reached
    return 0 if target_kcal.to_f <= 0
    ((total_kcal.to_f / target_kcal) * 100).round(1)
  end
end

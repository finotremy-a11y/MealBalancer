module MealBalancer
  class BalancedStrategy
    def self.call(meal:, fixed_items: [])
      unlocked_items = meal.meal_ingredients.to_a - fixed_items
      return if unlocked_items.empty?

      fixed_kcal = fixed_items.sum(&:kcal)
      remaining_kcal = meal.target_kcal - fixed_kcal

      if remaining_kcal <= 0
        unlocked_items.each { |item| item.update!(grams: 0) }
        return
      end

      target_kcal_per_item = remaining_kcal.to_f / unlocked_items.size
      unlocked_items.each do |item|
        next if item.ingredient.kcal_per_100g.zero?
        new_grams = [ (target_kcal_per_item * 100.0 / item.ingredient.kcal_per_100g).round, 0 ].max
        item.update!(grams: new_grams)
      end
    end
  end
end

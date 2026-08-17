module MealBalancer
  class ProportionalStrategy
    def self.call(meal:, fixed_items: [])
      unlocked_items = meal.meal_ingredients.to_a - fixed_items
      return if unlocked_items.empty?

      fixed_kcal = fixed_items.sum(&:kcal)
      remaining_kcal = meal.target_kcal - fixed_kcal

      if remaining_kcal <= 0
        unlocked_items.each { |item| item.update!(grams: 0) }
        return
      end

      current_unlocked_kcal = unlocked_items.sum(&:kcal)

      if current_unlocked_kcal > 0
        ratio = remaining_kcal.to_f / current_unlocked_kcal.to_f
        unlocked_items.each do |item|
          new_grams = [ (item.grams * ratio).round, 0 ].max
          item.update!(grams: new_grams)
        end
      else
        # If all unlocked items are currently 0g, split target equally
        target_kcal_per_item = remaining_kcal.to_f / unlocked_items.size
        unlocked_items.each do |item|
          next if item.ingredient.kcal_per_100g.zero?
          new_grams = [ (target_kcal_per_item * 100.0 / item.ingredient.kcal_per_100g).round, 0 ].max
          item.update!(grams: new_grams)
        end
      end
    end
  end
end

module MealBalancer
  class PriorityStrategy
    def self.call(meal:, fixed_items: [])
      unlocked_items = meal.meal_ingredients.sort_by(&:id).to_a - fixed_items
      return if unlocked_items.empty?

      fixed_kcal = fixed_items.sum(&:kcal)
      remaining_kcal = [ meal.target_kcal - fixed_kcal, 0 ].max

      current_remaining = remaining_kcal.to_f

      unlocked_items.each_with_index do |item, index|
        if current_remaining <= 0
          item.update!(grams: 0)
          next
        end

        # If it's the last item, assign all remaining kcal, otherwise assign up to 70% or full portion
        allocated_kcal = (index == unlocked_items.size - 1) ? current_remaining : (current_remaining * 0.6)
        current_remaining -= allocated_kcal

        next if item.ingredient.kcal_per_100g.zero?
        new_grams = [ (allocated_kcal * 100.0 / item.ingredient.kcal_per_100g).round, 0 ].max
        item.update!(grams: new_grams)
      end
    end
  end
end

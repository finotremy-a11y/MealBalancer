module MealBalancer
  class Recalculate
    def self.call(meal:, changed_item: nil, strategy_name: nil)
      strategy_type = strategy_name || meal.strategy || "proportional"

      # Fixed items are those explicitly locked + the changed_item (the slider currently moved)
      locked_items = meal.meal_ingredients.where(locked: true).to_a
      fixed_items = (locked_items + [ changed_item ]).compact.uniq

      case strategy_type.to_s.downcase
      when "balanced"
        MealBalancer::BalancedStrategy.call(meal: meal, fixed_items: fixed_items)
      when "priority"
        MealBalancer::PriorityStrategy.call(meal: meal, fixed_items: fixed_items)
      else
        MealBalancer::ProportionalStrategy.call(meal: meal, fixed_items: fixed_items)
      end

      meal.reload
    end
  end
end

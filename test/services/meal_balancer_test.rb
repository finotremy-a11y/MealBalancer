require "test_helper"

class MealBalancerTest < ActiveSupport::TestCase
  setup do
    @meal = Meal.create!(name: "Test Meal", target_kcal: 600, strategy: "proportional")
    @rice = Ingredient.create!(name: "Test Rice", kcal_per_100g: 130)
    @chicken = Ingredient.create!(name: "Test Chicken", kcal_per_100g: 165)
    @oil = Ingredient.create!(name: "Test Oil", kcal_per_100g: 900)

    @item_rice = MealIngredient.create!(meal: @meal, ingredient: @rice, grams: 200) # 260 kcal
    @item_chicken = MealIngredient.create!(meal: @meal, ingredient: @chicken, grams: 150) # 247.5 -> 248 kcal
    @item_oil = MealIngredient.create!(meal: @meal, ingredient: @oil, grams: 10) # 90 kcal
  end

  test "proportional strategy balances meal calories near target" do
    # Total initially = 260 + 248 + 90 = 598 kcal
    MealBalancer::Recalculate.call(meal: @meal)
    assert_in_delta 600, @meal.total_kcal, 5
  end

  test "fixed/locked ingredient remains unchanged while unlocked adjust" do
    @item_oil.update!(locked: true, grams: 15) # 135 kcal fixed
    MealBalancer::Recalculate.call(meal: @meal)

    assert_equal 15, @item_oil.reload.grams
    assert_in_delta 600, @meal.total_kcal, 5
  end

  test "balanced strategy splits remaining calories equally" do
    @meal.update!(strategy: "balanced")
    MealBalancer::Recalculate.call(meal: @meal)
    assert_in_delta 600, @meal.total_kcal, 5
  end

  test "priority strategy allocates calories sequentially" do
    @meal.update!(strategy: "priority")
    MealBalancer::Recalculate.call(meal: @meal)
    assert_in_delta 600, @meal.total_kcal, 5
  end
end

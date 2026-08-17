require "test_helper"

class MealIngredientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meal = Meal.create!(name: "Repas Test MI", target_kcal: 600, strategy: "proportional")
    @ingredient = Ingredient.create!(name: "Tofu", kcal_per_100g: 76, category: "Protéines")
    @meal_ingredient = MealIngredient.create!(meal: @meal, ingredient: @ingredient, grams: 100, locked: false)
  end

  test "should update meal_ingredient grams" do
    patch meal_ingredient_url(@meal_ingredient), params: { meal_ingredient: { grams: 250 } }
    assert_redirected_to meal_url(@meal)
    assert_equal 250, @meal_ingredient.reload.grams
  end

  test "should toggle lock on meal_ingredient" do
    assert_equal false, @meal_ingredient.locked
    patch toggle_lock_meal_ingredient_url(@meal_ingredient)
    assert_redirected_to meal_url(@meal)
    assert_equal true, @meal_ingredient.reload.locked
  end

  test "should destroy meal_ingredient" do
    assert_difference("MealIngredient.count", -1) do
      delete meal_ingredient_url(@meal_ingredient)
    end
    assert_redirected_to meal_url(@meal)
  end
end

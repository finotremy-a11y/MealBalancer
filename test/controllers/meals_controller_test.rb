require "test_helper"

class MealsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meal = Meal.create!(name: "Repas Test", target_kcal: 700, strategy: "proportional")
    @ingredient = Ingredient.create!(name: "Quinoa", kcal_per_100g: 120, category: "Féculents")
  end

  test "should get index" do
    get meals_url
    assert_response :success
  end

  test "should get new" do
    get new_meal_url
    assert_response :success
  end

  test "should create meal" do
    assert_difference("Meal.count", 1) do
      post meals_url, params: { meal: { name: "Repas Dinatoire", target_kcal: 800, strategy: "balanced" } }
    end
    assert_redirected_to meal_url(Meal.last)
  end

  test "should show meal" do
    get meal_url(@meal)
    assert_response :success
  end

  test "should get edit" do
    get edit_meal_url(@meal)
    assert_response :success
  end

  test "should update meal" do
    patch meal_url(@meal), params: { meal: { name: "Repas Mis à Jour", target_kcal: 750, strategy: "proportional" } }
    assert_redirected_to meal_url(@meal)
    assert_equal "Repas Mis à Jour", @meal.reload.name
  end

  test "should destroy meal" do
    assert_difference("Meal.count", -1) do
      delete meal_url(@meal)
    end
    assert_redirected_to meals_url
  end

  test "should add ingredient to meal" do
    assert_difference("@meal.meal_ingredients.count", 1) do
      post add_ingredient_meal_url(@meal), params: { ingredient_id: @ingredient.id, grams: 150 }
    end
    assert_redirected_to meal_url(@meal)
  end

  test "should recalculate meal on slider adjustment" do
    meal_ingredient = MealIngredient.create!(meal: @meal, ingredient: @ingredient, grams: 100)
    post recalculate_meal_url(@meal), params: { meal_ingredient_id: meal_ingredient.id, grams: 200 }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_equal 200, meal_ingredient.reload.grams
  end
end

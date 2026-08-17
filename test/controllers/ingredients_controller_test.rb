require "test_helper"

class IngredientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ingredient = Ingredient.create!(name: "Lentilles Cuites", kcal_per_100g: 116, category: "Féculents")
  end

  test "should get index" do
    get ingredients_url
    assert_response :success
  end

  test "should create ingredient" do
    assert_difference("Ingredient.count", 1) do
      post ingredients_url, params: { ingredient: { name: "Pois Chiches", kcal_per_100g: 164, category: "Féculents" } }
    end
    assert_redirected_to ingredients_url
  end

  test "should destroy ingredient" do
    assert_difference("Ingredient.count", -1) do
      delete ingredient_url(@ingredient)
    end
    assert_redirected_to ingredients_url
  end
end

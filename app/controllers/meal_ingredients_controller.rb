class MealIngredientsController < ApplicationController
  before_action :set_meal_ingredient

  def update
    if @meal_ingredient.update(meal_ingredient_params)
      MealBalancer::Recalculate.call(meal: @meal_ingredient.meal, changed_item: @meal_ingredient)
      respond_to do |format|
        format.turbo_stream { render "meals/recalculate" }
        format.html { redirect_to @meal_ingredient.meal }
      end
    else
      redirect_to @meal_ingredient.meal, alert: "Erreur lors de la mise à jour des grammages."
    end
  end

  def toggle_lock
    @meal_ingredient.update(locked: !@meal_ingredient.locked)
    MealBalancer::Recalculate.call(meal: @meal_ingredient.meal)
    respond_to do |format|
      format.turbo_stream { render "meals/recalculate" }
      format.html { redirect_to @meal_ingredient.meal }
    end
  end

  def destroy
    meal = @meal_ingredient.meal
    @meal_ingredient.destroy
    MealBalancer::Recalculate.call(meal: meal)
    respond_to do |format|
      format.turbo_stream { render "meals/recalculate" }
      format.html { redirect_to meal, notice: "Ingrédient retiré du repas." }
    end
  end

  private

  def set_meal_ingredient
    @meal_ingredient = MealIngredient.find(params[:id])
    @meal = @meal_ingredient.meal
  end

  def meal_ingredient_params
    params.require(:meal_ingredient).permit(:grams, :locked)
  end
end

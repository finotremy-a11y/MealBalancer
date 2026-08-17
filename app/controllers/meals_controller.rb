class MealsController < ApplicationController
  before_action :set_meal, only: [ :show, :edit, :update, :destroy, :recalculate, :add_ingredient ]

  def index
    @meals = Meal.all.order(created_at: :desc)
  end

  def show
    @ingredients = Ingredient.all.order(:name)
  end

  def new
    @meal = Meal.new(target_kcal: 650, strategy: "proportional")
  end

  def create
    @meal = Meal.new(meal_params)
    if @meal.save
      redirect_to @meal, notice: "Repas créé avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @meal.update(meal_params)
      MealBalancer::Recalculate.call(meal: @meal)
      respond_to do |format|
        format.html { redirect_to @meal, notice: "Repas mis à jour !" }
        format.turbo_stream
        format.json { render json: meal_json_data }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meal.destroy
    redirect_to meals_path, notice: "Repas supprimé."
  end

  def recalculate
    if params[:meal_ingredient_id].present?
      @changed_item = @meal.meal_ingredients.find_by(id: params[:meal_ingredient_id])
      if @changed_item && params[:grams].present?
        @changed_item.update(grams: params[:grams].to_i)
      end
    end

    if params[:strategy].present? && %w[proportional balanced priority].include?(params[:strategy])
      @meal.update(strategy: params[:strategy])
    end

    MealBalancer::Recalculate.call(meal: @meal, changed_item: @changed_item)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @meal }
      format.json { render json: meal_json_data }
    end
  end

  def add_ingredient
    ingredient = Ingredient.find(params[:ingredient_id])
    grams = params[:grams].presence&.to_i || 100

    meal_ingredient = @meal.meal_ingredients.find_or_initialize_by(ingredient: ingredient)
    meal_ingredient.grams = grams
    meal_ingredient.save!

    MealBalancer::Recalculate.call(meal: @meal, changed_item: meal_ingredient)

    respond_to do |format|
      format.turbo_stream { render "recalculate" }
      format.html { redirect_to @meal, notice: "#{ingredient.name} ajouté au repas !" }
    end
  end

  private

  def set_meal
    @meal = Meal.includes(meal_ingredients: :ingredient).find(params[:id])
  end

  def meal_params
    params.require(:meal).permit(:name, :target_kcal, :strategy)
  end

  def meal_json_data
    {
      target_kcal: @meal.target_kcal,
      total_kcal: @meal.total_kcal,
      remaining_kcal: @meal.remaining_kcal,
      exceeded: @meal.exceeded?,
      ingredients: @meal.meal_ingredients.map do |mi|
        {
          id: mi.id,
          name: mi.ingredient.name,
          grams: mi.grams,
          kcal: mi.kcal,
          kcal_per_100g: mi.ingredient.kcal_per_100g,
          locked: mi.locked
        }
      end
    }
  end
end

class IngredientsController < ApplicationController
  def index
    @ingredients = Ingredient.all.order(:name)
    @ingredient = Ingredient.new
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)
    if @ingredient.save
      redirect_to ingredients_path, notice: "Ingrédient '#{@ingredient.name}' ajouté à la bibliothèque !"
    else
      @ingredients = Ingredient.all.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @ingredient = Ingredient.find(params[:id])
    @ingredient.destroy
    redirect_to ingredients_path, notice: "Ingrédient supprimé."
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:name, :kcal_per_100g, :category)
  end
end

# db/seeds.rb

puts "Clearing old data..."
MealIngredient.destroy_all
Meal.destroy_all
Ingredient.destroy_all

puts "Creating Ingredients Library..."
ingredients_data = [
  { name: "Riz Basmati Cuit", kcal_per_100g: 130, category: "Féculents" },
  { name: "Pâtes Complètes Cuites", kcal_per_100g: 140, category: "Féculents" },
  { name: "Patate Douce Cuite", kcal_per_100g: 86, category: "Féculents" },
  { name: "Flocons d'Avoine", kcal_per_100g: 368, category: "Féculents" },
  { name: "Blanc de Poulet", kcal_per_100g: 165, category: "Protéines" },
  { name: "Pavé de Saumon", kcal_per_100g: 208, category: "Protéines" },
  { name: "Steak Haché 5% MG", kcal_per_100g: 125, category: "Protéines" },
  { name: "Œuf Entier", kcal_per_100g: 155, category: "Protéines" },
  { name: "Skyr / Yaourt Grec 0%", kcal_per_100g: 57, category: "Protéines" },
  { name: "Brocoli Cuit", kcal_per_100g: 34, category: "Légumes" },
  { name: "Haricots Verts", kcal_per_100g: 31, category: "Légumes" },
  { name: "Courgettes", kcal_per_100g: 17, category: "Légumes" },
  { name: "Huile d'Olive Extra Vierge", kcal_per_100g: 884, category: "Lipides" },
  { name: "Avocat", kcal_per_100g: 160, category: "Lipides" },
  { name: "Beurre de Cacahuète", kcal_per_100g: 588, category: "Lipides" },
  { name: "Amandes", kcal_per_100g: 579, category: "Lipides" }
]

ingredients = {}
ingredients_data.each do |data|
  ingredients[data[:name]] = Ingredient.create!(data)
end

puts "Creating Sample Meals..."

# Meal 1: Repas Fitness Poulet & Riz (Target 650 kcal)
meal1 = Meal.create!(name: "Repas Fitness Poulet-Riz", target_kcal: 650, strategy: "proportional")

# Initial ingredients
MealIngredient.create!(meal: meal1, ingredient: ingredients["Riz Basmati Cuit"], grams: 180)
MealIngredient.create!(meal: meal1, ingredient: ingredients["Blanc de Poulet"], grams: 150)
MealIngredient.create!(meal: meal1, ingredient: ingredients["Brocoli Cuit"], grams: 150)
MealIngredient.create!(meal: meal1, ingredient: ingredients["Huile d'Olive Extra Vierge"], grams: 10)

MealBalancer::Recalculate.call(meal: meal1)

# Meal 2: Petit Déjeuner Protéiné (Target 550 kcal)
meal2 = Meal.create!(name: "Petit Déjeuner Protéiné", target_kcal: 550, strategy: "proportional")

MealIngredient.create!(meal: meal2, ingredient: ingredients["Flocons d'Avoine"], grams: 70)
MealIngredient.create!(meal: meal2, ingredient: ingredients["Skyr / Yaourt Grec 0%"], grams: 150)
MealIngredient.create!(meal: meal2, ingredient: ingredients["Beurre de Cacahuète"], grams: 15)

MealBalancer::Recalculate.call(meal: meal2)

puts "Done! Created #{Ingredient.count} ingredients and #{Meal.count} sample meals."

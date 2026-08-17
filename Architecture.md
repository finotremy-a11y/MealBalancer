ARCHITECTURE DU PROJET — MealBalancer (Rails 8)
Application permettant de composer un repas en définissant un objectif calorique, d’ajuster les grammages des ingrédients via des curseurs, et de recalculer automatiquement les autres ingrédients pour rester dans le quota.

1. Vision du projet
   MealBalancer est une application web permettant :
   - de créer un repas avec un objectif calorique (ex : 650 kcal)
   - d’ajouter des ingrédients avec leurs kcal pour 100 g
   - d’ajuster les grammages via des curseurs
   - de recalculer automatiquement les autres ingrédients pour respecter le quota
   - d’afficher en temps réel la répartition calorique
   - d’offrir une interface premium, fluide, moderne

   Aucune IA n’est utilisée dans la première version.
   Tout repose sur Rails 8, Hotwire, Stimulus, TailwindCSS.

2. Architecture générale
   2.1 Stack technique
   - Backend : Ruby on Rails 8
   - Frontend : Hotwire (Turbo + Stimulus)
   - Design : TailwindCSS + Heroicons / Lucide Icons
   - Base de données : SQLite3 / PostgreSQL
   - Graphiques : Chart.js / SVG dynamique
   - Déploiement : Docker / Kamal / Render / Fly.io

3. Modèle de données
   3.1 Schéma global

   Meal
   - name: string
   - target_kcal: integer

   Ingredient
   - name: string
   - kcal_per_100g: integer

   MealIngredient
   - meal: references
   - ingredient: references
   - grams: integer
   - locked: boolean (par défaut false)

4. Logique métier
   4.1 Calcul des calories
   kcal_totales = sum(grams_i * kcal_per_100g_i / 100)

   4.2 Mise à jour dynamique
   Quand l’utilisateur modifie un ingrédient via un curseur :
   - L’ingrédient modifié devient fixe (ou est le pivot du recalcul).
   - On calcule les kcal restantes : K_restant = K_objectif - K_fixe
   - Les autres ingrédients sont recalculés selon le mode choisi.

   4.3 Modes de répartition
   - Proportionnel (par défaut)
   - Équilibré
   - Priorité

5. Architecture Rails
   5.1 Controllers
   - MealsController (index, show, create, update, destroy, recalculate)
   - MealIngredientsController (create, update, destroy, toggle_lock)
   - IngredientsController (index, create, destroy)

   5.2 Services (/app/services/meal_balancer/)
   - MealBalancer::Recalculate
   - MealBalancer::ProportionalStrategy
   - MealBalancer::BalancedStrategy
   - MealBalancer::PriorityStrategy

   5.3 Helpers
   - MealsHelper

6. Interface utilisateur (UI/UX premium)
   - Visualisation interactive modernisée avec Tailwind CSS, glassmorphism, animations et sliders réactifs.
   - Graphique circulaire/anneau interactif (Chart.js / SVG inline pour réactivité maximale).
Rails.application.routes.draw do
  root "meals#index"

  resources :meals do
    member do
      post :recalculate
      post :add_ingredient
    end
  end

  resources :meal_ingredients, only: [ :update, :destroy ] do
    member do
      patch :toggle_lock
    end
  end

  resources :ingredients, only: [ :index, :create, :destroy ]

  get "up" => "rails/health#show", as: :rails_health_check
end

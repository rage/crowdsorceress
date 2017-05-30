Rails.application.routes.draw do
  resources :users
  resources :exercise_types
  resources :exercises
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'exercises', to: 'exercise#create'
end

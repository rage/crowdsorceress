# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'assignments#index'
  resources :sessions, only: %i[create index]
  delete '/sessions', to: 'sessions#destroy'
  resources :tags
  resources :peer_review_question_answers
  resources :peer_review_questions
  resources :peer_reviews
  resources :assignments
  resources :users
  resources :exercise_types
  resources :exercises
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v0, defaults: { format: :json } do
      resources :assignments, module: :assignments, only: :show do
        resources :peer_review_exercise, only: :index
      end
      resources :exercises, module: :exercises, only: :create do
        get 'template.zip', to: 'zips#template'
        get 'model_solution.zip', to: 'zips#model_solution'
        resources :results, only: :create
      end
      resources :peer_reviews, only: :create
    end
  end
end

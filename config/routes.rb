# frozen_string_literal: true

Rails.application.routes.draw do
  resources :peer_review_question_answers
  resources :peer_review_questions
  resources :peer_reviews
  resources :assignments
  resources :users
  resources :exercise_types
  resources :exercises
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'exercises/:id/results', to: 'exercises#sandbox_results'

  get 'peer_reviews/assignments/:id/request_exercise', to: 'peer_reviews#draw_exercise'

  get 'peer_reviews/exercises/:id/stub_zip', to: 'peer_reviews#send_stub_zip'
  get 'peer_reviews/exercises/:id/model_zip', to: 'peer_reviews#send_model_zip'
end

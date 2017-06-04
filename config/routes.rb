# frozen_string_literal: true

Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
  resources :users, only: [:show, :edit, :update]
  resources :leaves, except: [:show]
  resources :holidays
  resource :oooconfigs, only: [:edit, :update]
  post '/number_of_days' => 'leaves#number_of_days', as: 'number_of_days'

  root to: 'home#show'
end

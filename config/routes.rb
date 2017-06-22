# frozen_string_literal: true

Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
  resources :users, only: [:show, :edit, :update, :index]
  resources :oooperiods, except: [:show]
  resources :holidays
  post '/number_of_days' => 'oooperiods#number_of_days', as: 'number_of_days'

  root to: 'home#show'

  namespace :admin do
    resources :users, only: [:show, :edit, :update, :index] do
      resources :oooperiods
    end

    resource :oooconfigs
  end

  get '/refreshconfigs' => 'admin/oooconfigs#refreshconfigs', as: 'refreshconfigs'
end

# frozen_string_literal: true

Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
  resources :users, only: [:show, :edit, :update, :index]
  resources :oooperiods, except: [:show] do
    get 'bydate', on: :collection
  end

  post 'users/download_users_details', to: 'users#download_users_details',
                                       as: 'download_users_details'

  root to: 'home#show'

  namespace :admin do
    resources :users, only: [:show, :edit, :update, :index] do
      resources :oooperiods
    end
    resources :oooconfigs do
      resources :holidays
    end
  end
end

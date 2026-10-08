Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show, :edit, :update]
  get "home/index"
  get "home/search", to: "home#search"
  resources :rooms do
    resources :reservations, only: [:create] do
      post :confirm, on: :collection
    end
  end
  resources :reservations, only: [:index, :destroy]
  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end

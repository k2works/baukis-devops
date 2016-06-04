Rails.application.routes.draw do
  config = Rails.application.config.baukis

  constraints host: config[:staff][:host] do
    namespace :staff, path: config[:staff][:path] do
      root 'top#index'
      get 'login' => 'sessions#new', asr: :login
      resource :session, only: [:create, :destroy ]
      resource :account, except: [ :new, :create, :destroy ] do
        patch :confirm
      end
      resource :password, only: [ :show, :edit, :update ]
      resources :customers
      resources :programs do
        patch :entries, on: :member
      end
    end
  end

  constraints host: config[:admin][:host] do
    namespace :admin, path: config[:admin][:path] do
      root 'top#index'
      get 'login' => 'sessions#new', as: :login
      resource :session, only: [ :create, :destroy ]
      resources :staff_members do
        resources :staff_events, only: [ :index]
      end
      resources :staff_events, only: [ :index ]
      resources :allowed_sources, only: [ :index, :create ] do
        delete :delete, on: :collection
      end
    end
  end

  constraints host: config[:customer][:host] do
    namespace :customer, path: config[:customer][:path] do
      root 'top#index'
      get 'login' => 'sessions#new', as: :login
      resource :session, only: [ :create, :destroy ]
      resource :account, except: [ :new, :create, :destroy ] do
        patch :confirm
      end
      resources :programs, only: [ :index, :show ] do
        resources :entries, only: [ :create ] do
          patch :cancel, on: :member
        end
      end
    end
  end

  root 'errors#routing_error'
  get '*anything' => 'errors#routing_error'
end

# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.roles.pluck(:name).include?('janitor') } do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Apidoco::Engine, at: "/api_docs"

  devise_for :users

  use_doorkeeper do
    # OAuth applications must be created using rake tasks `rake oauth:application`
    skip_controllers :applications, :authorized_applications
  end

  root 'homes#index'

  resources :homes do
    resources :rooms
    resources :home_viewers
    resources :sensors
    resources :readings
    resources :mqtt_user
  end

  resources :rooms
  resources :sensors do
    delete :unassign, to: 'sensors#unassign'
  end
  resources :messages
  resources :readings
  resources :home_viewers

  namespace :opendata do
    resources :readings, only: [:index]
  end

  namespace :api do
    scope module: :users do
      post 'sign_up', to: 'registrations#create', as: :sign_up
      put 'change_password', to: 'registrations#update', as: :change_password
      post 'reset_password', to: 'passwords#create', as: :reset_password
    end

    scope module: :v1, constraints: ApiConstraint.new(version: 1, default: :json) do
      resources :homes, except: [:new, :edit] do
        collection do
          get :form_options
        end

        resources :rooms, except: [:new, :edit] do
          get '/key/:key/readings', to: 'readings#index'
        end
        
        resources :sensors, except: [:new, :create, :edit, :destroy] do
          member do
            delete 'unassign'
          end
        end
        resources :home_viewers, except: [:new, :edit, :update]
      end

      get 'rooms/form_options', to: 'rooms#form_options'
    end
    
  end

  namespace :admin do
    resources :users
    resources :home_types
    resources :room_types
    resources :mqtt_users
  end

  namespace :gateway do
    resources :config
  end

  authenticate :user, ->(user) { user.janitor? } do
    mount PgHero::Engine, at: 'pghero'
  end
end

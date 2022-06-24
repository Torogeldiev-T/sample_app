Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get  '/about', to: 'static_pages#about'
  get  '/help', to: 'static_pages#help'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  resources :users do
    member do
      get :following, :followers
    end
  end
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :account_activations, only: [:edit]
  resources :password_resets, only: %i[new edit create update]
  resources :microposts, only: %i[create destroy]
  resources :relationships, only: %i[create destroy]
  get '/microposts', to: 'static_pages#home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end

Rails.application.routes.draw do
  get 'sessions/new'
  root 'static_pages#home'
  get  '/about', to: 'static_pages#about'
  get  '/help', to: 'static_pages#help'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  resources :users
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end

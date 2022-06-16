Rails.application.routes.draw do
  get 'users/new', as: 'signup'
  root "static_pages#home"
  get  "/about", to: "static_pages#about"
  get  "/help", to: "static_pages#help"
  get  "/contact", to: "static_pages#contact"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  
end

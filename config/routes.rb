Rails.application.routes.draw do
  resources :sessions
  get '/reservar' => 'reserves#new', as: :new_reserve
  root to: 'sessions#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

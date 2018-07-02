Rails.application.routes.draw do
  resources :sessions
  get '/reservations/choose', to: 'reservations#choose'
  get '/reservations/results', to: 'reservations#results', as: :results
  resources :reservations, except: [:edit, :update, :destroy]
  root to: 'sessions#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

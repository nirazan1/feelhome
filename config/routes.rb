Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => { registrations: 'registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, :only => [:show]
  root 'bookings#index'
  get 'booking/search' => 'bookings#search'
  post 'booking/set_flight' => 'bookings#set_flight'
  get 'quote_request' => 'bookings#quote_request'
  get 'user_lists' => 'users#list'

  resources :bookings
end

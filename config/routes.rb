Rails.application.routes.draw do
  devise_for :admins
  resources :merchants
  root to: 'merchants#index'
end

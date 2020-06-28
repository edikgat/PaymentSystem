Rails.application.routes.draw do
  resources :payment_transactions, only: [:index, :show]
  devise_for :admins
  resources :merchants
  root to: 'merchants#index'
end

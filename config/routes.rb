Rails.application.routes.draw do
  resources :payment_transactions, only: [:index, :show]
  devise_for :admins
  resources :merchants
  root to: 'merchants#index'
  mount GrapeSwaggerRails::Engine, at: '/documentation'
  mount Api::V1 => '/'
  root to: redirect('/documentation')
end

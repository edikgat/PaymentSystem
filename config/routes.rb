Rails.application.routes.draw do
  resources :merchants
  root to: 'merchants#index'
end

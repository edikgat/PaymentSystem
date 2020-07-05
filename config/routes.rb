# frozen_string_literal: true

require('sidekiq/web')
require('sidekiq-scheduler/web')

Rails.application.routes.draw do
  devise_for :admins
  devise_for :merchants
  namespace :admin do
    resources :payment_transactions, only: %i[index show]
    resources :merchants
  end
  namespace :merchant do
    resources :payment_transactions, only: %i[index show]
  end
  root to: 'admin/merchants#index'
  mount GrapeSwaggerRails::Engine, at: '/documentation'
  mount Api::V1 => '/'
  mount Sidekiq::Web => '/sidekiq'
end

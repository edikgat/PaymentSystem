# frozen_string_literal: true

module Api
  class Auth < Grape::API
    version 'v1', using: :path
    prefix 'api'

    resource :token do
      desc 'LogIn'
      params do
        requires :merchant, type: Hash do
          optional :email, type: String
          optional :password, type: String
        end
      end
      post do
        merchant = Merchant.find_by(email: permitted_params[:merchant][:email])
        if merchant&.valid_password?(permitted_params[:merchant][:password])
          status(201)
          {
            jwt: MerchantApiAuth::TokenCreator.token(merchant.id)
          }
        else
          status(422)
          { "error": 'invalid password or email' }
        end
      end
    end
  end
end

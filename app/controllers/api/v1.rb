# frozen_string_literal: true

require 'grape-swagger'

class Api::V1 < Grape::API
  prefix :api

  default_format :json
  content_type :xml, 'application/xml; charset=UTF-8'
  content_type :json, 'application/json; charset=UTF-8'

  rescue_from ActiveRecord::RecordNotFound do |e|
    error_response(message: e.message, status: 404)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    error_response(message: e.message, status: 422)
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error_response(message: e.message, status: 422)
  end

  rescue_from StandardError do |e|
    error_response(message: e.message, status: 500)
  end

  helpers do
    def permitted_params
      @permitted_params ||= declared(params, include_missing: false)
    end

    def logger
      Rails.logger
    end
  end

  mount Api::TransactionsApi

  add_swagger_documentation(
    api_version: 'v1',
    hide_documentation_path: true,
    mount_path: 'v1/swagger_doc',
    hide_format: true
  )
end

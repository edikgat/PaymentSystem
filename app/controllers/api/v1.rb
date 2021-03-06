# frozen_string_literal: true

require('grape-swagger')

module Api
  class V1 < Grape::API
    prefix :api

    format :json
    content_type :json, 'application/json'
    content_type :xml, 'application/xml'

    rescue_from ActiveRecord::RecordNotFound do |_e|
      error_response(message: 'record not present', status: 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      error_response(message: e.message, status: 422)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error_response(message: e.message, status: 422)
    end

    rescue_from ActiveRecord::StaleObjectError do |_e|
      error_response(message: 'Conflict with other change, please try it one more time', status: 412)
    end

    rescue_from StandardError do |_e|
      error_response(message: 'problem at server side, please try it one more time', status: 500)
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
    mount Api::Auth

    add_swagger_documentation(
      api_version: 'v1',
      hide_documentation_path: true,
      mount_path: 'v1/swagger_doc',
      hide_format: true
    )
  end
end

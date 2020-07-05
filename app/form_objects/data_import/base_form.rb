# frozen_string_literal: true

module DataImport
  class BaseForm
    attr_reader :params

    def self.process(params)
      new(params).process
    end

    def initialize(params)
      @params = params
    end

    def process
      build_resource
      resource.save!
    end

    private

    def build_resource
      raise(NotImplementedError, 'not implemented')
    end

    def resource_class
      raise(NotImplementedError, 'not implemented')
    end

    def supported_params
      raise(NotImplementedError, 'not implemented')
    end

    def resource
      @resource ||= resource_class.new
    end

    def sanitized_params
      params.slice(*supported_params)
    end

    def generated_password
      @generated_password ||= Devise.friendly_token.first(8)
    end
  end
end

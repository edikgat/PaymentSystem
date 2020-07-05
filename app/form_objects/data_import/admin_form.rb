# frozen_string_literal: true

module DataImport
  class AdminForm < BaseForm
    private

    def build_resource
      resource.assign_attributes(sanitized_params)
      resource.password = generated_password
      resource.password_confirmation = generated_password
    end

    def resource_class
      Admin
    end

    def supported_params
      [:email]
    end
  end
end

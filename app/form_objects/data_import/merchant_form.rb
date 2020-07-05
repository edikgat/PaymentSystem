# frozen_string_literal: true

module DataImport
  class MerchantForm < BaseForm
    private

    def build_resource
      resource.assign_attributes(sanitized_params)
      resource.password = generated_password
      resource.password_confirmation = generated_password
    end

    def resource_class
      Merchant
    end

    def supported_params
      %i[email name description status]
    end
  end
end

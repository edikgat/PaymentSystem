class PaymentTransaction < ApplicationRecord
  belongs_to :merchant

  def self.find_sti_class(type_name)
    ActiveSupport::Dependencies.constantize(type_name)
  end
end

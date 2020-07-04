# frozen_string_literal: true

class AuthorizeTransaction < PaymentTransaction
  state_machine :status, initial: :approved do
    event :error do
      transition(approved: :error)
    end

    event :reverse do
      transition(approved: :reversed)
    end
  end
end

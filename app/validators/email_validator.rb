# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  EMAIL_PATTERN = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  def validate_each(record, attribute, value)
    return if value =~ EMAIL_PATTERN

    record.errors.add(
      attribute,
      (options[:message] || :invalid_email)
    )
  end
end

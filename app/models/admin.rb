# frozen_string_literal: true

class Admin < ApplicationRecord
  validates :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true
  validates :email, uniqueness: { case_sensitive: false }, email: true, allow_blank: true

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable
end

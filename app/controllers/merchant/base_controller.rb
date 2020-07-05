# frozen_string_literal: true

class Merchant
  class BaseController < ApplicationController
    before_action :authenticate_merchant!
  end
end

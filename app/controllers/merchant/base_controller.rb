# frozen_string_literal: true

class Merchant
  class BaseController < ApplicationController
    before_action :authenticate_merchant!

    def current_merchant
      @current_merchant ||= super.decorate
    end
  end
end

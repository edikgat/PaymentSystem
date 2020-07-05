# frozen_string_literal: true

class Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!
  end
end

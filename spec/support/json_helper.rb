# frozen_string_literal: true

module JsonHelper
  def json
    @json ||= JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include(JsonHelper, type: :request)
end

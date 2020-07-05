# frozen_string_literal: true

require('webdrivers/chromedriver')

Capybara.register_driver(:chrome) do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new
  chrome_options.add_preference(
    :download,
    prompt_for_download: false
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    clear_local_storage: true,
    clear_session_storage: true,
    options: chrome_options
  )
end

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.default_driver = :chrome
Capybara.javascript_driver = :chrome

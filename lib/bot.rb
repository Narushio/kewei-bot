require_relative "utils"

class Bot
  attr_accessor :ws, :session, :adapter

  def initialize
    build_browser_driver
    @adapter = Mah::Adapter::Message.new
    @web_socket_client = Mah::Adapter::WebSocket.new(self).create_conn
  end

  private

  def build_browser_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.headless!
    headless_driver = Selenium::WebDriver.for :chrome, options: options
    # driver ||= Selenium::WebDriver.for :chrome
    Logger.new($stdout).info("Browser device loaded successfully :).")
    # self.class.define_singleton_method(:driver) { driver }
    self.class.define_singleton_method(:headless_driver) { headless_driver }
  end
end

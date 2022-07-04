module Features
  class Azurlane < Base
    include ShipData

    attr_reader :functions

    def initialize
      super
      @functions = []
    end

    def build
      query_ship_girl
    end

    private

    def query_ship_girl
      functions << {
        level: 2,
        function_name: "查询舰娘",
        lambda: lambda do |message, text|
          @message = message
          return unless text.match?(/\A查询舰娘 (.*)/)

          data = ship_info(text.split(" ")[1])
          return if data.nil?

          Bot.driver.get("file://#{Rails.root.join("templates", "azurlane", "shipInfo.html")}")
          Bot.driver.manage.window.resize_to(1400, 1400)
          Bot.driver.execute_script("initDom(#{data.to_json})")

          send_group_message(@message, [image(base64: "")], :at)
        end
      }

      functions
    end

    def query_weapon
      functions = []
      functions << {
        regex: /\A查询武器 (.+)/,
        function_name: "query_weapon",
        level: "2",
        proc: proc do |message, name|
          driver = Bot.headless_driver
          driver.get("https://wiki.biligame.com/blhx/" + CGI.escape(name))
          equip = driver.find_element(class: "equip")
          width = driver.execute_script("return Math.max(document.body.scrollWidth,document.body.offsetWidth,document.documentElement.clientWidth,document.documentElement.scrollWidth,document.documentElement.offsetWidth);")
          height = driver.execute_script("return Math.max(document.body.scrollHeight,document.body.offsetHeight,document.documentElement.clientHeight,document.documentElement.scrollHeight,document.documentElement.offsetHeight);")
          driver.manage.window.resize_to(width, height)
          driver.manage.window.maximize
          message_chain = {type: "image", base64: equip.screenshot_as(:base64)}
          BotEvent.new(message).send_group_message(message_chain, {at: true})
        end
      }

      functions
    end
  end
end

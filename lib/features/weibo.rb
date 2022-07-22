module Features
  class Weibo < Base
    include Sidekiq::Worker do
      initialize
    end

    def perform
      cards = get_cards
      unless cards.empty?
        updated_at_min = Admin.first.updated_at_min
        card = cards.find { |card| (card.dig("mblog", "edit_at") || card.dig("mblog", "created_at")) >= updated_at_min }
        unless card.nil?
          blog = card["mblog"]
          full_html_text = get_full_html_text(blog["id"])
          blog_card = get_blog_card(full_html_text, blog["edit_at"] || blog["created_at"])

          data = {
            syncId: 1,
            command: "sendGroupMessage",
            subCommand: nil,
            content: {
              sessionKey: Bot.current_session,
              target: 626229186,
              messageChain: [
                {type: "Plain", text: "来自【碧蓝航线】最新微博#{I18n.t "azurlane.emoji.be_cute"}\n#{card["scheme"]}\n"},
                {type: "Image", base64: blog_card}
              ]
            }
          }
          Admin.first.update_attribute("updated_at_min", Time.zone.now)
          return Bot.current_ws.send(data.to_json)
        end
      end
      Admin.first.update_attribute("updated_at_min", Time.zone.now)
    end

    private

    def initialize
      @conn = Faraday.new(
        headers: {
          "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) " \
                        "AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1",
          "Content-Type": "application/json; charset=utf-8",
          Referer: "https://m.weibo.cn/u/5770760941",
          "Accept-Language": "zh-CN,zh;q=0.9"
        }
      )
    end

    def get_cards
      params = {
        type: "uid",
        uid: "5770760941",
        value: "5770760941",
        containerid: "1076035770760941"
      }
      url = "https://m.weibo.cn/api/container/getIndex?#{params.to_query}"
      response = @conn.get(url)
      JSON.parse(response.body).dig("data", "cards") if response.status == 200
    end

    def get_full_html_text(blog_id)
      url = "https://m.weibo.cn/statuses/extend?#{{id: blog_id}.to_query}"
      response = @conn.get(url)
      JSON.parse(response.body).dig("data", "longTextContent") if response.status == 200
    end

    def get_blog_card(full_html_text, edit_at)
      data = {text: full_html_text, editAt: edit_at.to_time.strftime("%Y-%m-%d %H:%M:%S")}
      Bot.headless_driver.get("file://#{Rails.root.join("templates", "weibo", "blog.html")}")
      Bot.headless_driver.execute_script("initDom(#{data.to_json})")
      width = Bot.headless_driver.execute_script("return Math.max(document.body.scrollWidth,document.body.offsetWidth,document.documentElement.clientWidth,document.documentElement.scrollWidth,document.documentElement.offsetWidth);")
      height = Bot.headless_driver.execute_script("return Math.max(document.body.scrollHeight,document.body.offsetHeight,document.documentElement.clientHeight,document.documentElement.scrollHeight,document.documentElement.offsetHeight);")
      Bot.headless_driver.manage.window.resize_to(width, height)
      Bot.headless_driver.manage.window.maximize
      element = Bot.headless_driver.find_element(id: "template")
      element.screenshot_as(:base64)
    end
  end
end

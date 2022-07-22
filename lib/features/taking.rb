module Features
  class Taking < Base
    attr_reader :functions

    def initialize
      super
      @functions = []
    end

    def build
      send_emoji
      send_bully
    end

    private

    def send_bully
      functions << {
        level: 2,
        function_type: "暴打憨批",
        lambda: lambda do |message, text|
          return unless text.match?(/\A给你嘛来一拳/)


          url = "https://q1.qlogo.cn/g?"
          params = {
            b: "qq",
            nk: message.at_qq,
            s: 640
          }
          avatar = Faraday.get(url + params.to_query)
          byebug
        end
      }
    end

    def send_emoji
      functions << {
        level: 2,
        function_type: "梗图",
        lambda: lambda do |message, text|
          return unless text.match?(/\A梗图/)

          emojis = Dir[Rails.root.join("resource/images/emoji/*").to_s]
          chain = [image(path: emojis.sample)]
          send_group_message(message, chain)
        end
      }
    end
  end
end

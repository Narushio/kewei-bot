module Features
  class Taking < Base
    attr_reader :functions

    def initialize
      super
      @functions = []
    end

    def build
      send_emoji
    end

    private

    def send_emoji
      functions << {
        level: 2,
        function_name: "表情包",
        lambda: lambda do |message, text|
          @message = message
          return unless text == ""

          emojis = Dir[Rails.root.join("resource/images/emoji/*").to_s]
          send_group_message(@message, [image(path: emojis.sample)])
        end
      }
    end
  end
end
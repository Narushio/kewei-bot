module Mah
  class MessageAdapter
    def initialize
      @group_features = []
      @group_features << Features::Taking.new.build
      @group_features << Features::Setu.new.build
      @group_features << Features::Pixiv.new.build
      @group_features << Features::Azurlane.new.build
    end

    def handle(message)
      handle_message(message) if Message::MESSAGE_TYPE.include?(message.type)
      handle_event(message)
    end

    private

    def handle_message(message)
      return nil unless check_prefix_command(message)

      case message.type
      when "GroupMessage"
        functions = @group_features.flatten.sort {_1[:level]}
        functions.each do |function|
          function[:lambda].call(message, message.text[2..])
        end
      end
    end

    def handle_event(message)
      nil
    end

    def check_prefix_command(message)
      message.text.match?(/\A可畏/)
    end
  end
end

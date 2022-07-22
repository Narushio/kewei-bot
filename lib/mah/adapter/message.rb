module Mah
  module Adapter
    class Message
      include Sidekiq::Worker

      def initialize
        build_group_features
      end

      def perform(data)
        @message = Mah::Message.new(JSON.parse(data.to_json, object_class: OpenStruct))
        handle_message if Mah::Message::MESSAGE_TYPE.include?(@message.type)
        handle_event
      end

      private

      def handle_message
        case @message.type
        when "GroupMessage"
          functions = @group_features.flatten.sort {_1[:level]}
          functions.each do |function|
            function[:lambda].call(@message, @message.text.strip) unless @message.text.nil?
          end
        end
      end

      def handle_event
        nil
      end

      def build_group_features
        @group_features = []
        @group_features << Features::Taking.new.build
        @group_features << Features::Setu.new.build
        @group_features << Features::Pixiv.new.build
        @group_features << Features::Azurlane.new.build
      end
    end
  end
end

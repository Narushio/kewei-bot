module Mah
  module Connect
    class WebSocketClient
      def initialize(bot)
        @bot = bot
        @logger = Logger.new($stdout)
        @url = "ws://#{Settings.mah.host}:#{Settings.mah.port.ws || "80"}" \
          "/all?verifyKey=#{Settings.mah.verifyKey}&qq=#{Settings.mah.account}"
      end

      def create_conn
        EM.run do
          ws = Faye::WebSocket::Client.new(@url)
          Bot.define_singleton_method(:current_ws) { ws }

          ws.on :open do
            @logger.info("WebSocket connection is open :).")
          end

          ws.on :message do |event|
            os = JSON.parse(event.data, object_class: OpenStruct)
            data = os.data
            session = data.session
            puts data
            if session
              Bot.define_singleton_method(:current_session) { session }
              BotEvent.send_to_super_admins([Chain.plain("启动完毕...")])
            elsif os.syncId != "1"
              raise(data.msg) if data.code == 2
              return nil unless data.type.present?

              @logger.message(data)
              thread { @bot.adapter.handle(Message.new(data)) }
            end
          end

          ws.on :close do
            raise("WebSocket connection is failed :(.")
          end
        end
      end
    end
  end
end

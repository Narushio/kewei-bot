module Mah
  module Adapter
    class WebSocket
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
            os = JSON.parse(event.data)
            data = os["data"]
            if data["session"]
              Bot.define_singleton_method(:current_session) { data["session"] }

              chain = [Chain.plain("启动完毕#{I18n.t "azurlane.emoji.happy"}")]
              BuiltIn.send_to_super_admins(chain)
            elsif os["syncId"] != "1"
              raise(data["msg"]) if data["code"] == 2
              next unless data["type"].present?

              @logger.message(data)
              Mah::Adapter::Message.perform_async(data)
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

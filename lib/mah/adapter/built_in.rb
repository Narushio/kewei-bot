module Mah
  module Adapter
    module BuiltIn
      module_function

      def send_group_message(message, chain, **options)
        chain.unshift(at(message.qq), plain(" ")) if options[:at]
        data = {
          syncId: 1,
          command: "sendGroupMessage",
          subCommand: nil,
          content: {
            sessionKey: Bot.current_session,
            target: message.group_id,
            messageChain: chain
          }
        }
        Bot.current_ws.send(data.to_json) and (yield if block_given?)
      end

      def send_to_super_admins(chain, **options)
        Settings.bot.superAdmins.each do |super_admin|
          data = {
            syncId: 1,
            command: "sendFriendMessage",
            subCommand: nil,
            content: {
              sessionKey: Bot.current_session,
              target: super_admin,
              messageChain: chain
            }
          }
          Bot.current_ws.send(data.to_json) and (yield if block_given?)
        end
      end
    end
  end
end

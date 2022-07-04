module Mah
  module BotEvent
    module_function

    def send_group_message(message, chain, *options, &block)
      chain.unshift(at(message.qq), plain(" ")) if options.include?(:at)
      data = {
        syncId: 1,
        command: "sendGroupMessage",
        subCommand: nil,
        content: {
          sessionKey: Bot.current_session,
          target: message.sender.group.id,
          messageChain: chain
        }
      }
      Bot.current_ws.send(data.to_json) and block&.call
    end

    def send_to_super_admins(chain)
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
        Bot.current_ws.send(data.to_json)
      end
    end
  end
end

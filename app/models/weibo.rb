class Weibo < ApplicationRecord
  def send_weibo
    data = {
      syncId: 1,
      command: "sendGroupMessage",
      subCommand: nil,
      content: {
        sessionKey: Bot.current_session,
        target: 724082984,
        messageChain: [{type: "Plain", text: "Hello, world!"}]
      }
    }
    Bot.current_ws.send(data.to_json)
  end
end

module Mah
  class Message
    CHAIN_TYPE = %(Source Quote At AtAll Face Plain Image
                   FlashImage Voice Xml Json App Poke Dice
                   MarketFace MusicShare Forward File MiraiCode)

    MESSAGE_TYPE = %(GroupMessage FriendMessage TempMessage)

    attr_reader :type, :message_chain, :sender

    def initialize(attributes)
      @type = attributes["type"]
      @message_chain = attributes["messageChain"]
      @sender = attributes["sender"]
    end

    def text
      message_chain.map do |chain|
        chain.text.delete("\n") if chain.type == "Plain"
      end.join(" ")[1..]
    end

    def qq
      sender.id
    end

    def permission
      sender.permission
    end
  end
end

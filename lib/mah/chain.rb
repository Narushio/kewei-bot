module Mah
  module Chain
    module_function

    def at(qq)
      {
        type: "At",
        target: qq
      }
    end

    def plain(text)
      {
        type: "Plain",
        text: text
      }
    end

    def forward(node_list)
      {
        type: "Forward",
        nodeList: node_list
      }
    end

    def node_list(chain)
      {
        senderId: Settings.mah.account,
        time: Time.zone.now.to_i,
        senderName: "超级无敌酷炫可爱的可畏",
        messageChain: chain
      }
    end

    def image(**arg)
      temp = {type: "Image"}
      temp[:url] = arg[:url] if arg.has_key?(:url)
      temp[:path] = arg[:path] if arg.has_key?(:path)
      temp[:base64] = arg[:base64] if arg.has_key?(:base64)
      temp
    end
  end
end

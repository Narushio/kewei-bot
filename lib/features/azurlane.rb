module Features
  class Azurlane < Base
    include ShipData

    attr_reader :functions

    def initialize
      super
      @functions = []
    end

    def build
      query_ship_girl
      query_recommend_equipment
      set_ship_alias
    end

    private

    def set_ship_alias
      functions << {
        level: 2,
        function_name: "舰娘别名",
        lambda: lambda do |message, text|
          @message = message
          return unless text.match?(/\A舰娘别名 (.*)/)

          name = text.split(" ")[1]
          ship_alias = text.split(" ")[2]
          ship_id = ship_data(name: name)[:id]
          return if ship_id.nil? || ship_alias.nil?

          status = :un_approved
          text = "指挥官，设置成功，请等待管理员审核#{I18n.t "emoji.happy"}"
          if Settings.bot.superAdmins.include?(@message.qq)
            status = :approved
            text = "指挥官，设置成功#{I18n.t "emoji.be_cute"}"
          end

          begin
            ShipAlias.create!(ship_id: ship_id, qq: @message.qq, name: ship_alias, status: status)
            send_group_message(@message, [plain(text)], :at)
          rescue ActiveRecord::RecordNotUnique
            send_group_message(@message, [plain("指挥官，该别名已经被设置过了#{I18n.t "emoji.lying_down"}")], :at)
          end
        end
      }

      functions
    end

    def query_ship_girl
      functions << {
        level: 2,
        function_name: "查舰娘",
        lambda: lambda do |message, text|
          @message = message
          return unless text.match?(/\A查舰娘 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          absolute_path = ship_info(name: name) || ship_info(ship_id: ship_id)
          return if absolute_path.nil?

          send_group_message(@message, [plain("\n"), image(path: absolute_path)], :at)
        end
      }

      functions
    end

    def query_recommend_equipment
      functions << {
        level: 2,
        function_name: "查推荐装备",
        lambda: lambda do |message, text|
          @message = message
          return unless text.match?(/\A查推荐装备 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          absolute_path = recommend_equipment(name: name) || recommend_equipment(ship_id: ship_id)
          return if absolute_path.nil?

          send_group_message(@message, [plain("\n"), image(path: absolute_path)], :at)
        end
      }

      functions
    end

    def query_weapon
      functions << {
        level: 2,
        function_name: "查装备",
        lambda: lambda do |message, text|
          # message_chain = {I18n.type: "image", base64: equip.screenshot_as(:base64)}
          BotEvent.new(message).send_group_message(message_chain, {at: true})
        end
      }

      functions
    end
  end
end

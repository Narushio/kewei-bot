module Features
  class Azurlane < Base
    include Application

    attr_reader :functions

    def initialize
      super
      @functions = []
      @wait_process = []
    end

    def build
      query_ship_girl
      query_recommend_equipment
      set_ship_alias
      query_ship_skin
      query_ship_gallery
    end

    private

    def query_ship_gallery
      functions << {
        level: 2,
        function_type: "碧蓝航线",
        function_name: "舰娘美图",
        lambda: lambda do |message, text|
          return unless text.match?(/\A舰娘美图 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          gallery = random_gallery(name: name, ship_id: ship_id)
          return if gallery.nil?

          chain = [plain("\n"), image(base64: gallery)]
          send_group_message(message, chain, at: true)
        end
      }

      functions
    end

    def query_ship_skin
      functions << {
        level: 2,
        function_type: "碧蓝航线",
        function_name: "舰娘立绘",
        lambda: lambda do |message, text|
          return unless text.match?(/\A舰娘立绘 (.*)/)

          name = text.split(" ")[1]
          index = text.split(" ")[2]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          list = ship_skin_list(name: name, ship_id: ship_id)
          return if list.nil?

          if index.nil?
            if list.size == 1
              skin_card = ship_skin_card(name: name, ship_id: ship_id)
              chain = [plain("\n"), image(base64: skin_card)]
            else
              chain = []
              chain << plain("\n指挥官，找到以下立绘#{I18n.t "azurlane.emoji.be_cute"}：\n")
              chain << plain("----------------------------\n")
              list.each_with_index do |info, index|
                chain << plain("  #{info}\n")
                if index == list.size - 1
                  chain << plain("----------------------------\n")
                  chain << plain("回复【序号】可查看对应的立绘#{I18n.t "azurlane.emoji.lying_down"}")
                end
              end
            end
          else
            skin_card = ship_skin_card(name: name, ship_id: ship_id, index: index)
            chain = [plain("\n"), image(base64: skin_card)]
          end

          send_group_message(message, chain, at: true)
        end
      }

      functions
    end

    def set_ship_alias
      functions << {
        level: 2,
        function_type: "碧蓝航线",
        function_name: "舰娘别名",
        lambda: lambda do |message, text|
          return unless text.match?(/\A舰娘别名 (.*)/)

          name = text.split(" ")[1]
          ship_alias = text.split(" ")[2]
          ship = ships.find { |ship| ship.dig("names", "cn") == name }
          return if ship.nil? || ship_alias.nil?

          ship_id = ship["id"]
          status = :un_approved
          chain = [plain("指挥官，设置成功，请等待管理员审核#{I18n.t "azurlane.emoji.happy"}")]
          if Settings.bot.superAdmins.include?(message.qq) || message.permission == "ADMINISTRATOR"
            status = :approved
            chain = [plain("指挥官，设置成功#{I18n.t "azurlane.emoji.be_cute"}")]
          end

          begin
            ShipAlias.create!(ship_id: ship_id, qq: message.qq, name: ship_alias, status: status)
            send_group_message(message, chain, at: true)
          rescue ActiveRecord::RecordNotUnique
            chain = [plain("指挥官，该别名已经被设置过了#{I18n.t "azurlane.emoji.lying_down"}")]
            send_group_message(message, chain, at: true)
          end
        end
      }

      functions
    end

    def query_ship_girl
      functions << {
        level: 2,
        function_type: "碧蓝航线",
        function_name: "查舰娘",
        lambda: lambda do |message, text|
          return unless text.match?(/\A查舰娘 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          absolute_path = ship_info_card(name: name) || ship_info_card(ship_id: ship_id)
          return if absolute_path.nil?

          chain = [plain("\n"), image(path: absolute_path)]
          send_group_message(message, chain, at: true)
        end
      }

      functions
    end

    def query_recommend_equipment
      functions << {
        level: 2,
        function_type: "碧蓝航线",
        function_name: "查推荐装备",
        lambda: lambda do |message, text|
          return unless text.match?(/\A查推荐装备 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          absolute_path = recommend_equipment(name: name, ship_id: ship_id)
          return if absolute_path.nil?

          chain = [plain("\n"), image(path: absolute_path)]
          send_group_message(message, chain, at: true)
        end
      }

      functions
    end

    def query_weapon
      functions << {
        level: 2,
        function_type: "碧蓝航线",
        lambda: lambda do |message, text|
          # message_chain = {I18n.type: "image", base64: equip.screenshot_as(:base64)}
          BotEvent.new(message).send_group_message(message_chain, {at: true})
        end
      }

      functions
    end
  end
end

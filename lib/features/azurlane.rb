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
          @message = message
          return unless text.match?(/\A舰娘美图 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          gallery = random_gallery(name: name, ship_id: ship_id)
          return if gallery.nil?

          send_group_message(@message, [plain("\n"), image(base64: gallery)], :at)
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
          @message = message
          return unless text.match?(/\A舰娘立绘 (.*)/)

          name = text.split(" ")[1]
          index = text.split(" ")[2]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          list = ship_skin_list(name: name, ship_id: ship_id)
          return if list.nil?

          if index.nil?
            if list.size == 1
              skin_card = ship_skin_card(name: name, ship_id: ship_id)
              send_group_message(@message, [plain("\n"), image(base64: skin_card)], :at)
            else
              send_group_message(@message, ship_skin_chain(list), :at)
            end
          else
            skin_card = ship_skin_card(name: name, ship_id: ship_id, index: index)
            send_group_message(@message, [plain("\n"), image(base64: skin_card)], :at)
          end
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
          @message = message
          return unless text.match?(/\A舰娘别名 (.*)/)

          name = text.split(" ")[1]
          ship_alias = text.split(" ")[2]
          ship_id = ship_data(name: name)[:id]
          return if ship_id.nil? && ship_alias.nil?

          status = :un_approved
          text = "指挥官，设置成功，请等待管理员审核#{I18n.t "azurlane.emoji.happy"}"
          if Settings.bot.superAdmins.include?(@message.qq) || @message.permission == "ADMINISTRATOR"
            status = :approved
            text = "指挥官，设置成功#{I18n.t "azurlane.emoji.be_cute"}"
          end

          begin
            ShipAlias.create!(ship_id: ship_id, qq: @message.qq, name: ship_alias, status: status)
            send_group_message(@message, [plain(text)], :at)
          rescue ActiveRecord::RecordNotUnique
            send_group_message(@message, [plain("指挥官，该别名已经被设置过了#{I18n.t "azurlane.emoji.lying_down"}")], :at)
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
          @message = message
          return unless text.match?(/\A查舰娘 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          absolute_path = ship_info_card(name: name) || ship_info_card(ship_id: ship_id)
          return if absolute_path.nil?

          send_group_message(@message, [plain("\n"), image(path: absolute_path)], :at)
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
          @message = message
          return unless text.match?(/\A查推荐装备 (.*)/)

          name = text.split(" ")[1]
          ship_id = ShipAlias.find_by(name: name, status: :approved)&.ship_id
          absolute_path = recommend_equipment(name: name, ship_id: ship_id)
          return if absolute_path.nil?

          send_group_message(@message, [plain("\n"), image(path: absolute_path)], :at)
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

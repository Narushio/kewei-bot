module Features::Azurlane::ShipSkin
  include Magick

  def ship_skin_card(name: nil, ship_id: nil, index: 1)
    data = nil
    data = ship_skins.find { |ship| ship["name"] == name } unless name.nil?
    data = ship_skins.find { |ship| ship["id"] == ship_id } unless ship_id.nil?

    if data.nil?
      nil
    else
      begin
        bg = Image.read(data.dig("skins", index.to_i - 1, "background"))[0]
        bg_height = bg.properties["png:IHDR.width,height"].split(",")[1].strip
        image = Image.read(data.dig("skins", index.to_i - 1, "bg") || data.dig("skins", index.to_i - 1, "image"))[0]
        image_height = image.properties["png:IHDR.width,height"].split(",")[1].strip
        bg = bg.resize_to_fit(nil, image_height)

        chibi_path = data.dig("skins", index.to_i - 1, "chibi")
        if File.exist?(chibi_path)
          chibi = Image.read(chibi_path)[0]
          chibi_height = chibi.properties["png:IHDR.width,height"].split(",")[1].strip
          chibi = chibi.resize_to_fit(nil, image_height.to_i * chibi_height.to_i / bg_height.to_i)
          skin_card = bg.composite(image, CenterGravity, SrcOverCompositeOp)
          skin_card = skin_card.composite(chibi, SouthWestGravity, SrcOverCompositeOp)
        else
          skin_card = bg.composite(image, CenterGravity, SrcOverCompositeOp)
        end

        Base64.strict_encode64(skin_card.to_blob)
      rescue ArgumentError
        nil
      end
    end
  end

  def ship_skin_list(name: nil, ship_id: nil)
    data = nil
    data = ship_skins.find { |ship| ship["name"] == name } unless name.nil?
    data = ship_skins.find { |ship| ship["id"] == ship_id } unless ship_id.nil?

    if data.nil?
      nil
    else
      data["skins"].map.with_index do |skin, index|
        "【#{index.to_i + 1}】#{skin["info"]["cnClient"] || I18n.t("azurlane.#{skin["name"]}")}"
      end
    end
  end
end

module Features::Azurlane::ShipInfo
  def ship_info_card(name: nil, ship_id: nil)
    data = nil
    data = ships.find { |ship| ship.dig("names", "cn") == name } unless name.nil?
    data = ships.find { |ship| ship["id"] == ship_id } unless ship_id.nil?

    if data.nil?
      nil
    else
      format_data = {
        id: data["id"],
        name: name,
        code: data.dig("names", "code"),
        stars: data["stars"],
        thumbnail: data["thumbnail"],
        rarityBG: data["rarityBG"],
        hullType: data["hullType"],
        nationIcon: data["nationIcon"],
        hullTypeIcon: data["hullTypeIcon"],
        skills: data["skills"],
        baseStats: data.dig("stats", "baseStats"),
        maxStats: data["stats"].fetch("level125Retrofit") { data["stats"]["level125"] },
        limitBreaks: data["limitBreaks"],
        devLevels: data["devLevels"],
        wikiUrl: data["wikiUrl"]
      }

      path = "resource/images/ship_info/"
      png_path = path + "#{format_data[:id]}.png"
      driver = Bot.headless_driver

      unless File.exist?(png_path)
        driver.get("file://#{Rails.root.join("templates", "azurlane", "shipInfo.html")}")
        driver.manage.window.resize_to(1400, 1400)
        driver.execute_script("initDom(#{format_data.to_json})")
        element = driver.find_element(id: "template")
        FileUtils.mkdir_p(path) unless Dir.exist?(path)

        sleep 0.5
        element.save_screenshot(png_path)
      end

      Rails.root.join(png_path)
    end
  end
end

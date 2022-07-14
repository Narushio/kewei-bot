module Features::Azurlane::ShipInfo
  def ship_info_card(name: nil, ship_id: nil)
    data = ship_data(name: name, ship_id: ship_id)
    return nil if data.nil?

    path = "resource/images/ship_info/"
    unless File.exist?(path + "#{data[:id]}.png")
      Bot.headless_driver.get("file://#{Rails.root.join("templates", "azurlane", "shipInfo.html")}")
      Bot.headless_driver.manage.window.resize_to(1400, 1400)
      Bot.headless_driver.execute_script("initDom(#{data.to_json})")
      element = Bot.headless_driver.find_element(id: "template")
      FileUtils.mkdir_p(path) unless Dir.exist?(path)
      sleep 0.5
      element.save_screenshot(path + "#{data[:id]}.png")
    end

    Rails.root.join(path + "#{data[:id]}.png")
  end
end

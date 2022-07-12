module Features::Azurlane::ShipData
  module_function

  SHIPS = JSON.load_file("resource/ships.json")

  def equipment(name:)
    # driver = Bot.headless_driver
    # driver.get("https://wiki.biligame.com/blhx/" + CGI.escape(name))
    # equip = driver.find_element(class: "equip")
    # width = driver.execute_script("return Math.max(document.body.scrollWidth,document.body.offsetWidth,document.documentElement.clientWidth,document.documentElement.scrollWidth,document.documentElement.offsetWidth);")
    # height = driver.execute_script("return Math.max(document.body.scrollHeight,document.body.offsetHeight,document.documentElement.clientHeight,document.documentElement.scrollHeight,document.documentElement.offsetHeight);")
    # driver.manage.window.resize_to(width, height)
    # driver.manage.window.maximize
  end

  def recommend_equipment(name: nil, ship_id: nil)
    data = ship_data(name: name, ship_id: ship_id)
    return nil if data.nil?

    path = "resource/images/recommend_equipment/"
    unless File.exist?(path + "#{data[:id]}.png")
      Bot.headless_driver.get(data[:wikiUrl])
      width = Bot.headless_driver.execute_script("return Math.max(document.body.scrollWidth,document.body.offsetWidth,document.documentElement.clientWidth,document.documentElement.scrollWidth,document.documentElement.offsetWidth);")
      height = Bot.headless_driver.execute_script("return Math.max(document.body.scrollHeight,document.body.offsetHeight,document.documentElement.clientHeight,document.documentElement.scrollHeight,document.documentElement.offsetHeight);")
      Bot.headless_driver.manage.window.resize_to(width, height)
      Bot.headless_driver.manage.window.maximize
      element = Bot.headless_driver.find_elements(css: ".panel.panel-primary")[0]
      FileUtils.mkdir_p(path) unless Dir.exist?(path)
      sleep 1
      element.save_screenshot(path + "#{data[:id]}.png")
    end

    Rails.root.join(path + "#{data[:id]}.png")
  end

  def ship_info(name: nil, ship_id: nil)
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

  def ship_data(name: nil, ship_id: nil)
    ship = SHIPS.find { |ship| ship.dig("names", "cn") == name } unless name.nil?
    ship = SHIPS.find { |ship| ship["id"] == ship_id } unless ship_id.nil?

    if ship.nil?
      nil
    else
      data = {
        id: ship["id"],
        name: name,
        code: ship.dig("names", "code"),
        stars: ship["stars"],
        thumbnail: ship["thumbnail"],
        rarityBG: ship["rarityBG"],
        hullType: ship["hullType"],
        nationIcon: ship["nationIcon"],
        hullTypeIcon: ship["hullTypeIcon"],
        skills: ship["skills"],
        baseStats: ship.dig("stats", "baseStats"),
        maxStats: ship["stats"].fetch("level125Retrofit") { ship["stats"]["level125"] },
        limitBreaks: ship["limitBreaks"],
        devLevels: ship["devLevels"],
        wikiUrl: ship["wikiUrl"]
      }
    end
  end
end

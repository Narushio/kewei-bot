module Features::Azurlane::Equipment
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
    data = nil
    data = ships.find { |ship| ship.dig("names", "cn") == name } unless name.nil?
    data = ships.find { |ship| ship["id"] == ship_id } unless ship_id.nil?

    if data.nil?
      nil
    else
      path = "resource/images/recommend_equipment/"
      png_path = path + "#{data[:id]}.png"
      driver = Bot.headless_driver

      unless File.exist?(png_path)
        driver.get(data[:wikiUrl])
        width = driver.execute_script("return Math.max(document.body.scrollWidth,document.body.offsetWidth,document.documentElement.clientWidth,document.documentElement.scrollWidth,document.documentElement.offsetWidth);")
        height = driver.execute_script("return Math.max(document.body.scrollHeight,document.body.offsetHeight,document.documentElement.clientHeight,document.documentElement.scrollHeight,document.documentElement.offsetHeight);")
        driver.manage.window.resize_to(width, height)
        driver.manage.window.maximize
        element = driver.find_elements(css: ".panel.panel-primary")[0]
        FileUtils.mkdir_p(path) unless Dir.exist?(path)

        sleep 1
        element.save_screenshot(png_path)
      end

      Rails.root.join(png_path)
    end
  end
end

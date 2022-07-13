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
end

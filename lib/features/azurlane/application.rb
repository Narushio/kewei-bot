module Features::Azurlane::Application
  module_function

  include Features::Azurlane::Equipment
  include Features::Azurlane::ShipInfo
  include Features::Azurlane::ShipSkin

  SHIPS = JSON.load_file("resource/ships.json")
  SHIP_SKINS = JSON.load_file("resource/ship_skins.json")

  def ship_data(name: nil, ship_id: nil)
    data = SHIPS.find { |ship| ship.dig("names", "cn") == name } unless name.nil?
    data = SHIPS.find { |ship| ship["id"] == ship_id } unless ship_id.nil?

    if data.nil?
      nil
    else
      {
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
    end
  end

  def ship_skin_data(name: nil, ship_id: nil)
    data = SHIP_SKINS.find { |ship| ship["name"] == name } unless name.nil?
    data = SHIP_SKINS.find { |ship| ship["id"] == ship_id } unless ship_id.nil?
    data.nil? ? nil : data
  end
end

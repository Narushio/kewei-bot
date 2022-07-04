module Features::Azurlane::ShipData
  module_function

  SHIPS = JSON.load_file("resource/ships.json")

  def ship_info(name)
    ship = SHIPS.find { _1.dig("names", "cn") == name }
    if ship.nil?
      nil
    else
      {
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
        devLevels: ship["devLevels"]
      }
    end
  end
end

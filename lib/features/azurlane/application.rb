module Features::Azurlane::Application
  include Features::Azurlane::Equipment
  include Features::Azurlane::ShipInfo
  include Features::Azurlane::ShipSkin
  include Features::Azurlane::ShipGallery

  def ships
    JSON.load_file("resource/ships.json")
  end

  def ship_skins
    JSON.load_file("resource/ship_skins.json")
  end

  def ship_gallery
    JSON.load_file("resource/ship_gallery.json")
  end
end

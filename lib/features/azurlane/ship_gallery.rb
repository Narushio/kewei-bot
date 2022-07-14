module Features::Azurlane::ShipGallery
  def random_gallery(name: nil, ship_id: nil)
    data = ship_gallery_data(name: name, ship_id: ship_id)
    return nil if data.nil?

    path = data["gallery"].sample["path"]
    Base64.strict_encode64(File.read(path))
  end
end

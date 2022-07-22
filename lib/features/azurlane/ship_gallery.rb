module Features::Azurlane::ShipGallery
  def random_gallery(name: nil, ship_id: nil)
    data = nil
    data = ship_gallery.find { |ship| ship["name"] == name } unless name.nil?
    data = ship_gallery.find { |ship| ship["id"] == ship_id } unless ship_id.nil?

    if data.nil?
      nil
    else
      png_path = data["gallery"].sample["path"]
      return nil unless File.exist?(png_path)

      Base64.strict_encode64(File.read(png_path))
    end
  end
end

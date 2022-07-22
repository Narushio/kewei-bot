class Logger
  def message(data)
    type = data["type"]
    case type
    when "FriendMessage"
      info("Event(#{type}) #{data.dig("sender", "nickname")}(#{data.dig("sender", "id")}): #{data["messageChain"]}")
    when "GroupMessage"
      info("Event(#{type}) [#{data.dig("sender", "group", "name")}(#{data.dig("sender", "group", "id")})] #{data.dig("sender", "memberName")}(#{data.dig("sender", "id")}): #{data["messageChain"]}")
    else
      info("Event(#{type})")
    end
  end
end

def download_pic(img_name, url, path: false, base64: false)
  pic_dir = "tmp/images"
  FileUtils.mkdir_p(pic_dir) unless Dir.exist?(pic_dir)
  destination = "#{pic_dir}/#{img_name}.jpg"

  begin
    if File.exist?(destination)
      stream = File.read(destination)
      stream[-36..-1] = SecureRandom.uuid.to_s
    else
      Down.download(url, destination: destination)
      stream = File.read(destination) + SecureRandom.uuid.to_s
    end
    File.write(destination, stream)
  rescue
    nil
  end

  if path
    Rails.root.join(destination).to_s
  elsif base64
    Base64.strict_encode64(File.read(destination))
  else
    true
  end
end

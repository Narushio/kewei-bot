module Features
  class Setu < Base
    attr_reader :functions

    def initialize
      super
      url = "https://api.lolicon.app/setu/v2"
      headers = {"Content-type" => "application/json"}
      @functions = []
      @conn = Faraday.new(url, {headers: headers})
    end

    def build
      send_setu
    end

    private

    def send_setu
      functions << {
        level: 2,
        function_type: "色图",
        lambda: lambda do |message, text|
          return if text.match(/\A(色图|涩图|🐍图)(.*)/).nil?

          is_r18 = false
          params = {proxy: "i.pixiv.re", size: "original"}
          begin
            unless Regexp.last_match(2).nil? || Regexp.last_match(2) == ""
              options = Regexp.last_match(2).split(" ")
              (params[:r18] = 1) and (is_r18 = true) if options.delete("r18") == "r18"
              if is_r18 && !Settings.setu.r18
                image_base64 = Base64.strict_encode64(File.read("resource/images/emoji/不可以涩涩.gif"))

                chain = [plain("\n"), image(base64: image_base64)]
                return send_group_message(message, chain, at: true)
              end
              params[:tag] = options unless options.empty?
            end

            chain = [plain("嗯————?，指挥官竟然看我的色图，真是可爱呢~~~")]
            send_group_message(message, chain, at: true) if params[:tag].to_s.match?(/(可畏)/)
            data = JSON.parse(@conn.post(nil, params.to_json).body).dig("data", 0)
          rescue => e
            chain = [plain(e.message)]
            send_to_super_admins(chain)

            chain = [plain("指挥官，网络请求失败惹#{I18n.t "azurlane.emoji.cry"}")]
            return send_group_message(message, chain, at: true)
          end

          chain = [plain("指挥官的性癖太独特找不到图片#{I18n.t "azurlane.emoji.sweat"}")]
          return send_group_message(message, chain, at: true) if data.nil?

          image_base64 = download_pic(data["pid"], data.dig("urls", "original"), base64: true)
          chain = [plain("指挥官，下载图片出错惹#{I18n.t "azurlane.emoji.cry"}")]
          return send_group_message(message, chain, at: true) unless image_base64

          chain = [
            plain("\nPID: #{data["pid"]}\nUID: #{data["uid"]}\nTitle: #{data["title"]}\n" \
                  "Author: #{data["author"]}\nTags: #{data["tags"].join(",")}\n"),
            image(base64: image_base64)
          ]
          chain = [forward(chain)] if is_r18
          send_group_message(message, chain, at: true)
        end
      }
    end
  end
end

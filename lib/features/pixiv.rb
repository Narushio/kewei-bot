module Features
  class Pixiv < Base
    attr_reader :functions

    RANKING_TYPE = {
      1 => "day",
      2 => "week",
      3 => "month",
      4 => "day_male",
      5 => "day_female",
      6 => "week_original",
      7 => "week_rookie",
      8 => "day_r18",
      9 => "week_r18",
      10 => "week_r18g",
      11 => "day_male_r18",
      12 => "day_female_r18"
    }.freeze

    RANKING_INFO =
      "以下是排行榜搜索的序号，命令格式：p站排行 【序号】\n" \
      "\t1: 日榜\n" \
      "\t2: 周榜\n" \
      "\t3: 月榜\n" \
      "\t4: 男性向\n" \
      "\t5: 女性向\n" \
      "\t6: 原创\n" \
      "\t7: 新人\n" \
      "\t8: 日榜r18\n" \
      "\t9: 周榜r18\n" \
      "\t10: 周榜r18重口猎奇向\n" \
      "\t11: 男性向r18\n" \
      "\t12: 女向性r18".freeze

    def initialize
      super
      url = "https://hibiapi-kewei.herokuapp.com/api/pixiv/"
      @functions = []
      @queue = []
      @conn = Faraday.new(url, {
        headers: {
          "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1",
          Referer: "https://www.pixiv.net"
        },
        proxy: "http://127.0.0.1:7890"
      })
    end

    def build
      send_rank_list
    end

    private

    def send_rank_list
      functions << {
        level: 2,
        function_name: "pixiv排行榜",
        lambda: lambda do |message, text|
          @message = message
          return unless text.match?(/\A(pixiv排行|pixiv排行榜|p站排行|p站排行榜)/)

          return send_group_message(@message, [plain("指挥官，P站排行榜或搜图正在搜索，请不要重复触发命令...")], :at) if @queue.include?(@message.qq)

          mode_index = text.split(" ")[-1]
          params = {mode: "day", page: 1}

          unless mode_index == text
            mode = RANKING_TYPE.fetch(mode_index.to_i) do
              return send_group_message(@message, [plain("指挥官，没有这个排行榜类型喔...\n#{RANKING_INFO}")], :at) { @queue.delete(@message.qq) }
            end
            if mode.match?(/(r18)/) && !Settings.pixiv.r18
              image_base64 = Base64.strict_encode64(File.read("resource/images/emoji/不可以涩涩.gif"))
              return send_group_message(@message, [plain("\n"), image(base64: image_base64)], :at) { @queue.delete(@message.qq) }
            else
              params[:mode] = mode
            end
          end
          send_group_message(@message, [plain("指挥官，开始搜索整理p站排行榜图片...")], :at) { @queue.push(@message.qq) }

          illusts = get_illusts(params)
          if illusts.empty?
            send_group_message(@message, [plain("指挥官，该排行榜类型今日数据好像还没有更新呢...为你找到昨天的数据...")], :at)
            illusts = get_illusts(params, date: Date.yesterday.strftime("%Y-%m-%d"))
          end

          send_group_message(@message, [list_chain(illusts)]) { @queue.delete(@message.qq) }
        end
      }
    end

    def list_chain(illusts)
      node_list = []
      threads = []
      illusts.each do |illust|
        threads << Thread.new do
          url = illust.dig("image_urls", "large")
            .gsub("i.pximg.net", "i.pixiv.re")
            .gsub("_webp", "")
          image_base64 = download_pic(illust["id"], url, base64: true)
          chain = if image_base64 == false
            [plain("该图片下载失败...")]
          else
            [plain("PID: #{illust["id"]}\nTitle: #{illust["title"]}\n"), image(base64: image_base64)]
          end
          node_list.push(node_list(chain))
        end
      end
      threads.each(&:join)
      forward(node_list)
    end

    def get_illusts(params, date: nil)
      begin
        params[:date] = date unless date.nil?
        illusts = JSON.parse(@conn.get("rank", params).body)["illusts"][0..Settings.pixiv.limit.to_i - 1]
      rescue => e
        send_to_super_admins([plain(e.message)])
        return send_group_message(@message, [plain("指挥官，网络出错惹...")], :at) { @queue.delete(@message.qq) }
      end
      illusts
    end
  end
end

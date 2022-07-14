module Features::Azurlane::Helper
  def ship_skin_chain(list)
    chain = []
    chain << plain("\n指挥官，找到以下立绘#{I18n.t "azurlane.emoji.be_cute"}：\n")
    chain << plain("----------------------------\n")
    list.each_with_index do |info, index|
      chain << plain("  #{info}\n")
      if index == list.size - 1
        chain << plain("----------------------------\n")
        chain << plain("回复【序号】可查看对应的立绘#{I18n.t "azurlane.emoji.lying_down"}")
      end
    end

    chain
  end
end

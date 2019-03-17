
class NekoWrapper
  def canShowVideoAD
    puts 'canShowVideoAD'
    return false
  end

  def showVideoAD(skip=false)
    puts 'showVideoAD'
  end

  def showBannerAD(align, type='')
    puts "showBannerAD align=#{align}, type=#{type}"
  end

  def hideBannerAD
    puts 'hideBannerAD'
  end

  def showFullAD(type='')
    puts "showFullAD type=#{type}"
  end

  def useCash(switch_id, name, amount)
    $game_switches[switch_id] = false
    $game_map.need_refresh = true

    puts "useCash switch_id=#{switch_id}, type=#{name}, amount=#{amount}"
    $game_switches[switch_id] = true
    $game_map.need_refresh = true
    return true
  end

  def buyCash()
    puts "buyCash"
  end
end

$neko = NekoWrapper.new unless $neko

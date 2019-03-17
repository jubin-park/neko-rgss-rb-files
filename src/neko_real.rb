
if $NEKO_RUBY
  class Neko

    def unescape(s)
      s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){
        [$1.delete('%')].pack('H*')
      }
    end

    def normalize_params(params, name, v = nil)
      name =~ %r([\[\]]*([^\[\]]+)\]*)
      k = $1 || ''
      after = $' || ''

      return if k.empty?

      if after == ""
        params[k] = v
      elsif after == "[]"
        params[k] ||= []
        raise TypeError unless params[k].is_a?(Array)
        params[k] << v
      elsif after =~ %r(^\[\]\[([^\[\]]+)\]$) || after =~ %r(^\[\](.+)$)
        child_key = $1
        params[k] ||= []
        raise TypeError unless params[k].is_a?(Array)
        if params[k].last.is_a?(Hash) && !params[k].last.key?(child_key)
          normalize_params(params[k].last, child_key, v)
        else
          params[k] << normalize_params({}, child_key, v)
        end
      else
        params[k] ||= {}
        params[k] = normalize_params(params[k], after, v)
      end

      return params
    end

    def parse_nested_query(qs, d = '&;')
      params = {}

      (qs || '').split(/[#{d}] */n).each do |p|
        k, v = unescape(p).split('=', 2)
        normalize_params(params, k, v)
      end

      return params
    end

    def canShowVideoAD
      result = SDL.sendCommand "command=canShowVideoAD"
      if result
          return parse_nested_query(result)['result'] == 'true'
      end

      return false
    end

    def showVideoAD(skip=false)
      SDL.sendCommand "command=showVideoAD&skip=#{skip}"
    end

    def showBannerAD(align, type='')
      SDL.sendCommand "command=showBannerAD&align=#{align}&type=#{type}"
    end

    def hideBannerAD
      SDL.sendCommand 'command=hideBannerAD'
    end

    def showFullAD(type='')
      SDL.sendCommand "command=showFullAD&type=#{type}"
    end

    def useCash(switch_id, name, amount)
      $game_switches[switch_id] = false
      $game_map.need_refresh = true

      SDL.sendCommand "command=useCash&switch_id=#{switch_id}&amount=#{amount}&name=#{name}"
    end

    def buyCash()
      puts "buyCash"
      SDL.sendCommand 'command=buyCash'
    end

    def handleCommand(result)
      result = parse_nested_query(result)
      if result['receipt_data']
        puts 'eqwekqrkqor', result['switch_id'].to_i
        $game_switches[result['switch_id'].to_i] = true
        $game_map.need_refresh = true
      end
    end
  end

  $neko = Neko.new
end
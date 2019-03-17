
module RPG

end

def require_relative(v)
  require "rpg/#{v}"
end

require_relative 'rpgvx/map'
require_relative 'rpgvx/mapinfo'
require_relative 'rpgvx/area'
require_relative 'rpgvx/event'
require_relative 'rpgvx/event_page'
require_relative 'rpgvx/event_page_condition'
require_relative 'rpgvx/event_page_graphic'
require_relative 'rpgvx/eventcommand'
require_relative 'rpgvx/moveroute'
require_relative 'rpgvx/movecommand'
require_relative 'rpgvx/actor'
require_relative 'rpgvx/class'
require_relative 'rpgvx/class_learning'
require_relative 'rpgvx/baseitem'
require_relative 'rpgvx/usableitem'
require_relative 'rpgvx/skill'
require_relative 'rpgvx/item'
require_relative 'rpgvx/weapon'
require_relative 'rpgvx/armor'
require_relative 'rpgvx/enemy'
require_relative 'rpgvx/enemy_dropitem'
require_relative 'rpgvx/enemy_action'
require_relative 'rpgvx/troop'
require_relative 'rpgvx/troop_member'
require_relative 'rpgvx/troop_page'
require_relative 'rpgvx/troop_page_condition'
require_relative 'rpgvx/state'
require_relative 'rpgvx/animation'
require_relative 'rpgvx/animation_frame'
require_relative 'rpgvx/animation_timing'
require_relative 'rpgvx/commonevent'
require_relative 'rpgvx/system'
require_relative 'rpgvx/system_vehicle'
require_relative 'rpgvx/system_terms'
require_relative 'rpgvx/system_testbattler'
require_relative 'rpgvx/audiofile'
require_relative 'rpgvx/bgm'
require_relative 'rpgvx/bgs'
require_relative 'rpgvx/me'
require_relative 'rpgvx/se'

require_relative 'rpgvx/cache'
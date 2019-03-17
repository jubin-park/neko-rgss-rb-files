
module RPG

end

def require_relative(v)
  require "rpg/#{v}"
end

require_relative 'rpgva/map'
require_relative 'rpgva/map_encounter'
require_relative 'rpgva/mapinfo'
require_relative 'rpgva/event'
require_relative 'rpgva/event_page'
require_relative 'rpgva/event_page_condition'
require_relative 'rpgva/event_page_graphic'
require_relative 'rpgva/eventcommand'
require_relative 'rpgva/moveroute'
require_relative 'rpgva/movecommand'

require_relative 'rpgva/baseitem'
require_relative 'rpgva/actor'
require_relative 'rpgva/class'
require_relative 'rpgva/usableitem'
require_relative 'rpgva/skill'
require_relative 'rpgva/item'
require_relative 'rpgva/equipitem'
require_relative 'rpgva/weapon'
require_relative 'rpgva/armor'
require_relative 'rpgva/enemy'
require_relative 'rpgva/state'
require_relative 'rpgva/baseitem_feature'
require_relative 'rpgva/usableitem_damage'
require_relative 'rpgva/usableitem_effect'
require_relative 'rpgva/enemy_dropitem'
require_relative 'rpgva/enemy_action'
require_relative 'rpgva/troop'
require_relative 'rpgva/troop_member'
require_relative 'rpgva/troop_page'
require_relative 'rpgva/troop_page_condition'
require_relative 'rpgva/animation'
require_relative 'rpgva/animation_frame'
require_relative 'rpgva/animation_timing'
require_relative 'rpgva/tileset'
require_relative 'rpgva/commonevent'
require_relative 'rpgva/system'
require_relative 'rpgva/system_vehicle'
require_relative 'rpgva/system_terms'
require_relative 'rpgva/system_testbattler'
require_relative 'rpgva/audiofile'
require_relative 'rpgva/bgm'
require_relative 'rpgva/bgs'
require_relative 'rpgva/me'
require_relative 'rpgva/se'

require_relative 'rpgva/class_learning'

require_relative 'rpgva/cache'
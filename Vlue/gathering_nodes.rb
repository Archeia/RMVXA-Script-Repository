#Gathering Nodes v1.1
#----------#
#Features: Now you too can create simple and easy (and copy/pastable *wink*)
#           gathering nodes for your game! Want a herb patch that respawns
#           every 6 minutes and gives the player some herbs? You can do that.
#           Need to change the herb patch but already placed a 100 of them?
#           You can change them all at once, since it uses script options!
#
#Usage:    Simply name an empty event: Node #id
#           And the script does the rest! Say for example you named an
#           event: Node #1, it'd use the node data of id 1. You can have
#           as many events of the same node and as many node types that
#           you want! And more to come I'm sure...
#
#~ #----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#Setting up your nodes is as easy as minor surgery.
# A basic node consists of:
#   id => {:item => [:type,id,[min,max]],  #:type is :item, :weapon, or :armor
#          :tool => [:type, id]            #item required to gather (optional)
#          :level => value,                #level needed to gather
#          :timer => value(in seconds),    #respawn timer
#          :base_chance => value,          #chance to gather
#          :max_chance => value,           #max chance to gather
#          :chance_mod => value,}          #see below
#          :graphic_b => [:type,val1,val2] #also see below
#          :graphic_a => [:type,val1,val2] #still also see below
#          :sound => ["se name",vol,times,wait]
#
# Below: The chance to gather from a node is: bc + (level - node_level) * cm
#  Which means for every level the player is above the node, they get the
#   chance mod times that added on to the base chance. And reverse for lower
#   player level compared to node level.
# Example: BC = 50, CM = 5
#   50 + (5 - 1) * 5 = 70% chance to gather (PL 5, NL 1)
#   50 + (5 - 5) * 5 = 50% chance to gather (PL 5, NL 5)
#   50 + (5 - 9) * 5 = 30% chance to gather (PL 5, NL 9)
#
# Graphic_A and Graphic_B (Optional)
#  Denotes the graphic for each node before harvest (graphic_b) and after
#  harvest (graphic_a). Could be tileset or character like as follows:
#   :graphic_b => [:tileset,11],
#   :graphic_a => [:char,"Animal",1],
#  Tileset numbers start at 0 (B top left corner), uses map tileset
#
# Items - The :item section can also be set up to include multiple different
#   gathering results!
#  Instead of :item => [:type,id,[min,max]], you would set it up like:
#   :item => [ [:type,id,[min,max],chance], [:type,id,[min,max],chance], ... ],
#  Where chance is a value out of 100 (higher values more likely), the script
#   will iterate through all possible items until one passes it's chance check.

$imported = {}
$imported[:Vlue_GatheringNodes] = true
 
#Note the strange and bizarre double quotes ( '" "' ), keep those.
NODES_OBTAINED_STRING = '"Obtained \\\i[#{item.icon_index}] #{item.name} x#{amount}."'
NODES_LOWLEVEL_STRING = '"Level #{node_data[:level]} required."'
NODES_TOOLREQ_STRING = '"Tool \\\i[#{item.icon_index}] #{item.name} required."'
NODES_GATHERFAIL_STRING = "Failed to gather resource."
 
GATHERING_NODES = {
  1 => {:item => [:item,1,[1,5]],
        :tool => [:weapon,1],
        :level => 1,
        :timer => 6,
        :base_chance => 70,
        :max_chance => 95,
        :chance_mod => 5,
        :graphic_b => [:tileset,177],
        :graphic_a => [:tileset,100],
        :sound => ["Blow2",75,3,15]},
        
  2 => {:item => [
          [:item,2,[1,3],90],
          [:item,3,[1,1],5]],
        :level => 0,
        :timer => 1,
        :base_chance => 100,
        :max_chance => 100,
        :chance_mod => 1,
        :graphic_b => [:tileset,281],
        :graphic_a => [:tileset,0],
        :sound => ["Equip3",75,1,5]}
        
}
 
class Game_Event
  alias gather_update update
  alias gather_start start
  alias gather_init setup_page
  def setup_page(*args)
    gather_init(*args)
    if node
      graphic = erased? ? node_data[:graphic_a] : node_data[:graphic_b]
      if graphic
        if graphic[0] == :tileset
          @tile_id = graphic[1]
        else
          @character_name = graphic[1]
          @character_index = graphic[2]
        end
      end
    end
  end
  def node
    @event.name.include?("Node")
  end
  def node_id
    @event.name =~ /Node #(\d+)/ ? $1.to_i : nil
  end
  def node_data
    GATHERING_NODES[node_id]
  end
  def start
    node ? node_start : gather_start
  end
  def node_start
    return if $imported[:Vlue_PopupWindow] and $popup
    return no_tool if !carrying_tool?
    return no_level if node_data[:level] > $game_party.highest_level
    $game_party.gathering = true
    if node_data[:sound]
      node_data[:sound][2].times do |i|
        Audio.se_play("Audio/SE/" + node_data[:sound][0],node_data[:sound][1])
        node_data[:sound][3].times do |i|
          Graphics.update
          SceneManager.scene.update
        end
      end
    end
    $game_party.gathering = false
    if gather_success
      if node_data[:item][0].is_a?(Array)
        item_d = nil
        while item_d.nil?
          node_data[:item].each do |array|
            item_d = array if rand(100) < array[3]
          end
        end
      else
        item_d = node_data[:item]
      end
      item = $data_items[item_d[1]] if item_d[0] == :item
      item = $data_weapons[item_d[1]] if item_d[0] == :weapon
      item = $data_armors[item_d[1]] if item_d[0] == :armor
      msgbox("Invalid item category") unless item
      amount = (rand(item_d[2][1] - item_d[2][0]) + item_d[2][0]).to_i
      $game_party.gain_item(item,amount)
      if $imported[:Vlue_SleekPopup]
        Popup_Manager.add(item,amount,PU_DEFAULT_DURATION,false,0,0)
      elsif $imported[:Vlue_PopupWindow]
        Popup.add([eval(NODES_OBTAINED_STRING)],POPUP_DURATION,nil,nil)
      else
        $game_message.add(eval(NODES_OBTAINED_STRING))
      end
    end
    erase
    set_timer(node_data[:timer])
  end
  def carrying_tool?
    item_d = node_data[:tool]
    return true if item_d.nil?
    item = $data_items[item_d[1]] if item_d[0] == :item
    item = $data_weapons[item_d[1]] if item_d[0] == :weapon
    item = $data_armors[item_d[1]] if item_d[0] == :armor
    return $game_party.has_item?(item)
  end
  def set_timer(length)
    $game_party.node_timers.set_timer(@id,$game_map.map_id,length)
  end
  def unerase
    @erased = false
    refresh
  end
  def erased?; @erased == true; end
  def event_id; @id; end
  def no_level
    if $imported[:Vlue_PopupWindow]
      Popup.add([eval(NODES_LOWLEVEL_STRING)],POPUP_DURATION,nil,nil)
    else
      $game_message.add(eval(NODES_LOWLEVEL_STRING))
    end
  end
  def no_tool
    item_d = node_data[:tool]
    item = $data_items[item_d[1]] if item_d[0] == :item
    item = $data_weapons[item_d[1]] if item_d[0] == :weapon
    item = $data_armors[item_d[1]] if item_d[0] == :armor
    if $imported[:Vlue_PopupWindow]
      Popup.add([eval(NODES_TOOLREQ_STRING)],POPUP_DURATION,nil,nil)
    else
      $game_message.add(eval(NODES_TOOLREQ_STRING))
    end
  end
  def gather_success
    chance = node_data[:base_chance]
    chance += node_data[:chance_mod] * ($game_party.highest_level - node_data[:level])
    chance = [chance,node_data[:max_chance]].min
    if rand(100) < chance
      return true
    else
      if $imported[:Vlue_PopupWindow]
        Popup.add([NODES_GATHERFAIL_STRING],POPUP_DURATION,nil,nil)
      else
        $game_message.add(NODES_GATHERFAIL_STRING)
      end
      return false
    end
  end
end

class Game_Player
  alias gather_movable? movable?
  def movable?
    return if $game_party.gathering
    return gather_movable?
  end
end
 
class Game_Map
  alias gather_se setup_events
  alias gather_ue update_events
  def setup_events
    gather_se
    @events.each_value do |event|
      next unless event.node
      event.erase if $game_party.node_timers.timer(event.event_id,@map_id) > 0
    end
  end
  def update_events
    $game_party.node_timers.update
    gather_ue
    @events.each_value do |event|
      next unless event.node && event.erased?
      event.unerase if $game_party.node_timers.timer(event.event_id,@map_id) == 0
    end
  end
end
 
class Node_Timers
  def initialize
    @event_timers = {}
  end
  def update
    return unless Graphics.frame_count % 60 == 0
    @event_timers.each do |k,i|
      @event_timers[k] -= 1 if @event_timers[k] > 0
    end
  end
  def timer(eid,mid)
    res = @event_timers[[eid,mid]]
    res ? res : 0
  end
  def set_timer(eid,mid,len)
    @event_timers[[eid,mid]] = len
  end
end
 
class Game_Party
  attr_accessor :node_timers
  attr_accessor :gathering
  alias gather_init initialize
  def initialize(*args)
    gather_init
    @node_timers = Node_Timers.new
    @gathering = false
  end
end
=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - DECOR AND BUILD v1.2
 by Estriole
 
 ■ License          ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE). 
 
 ■ Support          ╒═════════════════════════════════════════════════════════╛
 While I'm flattered and I'm glad that people have been sharing and asking
 support for scripts in other RPG Maker communities, I would like to ask that
 you please avoid posting my scripts outside of where I frequent because it
 would make finding support and fixing bugs difficult for both of you and me.
   
 If you're ever looking for support, I can be reached at the following:
 ╔═════════════════════════════════════════════╗
 ║       http://www.rpgmakervxace.net/         ║
 ╚═════════════════════════════════════════════╝
 pm me : Estriole.
  
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
    This script is the execution phase of the series... you assign master map, event id
 to database item. so when used it will copy that event to current map. with this
 combination of scripts. you can create your decor / build system. with more
 modification this could even transform to farming system.

 ■ Features         ╒═════════════════════════════════════════════════════════╛
 * Decorate room
 * Build Building
 * Use item to show what Decoration/Building the party has...
 * Multiple 'Master Map' so you can put master event by category (ex: Building Map, Decoration Map, etc)
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.05.29           Initial Release
 v1.1 2013.10.10           add on_top_any? method for decoration on top others
 v1.2 2014.01.02           fix the size did not delete when deleting events.
 
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 Compatible with most script.
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 1) Create Master Map...
 master map is where you put event that will be copied... you can create more than
 one master map. ex: Building List Map, Decoration List Map, etc.
 the master map id will later referenced inside the ITEM notebox
 
 2) Create the Master Event
 in master map create the event that you want to be copied...
 all the behavior you want must be put in the event...
 the event id will later referenced inside the ITEM notebox
 
 3) Create the "ITEM"
 the item must be ITEM (not weapon or armor). it's up to you to set it as Key Item or not...
 then you must gave this notetags:
 below notetags is REQUIRED:
 <decor_map: x>
 <decor_id: y>
 <decor_type: z>
 x-> map id where you want the copied event from
 y-> event id where you want to copy
 z-> decoration type. must not contain spaces. if you want to contain space put it inside ""
 example
 <decor_map: 3>
 <decor_id: 7>
 <decor_type: "Wall Painting">
 it will copy event from map 3 id 7. and will be listed only in Wall Painting 
 decor select call (explanation in next step)
 
 below notetags is OPTIONAL:
 <decor_xmod: x>
 <decor_ymod: y>
 x -> it will shift the new event place(x) from the calling event
 y -> it will shift the new event place(y) from the calling event
 (both neccessary when working with building)
 
 CURRENTLY THERE IS TWO WAY HOW YOU DESIGN THE DECORATION SCENE
 1) Create the Event that can be replaced with other event (Building/Furniture Spot)
 (we can called that item MASTER ITEM)
 give it script call:
 decor_select("x")
 x-> category you set in item notebox

 +>to remove the decoration/building item. 
 you could use create choice like "Check", "Remove". when selecting remove. 
 put Script call:
 
 remove_decoration
 
 then add the 'item' back to inventory using event command after that.
 (see demo if you don't understand)
 
 +>you could also make it revert back to the MASTER ITEM. script call:
 
 remove_decoration(map_id,master_event_id)
 
 it will revert that decoration back to MASTER ITEM 
 
 +>also IF you modify the place before (decor_modx or decor_mody) you can revert it back too...
 
 remove_decoration(map_id,master_event_id,modx,mody)
 
 put the negative value of what you set in the database to revert it back to where
 it should belong. you can look the demo how i create my item shop.

 2) Set where you push certain button you enter build mode.
 you need these scripts: 
 -Yanfly Button Common Event
 -Yanfly Stop All Movement
 -EST - DECOR MOVEMENT
 
 first set the switch you want to use to stop the player.
 second set the common event id you want to use.
 third create the common event.
 
 you could custom what you want in yours. in mine i do it like this:
 - when pressing s. it will enter build/decor mode.
 - then i do conditional check if the map is allowed to place decoration. (currently using switch)
   later might use notetags in map.
 - if above yes... show choice:
    > place furniture > decor_select("moveable_furniture")
    > place beds > decor_select("beds")
   (just example i use in demo. basically it show we can choose item by category)
 then in the event in master map...
 first page must be set as parallel process. in that page put event command
 Set Single File Member
 Define Movement Route(this event)(wait)change_speed: 4
 Script call: decor_move
 then create the second page which is the actual EVENT with condition SELFSWITCH A is ON.
 
 
 GUIDE ON CREATING BUILDING EVENT
 you need to understand on how charset works.
 by default 1 tiles = 32x32.
 by default charset sized = 3x4 tiles.
 you could make larger charset by adding $ in front of the file name as long
 the proportion is the same. you could change 1 tiles to 7x7 tiles for example.
 
 what you should know...
 event trigger at the bottom center of the graphic. so if it's 3x7 tiles image.
 xxxxxxx
 xxxxxxx
 xxxoxxx
 it will trigger at o.

 so you have to make sure your 'door' is at o. if not you might want to enlarge
 the size and place it until the door at the center.
 
 too bad that we cannot make building face left/right/up using this method >.<.
 
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 This is part of the EST - DECOR AND BUILD SERIES.

=end


$imported = {} if $imported.nil?
$imported["EST - DECOR AND BUILD"] = true

module ESTRIOLE
  module DECOR
    ITEM_SEL_VAR = 1
  end
end

#patch for decoration on top another decoration
class Game_Interpreter
  def any_event_on_top?
    $game_map.events.each_value do |event|
    next if event.id == @event_id
    return true if event.x == $game_map.events[@event_id].x && 
    event.y == $game_map.events[@event_id].y
    end
    return false
  end
end

class Game_Interpreter
  include ESTRIOLE::DECOR
  def decor_select(type=nil,delete=true, pos_fix = [nil,nil])
    type = [type] if type && type.is_a?(String)
    decor_init_var
    $game_party.decor_type = type
    @params = [ITEM_SEL_VAR]
    command_104
    $game_party.saving_status = $game_system.menu_disabled
    add_decoration(0, delete, pos_fix)
    $game_party.decor_type = nil
  end
  
  def add_decoration(mastermap = 0, delete = true, pos_fix = [nil,nil])
    return if $game_variables[ITEM_SEL_VAR] == 0
    x = $game_map.events[@event_id].x rescue $game_player.x
    y = $game_map.events[@event_id].y rescue $game_player.y
    id = $game_variables[ITEM_SEL_VAR]
    mastermap = $data_items[id].decor_map if $data_items[id].decor_map    

    event_id = check_decor_item_id
    
    return if mastermap == 0
    return if !event_id
    xmod = $data_items[id].decor_xmod if $data_items[id].decor_xmod 
    ymod = $data_items[id].decor_ymod if $data_items[id].decor_ymod 
    x += xmod if xmod
    y += ymod if ymod
    x = pos_fix[0] if pos_fix[0]
    y = pos_fix[1] if pos_fix[1]
    delete_this_event if delete
    $game_map.add_event(mastermap, event_id, x, y)
    reduce_item_decor(1)
  end

  def delete_this_event
    $game_map.events[@event_id].decor_remove_size if $imported["EST - EVENT SIZE"] == true
    $game_map.delete_event(@event_id)    
  end
  
  def remove_decoration(mastermap = 0, masteritem = 0, xmod = 0, ymod = 0)
    x = $game_map.events[@event_id].x + xmod
    y = $game_map.events[@event_id].y + ymod
    item = masteritem
    delete_this_event
    return if mastermap == 0
    return if masteritem == 0
    $game_map.add_event(mastermap, item, x, y)    
  end

  def check_decor_item_id
    return nil if $game_variables[ITEM_SEL_VAR] == 0
    a = $game_variables[ITEM_SEL_VAR]
    return b = $data_items[a].decor_id
  end
  def reduce_item_decor(number)
    return if $game_variables[ITEM_SEL_VAR] == 0
     a = $game_variables[ITEM_SEL_VAR]
     $game_party.lose_item($data_items[a], number)    
  end    
  # init the variable used in item selection
  def decor_init_var
  $game_variables[ITEM_SEL_VAR] = 0
  end
  def rescue_player_stuck(offset_x=0,offset_y=0)
  #place player where it won't stuck from event
  eventx = $game_map.events[@event_id].x
  eventy = $game_map.events[@event_id].y
  $game_player.moveto(eventx+offset_x , eventy+offset_y)
  end
end

class RPG::Item < RPG::UsableItem
  def decor_type
    return nil if !note[/<decor_type:(.*)>/i]
    a = note[/<decor_type:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0]
  end
  def decor_id
    return nil if !@note[/<decor_id:(.*)>/i]
    a = note[/<decor_id:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_i
  end
  def decor_xmod
    return nil if !@note[/<decor_xmod:(.*)>/i]
    a = note[/<decor_xmod:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_i
  end
  def decor_ymod
    return nil if !@note[/<decor_ymod:(.*)>/i]
    a = note[/<decor_ymod:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_i    
  end
  def decor_map
    return nil if !@note[/<decor_map:(.*)>/i]
    a = note[/<decor_map:(.*)>/i].scan(/:(.*)/).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    return noteargs = a[0].to_i    
  end
end

class Game_Party < Game_Unit
  attr_accessor :decor_type
  attr_accessor :saving_status
end

class Window_KeyItem < Window_ItemList
  alias est_decor_and_build_include? include?
  def include?(item)
    if $game_party.decor_type
    
    return true if item.is_a?(RPG::Item) && item.decor_type && 
                    $game_party.decor_type.any? {|type|type.is_a?(String) && type.upcase == item.decor_type.upcase}
    return false
    end
    return est_decor_and_build_include?(item)
  end
  def enable?(item)
    return true
  end
end
=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - COPY EVENT v1.5
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
    This script make we able to copy event from other map to current map. it will
 save that event in save files.
 ■ Features         ╒═════════════════════════════════════════════════════════╛
 * copy event
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.05.29           Initial Release
 v1.1 2013.06.07     - add method to save current map events.
 v1.2 2013.06.30     - f12 bugfix
 v1.3 2014.01.09     - khas light script compatibility
 v1.4 2014.07.01     - bugfix to make this script can used stand alone.
 v1.5 2015.02.10     - bugfix when exiting the game then load savefile then
                       exiting map then reenter map... event disappear
 
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 Compatible with most script.
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 $game_map.add_event(mastermap, event_id, x, y)
 #mastermap -> id of the map that the copied event from
 # event_id -> id of the copied event
 #        x -> where the new event placed (x)
 #        y -> where the new event placed (y)
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 This is part of the EST - DECOR AND BUILD SERIES.

=end

$imported = {} if $imported.nil?
$imported["EST - COPY EVENT"] = true


#this init $resaved_maps for the first time
$resaved_maps = {} if $resaved_maps.nil?

class Game_Map
  alias est_event_new_setup setup
  def setup(map_id)
    est_event_new_setup(map_id)
    if $resaved_maps.include?(@map_id)
      @events = $resaved_maps[@map_id]      
      $game_map.refresh
    end
  end
  def save_map_events
  $resaved_maps[@map_id] = @events #save the map     
  end
  def next_event_id
  idlist= [] #init new array to store only the numbers not game_event object
  @events.each_key {|key| idlist.push(key)} 
  betweenid = (1..idlist.max).to_a - idlist
  #this store the blank between 1 and max [3,4,6,7] means this = [1,2,5]
    if betweenid.size >0
    next_id = betweenid[0] #use the first between id if exist
    else #if between not exist
    next_id = idlist.max + 1 #get the maximum id and increment it by 1
    end
  return next_id
  end
  def save_current_map
  $resaved_maps[@map_id] = @events #save the map 
  end
  #--------------------------------------------------------------------------
  # ● Adds an event from another map to the current map
  #--------------------------------------------------------------------------
  def add_event(mapid, eventid, x, y)
	map = load_data(sprintf("Data/Map%03d.rvdata2", mapid))
  new_event = map.events[eventid].dup
  new_event.id = next_event_id
  new_event.x = x
  new_event.y = y
	e = Game_Event.new(@map_id, new_event)
#	e.moveto(x,y)
	@events[e.id] = e
  save_current_map
  SceneManager.scene.refresh_characters
  return e.id
  end

  def delete_event(id)
    chk = @events[id].decor_remove_size rescue nil
    @events.delete(id)
    $resaved_maps[@map_id] = @events  
    SceneManager.scene.refresh_characters
  end

  def delete_batch_event(range)
    delete_list = range.to_a
    for i in 0..delete_list.size
    chk = @events[delete_list[i]].decor_remove_size rescue nil
    @events.delete(delete_list[i]) rescue nil
    end
    $resaved_maps[@map_id] = @events  
    SceneManager.scene.refresh_characters
  end
  
end

class Game_Event < Game_Character
  attr_accessor :event
  attr_accessor :id
end
class Scene_Map < Scene_Base
	def refresh_characters
		@spriteset.refresh_characters
	end
end

# to fix f12 problem and/or loading in game
class Scene_Load < Scene_File
  alias est_copy_event_on_load_success on_load_success
  def on_load_success
    $resaved_maps = {} if !$resaved_maps
    est_copy_event_on_load_success
  end
end

class Scene_Title < Scene_Base
  alias est_copy_event_start start
  def start
    $resaved_maps ||= {}
    est_copy_event_start
  end
end

#module data manager to save the resaved map
module DataManager
  
  class << self
    alias est_clone_event_make_save_contents make_save_contents
    alias est_clone_event_extract_save_contents extract_save_contents
  end
    
  def self.make_save_contents
    contents = est_clone_event_make_save_contents
    contents = contents.merge(make_resaved_map_contents)
    contents
  end
  
  def self.make_resaved_map_contents
    contents = {}
    contents[:resaved_maps]	       =	$resaved_maps
    contents
  end
  
  def self.extract_save_contents(contents)
    est_clone_event_extract_save_contents(contents)
    extract_resaved_map_contents(contents)
  end
  
  def self.extract_resaved_map_contents(contents)
    $resaved_maps         = contents[:resaved_maps]
  end
  
end

#compatibility patch with khas lightning effect
chk = Light_Core rescue false
if chk
  class Game_Map
    alias khas_compatibility_est_event_new_setup setup    
    def setup(map_id)
      khas_compatibility_est_event_new_setup(map_id)
        @events.each_value do |ev|
          ev.setup_light(true)
        end
      $game_map.refresh
    end
    alias est_copy_event_khas_comp_delete_event delete_event
    def delete_event(id)
      return if !@events[id]
      @events[id].dispose_light
      est_copy_event_khas_comp_delete_event(id)
    end    
  end 
  class Game_Event
    def dispose_light
      @light.dispose if @light
    end
    def draw_light
      sx = @light.sx
      sy = @light.sy
      w = @light.w
      h = @light.h
      return if sx > Graphics.width && sy > Graphics.height && sx + w < 0 && sy + h < 0
      $game_map.light_surface.bitmap.blt(sx,sy,@light.bitmap,Rect.new(0,0,w,h),@light.opacity) if @light.bitmap
    end
  end
end
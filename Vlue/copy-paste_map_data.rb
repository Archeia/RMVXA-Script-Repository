#Copy/Paste Map Data v1.2
#----------#
#Features: Let's you copy and paste portions of one map to another! Fancy!
#           And copy events around too!
#
#Usage:   map_copy("map_id",x,y,width,height)
#
#          Where... map_id is the id of the map as a string (including 0's!)
#          For example, map 1 is "001", map 24 is "024" and map 987 is "987"
#          And x, y are the starting point and width/heigth define the size
#          to copy
#
#         map_paste(x,y,layer1,layer2,layer3,shadow - optional)
#         map_paste_ex(id,x,y,layer1,layer2,layer3,shadow - optional)
#
#          Where... x, y are the starting points to paste to and layer1, layer2,
#          and layer3 are which layers to copy (true/false form)
#
#         event_copy(map_id,event_id,x,y)
#        
#          Where... actually I probably don't really need to explain this.
#          You know what, just in case. Map_id is the map with the event you
#          want to copy, event_id is the event you want to copy, and x,y is where
#          you want to paste the event to in the current map!
#
#Examples:
#     map_copy("024",5,5,10,7)
#     map_paste(0,0,true,true,false)
#     event_copy(1,3,5,6)
#
#      This would copy a 10*7 portion from map 24 starting at 5,5 and then paste
#       it into the current map at 0,0 but only layer 1 and layer 2
#     (The layers as far as I recall are.. ground, path, anything from B-E)
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
class Game_Party
  attr_accessor  :saved_maps
  attr_accessor  :saved_events
end
 
class Game_Interpreter
  def map_copy(map_id,x,y,w,h)
    $game_map.copy_portion(map_id,x,y,w,h)
  end
  def map_paste(x,y,l1,l2,l3,sh = false)
    $game_map.paste_portion(x,y,l1,l2,l3,sh)
  end
  def map_paste_ex(id,x,y,l1,l2,l3,sh = false)
    $game_map.paste_portion_ex(id,x,y,l1,l2,l3,sh)
  end
  def event_copy(map,event,x,y)
    $game_map.copy_event(map,event,x,y)
  end
end
 
class Game_Event
  alias sc_initialize initialize
  def initialize(*args)
    sc_initialize(*args)
    @origin = [@event.x,@event.y]
  end
  def reset_event
    moveto(@origin[0],@origin[1])
    @page = nil
    refresh
  end
  def change_id(id)
    @id = @event.id = id
  end
end
 
class Scene_Map
  def refresh_spriteset
    @spriteset.dispose_characters
    @spriteset.create_characters
  end
end
 
class Game_Map
  alias sc_setup setup
  def setup(id)
    sc_setup(id)
    load_map(id)
    load_events(id)
  end
  def copy_portion(map_id,x,y,w,h)
    map = load_data("Data/Map" + map_id + ".rvdata2")
    @copy_hash = {};kx = 0;ky = 0;@w = w;@h = h;ox = x
    (w*h).times do |i|
      @copy_hash[[kx,ky,0]] = map.data[x,y,0]
      @copy_hash[[kx,ky,1]] = map.data[x,y,1]
      @copy_hash[[kx,ky,2]] = map.data[x,y,2]
      @copy_hash[[kx,ky,3]] = map.data[x,y,3]
      kx += 1;x += 1
      if kx > w - 1
        x = ox;kx = 0;y += 1; ky += 1
      end
    end
  end
  def paste_portion(x,y,l1,l2,l3,sh)
    return unless @copy_hash
    kx = 0;ky = 0;ox = x;oy = y
    (@w*@h).times do |i|
      @map.data[x,y,0] = @copy_hash[[kx,ky,0]] if l1
      @map.data[x,y,1] = @copy_hash[[kx,ky,1]] if l2
      @map.data[x,y,2] = @copy_hash[[kx,ky,2]] if l3
      @map.data[x,y,3] = @copy_hash[[kx,ky,3]] if sh
      kx += 1;x += 1
      if kx > @w - 1
        x = ox;kx = 0;y += 1; ky += 1
      end
    end
    if Game_Map.instance_methods(false).include?(:update_autotile)
      kx = 0;ky = 0;x = ox;y = oy
      (@w*@h).times do |i|
        update_autotile(x,y,0)
        update_autotile(x,y,1)
        kx += 1;x += 1
        if kx > @w - 1
          x = ox;kx = 0;y += 1; ky += 1
        end
      end
    end
    save_map(@map_id)
  end
  def paste_portion_ex(id,x,y,l1,l2,l3,sh)
    if @map_id == id
      paste_portion(x,y,l1,l2,l3,sh)
    else
      ex_map = Game_Map.new
      ex_map.setup(id)
      ex_map.set_copy_hash(@copy_hash,@w,@h)
      ex_map.paste_portion(x,y,l1,l2,l3,sh)
    end
  end
  def set_copy_hash(hash,sw,sh)
    @copy_hash = hash
    @w = sw
    @h = sh
  end
  def copy_event(map_id, event_id, x, y)
    begin
      if map_id == @map_id
        event = @map.events[event_id]
      else
        map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
        event = map.events[event_id]
      end
    rescue
      event = nil
    end
    return if event.nil?
    i = 500
    while @events.has_key?(i)
      i += 1
    end
    event.x = x;event.y = y
    @events[i] = Game_Event.new(@map_id,event)
    @events[i].change_id(i)
    SceneManager.scene.refresh_spriteset
    save_events(@map_id)
  end
  def save_events(id)
    $game_party.saved_events = {} if $game_party.saved_events.nil?
    $game_party.saved_events[id] = @events
  end
  def save_map(id)
    $game_party.saved_maps = {} if $game_party.saved_maps.nil?
    $game_party.saved_maps[id] = @map.data
  end
  def load_events(id)
    return if $game_party.saved_events.nil?
    return if !$game_party.saved_events.include?(id)
    @events = $game_party.saved_events[id]
    @events.each do |i,event|
      event.reset_event
    end
  end
  def load_map(id)
    return if $game_party.saved_maps.nil?
    return if !$game_party.saved_maps.include?(id)
    @map.data = $game_party.saved_maps[id]
  end
end
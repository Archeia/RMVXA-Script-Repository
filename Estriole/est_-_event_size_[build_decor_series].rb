=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - EVENT SIZE v1.6
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
    This script add size to event. now we can have Large event like building, etc.
 When building is made from event... we can animate it...

 ■ Features         ╒═════════════════════════════════════════════════════════╛
 * Large event
 * Compatibility with Victor Pixel Movement (Also LOTS BUGFIX to that script too...)
 * Compatibility with new JET Mouse Script if you're not using Victor Pixel Movement.
 * Different size each event PAGE
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.05.29           Initial Release
 v1.1 2013.06.07    - improved regexp to recognize multi line. 
                    - add extra size feature (in case you want more than box size)
                     format:
                     <extra_fixed_size: [x1,y1], [x2,y2], [x3,y3]>
                     it will make the map coordinate [x1,y1] unpassable
                     it will make the map coordinate [x2,y2] unpassable
                     it will make the map coordinate [x3,y3] unpassable
                     <extra_dynamic_size: [x1,y1], [x2,y2], [x3,y3]">
                     it will make the map coordinate [eventx + x1,eventy + y1] unpassable
                     it will make the map coordinate [eventx + x2,eventy + y2] unpassable
                     it will make the map coordinate [eventx + x3,eventy + y3] unpassable
                    - add size trigger feature (so all the event size trigger the event)
                    - add extra trigger feature (if you want the size for the size but still 
                     want extra trigger)(example house with two doors...)
                     format:
                     <extra_fixed_trigger: [x1,y1], [x2,y2], [x3,y3]>
                     it will make the map coordinate [x1,y1] trigger the event
                     it will make the map coordinate [x2,y2] trigger the event
                     it will make the map coordinate [x3,y3] trigger the event
                     <extra_dynamic_trigger: [x1,y1], [x2,y2], [x3,y3]>
                     it will make the map coordinate [eventx + x1,eventy + y1] trigger the event
                     it will make the map coordinate [eventx + x2,eventy + y2] trigger the event
                     it will make the map coordinate [eventx + x3,eventy + y3] trigger the event
                     - add compatibility with new JET Mouse Script
                     the jet script is this one: http://www.rpgmakervxace.net/topic/14756-mouse-system/
                     WARNING this script cannot compatible with both mouse and pixel movement.
                     so if you use VICTOR pixel movement. don't use JET mouse
                     vice versa. I tried but apparently it's hard.
                     (this update is for making point and click game)
 v1.2 2013.06.10    - size update when moving event... (fixed size still the same)
                    - dynamic trigger update when moving event... (fixed trigger still the same)
 v1.3 2013.08.11    - fix event with size trigger or extra trigger cannot move because
                      blocked by their own size.
                    - now event with size will move considering it's size.
                      if when moved... it's size collide another event/player. 
                      it won't move then. for more realistic big event movement.
                      but this feature not to compatible with pixel movement.
 v1.4 2014.01.01    - happy new year... correct a typo in extra_fixed_trigger notetags
 v1.5 2014.01.09    - fix some instruction. add exclude trigger feature
                      format:
                     <exclude_fixed_trigger: [x1,y1], [x2,y2], [x3,y3]>
                     it will make the map coordinate [x1,y1] WILL NOT trigger the event
                     it will make the map coordinate [x2,y2] WILL NOT trigger the event
                     it will make the map coordinate [x3,y3] WILL NOT trigger the event
                     <exclude_dynamic_trigger: [x1,y1], [x2,y2], [x3,y3]>
                     it will make the map coordinate [eventx + x1,eventy + y1] WILL NOT trigger the event
                     it will make the map coordinate [eventx + x2,eventy + y2] WILL NOT trigger the event
                     it will make the map coordinate [eventx + x3,eventy + y3] WILL NOT trigger the event
                     this is useful if you want to create building that faced other than bottom.
 v1.6 2015.03.29    - fix size didn't trigger when set to 'event touch' event you set it to trigger using notetags
                    - default code bugfix for direction fix that didn't trigger 'event touch'
                      
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 Compatible with most script. Put this below VE - Pixel Movement script if using it.
 Put this below new JET MOUSE SCRIPT if using it.
 CANNOT USE BOTH VE - Pixel Movement + JET MOUSE SCRIPT. it conflict each other.
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 Give comment to event page:
 <event_size: a, b, c, d>
 a = top, b = left, c = right, d = down
 example: <event_size:1, 2, 1, 0>
 will make event size like this:
 
 xxxx
 xxox
 
 x-> size, o->event
 the event size WILL always shape like rectangle/square...
 the event size cannot be pass by player (unless through)
 it's best to set the event priority to same as character... (you'll see in demo)
 
 
 more trigger and size comment notetags feature:
 <size_trigger>
   it will make all event size trigger that event
   
 <extra_fixed_size: [x1,y1], [x2,y2], [x3,y3]>
   it will make the map coordinate [x1,y1] unpassable
   it will make the map coordinate [x2,y2] unpassable
   it will make the map coordinate [x3,y3] unpassable
 <extra_dynamic_size: [x1,y1], [x2,y2], [x3,y3]>
   it will make the map coordinate [eventx + x1,eventy + y1] unpassable
   it will make the map coordinate [eventx + x2,eventy + y2] unpassable
   it will make the map coordinate [eventx + x3,eventy + y3] unpassable
   
 <extra_fixed_trigger: [x1,y1], [x2,y2], [x3,y3]>
   it will make the map coordinate [x1,y1] trigger the event
   it will make the map coordinate [x2,y2] trigger the event
   it will make the map coordinate [x3,y3] trigger the event
 <extra_dynamic_trigger: [x1,y1], [x2,y2], [x3,y3]>
   it will make the map coordinate [eventx + x1,eventy + y1] trigger the event
   it will make the map coordinate [eventx + x2,eventy + y2] trigger the event
   it will make the map coordinate [eventx + x3,eventy + y3] trigger the event

 <exclude_fixed_trigger: [x1,y1], [x2,y2], [x3,y3]>
   it will make the map coordinate [x1,y1] WILL NOT trigger the event
   it will make the map coordinate [x2,y2] WILL NOT trigger the event
   it will make the map coordinate [x3,y3] WILL NOT trigger the event
 <exclude_dynamic_trigger: [x1,y1], [x2,y2], [x3,y3]>
   it will make the map coordinate [eventx + x1,eventy + y1] WILL NOT trigger the event
   it will make the map coordinate [eventx + x2,eventy + y2] WILL NOT trigger the event
   it will make the map coordinate [eventx + x3,eventy + y3] WILL NOT trigger the event
   
 some script call to use in conditional branch:
 
 any_event_on_top?
 > it will check if any event on top of the current event and it's size.
 it will return true if there's event on top of it
 it will return false if there's no event on top of it
 use this for your table / some event that can have other event placed above it)
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 This is part of the EST - DECOR AND BUILD SERIES.

=end

$imported = {} if $imported.nil?
$imported["EST - EVENT SIZE"] = true

$custom_passage_maps = {} if $custom_passage_maps.nil?
class Game_CharacterBase
  def check_events_size(x,y)
    $custom_passage_maps[$game_map.map_id] = {} if !$custom_passage_maps[$game_map.map_id]
    $custom_passage_maps[$game_map.map_id].each{|key,val|
      if $imported[:ve_pixel_movement]
        val.each do |pos|
        return val if x > pos[0]-1 && x < pos[0]+1 && y > pos[1]-1 && y < pos[1]+1 && key != self.id
        end
      else
      return val if val.include?([x,y]) && key != self.id
      end
    }
    return false
  end    
  
  alias est_event_size_collide_with_events? collide_with_events?
  def collide_with_events?(x, y)
    return true if check_events_size(x,y)
    est_event_size_collide_with_events?(x, y) && check_collide_with_own_size?(x,y) 
  end
    
  #method to check if the collide event is it's own size...
  def check_collide_with_own_size?(x,y)
    $game_map.events_xy_nt(x, y).any? do |event|
      event != self
    end
  end
  alias est_event_size_passable? passable?
  def passable?(x, y, d)
    return est_event_size_passable?(x, y, d) if !self.is_a?(Game_Event)
    return est_event_size_passable?(x, y, d) if !size_list
    size_list.each{|val|
        x2 = $game_map.round_x_with_direction(val[0], d)
        y2 = $game_map.round_y_with_direction(val[1], d)
        return false if !$game_map.valid?(x2, y2)
        return true if @through || debug_through?
        return false if !map_passable?(x, y, d)
        return false if !map_passable?(x2, y2, reverse_dir(d))
        return false if collide_with_characters?(x2, y2)
    }
    return est_event_size_passable?(x, y, d)
  end

  #victor patch
  def side_collision_fix?(x, y, d, d2, t)
    character_collision?(x, y, d)
  end 
  if $imported[:ve_pixel_movement]
  #airship fix alternate...
  alias est_ev_size_setup_movement setup_movement
    def setup_movement(horz, vert)
      chkx = $game_map.round_x_with_direction(@x, horz)
      chky = $game_map.round_y_with_direction(@y, horz)
      set_direction(horz) if @direction == reverse_dir(horz) || horz == vert
      set_direction(vert) if @direction == reverse_dir(vert) && horz != vert
      return if chkx > $game_map.width-1
      return if chky > $game_map.height-1
      est_ev_size_setup_movement(horz,vert)
    end
  #change graphic collision only to one which tagged with comment
    def collision_condition?(x, y, bw, bh, event, event_id, side)
      return false if event && self.id == event_id
      return false unless collision?(x, y, bw, bh)
      return false unless normal_priority? || event
      return false if side && !side_collision?
      return true if self.graphic_collision
      return false unless x > self.x-1 && x < self.x+1 && y > self.y-1 && y < self.y+1
      return true
    end
  end#end if import
end#end class game character base

class Game_Character < Game_CharacterBase
  if $imported[:ve_diagonal_move] && $imported[:ve_diagonal_move] > 1.06
    def update_move_straight
      update_move_straight_ve_diagonal_move
      return if !@move_value
      diagonal_move_fix(@move_value[:d].first) if player? && !@moved
    end
    def update_move_diagonal
      update_move_diagonal_ve_diagonal_move
      return if !@move_value
      if player? && !@moved
        d = 1 if @move_value[:d] == [4, 2]
        d = 3 if @move_value[:d] == [6, 2]
        d = 7 if @move_value[:d] == [4, 8]
        d = 9 if @move_value[:d] == [6, 8]
        diagonal_move_fix(d)
      end
    end
  end
end

class Game_Player < Game_Character
  attr_reader :direction
  def check_event_contiontion(x, y, event, triggers, normal)
    passable = passable_tile?(@x, @y, @direction)
    w = (counter_tile? || !passable) ? 1.0 : bw
    h = (counter_tile? || !passable) ? 1.0 : bh
    return false unless event.trigger_in?(triggers)
    return false unless passable || event.over_tile? || counter_tile?
    return false unless event.collision?(x, y, w, h) || !jumping?
    return false unless !event.in_front? || front_collision?(x, y, @direction)
    return true  if event.graphic_collision && gc_chk_dir(event)
    return default_collosion(x,y,event)
  end
  def gc_chk_dir_size_trigger(val)
    val.each do |pos|
      case @direction
        when 2 #down
        return true if @y <= pos[1] && pos[1] <= @y+1 && @x > pos[0]-1 && @x < pos[0]+1
        when 4 #left
        return true if @x >= pos[0] && pos[0] >= @x-1 && @y > pos[1]-1 && @y < pos[1]+1
        when 6 #right
        return true if @x <= pos[0] && pos[0] <= @x+1 && @y > pos[1]-1 && @y < pos[1]+1
        when 8 #up
        return true if @y >= pos[1] && pos[1] >= @y-1 && @x > pos[0]-1 && @x < pos[0]+1
      end
    end
    return false
  end
  
  def gc_chk_dir(event)
    case @direction
    when 2 #down
      return true if @y <= event.y && @x > event.x-1 && @x < event.x+1
    when 4 #left
      return true if @x >= event.x && @y > event.y-1 && @y < event.y+1
    when 6 #right
      return true if @x <= event.x && @y > event.y-1 && @y < event.y+1
    when 8 #up
      return true if @y >= event.y  && @x > event.x-1 && @x < event.x+1
    end
    return false
  end
  
  def default_collosion(x,y,event)
    return true if x > event.x-1 && x < event.x+1 && y > event.y-1 && y < event.y+1
    return true if event.size_trigger_check(x,y) && gc_chk_dir_size_trigger(event.size_list)
    return true if event.extra_trigger_check(x,y) && gc_chk_dir_size_trigger(event.extra_trigger)
    return false
  end  
end

class Game_Event < Game_Character
  attr_reader :graphic_collision
  attr_reader :through
  
  def note
    return "" if !@page || !@page.list || @page.list.size <= 0
    comment_list = []
    @page.list.each do |item|
      next unless item && (item.code == 108 || item.code == 408)
      comment_list.push(item.parameters[0])
    end
    comment_list.join("\r\n")
  end  

  alias setup_page_settings_est_event_size setup_page_settings
  def setup_page_settings
    setup_page_settings_est_event_size
    @graphic_collision = note =~ /<GRAPHIC COLLISION>/i   ? true : false    
    set_event_size_and_triggers
  end
  
  def set_event_size_and_triggers
    return if !esize && extra_fixed_size == [] && extra_dynamic_size == []
    decor_remove_size(self)
    top = esize[0].to_i rescue 0
    left = esize[1].to_i rescue 0 
    right = esize[2].to_i rescue 0
    down = esize[3].to_i rescue 0
    decor_add_size(top,left,right,down) if esize
    extra_fixed_size.each do |size|
      decor_change_passability(size[0],size[1])
    end
    extra_dynamic_size.each do |size|
      decor_change_passability(self.x+size[0],self.y+size[1])
    end
  end
  
  #size update patch
  alias est_decor_size_move_straight move_straight
  def move_straight(d, turn_ok = true)
    est_decor_size_move_straight(d, turn_ok = true)
    set_event_size_and_triggers
  end
  alias est_decor_size_move_diagonal move_diagonal
  def move_diagonal(horz, vert)
    est_decor_size_move_diagonal(horz, vert)
    set_event_size_and_triggers    
  end
  alias est_decor_size_moveto moveto
  def moveto(x, y)
    est_decor_size_moveto(x, y)
    set_event_size_and_triggers    
  end  
  
  def esize
    return nil if !note[/<event_size:([^>]*)>/im]
    a = note[/<event_size:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a    
  end
    
  def extra_fixed_size
    return [] if !note[/<extra_fixed_size:([^>]*)>/im]
    a = note[/<extra_fixed_size:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| eval("[#{x}]")}
    return noteargs = a    
  end
  def extra_dynamic_size
    return [] if !note[/<extra_dynamic_size:([^>]*)>/im]
    a = note[/<extra_dynamic_size:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| eval("[#{x}]")}
    return noteargs = a    
  end  
  def size_trigger
    return false if !note[/<size_trigger>/im]
    return true if note[/<size_trigger>/im]
  end
  def size_list
    a = $custom_passage_maps[@map_id][@id] rescue []
  end

  def extra_fixed_trigger
    return [] if !note[/<extra_fixed_trigger:([^>]*)>/im]
    a = note[/<extra_fixed_trigger:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| eval("[#{x}]")}
    return noteargs = a        
  end
  def extra_dynamic_trigger
    return [] if !note[/<extra_dynamic_trigger:([^>]*)>/im]
    a = note[/<extra_dynamic_trigger:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| eval("[#{x}]")}
    a.collect!{|x| [self.x + x[0], self.y + x[1]] }
    return noteargs = a        
  end
  def extra_trigger
    a = extra_fixed_trigger + extra_dynamic_trigger rescue []
  end  

  def exclude_fixed_trigger
    return [] if !note[/<exclude_fixed_trigger:([^>]*)>/im]
    a = note[/<exclude_fixed_trigger:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| eval("[#{x}]")}
    return noteargs = a        
  end
  def exclude_dynamic_trigger
    return [] if !note[/<exclude_dynamic_trigger:([^>]*)>/im]
    a = note[/<exclude_dynamic_trigger:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| eval("[#{x}]")}
    a.collect!{|x| [self.x + x[0], self.y + x[1]] }
    return noteargs = a        
  end
  def exclude_trigger
    a = exclude_fixed_trigger + exclude_dynamic_trigger rescue []
  end  
  
  
  def check_pixel_list(val,x,y)
    val.each do |pos|
    return true if x > pos[0]-1 && x < pos[0]+1 && y > pos[1]-1 && y < pos[1]+1
    end
  end
  
  def size_trigger_check(x,y)
     if $imported[:ve_pixel_movement]    
     size_trigger && check_pixel_list(size_list,x,y)  
     else
     size_trigger && size_list.include?([x,y]) if size_list
     end
  end
  def extra_trigger_check(x,y)
    if $imported[:ve_pixel_movement]    
    check_pixel_list(extra_trigger,x,y)    
    else
    extra_trigger.include?([x,y])
    end
  end
  def exclude_trigger_check(x,y)
    if $imported[:ve_pixel_movement]    
    check_pixel_list(exclude_trigger,x,y)    
    else
    exclude_trigger.include?([x,y])
    end
  end
    
  def decor_change_passability(x,y,passability = true)
    $custom_passage_maps[$game_map.map_id] = {} if !$custom_passage_maps[$game_map.map_id]
    $custom_passage_maps[$game_map.map_id][self.id] = [] if !$custom_passage_maps[$game_map.map_id][self.id]
    $custom_passage_maps[$game_map.map_id][self.id].push([x,y]).uniq!
  end #end decor change pass
  
  def decor_remove_passability(event = self)
    $custom_passage_maps[$game_map.map_id] = {} if !$custom_passage_maps[$game_map.map_id]
    $custom_passage_maps[$game_map.map_id].delete(event.id)
  end
  
  def decor_add_size(top = 0, left = 0, right = 0, down = 0)
  return if top < 1 && left < 1 && right < 1 && down < 1
  event_x = self.x
  event_y = self.y
  if top > 0
    for i in 1..top
    decor_change_passability(event_x,event_y - i,false)
    end
  end  

  if down > 0
    for i in 1..down
    decor_change_passability(event_x,event_y + i,false)
    end
  end
  
  if left > 0
    for i in 1..left
    decor_change_passability(event_x-i,event_y,false)
    end
    if top >0
      for i in 1..left
        for j in 1..top
        decor_change_passability(event_x-i,event_y-j,false)
        end
      end
    end
    if down >0
      for i in 1..left
        for j in 1..down
        decor_change_passability(event_x-i,event_y+j,false)
        end
      end
    end
  end

  if right > 0 
    for i in 1..right
    decor_change_passability(event_x+i,event_y,false)
    end    
    if top >0
      for i in 1..right
        for j in 1..top
        decor_change_passability(event_x+i,event_y-j,false)
        end
      end
    end
    if down >0
      for i in 1..right
        for j in 1..down
        decor_change_passability(event_x+i,event_y+j,false)
        end
      end
    end
  end
    
  end #end decor add size

  def decor_remove_size(top = 0, left = 0, right = 0)
  decor_remove_passability(self)    
  end #end decor add size

end

class Game_Map
  def events_xy(x, y)
    @events.values.select {|event| 
    !event.exclude_trigger_check(x,y) &&
    (event.pos?(x, y) || event.size_trigger_check(x,y) || event.extra_trigger_check(x,y))
    }
  end
  def events_xy_nt(x, y)
    @events.values.select {|event| 
    !event.through && 
    !event.exclude_trigger_check(x,y) &&    
    (event.pos_nt?(x, y) || 
    event.size_trigger_check(x,y) || 
    event.extra_trigger_check(x,y)) 
    }
  end
end

#module data manager to save the event_size
module DataManager
  class << self
    alias est_event_size_make_save_contents make_save_contents
    alias est_event_size_extract_save_contents extract_save_contents
  end  
  def self.make_save_contents
    contents = est_event_size_make_save_contents
    contents = contents.merge(make_est_event_size_contents)
    contents
  end
  def self.make_est_event_size_contents
    contents = {}
    contents[:custom_passage_maps] =	$custom_passage_maps
    contents
  end
  def self.extract_save_contents(contents)
    est_event_size_extract_save_contents(contents)
    extract_est_event_size_contents(contents)
  end
  def self.extract_est_event_size_contents(contents)
    $custom_passage_maps = contents[:custom_passage_maps]
  end
end

#patch for event touch size & default system direction fix bug
class Game_Event
  alias est_decor_build_check_event_trigger_touch_front check_event_trigger_touch_front
  def check_event_trigger_touch_front
    @tmp_direction = @direction if @real_direction
    @direction = @real_direction if @real_direction
    size_chk = false
      if size_list
        size_list.each do |sz|
        x2 = $game_map.round_x_with_direction(sz[0], @direction) 
        y2 = $game_map.round_y_with_direction(sz[1], @direction)
        size_chk = size_chk || check_event_trigger_touch(x2, y2)
        end
      end
    trg = est_decor_build_check_event_trigger_touch_front || size_chk
    @direction = @tmp_direction if @real_direction
    @tmp_direction = nil
    return trg
  end
  
  alias est_decor_build_set_direction set_direction
  def set_direction(d)
    est_decor_build_set_direction(d)
    @real_direction = d if d != 0
  end
end
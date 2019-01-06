## Eventing: Fine Tuning v3.4 ##
# Fine tune the x-y position, zoom, rotation, hue, as well as mirror and
#   flash event's sprites!
#
# Usage: All script calls are made with set move route
#          offset(x,y)             within set move route x and y are equal to
#                                   the number of pixels to be offset
#
#          set_zoom(zoom)          where zoom is a number
#
#          rotate(angle)           where angle is a number from -360 to 360
#
#          blend(color)            where color is a color object
#                                   -> Color.new(red,blue,green,alpha)
#
#          mirrored                toggles mirror effect
#
#          flash(color,duration)   where color is a color object and duration
#                                   is the length of the flash
#
#          slide(x, y)             offsets the sprite, but moves them to the
#                                   position instead of transfering
#
#          waypoint(x,y)           will cause the character to head towards the
#                                   specified point. Next command starts after
#                                   point is reached.
#
#          moveto(x,y)             Not actually a new command, but one that is
#                                   nice to know, transfers event to specified
#                                   point.
#
#          fadein                  Fades the character to 255 opacity based
#          fadein(duration)         on duration. Default of 10 frames.
#
#          fadeout                 Fades the character to 0 opacity based
#          fadeout(duration)        on duration. Default of 10 frames.
#
#          shake                   Shakes the sprite, default duration of 30
#          shake(duration)          frames.
#
#          random                  Moves the character to a random location
#          random(width,height)     on the map. Can specify maximum range.
#
#          random_region(id)       Moves the character to a random location on
#          random_region(id,w,h)    the map with the same region. Can specify
#                                   maximum range.
#
#      self_switch("letter",value) Sets the self switch of the event. Letter is
#                                   "A" to "D", value is true or false.
#
#          balloon(id)             Plays the specific balloon animation on the
#                                   char
#
#      Newer Commands:
#          jump_forward(length)    Makes the character jump in the direction they
#                                   are facing, or backwards if negative.
#          jump_side(length)       Makes the character jump to their left, or
#                                   right if negative.
#          jumpto(x, y)            Makes the character jump to the specified coords
#
#          memorize                Saves the event's current position
#          recall                  Transfers event to saved position, or origin
#                                   if position not set
#          recall_walk             Walks the character to it's saved position
#
#          reset                   Resets all Fine Tuning details
#          restart                 Resets the event completely, not self switches
#          restart(true)           Resets the event completely and self switches
#
#          moveto_player           Transfers the event to the player
#          moveto_player(true)     Walks the event to the player
#
#          moveto_event(id)        Transfers the event to the specified event
#          moveto_event(id, true)  Walks the event to the specified event
#
#      play_animation(event, anim) Plays the specified animation on the specified
#                                   event
#
#                                  
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
EVENTING_USE_DIR8 = false
 
class Game_CharacterBase
  alias shake_init_public_members init_public_members
  alias shake_update update
  alias shake_moveto moveto
 
  attr_accessor   :zoom
  attr_accessor   :flash_on
  attr_accessor   :flash_color
  attr_accessor   :flash_time
  attr_accessor   :angle
  attr_accessor   :mirror
  attr_accessor   :blend_color
 
  def init_public_members
    shake_init_public_members
    reset_event_details
  end
  def reset_event_details
    @shakechar = [false, 0, 0]
    @zoom = 1
    @flash_on = false
    @flash_color = Color.new(0,0,0,0)
    @flash_duration = 0
    @angle = 0
    @total_angle = 0
    @mirror = false
    @blend_color = Color.new(0,0,0,0)
    @fade = @opacity
    @fade_time = 0
    @shake_time = 0
    @shake_direction = 0
    @memo_x = -1
    @memo_y = -1
  end
  def offset(x,y); @shakechar = [true, x, y]; end
  def reset
    reset_event_details
    rotate(@total_angle*-1)
  end
  def set_zoom(size); @zoom = size; end
  def flash(color,duration)
    @flash_color = color
    @flash_time = duration
    @flash_on = true
  end
  def rotate(angle)
    @total_angle += angle
    @angle = angle
  end
  def flashoff; @flash_on = false; end
  def mirrored; @mirror == true ? @mirror = false : @mirror = true; end
  def blend(color); @blend_color = color; end
  def screen_x
    if @shakechar[0] == false || @shakechar[1] == nil then
      $game_map.adjust_x(@real_x) * 32 + 16 else
      $game_map.adjust_x(@real_x) * 32 + 16 + @shakechar[1] end
  end
  def screen_y
    if @shakechar[0] == false || @shakechar[2] == nil then
      $game_map.adjust_y(@real_y) * 32 + 32 - shift_y - jump_height else
      $game_map.adjust_y(@real_y) * 32 + 32 - shift_y - jump_height + @shakechar[2] end
  end
  def slide(x, y)
    @slide_x = x + @shakechar[1]
    @slide_y = y + @shakechar[2]
    @step_anime = true
    @shakechar[0] = true
    @sliding = true
  end
  def fadein(time = 10)
    @fade_time = time
    @fade = 255
  end
  def fadeout(time = 10)
    @fade_time = time
    @fade = 0
  end
  def shake(time = 30)
    @shakechar[0] = true
    @shake_time = time
  end
  def random(rect_x = 250, rect_y = 250)
    tiles = []
    tiles = tile_array(rect_x,rect_y)
    tiles = tiles.compact
    return if tiles.empty?
    tile = rand(tiles.size)
    moveto(tiles[tile][0],tiles[tile][1])
  end
  def random_region(id, rect_x = 250, rect_y = 250)
    tiles = tile_array(rect_x,rect_y)
    tiles.each_index do |i|
      next if tiles[i].nil?
      erase = false
      erase = true unless $game_map.region_id(tiles[i][0], tiles[i][1]) == id
      tiles[i] = nil if erase
    end
    tiles = tiles.compact
    return if tiles.empty?
    tile = rand(tiles.size)
    moveto(tiles[tile][0],tiles[tile][1])
  end
  def random_wait(min, max)
    @wait_count = rand(max-min) + min - 1
  end
  def tile_array(rect_x,rect_y)
    tiles = [];nx = 0;ny = 0
    ($game_map.width * $game_map.height).times do |i|
      tiles.push([nx,ny])
      nx += 1
      if nx == $game_map.width
        nx = 0
        ny += 1
      end
    end
    tiles.each_index do |i|
      erase = false
      erase = true if tiles[i][0] == $game_player.x && tiles[i][1] == $game_player.y
      erase = true if tiles[i][0] == x && tiles[i][1] == y
      erase = true if tiles[i][0] > x + rect_x || tiles[i][0] < x - rect_x
      erase = true if tiles[i][1] > y + rect_y || tiles[i][1] < y - rect_y
      erase = true if !$game_map.check_passage(tiles[i][0], tiles[i][1], 0x0f)
      tiles[i] = nil if erase
    end
    return tiles
  end
  def self_switch(symbol, boolean)
    return if !self.is_a?(Game_Event)
    key = [$game_map.map_id, @event.id, symbol]
    $game_self_switches[key] = boolean
  end
  def balloon(id)
    @balloon_id = id
  end
  def update
    shake_update
    update_sliding if @sliding
    update_fading if @opacity != @fade && @fade_time > 0
    update_shake if @shake_time > 0
  end
  def update_fading
    @opacity += (255 / @fade_time) if @fade > @opacity
    @opacity -= (255 / @fade_time) if @fade < @opacity
    @opacity = 0 if @opacity < 0; @opacity = 255 if @opacity > 255
    @fade_time = 0 if @opacity == 0 || @opacity == 255
  end
  def update_sliding
    @shakechar[1] += 0.5 if @slide_x > @shakechar[1]
    @shakechar[1] -= 0.5 if @slide_x < @shakechar[1]
    @shakechar[2] += 0.5 if @slide_y > @shakechar[2]
    @shakechar[2] -= 0.5 if @slide_y < @shakechar[2]
    return unless screen_x == @next_x
    return unless screen_y == @next_y
    @sliding = false
    @step_anime = false
  end
  def update_shake
    @shake_time -= 1
    @shakechar[2] += 1 if @shake_direction == 0
    @shakechar[2] -= 1 if @shake_direction == 1
    if @shake_time % 3 == 0
      @shake_direction += 1
      @shake_direction = 0 if @shake_direction > 1
    end
  end
  def moveto(x,y)
    shake_moveto(x,y)
    @memo_x = @x if @memo_x < 0
    @memo_y = @y if @memo_y < 0
  end
  def jump_forward(length)
    x = 0; y = 0
    x += length if @direction == 6
    x -= length if @direction == 4
    y += length if @direction == 2
    y -= length if @direction == 8
    jump(x,y)
  end
  def jump_side(length)
    x = 0; y = 0
    y += length if @direction == 6
    y -= length if @direction == 4
    x += length if @direction == 2
    x -= length if @direction == 8
    jump(x,y)
  end
  def jumpto(x,y)
    x = x - @x
    y = y - @y
    jump(x,y)
  end
  def memorize
    @memo_x = @x
    @memo_y = @y
  end
  def recall
    moveto(@memo_x, @memo_y)
  end
  def recall_walk
    waypoint(@memo_x, @memo_y)
  end
  def restart(switches = false)
    initialize(@map_id, @event)
    if switches
      self_switch("A", false)
      self_switch("B", false)
      self_switch("C", false)
      self_switch("D", false)
    end
  end
  def moveto_player(wp = false)
    if wp
      waypoint($game_player.x, $game_player.y)
    else
      moveto($game_player.x, $game_player.y)
    end
  end
  def moveto_event(id, wp = false)
    return if $game_map.events[id].nil?
    event = $game_map.events[id]
    if wp
      waypoint(event.x, event.y)
    else
      moveto(event.x, event.y)
    end
  end
  def play_animation(event_id, animation_id)
    if event_id > 0
      return if $game_map.events[event_id].nil?
      event = $game_map.events[event_id]
    elsif event_id == -1
      event = $game_player
    end
    event.animation_id = animation_id
  end
end
 
class Game_Character
  alias eft_init_private_members init_private_members
  def init_private_members
    eft_init_private_members
    @waypoint = [-1,-1]      
  end
  def update_routine_move
    if @wait_count > 0
      @wait_count -= 1
    else
      @move_succeed = true
      command = @move_route.list[@move_route_index]
      if command
        if @waypoint[0] != -1
          process_waypoint_command
          advance_waypoint_route_index
        else
          process_move_command(command)
          advance_move_route_index
        end
      end
    end
  end
  def process_waypoint_command
    sx = distance_x_from(@waypoint[0])
    sy = distance_y_from(@waypoint[1])
    if sx.abs > sy.abs
      if EVENTING_USE_DIR8
        @move_succeed = false
        if sy != 0
          move_diagonal(sx > 0 ? 4 : 6, sy > 0 ? 8 : 2)
        end
        move_straight(sx > 0 ? 4 : 6) if !@move_succeed
        move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
      else
        move_straight(sx > 0 ? 4 : 6)
        move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
      end
    elsif sy != 0
      if EVENTING_USE_DIR8
        @move_succeed = false
        if sx != 0
          move_diagonal(sx > 0 ? 4 : 6, sy > 0 ? 8 : 2)
        end
        move_straight(sy > 0 ? 8 : 2) if !@move_succeed
        move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
      else
        move_straight(sy > 0 ? 8 : 2)
        move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
      end
    end
    @waypoint = [-1,-1] if !@move_succeed && @move_route.skippable
  end
  def advance_waypoint_route_index
    return unless @x == @waypoint[0]
    return unless @y == @waypoint[1]
    @waypoint = [-1,-1]
  end
  def waypoint(x,y); @waypoint = [x,y]; end
end
 
class Sprite_Character
  alias eventfp_update update
  def update
    eventfp_update
    zoom_update
    mirror_update
    blend_update
    rotate_update
    flash_update if @character.flash_on
  end
  def blend_update; self.color = @character.blend_color; end
  def zoom_update
    self.zoom_y = @character.zoom
    self.zoom_x = @character.zoom
  end
  def mirror_update; self.mirror = @character.mirror; end
  def flash_update
    flash(@character.flash_color,@character.flash_time)
    @character.flashoff
  end
  def rotate_update
    self.angle = @character.angle
  end
end
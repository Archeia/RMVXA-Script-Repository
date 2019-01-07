##----------------------------------------------------------------------------##
## Common Bubble Pop-ups
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0 - 4.25.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_BUBBLE_POP"] = 1.0                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows bubbles to appear over a player's head while they're
## standing over a specific event.  You can have this only occur on certain
## pages and have any bubble from the sheet appear.  To do this, place the
## following tag in a comment on the page you would like to activate this.
##
## pop bubble[1]
##  - Causes balloon 1 from the balloon sheet to appear over the player's head.
##    The first balloon is number 1 and you can use any number rather than 1.
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


class RPG::Event::Page
  def bubble
    return @bubble if @bubble
    self.list.each do |l|
      next unless [108, 408].include?(l.code)
      if l.parameters[0] =~ /pop bubble\[(\d+)\]/i
        @bubble = $1.to_i
      end
    end
    @bubble ||= 0
    bubble
  end
end

class Game_Event < Game_Character
  alias :cp_42513_update :update
  def update(*args)
    cp_42513_update(*args)
    check_bubble if @page.bubble > 0
  end
  
  def check_bubble
    $game_player.special_balloon = @page.bubble if $game_player.pos?(x, y)
  end
end

class Game_CharacterBase
  attr_accessor :special_balloon
  
  alias :cp_42513_init_mems :init_public_members
  def init_public_members(*args)
    cp_42513_init_mems(*args)
    @special_balloon = 0
  end
end

class Sprite_Character < Sprite_Base
  alias :cp_42513_update :update
  def update(*args)
    cp_42513_update(*args)
    update_sp_balloon
  end
  
  alias :cp_42513_new_effect :setup_new_effect
  def setup_new_effect(*args)
    cp_42513_new_effect(*args)
    if !@balloon_sprite && !@balloon_sp_sprite && @character.special_balloon > 0
      @balloon_sp_id = @character.special_balloon
      start_sp_balloon
    end
  end
  
  alias :cp_42513_start_balloon :start_balloon
  def start_balloon(*args)
    end_sp_balloon
    cp_42513_start_balloon(*args)
  end
  
  def start_sp_balloon
    dispose_sp_balloon
    @balloon_sp_duration = 8 * balloon_speed + balloon_wait
    @balloon_sp_sprite = ::Sprite.new(viewport)
    @balloon_sp_sprite.bitmap = Cache.system("Balloon")
    @balloon_sp_sprite.ox = 16
    @balloon_sp_sprite.oy = 32
  end
  
  def update_sp_balloon
    if @character.special_balloon > 0 && @balloon_sp_sprite
      @balloon_sp_duration -= 1 if @balloon_sp_duration > 0
      @balloon_sp_sprite.x = x
      @balloon_sp_sprite.y = y - height
      @balloon_sp_sprite.z = z + 200
      frame = 7 - [(@balloon_sp_duration - balloon_wait) / balloon_speed, 0].max
      sx = frame * 32
      sy = (@balloon_sp_id - 1) * 32
      @balloon_sp_sprite.src_rect.set(sx, sy, 32, 32)
      @character.special_balloon = 0
    elsif @character.special_balloon == 0
      end_sp_balloon
    end
  end
  
  def end_sp_balloon
    dispose_sp_balloon
    @character.special_balloon = 0
  end
  
  def dispose_sp_balloon
    if @balloon_sp_sprite
      @balloon_sp_sprite.dispose
      @balloon_sp_sprite = nil
    end
  end
end


###----------------------------------------------------------------------------
#  End of script.
###----------------------------------------------------------------------------
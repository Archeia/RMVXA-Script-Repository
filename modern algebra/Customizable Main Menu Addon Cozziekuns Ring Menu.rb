#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ** Cozziekuns Ring Menu Addon
#-------------------------------------------------------------------------------
# Version: 1.0
# Author: cozziekuns (rmrk)
# Last Date Updated: 2/4/2013
#===============================================================================
# Description: 
#-------------------------------------------------------------------------------
# An addon to Modern Algebra's lovely Customisable Main Menu script, allowing
# it to be transformed into a ring menu ala Seiken Densetsu 3. 
#===============================================================================
# Instructions:
#-------------------------------------------------------------------------------
# Everything should be pretty straight forward. Edit the module as you wish.
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

#=============================================================================
# ** Cozziekuns
#=============================================================================

module Cozziekuns
  
  module Ring_Menu
    
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    #  Editable Region
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    
    Ring_Menu_Radius = 128 # How large the ring menu will be
    Ring_Menu_Speed = 16 # How quickly the ring menu scrolls (less is faster)
    Ring_Menu_Icons ={ # Syntax: MA Command Symbol => Icon Index
      :item => 260,
      :skill => 418,
      :equip => 147,
      :status => 121,
      :formation => 164,
      :save => 227,
      :game_end => 225,
    }
    
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #  END Editable Region
    #//////////////////////////////////////////////////////////////////////////
    
  end
  
end

include Cozziekuns

#=============================================================================
# ** Math
#=============================================================================

module Math
    
  def self.sind(value)
    sin(value * PI / 180)
  end
    
  def self.cosd(value)
   cos(value * PI / 180)
  end
      
  def self.tand(value)
    tan(value * PI / 180)
  end
      
end

#==============================================================================
# ** Window_MenuCommand
#==============================================================================

class Window_MenuCommand
  
  alias coz_ringmnu_wmcmnd_initialize initialize
  def initialize(*args)
    @angle = 0
    coz_ringmnu_wmcmnd_initialize(*args)
    self.opacity = 0
    cursor_rect.empty
    refresh
  end

  def window_width
    Graphics.width
  end
  
  def window_height
    Graphics.height
  end
  
  def angle_size
    360 / item_max
  end

  def draw_item(index)
    radius = Ring_Menu::Ring_Menu_Radius
    n = (index - @index) * angle_size + @angle
    cx = radius * Math.sind(n) + Graphics.width / 2
    cy = -radius * Math.cosd(n) + Graphics.height / 2
    draw_zoom_icon(Ring_Menu::Ring_Menu_Icons[@list[index][:symbol]], cx - 24, cy - 24, n == 0)
    if n == 0
      change_color(normal_color, command_enabled?(index))
      item_rect = Rect.new(0, 0, 0, 0)
      item_rect.x = Graphics.width / 2 - 80
      item_rect.y = Graphics.height / 2 - line_height
      item_rect.width = 160
      item_rect.height = line_height
      draw_text(item_rect, command_name(index), 1)
    end
  end
  
  def draw_zoom_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    stretch_rect = Rect.new(x, y, 48, 48)
    contents.stretch_blt(stretch_rect, bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  
  def update
    update_index
    process_handling
  end
  
  def update_cursor
    cursor_rect.empty
  end
  
  def update_spin(reverse = false)
    speed = Ring_Menu::Ring_Menu_Speed
    @angle += (reverse ? -angle_size : angle_size) / speed.to_f
    Graphics.update
    refresh
  end
  
  def update_index
    if Input.trigger?(:LEFT)
      Sound.play_cursor
      update_spin while @angle.round < angle_size
      @index -= 1
      @index %= item_max
      @angle = 0
      refresh
    elsif Input.trigger?(:RIGHT)
      Sound.play_cursor
      update_spin(true) while @angle.round > -angle_size
      @index += 1
      @index %= item_max
      @angle = 0
      refresh
    end
  end
  
end

#==============================================================================
# ** Scene_Menu
#==============================================================================

class Scene_Menu
  
  def command_personal
    on_personal_ok
  end
  
end
###-----------------------------------------------------------------------------
#  Skill Display v1.2
#  Created by Neon Black
#  V1.2 - 2.11.2014 - More small updates
#  V1.1 - 1.28.2013 - Small updates
#  V1.0 - 1.9.2013 - Version created for release
#  For both commercial and non-commercial use as long as credit is given to
#  Neon Black and any additional authors.  Licensed under Creative Commons
#  CC BY 4.0 - http://creativecommons.org/licenses/by/4.0/
###-----------------------------------------------------------------------------

class Window_BattleLog < Window_Selectable
  ##------
  #  These three constants can be changed from nil to a string value ("Counter"
  #  with the quotes for example) to display a message when counter, reflection,
  #  or substitution occurs.
  ##------
  COUNTER = nil
  REFLECT = nil
  SUB = nil
  
  ##------
  #  These twho constants are used to determined the X and Y offsets of the
  #  window.  Increase these values to move them down or right and decrease
  #  them to move the window up and left.
  ##------
  
  X_OFFSET = 0
  Y_OFFSET = 48
  
  ##------
  #  Allows a picture to be used instead of the default black background.  If
  #  you do not want to use a picture, just set this to nil.  The picture goes
  #  in the Graphics/Pictures folder.
  ##------
  
  BACK_COLOR = Color.new(0, 0, 0, 64)
  BACK_PIC = nil
  
  ##------
  #  The time taken for each turn measured in frames.
  ##------
  ACTION_SPEED = 20
    
##-----------------------------------------------------------------------------
#  The following lines are the actual core code of the script.  While you are
#  certainly invited to look, modifying it may result in undesirable results.
#  Modify at your own risk!
##-----------------------------------------------------------------------------
  

  ## Adds a new array to store skill names.
  alias cp_init initialize
  def initialize
    @pop_wind = []
    cp_init
    @back_sprite.x = self.x = X_OFFSET
    @back_sprite.y = self.y = Y_OFFSET
    create_background_picture
  end
  
  def create_background_picture
    @back_pic_sprite = Sprite.new
    return unless BACK_PIC
    @back_pic_sprite.bitmap = Cache.picture(BACK_PIC)
    @back_pic_sprite.ox = @back_pic_sprite.width / 2
    @back_pic_sprite.oy = @back_pic_sprite.height / 2
    @back_pic_sprite.x = width / 2 + x
    @back_pic_sprite.y = height / 2 + y
    @back_pic_sprite.visible = false
  end
  
  ## Change the log window to 1 line max.
  def max_line_number
    return 1
  end
  
  alias cp_window_clear clear
  def clear
    @pop_wind.clear
    cp_window_clear
  end
  
  ## Overwrites the refresh to change what is drawn.
  def refresh
    draw_background unless BACK_PIC
    contents.clear
    @back_pic_sprite.visible = false if @back_pic_sprite
    return if @pop_wind.empty?
    @back_pic_sprite.visible = true
    if @pop_wind[-1].is_a?(String)
      draw_text(0, 0, contents.width, line_height, @pop_wind[-1], 1)
    elsif @pop_wind[-1].is_a?(Array)
      xpos = contents.width - (contents.text_size(@pop_wind[-1][1]).width + 24)
      xpos /= 2
      draw_icon(@pop_wind[-1][0], xpos, 0)
      change_color(normal_color)
      draw_text(xpos + 24, 0, contents.width, line_height, @pop_wind[-1][1])
    else
      xpos = contents.width - (contents.text_size(@pop_wind[-1].name).width + 24)
      xpos /= 2
      draw_item_name(@pop_wind[-1], xpos, 0)
    end
  end
  
  ## Draws the display box in a different size.
  def draw_background
    @back_bitmap.clear
    @back_bitmap.fill_rect(back_rect, back_color)
    rect1 = Rect.new(back_rect.x - 64, back_rect.y, 64, back_rect.height)
    rect2 = Rect.new(back_rect.x + back_rect.width, back_rect.y, 64,
                     back_rect.height)
    @back_bitmap.gradient_fill_rect(rect1, no_colour, back_color)
    @back_bitmap.gradient_fill_rect(rect2, back_color, no_colour)
  end
  
  def back_rect
    if @pop_wind.empty?
      i = width
    elsif @pop_wind[-1].is_a?(Array)
      n = @pop_wind[-1][1]
      i = contents.text_size(n).width
      i += 24
    else
      n = @pop_wind[-1].is_a?(String) ? @pop_wind[-1] : @pop_wind[-1].name
      i = contents.text_size(n).width
      i += 24 unless @pop_wind[-1].is_a?(String)
    end
    Rect.new((width - i) / 2, padding, i, (@pop_wind.empty? ? 0 : 1) * line_height)
  end
  
  def back_color
    BACK_COLOR
  end
  
  def no_colour
    color = back_color.clone
    color.alpha = 0
    color
  end
    
  def add_pop_line(item = nil)
    @pop_wind.push(item) unless item.nil? || item == ""
    @pop_wind.pop if !item.is_a?(String) && item.name == ""
    refresh
  end
    
  def add_pop_array(icon = 0, text = "")
    @pop_wind.push([icon, text]) unless text.empty?
    refresh
  end
  
  ## Grabs the names of skills rather than the usage lines.  
  def display_use_item(subject, item)
    add_pop_line(item)
  end
  
  def display_counter(target, item)
    return unless COUNTER
    add_pop_line(COUNTER)
    wait
  end
  
  def display_reflection(target, item)
    return unless REFLECT
    add_pop_line(REFLECT)
    wait
  end
  
  def display_substitute(substitute, target)
    return unless SUB
    add_pop_line(SUB)
    wait
  end
  
  def message_speed
    return ACTION_SPEED
  end
end


##-----------------------------------------------------------------------------
#  End of script.
##-----------------------------------------------------------------------------
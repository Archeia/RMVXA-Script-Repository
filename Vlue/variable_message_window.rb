#Vlue
#Script calls
#  $game_message.set_size(width,height)
#  $game_message.set_position(x,y)
#  $game_message.set(x,y,width,height)
#  $game_message.set_for_event(event_id,width(opt),height(opt))
#  $game_message.set_for_player(width(opt),height(opt))
 
class Game_Message
 
  DEFAULT_WIDTH = Graphics.width
  DEFAULT_HEIGHT = 24*5
  DEFAULT_X = 0
  DEFAULT_Y = Graphics.height-DEFAULT_HEIGHT
 
  attr_reader  :x
  attr_reader  :y
  attr_reader  :width
  attr_reader  :height
  def set_size(width,height)
    @width = width
    @height = height
  end
  def set_position(x,y)
    @x = x
    @y = y
    @x = 0 if @x < 0
    @y = 0 if @y < 0
    @x = Graphics.width - width if @x > Graphics.width - width
    @y = Graphics.height - height if @y > Graphics.height - height
  end
  def set_both(x,y,w,h)
    set_size(w,h)
    set_position(x,y)
  end
  def set_for_event(id, width = DEFAULT_WIDTH, height = DEFAULT_HEIGHT)
    set_size(width,height)
    xx = $game_map.events[id].screen_x - self.width / 2
    yy = $game_map.events[id].screen_y - self.height - 32
    set_position(xx,yy)
    if @y != yy
      set_position(xx, $game_map.events[id].screen_y)
    end
  end
  def set_for_player(width = DEFAULT_WIDTH, height = DEFAULT_HEIGHT)
    set_size(width,height)
    xx = $game_player.screen_x - self.width / 2
    yy = $game_player.screen_y - self.height - 32
    set_position(xx,yy)
  end
  alias variable_clear clear
  def clear
    variable_clear
    @width = DEFAULT_WIDTH
    @height = DEFAULT_HEIGHT
    @x = DEFAULT_X
    @y = DEFAULT_Y
  end
end
 
class Window_Message
  def update_placement
    self.x = $game_message.x
    self.y = $game_message.y
    self.width = $game_message.width
    self.height = $game_message.height
    create_contents
  end
  def adjust_message_window_size
  end
end
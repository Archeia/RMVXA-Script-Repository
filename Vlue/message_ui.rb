#Usage:
# $game_message.set("bust name", position, "name")
# Bust name is name of bust image in the pictures folder
# Position is 0 for left and not 0 for right
# Name is the name for the text box

#Using a custom message skin to achieve borderless look without messing with
# other windows. Delete line 42 to remove effect.

#Ignoring tone setting in database to achieve grey look without messing with 
# other windows. Delete lines 47-49 to remove effect.

class Game_Message
  attr_accessor  :bust_name
  attr_accessor  :bust_position
  attr_accessor  :name
  alias message_clear clear
  def clear
    message_clear
    @bust_name = nil
    @bust_position = nil
    @name = nil
  end
  def set(bustname, pos, name)
    @bust_name = bustname
    @bust_position = pos
    @name = name
  end
end

#56,13,144+24,28+24
class Window_Message
  alias message_init initialize
  def initialize
    message_init
    self.width += 12
    self.x -= 6
    @uiname_window = Window_Base.new(0,0,168,52)
    @uiname_window.opacity = 0
    @border_sprite = Sprite_Base.new
    @border_sprite.z = self.z + 1
    #@border_sprite.opacity = 0
    @bust_sprite = Sprite_Base.new
    #@bust_sprite.opacity = 0
    self.windowskin = Cache.system("Messageskin")
  end
  def update_tone
    self.tone = Tone.new(0,0,0,255)
  end
  def update_placement
    @position = $game_message.position
    self.y = @position * (Graphics.height - height) / 2 + 6
    @gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
  end
  alias ui_open open_and_wait
  def open_and_wait
    if $game_message.bust_name
      @bust_sprite.bitmap = Cache.picture($game_message.bust_name)
      if $game_message.bust_position == 0 
        @bust_sprite.mirror = false
        @bust_sprite.x = 0
      else
        @bust_sprite.mirror = true
        @bust_sprite.x = Graphics.width - @bust_sprite.width
      end
      @bust_sprite.y = self.y + 3 - @bust_sprite.height
    end
    if $game_message.name
      if $game_message.bust_position == 0
        @uiname_window.x = Graphics.width - 168 - 24
      else
        @uiname_window.x = 56 - 16
      end
      @uiname_window.y = self.y - @uiname_window.height + 12
      @uiname_window.contents.clear
      @uiname_window.contents.fill_rect(0,0,144,28,Color.new(75,75,75,175))
      @uiname_window.draw_text(4,0,144,28,$game_message.name)
    end
    if $game_message.bust_position == 0
      @border_sprite.bitmap = Cache.system("UI text right")
    else
      @border_sprite.bitmap = Cache.system("UI text left")
    end
    @border_sprite.y = self.y + 12 - @border_sprite.height
    ui_open
  end
  alias ui_close close_and_wait
  def close_and_wait
    @uiname_window.contents.clear
    if @bust_sprite.bitmap
      @bust_sprite.bitmap.dispose
      @bust_sprite.bitmap = nil
    end
    if @border_sprite.bitmap
      @border_sprite.bitmap.dispose
      @border_sprite.bitmap = nil
    end
    ui_close
  end
end
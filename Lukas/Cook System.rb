=begin

 * Simple Cook System.
 Vers. 1.a
 Original Creator: Lukas Cahyadi Gunawan:  03/5/2012
 Converted and add more feature by DrDhoom/WhiteHopper: 17/5/2012

 How To Use ? Place above Main.
 For RPG VXA (RGSS3)

 Feature:
 - Cooking.
 
=end
#=============================================================================#
#                                ▼ CONFIGURATION ▼
#-----------------------------------------------------------------------------#
  $DRRECIPE = []
  #DRRECIPE[RECIPE ID] = [NAME OF RECIPE, [[ITEM ID, QUANTITY],[ITEM ID, QUANTITY], ...], [EQUIPMENT, ...], ITEM ID THAT WILL BE CREATED, TIME, DESCRIPTION(LEAVE BLANK IF YOU WANT USE ITEM DESCRIPTION)]
  #You also can add more recipe with event and script command, just write it with this format
  $DRRECIPE[0] = ['Ikan Goreng', [[1,2],[2,1]], [3], 4, 140, '']
  $DRRECIPE[1] = ['Potion', [[5,2],[6,1]], [7], 8, 140, '']
# To call script : SceneManager.call(Scene_Resep)

module Dhoom
  module CookSystem
    CONFIRM_MESSAGE = ["Yes", "No"]
    CONFIRM_HELP = "Are you sure to create this item?"
    RECIPE_INGREDIENT = 'Bahan yang diperlukan: '
    RECIPE_EQUIP = 'Peralatan yang diperlukan: '
    RECIPE_WAIT = 'Process...'
    CREATED_MESSAGE = "You've just created:"
  end
end
#-----------------------------------------------------------------------------#
#                                ▲ CONFIGURATION ▲
#=============================================================================#

class Game_Temp
  attr_accessor :bisa_masak
  attr_accessor :bahan
  alias masak_masak initialize
  def initialize
    masak_masak
    @bisa_masak = true
    @bahan = {}
  end
end

class Window_Help_Str < Window_Base
  def initialize
    super(0, 0, Graphics.width, 56)
  end
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  def clear
    set_text("")
  end
  def set_item(item)
    set_text(item ? item.description : "")
  end
  def refresh
    contents.clear
    draw_text(4, 0, Graphics.width, 32, @text, 1)
  end
end

class Window_Resep < Window_Selectable
  def initialize
    super(0, 56, 272, 360)   
    @data = []   
    refresh
    self.index = 0   
  end
  def item_max
    $DRRECIPE.size
  end
  def item
    return @data[@index]
  end
  def refresh
    @i = 0   
    @item_max = $DRRECIPE.size
    if @item_max > 0
      create_contents
      for resep in $DRRECIPE
        self.contents.draw_text(4, @i * line_height, 320, line_height, resep[0])
        @data.push(resep)
        @i += 1
      end
    end
  end
  def update_help
    if @data[@index][5] == ''
      @help_window.set_text($data_items[@data[@index][3]].description)
    else
      @help_window.set_text(@data[@index][5])
    end
  end
end

class Window_PrsMasak < Window_Base
  def initialize
    super(192, 176, 160, line_height + 32)
    refresh
  end
  def refresh
    self.contents.clear
    self.contents.draw_text(4, 0, width - 40, line_height, Dhoom::CookSystem::RECIPE_WAIT,1)
  end
end

class Window_Bahan < Window_Base
  def initialize
    super(272, 56, 272, 360)
    refresh
  end
  def set(item)
    @item = item
    @i = 0
    refresh
  end
  def refresh
    self.contents.clear
    $game_temp.bisa_masak = true
    $game_temp.bahan.clear
    @i = 0
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 240, line_height, Dhoom::CookSystem::RECIPE_INGREDIENT)
    if @item != nil
      for bahan in @item[1]
        @i += 1
        number = $game_party.item_number($data_items[bahan[0]])
        self.contents.font.color = normal_color
        if number >= bahan[1]
          self.contents.font.color.alpha = 255
          $game_temp.bisa_masak = true if $game_temp.bisa_masak
        else
          self.contents.font.color.alpha = 128
          $game_temp.bisa_masak = false
        end
        $game_temp.bahan[bahan[0]] = bahan[1]
        draw_item_name($data_items[bahan[0]], 4, @i * line_height, number >= bahan[1] ? true : false)
        self.contents.draw_text(248, @i * line_height, 32, line_height,'x ' + bahan[1].to_s)
      end 
      @i += 1
      self.contents.font.color = system_color
      self.contents.draw_text(4, @i * line_height, 240, line_height, Dhoom::CookSystem::RECIPE_EQUIP)
      if @item != nil
        for perl in @item[2]
          @i += 1
          number = $game_party.item_number($data_items[perl])
          if number > 0
            $game_temp.bisa_masak = true if $game_temp.bisa_masak
          else
            $game_temp.bisa_masak = false
          end
          draw_item_name($data_items[perl],4 ,@i * line_height, number > 0 ? true : false)
        end
      end
    end
  end
end

class Window_Confirm < Window_Command
  def initalize(x, y)
    super(x, y)
  end
  def window_width
    return 160
  end
  def visible_line_number
    return 2
  end
  def make_command_list
    add_command(Dhoom::CookSystem::CONFIRM_MESSAGE[0], :yes)
    add_command(Dhoom::CookSystem::CONFIRM_MESSAGE[1], :no)
  end
  def update_help
    @help_window.set_text(Dhoom::CookSystem::CONFIRM_HELP)
  end
end     

class Window_Created < Window_Base
  def initialize(item)
    super(112,128,320,160)
    @item = $data_items[item]
    refresh
  end
  def refresh
    draw_text(0,0,288,32,Dhoom::CookSystem::CREATED_MESSAGE,1)
    draw_item_name(@item, 0, 48)
  end
end

class Scene_Resep < Scene_MenuBase
  def start
    super
    create_background
    @viewport = Viewport.new(0, 0, 544, 416)
    $DRRECIPE.compact!
    @resep_window = Window_Resep.new
    @bahan_window = Window_Bahan.new
    @bahan_window.set(@resep_window.item)
    @help_window = Window_Help_Str.new
    @resep_window.help_window = @help_window
    @resep_window.active = true
    @wait_window = Window_PrsMasak.new
    @wait_window.visible = false
    @wait_window.z = 888
    @confirm_window = Window_Confirm.new(192, 180)   
    @confirm_window.set_handler(:yes, method(:on_confirm_yes))
    @confirm_window.set_handler(:no, method(:on_confirm_no))
    @confirm_window.set_handler(:cancel, method(:on_confirm_no))
    @confirm_window.active = false
    @confirm_window.visible = false
    @confirm_window.help_window = @help_window
    Sound.play_ok
  end
  def terminate
    super
    dispose_background
    @viewport.dispose
    @bahan_window.dispose
    @resep_window.dispose
    @wait_window.dispose
    @help_window.dispose
    @confirm_window.dispose
  end
  def on_confirm_yes
    @item = @resep_window.item
    for bahan in @item[1]
      $game_party.lose_item($data_items[bahan[0]], bahan[1])
    end
    @bahan_window.refresh
    @wait = @item[4]
    @tiaw = 0
    @resep_window.active = false
    @wait_window.visible = true
  end
  def on_confirm_no
    Sound.play_cancel
    @confirm_window.active = false
    @resep_window.active = true 
    @confirm_window.visible = false
  end
  def update
    super
    @help_window.update
    if @resep_window.active
      if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        @bahan_window.set(@resep_window.item)
      end
      update_resep
      return
    end
    if @wait_window.visible
      @wait -= 1 if @wait > 0
      @tiaw += 1 if @wait > 0
      if @tiaw >= 10
        @tiaw = 0
      end
      if @wait <= 0
        if @created_window.nil?
          Audio.se_play('Audio/SE/chime2', 100, 100)
          $game_party.gain_item($data_items[@resep_window.item[3]], 1)
          @created_window = Window_Created.new(@resep_window.item[3])
          @wait_window.visible = false
        end
      end
      return
    end
    if @created_window != nil
      if Input.trigger?(Input::C)
        Sound.play_ok
        SceneManager.call(Scene_Map)
      end
    end
  end
  def update_resep
    if Input.trigger?(Input::C)
      unless $game_temp.bisa_masak
        Sound.play_buzzer
        return
      end
      Sound.play_ok
      @resep_window.active = false
      @confirm_window.active = true
      @confirm_window.visible = true
      return
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      SceneManager.call(Scene_Map)
    end
  end
end
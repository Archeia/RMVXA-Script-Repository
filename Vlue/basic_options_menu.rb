#Basic Options Menu v1.4
#----------#
#Features: Provides a simple option menu for the player to do optiony stuff...
#           Like volume effects for all, bgm, and se's. Fancy!
#          
#          Also additional options if you have Basic Window Resizer,
#           Basic Message SE, and Basic Autosave.
#
#Usage:    Plug and play unless you want a bit more. Customization below.
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
 
#This lets you set the order of the windows via an array
WINDOW_ORDER = [:master,:bgm,:se,:resolution,:message_se,:switch]
#Basic options are:
#  :master - Master Volume               :bgm     - Background Music Volume
#  :se     - Sound Effect Volume         :switch  - Allow the player to turn on/off a switch or global variable
#
#-- Additional Options are:
#  :resolution     -   If you have Basic Window Resizer installed
#  :message_se     -   If you have Basic Message SE installed
#  :autosave       -   If you have Basic Autosave installed
 
#These are all the strings for the help window and headers:
module OPT_STR
  #When the command window is selected
  COMMAND_HELP       = "Confirm and exit or simply exit"
  #Details for :master
  MASTER_VOLUME      = "Master Volume"
  MASTER_VOLUME_HELP = "Set the volume of all sound"
  #Details for :bgm
  BGM_VOLUME         = "BGM Volume"
  BGM_VOLUME_HELP    = "Set the volume of music"
  #Details for :se
  SE_VOLUME          = "SE Volume"
  SE_VOLUME_HELP     = "Set the volume of sound effects"
  #Details for :resolution
  RESOLUTION         = "Resolution"
  RESOLUTION_HELP    = "Change the resolution of the game window"
  #Details for :autosave
  AUTOSAVE           = "Autosave"
  AUTOSAVE_HELP      = "Enable/Disable autosaving"
  #Details for :message
  MESSAGE_SE         = "Message SE"
  MESSAGE_SE_HELP    = "Enable/Disable the message sound effect"
  #Details for :switch
  SWITCH_DETAIL      = "$game_switches[5]"
  SWITCH             = "Header"
  SWITCH_HELP        = "Help Message"
  SWITCH_COMMAND     = ["On","Off"]
end
 
class Scene_Options < Scene_MenuBase
  def start
    super
    $game_options.memorize_options
    create_base_windows
    @current_index = 1
    @window_index = []
    @size = 0
    WINDOW_ORDER.each do |symbol|
      create_resolution_window if symbol == :resolution
      create_autosave_window   if symbol == :autosave
      create_master_window     if symbol == :master
      create_bgm_window        if symbol == :bgm
      create_se_window         if symbol == :se
      create_message_se_window if symbol == :message_se
      create_window_switch     if symbol == :switch
    end
    create_command_window
    @index = 0
    @old_index = @index
    activate_window(0)
  end
  def create_base_windows
    @help_window = Window_Help.new(1)
    @help_window.set_text("Options")
    @back_window = Window_Options.new
    @back_window.height = (WINDOW_ORDER.size + 1)* 48 + 24
    @back_window.create_contents
  end
  def create_command_window
    @window_command = Window_OCommand.new(48+24 * @current_index)
    @window_command.set_handler(:ok, method(:command_ok))
    @window_index.push(:command)
    @back_window.draw_line(24 * (@current_index - 1))
  end
  def create_resolution_window
    if Module.const_defined?(:Window_Resize)
      @window_resolution = Window_OR.new(48+24 * @current_index)
      @window_resolution.set_handler(:ok, method(:resolution_ok))
      @back_window.add_text(24 * (@current_index - 1),OPT_STR::RESOLUTION)
      @current_index += 2
      @size += 1
      @window_index.push(:resolution)
    end
  end
  def create_autosave_window
    if Module.const_defined?(:AUTOSAVE_FILE_NAME)
      @window_autosave = Window_OAS.new(48+24 * @current_index)
      @window_autosave.set_handler(:ok, method(:autosave_ok))
      @back_window.add_text(24 * (@current_index - 1),OPT_STR::AUTOSAVE)
      @current_index += 2
      @size += 1
      @window_index.push(:autosave)
    end
  end
  def create_master_window
    @window_masterbar = Window_OBar.new(48+24 * @current_index)
    @back_window.add_text(24 * (@current_index - 1),OPT_STR::MASTER_VOLUME)
    @current_index += 2
    @size += 1
    @window_masterbar.refresh($game_options.master_volume)
    @window_index.push(:master)
  end
  def create_bgm_window
    @window_bgmbar = Window_OBar.new(48+24 * @current_index)
    @back_window.add_text(24 * (@current_index - 1),OPT_STR::BGM_VOLUME)
    @current_index += 2
    @size += 1
    @window_bgmbar.refresh($game_options.bgm_volume)
    @window_index.push(:bgm)
  end
  def create_se_window
    @window_sebar = Window_OBar.new(48+24*@current_index)
    @back_window.add_text(24 * (@current_index - 1),OPT_STR::SE_VOLUME)
    @current_index += 2
    @size += 1
    @window_sebar.refresh($game_options.se_volume)
    @window_index.push(:se)
  end
  def create_message_se_window
    if Window_Message.const_defined?(:DEFAULT_SE_FREQ)
      @window_message = Window_OMSE.new(48+24 * @current_index)
      @window_message.set_handler(:ok, method(:message_ok))
      @back_window.add_text(24 * (@current_index - 1),OPT_STR::MESSAGE_SE)
      @current_index += 2
      @size += 1
      @window_index.push(:message)
    end
  end
  def create_window_switch
    @window_switch = Window_OSW.new(48+24 * @current_index)
    @window_switch.set_handler(:ok, method(:switch_ok))
    @back_window.add_text(24 * (@current_index - 1),OPT_STR::SWITCH)
    @current_index += 2
    @size += 1
    @window_index.push(:switch)
  end
  def activate_window(index)
    case @window_index[index]
    when :resolution
      @window_resolution.select(0)
      @window_resolution.activate
      @help_window.set_text(OPT_STR::RESOLUTION_HELP)
    when :autosave
      @window_autosave.select(0)
      @window_autosave.activate
      @help_window.set_text(OPT_STR::AUTOSAVE_HELP)
    when :master
      @window_masterbar.select(0)
      @window_masterbar.activate
      @help_window.set_text(OPT_STR::MASTER_VOLUME_HELP)
    when :bgm
      @window_bgmbar.select(0)
      @window_bgmbar.activate
      @help_window.set_text(OPT_STR::BGM_VOLUME_HELP)
    when :se
      @window_sebar.select(0)
      @window_sebar.activate
      @help_window.set_text(OPT_STR::SE_VOLUME_HELP)
    when :message
      @window_message.select(0)
      @window_message.activate
      @help_window.set_text(OPT_STR::MESSAGE_SE_HELP)
    when :command
      @window_command.select(0)
      @window_command.activate
      @help_window.set_text(OPT_STR::COMMAND_HELP)
    when :switch
      @window_switch.select(0)
      @window_switch.activate
      @help_window.set_text(OPT_STR::SWITCH_HELP)
    end
  end
  def deactivate_window(index)
    case @window_index[index]
    when :resolution
      @window_resolution.select(-1)
      @window_resolution.deactivate
    when :autosave
      @window_autosave.select(-1)
      @window_autosave.deactivate
    when :master
      @window_masterbar.select(-1)
      @window_masterbar.deactivate
    when :bgm
      @window_bgmbar.select(-1)
      @window_bgmbar.deactivate
    when :se
      @window_sebar.select(-1)
      @window_sebar.deactivate
    when :message
      @window_message.select(-1)
      @window_message.deactivate
    when :command
      @window_command.select(-1)
      @window_command.deactivate
    when :switch
      @window_switch.select(-1)
      @window_switch.deactivate
    end
  end
  def update
    super
    update_input
    update_index
  end
  def update_input
    if Input.trigger?(:UP)
      @index -= 1
      @index = @size if @index < 0
    elsif Input.trigger?(:DOWN)
      @index += 1
      @index = 0 if @index > @size
    elsif Input.repeat?(:LEFT)
      change_volume(@index, -0.01)
    elsif Input.repeat?(:RIGHT)
      change_volume(@index, 0.01)
    elsif Input.trigger?(:B)
      @index = @size
    end
  end
  def update_index
    return if @index == @old_index
    deactivate_window(@old_index)
    activate_window(@index)
    Sound.play_cursor
    @old_index = @index
  end
  def change_volume(index, value)
    return unless audio_index(index)
    $game_options.set_volume(:master, value) if @window_index[index] == :master
    $game_options.set_volume(:bgm, value) if @window_index[index] == :bgm
    $game_options.set_volume(:se, value) if @window_index[index] == :se
    @window_masterbar.refresh($game_options.master_volume)
    @window_bgmbar.refresh($game_options.bgm_volume)
    @window_sebar.refresh($game_options.se_volume)
    Sound.play_cursor
    $game_map.autoplay if $game_map && $game_map.map_id > 0
  end
  def audio_index(index)
    return true if @window_index[index] == :master
    return true if @window_index[index] == :bgm
    return true if @window_index[index] == :se
    return false
  end
  def resolution_ok
    case @window_resolution.index
    when 0
      $game_options.set_resolution(Graphics.width,Graphics.height)
    when 1
      $game_options.set_resolution(Graphics.width*2,Graphics.height*2)
    when 2
      $game_options.set_fullscreen
    end
    @window_resolution.refresh
    @window_resolution.activate
  end
  def autosave_ok
    $game_options.auto_save = true if @window_autosave.index == 0
    $game_options.auto_save = false if @window_autosave.index == 1
    @window_autosave.refresh
    @window_autosave.activate
  end
  def message_ok
    $game_options.message_se = true if @window_message.index == 0
    $game_options.message_se = false if @window_message.index == 1
    @window_message.refresh
    @window_message.activate
  end
  def switch_ok
    eval(OPT_STR::SWITCH_DETAIL + " = true") if @window_switch.index == 0
    eval(OPT_STR::SWITCH_DETAIL + " = false") if @window_switch.index == 1
    @window_switch.refresh
    @window_switch.activate
  end
  def command_ok
    case @window_command.index
    when 0
      $game_options.save_options
      $game_options.clear_memorize
      return_scene
    when 1
      $game_options.copy_memorize
      $game_options.clear_memorize
      return_scene
    end
  end
end
 
class Window_Options < Window_Base
  def initialize
    super(0,48,544,416-48)
    self.contents.font.color = Color.new(150,100,255,200)
  end
  def add_text(y,string)
    draw_text(15,y,544-24,24,string)
  end
  def draw_line(y)
    contents.fill_rect(15,y+12,544-24,1,Color.new(75,75,75))
  end
end
 
class Window_OR < Window_Selectable
  TEXT = ["Normal","Large","Fullscreen"]
  def initialize(y)
    super(24,y,544-48,48)
    refresh
    self.opacity = 0
  end
  def item_width; self.contents.width / 4; end
  def item_max; return 3; end
  def col_max; return item_max; end
  def row_max; return 1; end
  def draw_item(index)
    rect = item_rect(index)
    change_color(normal_color, index == $game_options.resolution_index)
    draw_text(rect, TEXT[index],1)
  end
end
 
class Window_OAS < Window_Selectable
  def initialize(y)
    super(24,y,544-48,48)
    refresh
    self.opacity = 0
  end
  def item_width; return 118; end
  def item_max; return 2; end
  def col_max; return item_max; end
  def row_max; return 1; end
  def draw_item(index)
    rect = item_rect(index)
    $game_options.auto_save ? id = 0 : id = 1
    change_color(normal_color, id == index)
    draw_text(rect, ["Yes","No"][index],1)
  end
end
 
class Window_OSW < Window_Selectable
  def initialize(y)
    super(24,y,544-48,48)
    refresh
    self.opacity = 0
  end
  def item_width; return 118; end
  def item_max; return 2; end
  def col_max; return item_max; end
  def row_max; return 1; end
  def draw_item(index)
    rect = item_rect(index)
    eval(OPT_STR::SWITCH_DETAIL) ? id = 0 : id = 1
    change_color(normal_color, id == index)
    draw_text(rect, [OPT_STR::SWITCH_COMMAND[0],OPT_STR::SWITCH_COMMAND[1]][index],1)
  end
end
 
class Window_OCommand < Window_Selectable
  def initialize(y)
    super(24+96,y,544-48,48)
    refresh
    self.opacity = 0
  end
  def item_width; return 118; end
  def item_max; return 2; end
  def col_max; return item_max; end
  def row_max; return 1; end
  def draw_item(index)
    rect = item_rect(index)
    draw_text(rect, ["Ok","Cancel"][index],1)
  end
end
 
class Window_OMSE < Window_OAS
  def initialize(y)
    super
    self.y = y
    refresh
    self.opacity = 0
  end
  def draw_item(index)
    rect = item_rect(index)
    $game_options.message_se ? id = 0 : id = 1
    change_color(normal_color, id == index)
    draw_text(rect, ["Yes","No"][index],1)
  end
end
 
class Window_OBar < Window_Selectable
  def initialize(y)
    super(24,y,544-48,48)
    self.opacity = 0
  end
  def item_width; return contents.width; end
  def item_max; return 1; end
  def col_max; return item_max; end
  def row_max; return 1; end
  def refresh(temp_value)
    contents.clear
    temp_value *= 100
    temp_value.to_i.times do |i|
      rect = Rect.new(4+i*4,6,2,8)
      contents.fill_rect(rect, Color.new(75,100,255))
    end
    (100-temp_value).to_i.times do |i|
      rect = Rect.new(396-i*4,6,2,8)
      contents.fill_rect(rect, Color.new(0,0,0))
    end
    draw_text(0,0,contents.width,24,temp_value.to_i.to_s + "%",2)
  end
  def update_mouse
  end
end
 
class Game_Options
  attr_accessor  :fullscreen
  attr_accessor  :resolution
  attr_accessor  :master_volume
  attr_accessor  :bgm_volume
  attr_accessor  :se_volume
  attr_accessor  :auto_save
  attr_accessor  :message_se
  def default_options
    @fullscreen = false
    @resolution = [544,416]
    @master_volume = 1.0
    @bgm_volume = 1.0
    @se_volume = 1.0
    @auto_save = true
    @message_se = true
    save_options
  end
  def load_options
    if FileTest.exist?("System/Options.dt")
      File.open("System/Options.dt", "rb") do |file|
        $game_options = Marshal.load(file)
      end
    else
      default_options
    end
    reset_screen
  end
  def reset_screen
    if Module.const_defined?(:Window_Resize)
      if $game_options.fullscreen
        Window_Resize.f
      else
        Window_Resize.r($game_options.resolution[0],$game_options.resolution[1])
      end
    end
  end
  def save_options
    File.open("System/Options.dt", "wb") do |file|
      Marshal.dump($game_options, file)
    end
  end
  def memorize_options
    @old_options = Marshal.load(Marshal.dump($game_options))
  end
  def copy_memorize
    $game_options = Marshal.load(Marshal.dump(@old_options))
    reset_screen
  end
  def clear_memorize
    @old_options = nil
  end
  def resolution_index
    return 2 if @fullscreen
    return 1 if @resolution[0] == 544*2
    return 0
  end
  def set_resolution(w,h)
    @resolution = [w,h]
    @fullscreen = false
    Window_Resize.window
    15.times {|i| Graphics.update }
    Window_Resize.r(@resolution[0],@resolution[1])
  end
  def set_fullscreen
    @fullscreen = true
    Window_Resize.f
  end
  def set_volume(symbol, value)
    case symbol
    when :master
      @master_volume += value
      @master_volume = [[@master_volume, 1].min, 0].max
    when :bgm
      @bgm_volume += value
      @bgm_volume = [[@bgm_volume, 1].min, 0].max
    when :se
      @se_volume += value
      @se_volume = [[@se_volume, 1].min, 0].max
    end
  end
  def preset_volume(symbol, value)
    if symbol == :master
      @master_volume = value
      @master_volume = [[@master_volume, 1].min, 0].max
    end
    if symbol == :bgm
      @bgm_volume = value
      @bgm_volume = [[@bgm_volume, 1].min, 0].max
    end
    if symbol == :se
      @se_volume = value
      @se_volume = [[@se_volume, 1].min, 0].max
    end
  end
end
 
class RPG::BGM < RPG::AudioFile
  def play(pos = 0)
    if @name.empty?
      Audio.bgm_stop
      @@last = RPG::BGM.new
    else
      if $game_options
        volume = @volume * $game_options.master_volume
        volume *= $game_options.bgm_volume
      else
        volume = @volume
      end
      Audio.bgm_play('Audio/BGM/' + @name, volume.to_i, @pitch, pos)
      @@last = self.clone
    end
  end
end
 
class RPG::BGS < RPG::AudioFile
  def play(pos = 0)
    if @name.empty?
      Audio.bgs_stop
      @@last = RPG::BGS.new
    else
      if $game_options
        volume = @volume * $game_options.master_volume
        volume *= $game_options.bgm_volume
      else
        volume = @volume
      end
      Audio.bgs_play('Audio/BGS/' + @name, volume.to_i, @pitch, pos)
      @@last = self.clone
    end
  end
end
 
class RPG::ME < RPG::AudioFile
  def play
    if @name.empty?
      Audio.me_stop
    else
      if $game_options
        volume = @volume * $game_options.master_volume
        volume *= $game_options.se_volume
      else
        volume = @volume
      end
      Audio.me_play('Audio/ME/' + @name, volume.to_i, @pitch)
    end
  end
end
 
class RPG::SE < RPG::AudioFile
  def play
    unless @name.empty?
      if $game_options
        volume = @volume * $game_options.master_volume
        volume *= $game_options.se_volume
      else
        volume = @volume
      end
      Audio.se_play('Audio/SE/' + @name, volume.to_i, @pitch)
    end
  end
end
 
module SceneManager
  def self.run
    DataManager.init
    Audio.setup_midi if use_midi?
    $game_options = Game_Options.new
    $game_options.load_options
    @scene = first_scene_class.new
    @scene.main while @scene
  end
end
 
class Window_MenuCommand < Window_Command
  alias options_aoc add_original_commands
  def add_original_commands
    options_aoc
    add_command("Options", :options)
  end
end
 
class Scene_Menu < Scene_MenuBase
  alias options_create_command_window create_command_window
  def create_command_window
    options_create_command_window
    @command_window.set_handler(:options,   method(:command_options))
  end
  def command_options
    SceneManager.call(Scene_Options)
  end
end
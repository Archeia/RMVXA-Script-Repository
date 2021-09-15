#encoding:UTF-8
# ISS031 - Jukebox
# // 09/30/2011
# // 10/04/2011
#==============================================================================#
# ** ISS::Jukebox
#==============================================================================#
module ISS
  install_script(31, :audio)
  module Jukebox

    # // Song Setup
    SONGS = {
    # :tag    => ["DisplayName"        , "Filename"          , vol, pit],
      :black  => ["Blackout"           , "Blackout"          , 100, 100],
      :elg    => ["Elegance"           , "Elegance"          , 100, 100],
      :div0   => ["Division By Zero"   , "DivisionByZero"    , 100, 100],
      :flight => ["Flightless Machine" , "FlightlessMachine" , 100, 100],
      :lone   => ["Lone Machine"       , "LoneMachine"       , 100, 100],
      :panic  => ["Panicing Machine"   , "PanicingMachine"   , 100, 100],
      :bluerk => ["Blue Ranks"         , "BlueRanks"         , 100, 100],
      :nuekn  => ["Nue Knights"        , "NueKnights"        , 100, 100],
      :saveme => ["Save Me"            , "SaveMe"            , 100, 100],
      :zarotk => ["Zarotek"            , "Zarotek"           , 100, 100],
    }

    # // Order of appearance
    SONGLIST = [
      :black,
      :elg,
      :div0,
      :flight,
      :lone,
      :panic,
      :bluerk,
      :nuekn,
      :saveme,
      :zarotk
    ]

    module_function()

    def get_song_data(name)
      return SONGLIST.index(name), ISS::Jukebox::Song.new(*SONGS[name])
    end

    BUTTON_LAYOUT = [ :play, :stop, :next, :prev ]

    JUKE_STATE_MAP = {
      :null    => 0,
      :play_s  => 1, # // Play Selecting
      :stop_s  => 2, # // Stop Selecting
      :next_s  => 3, # // Next Selecting
      :prev_s  => 4, # // Previous Selecting
      :null_on => 5,
      :play_on => 6, # // Play ON
      :stop_on => 7, # // Stop ON
      :next_on => 8, # // Next ON
      :prev_on => 9, # // Prev ON
    }

    JUKE_SKIN_WIDTH  = 224
    JUKE_SKIN_HEIGHT = 384

  end
end

# // Basically RPG::BGM all over again @___@
#==============================================================================#
# ** ISS::Jukebox::Song
#==============================================================================#
class ISS::Jukebox::Song

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_reader :filename
  attr_reader :name
  attr_reader :pitch

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(name="", filename="", volume=100, pitch=100)
    @name, @filename, @volume, @pitch = name, filename, volume, pitch
  end

  #--------------------------------------------------------------------------#
  # * new-method :play
  #--------------------------------------------------------------------------#
  def play()
    return if self.filename.empty?()
    Audio.bgm_play("Audio/BGM/" + self.filename, self.volume, self.pitch)
  end

  #--------------------------------------------------------------------------#
  # * new-method :volume
  #--------------------------------------------------------------------------#
  def volume()
    return @volume
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_volume
  #--------------------------------------------------------------------------#
  def set_volume(new_volume)
    @volume = new_volume
  end

  #--------------------------------------------------------------------------#
  # * class-method :stop
  #--------------------------------------------------------------------------#
  def self.stop()
    Audio.bgm_stop()
  end

end

# // Handles all the Jukebox songs and stuff
# // $game_jukebox
#==============================================================================#
# ** ISS::Jukebox::Jukebox_Case
#==============================================================================#
class ISS::Jukebox::Jukebox_Case

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :index
  attr_accessor :song_index

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize()
    @songs = Array.new(::ISS::Jukebox::SONGLIST.size).map! {
      ISS::Jukebox::Song.new("????????") }
    ::ISS::Jukebox::SONGLIST.each { |n| unlock_song(n) } # // Remove Later
    @index = 0
    @song_index = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :unlock_song
  #--------------------------------------------------------------------------#
  def unlock_song(name)
    index, song = *(::ISS::Jukebox.get_song_data(name))
    @songs[index] = song
  end

  #--------------------------------------------------------------------------#
  # * new-method :songs
  #--------------------------------------------------------------------------#
  def songs()
    return @songs
  end

  #--------------------------------------------------------------------------#
  # * new-method :buttons
  #--------------------------------------------------------------------------#
  def buttons()
    return ::ISS::Jukebox::BUTTON_LAYOUT
  end

  #--------------------------------------------------------------------------#
  # * new-method :button_at
  #--------------------------------------------------------------------------#
  def button_at(index)
    return buttons[index]
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_song_at
  #--------------------------------------------------------------------------#
  def get_song_at(index)
    return songs[index]
  end

  #--------------------------------------------------------------------------#
  # * new-method :play_song_at
  #--------------------------------------------------------------------------#
  def play_song_at(index)
    get_song_at(index).play()
  end

  #--------------------------------------------------------------------------#
  # * new-method :stop_song
  #--------------------------------------------------------------------------#
  def stop_song()
    ISS::Jukebox::Song.stop()
  end

end

#==============================================================================#
# ** ISS::Jukebox::Jukebox_SongListSprite
#==============================================================================#
class ISS::Jukebox::Jukebox_SongListSprite < ::Sprite

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :song_index
  attr_accessor :song_max

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  WLH = 20

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(list, viewport=nil)
    super(viewport)
    @song_list = list
    @selection_sprite = ::Sprite.new()
    @selection_sprite.bitmap = Bitmap.new(100, 20)
    @selection_sprite.bitmap.fill_rect(1, 1, 98, 18, system_color)
    @selection_sprite.bitmap.blur()
    @song_index = 0
    @song_max   = 1
    @column_max = 1

    @target_rect   = Rect.new(0, 0, 100, 128)
    @starget_rect  = Rect.new(0, 0, 100, 128) # // Set Target
    @srtarget_rect = Rect.new(0, 0, 100, 128) # // Updating Rect
    refresh()
    update()
  end

  #--------------------------------------------------------------------------#
  # * super-method :dispose
  #--------------------------------------------------------------------------#
  def dispose()
    self.bitmap.dispose() unless self.bitmap.nil?() ; self.bitmap = nil
    @selection_sprite.bitmap.dispose() unless @selection_sprite.bitmap.nil?()
    @selection_sprite.dispose() ; @selection_sprite = nil
    super()
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    @song_max = @song_list.size
    self.bitmap.dispose() unless self.bitmap.nil?()
    self.bitmap = Bitmap.new(100, [@song_list.size, 5].max*20 ) #128*10)
    self.bitmap.font.size = Font.default_size - 4
    #self.bitmap.font.name = "ProggyCleanTT"
    #self.bitmap.font.size = 13
    for i in 0...@song_list.size
      song = @song_list[i]
      self.bitmap.draw_text(4, 4+(i*WLH), 100+24, 20, song.name )#sprintf("%03d: %s", i+1, song.name ))
    end
    self.src_rect.set(0, 0, 100, 128)
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    clamp_index = [(@song_index), 0, @song_max-6].clamp
    @target_rect.set(0, clamp_index*WLH, 100, 128)
    @starget_rect.set(0, ([@song_index-clamp_index, 0].max)*WLH, 100, 128)
    #if self.src_rect.x > @target_rect.x
    #  self.src_rect.x = [self.src_rect.x - 20/10.0, @target_rect.x].max
    #elsif self.src_rect.x < @target_rect.x
    #  self.src_rect.x = [self.src_rect.x + 20/10.0, @target_rect.x].min
    #end
    if self.src_rect.y > @target_rect.y
      self.src_rect.y = [self.src_rect.y - WLH/5.0, @target_rect.y].max
    elsif self.src_rect.y < @target_rect.y
      self.src_rect.y = [self.src_rect.y + WLH/5.0, @target_rect.y].min
    end

    if @srtarget_rect.y > @starget_rect.y
      @srtarget_rect.y = [@srtarget_rect.y - WLH/5.0, @starget_rect.y].max
    elsif @srtarget_rect.y < @starget_rect.y
      @srtarget_rect.y = [@srtarget_rect.y + WLH/5.0, @starget_rect.y].min
    end

    @selection_sprite.x = self.x
    @selection_sprite.y = self.y + 4 + @srtarget_rect.y

    @selection_sprite.opacity = 64+(132 * Math.cos((((Graphics.frame_count*3) % 360)/180.0)*Math::PI)).abs
  end

end

#==============================================================================#
# ** ISS::Jukebox::Jukebox_CaseSprite
#==============================================================================#
class ISS::Jukebox::Jukebox_CaseSprite < ::Sprite

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  STATE_ACTIONS = {}
  STATE_ACTIONS["PLAY"] = [
    ["SET_STATE", ["play_on"]], ["WAIT", [12]], ["SET_STATE", ["play_s"]]
  ]
  STATE_ACTIONS["STOP"] = [
    ["SET_STATE", ["stop_on"]], ["WAIT", [12]], ["SET_STATE", ["stop_s"]]
  ]
  STATE_ACTIONS["NEXT"] = [
    ["SET_STATE", ["next_on"]], ["WAIT", [12]], ["SET_STATE", ["next_s"]]
  ]
  STATE_ACTIONS["PREV"] = [
    ["SET_STATE", ["prev_on"]], ["WAIT", [12]], ["SET_STATE", ["prev_s"]]
  ]

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(viewport=nil)
    super(viewport)
    @state_list_index = 0
    @state_list = []
    @wait_count = 0

    setup_skin()
    set_juke_state(:null)
    create_song_list()
  end

  #--------------------------------------------------------------------------#
  # * super-method :viewport=
  #--------------------------------------------------------------------------#
  def viewport=(new_viewport)
    super(new_viewport)
    @songlist.viewport = new_viewport
  end

  #--------------------------------------------------------------------------#
  # * super-method :dispose
  #--------------------------------------------------------------------------#
  def dispose()
    @songlist.dispose() unless @songlist.nil?() ; @songlist = nil
    super()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_song_list
  #--------------------------------------------------------------------------#
  def create_song_list()
    @songlist = ISS::Jukebox::Jukebox_SongListSprite.new($game_jukebox.songs)
  end

  #--------------------------------------------------------------------------#
  # * new-method :song_index
  #--------------------------------------------------------------------------#
  def song_index()
    return @songlist.song_index
  end

  #--------------------------------------------------------------------------#
  # * new-method :song_index=
  #--------------------------------------------------------------------------#
  def song_index=(new_index)
    @songlist.song_index = new_index
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_skin
  #--------------------------------------------------------------------------#
  def setup_skin()
    self.bitmap = Cache.system("JUKE-Skins/Default")
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_juke_state
  #--------------------------------------------------------------------------#
  def set_juke_state(state)
    inex = ISS::Jukebox::JUKE_STATE_MAP[state]
    self.src_rect.set(
      ISS::Jukebox::JUKE_SKIN_WIDTH*(inex%5), ISS::Jukebox::JUKE_SKIN_HEIGHT*(inex/5),
      ISS::Jukebox::JUKE_SKIN_WIDTH, ISS::Jukebox::JUKE_SKIN_HEIGHT)
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()

    @songlist.x, @songlist.y = self.x + 62, self.y + 160
    @songlist.update()
    update_state()
  end

  #--------------------------------------------------------------------------#
  # * new-method :run_new_state
  #--------------------------------------------------------------------------#
  def run_new_state(state)
    @state_list_index = 0
    @state_list = []
    @wait_count = 0
    case state
    when :play
      @state_list = STATE_ACTIONS["PLAY"].clone
    when :stop
      @state_list = STATE_ACTIONS["STOP"].clone
    when :next
      @state_list = STATE_ACTIONS["NEXT"].clone
    when :prev
      @state_list = STATE_ACTIONS["PREV"].clone
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_state
  #--------------------------------------------------------------------------#
  def update_state()
    @wait_count = [@wait_count-1, 0].max
    return unless @wait_count == 0
    return if @state_list_index >= @state_list.size
    action, parameters = *@state_list[@state_list_index]
    case action.upcase
    when "SET_STATE", "SET STATE", "SETSTATE"
      set_juke_state(parameters[0].to_s.downcase.to_sym)
    when "WAIT"
      @wait_count = parameters[0].to_i
    end
    @state_list_index += 1
  end

  #--------------------------------------------------------------------------#
  # * new-method :next_song
  #--------------------------------------------------------------------------#
  def next_song()
    @songlist.song_index = [@songlist.song_index + 1, @songlist.song_max-1].min
    #@songlist.song_index = (@songlist.song_index + 1) % @songlist.song_max
  end

  #--------------------------------------------------------------------------#
  # * new-method :prev_song
  #--------------------------------------------------------------------------#
  def prev_song()
    @songlist.song_index = [@songlist.song_index - 1, 0].max
    #@songlist.song_index = (@songlist.song_index - 1) % @songlist.song_max
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :create_game_objects
  #--------------------------------------------------------------------------#
  alias :iss031_sct_create_game_objects :create_game_objects unless $@
  def create_game_objects(*args, &block)
    iss031_sct_create_game_objects(*args, &block)
    $game_jukebox = ISS::Jukebox::Jukebox_Case.new()
  end

end

#==============================================================================#
# ** Scene_Jukebox
#==============================================================================#
class Scene_Jukebox < Scene_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :input_disabled

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(called_from=:title, return_index=0)
    super()
    @called_from  = called_from
    @return_index = return_index
    @last_index = $game_jukebox.index
    @return_bgm = RPG::BGM.last
    @input_disabled = false
    RPG::BGM.stop()
  end

  #--------------------------------------------------------------------------#
  # * super-method :start
  #--------------------------------------------------------------------------#
  def start()
    super()
    create_menu_background()
    @jukebox = ISS::Jukebox::Jukebox_CaseSprite.new()
    @jukebox.x = 20
    @jukebox.y = (Graphics.height - ISS::Jukebox::JUKE_SKIN_HEIGHT) / 2
    @state = :stopped
    update_juke_state()
    @jukebox.song_index = $game_jukebox.song_index
    @jukebox.update()
  end

  #--------------------------------------------------------------------------#
  # * super-method :terminate
  #--------------------------------------------------------------------------#
  def terminate()
    super()
    dispose_menu_background()
    $game_jukebox.song_index = @jukebox.song_index
    @jukebox.dispose()
    @return_bgm.play()
  end

  #--------------------------------------------------------------------------#
  # * new-method :index
  #--------------------------------------------------------------------------#
  def index()
    return $game_jukebox.index
  end

  #--------------------------------------------------------------------------#
  # * new-method :index=
  #--------------------------------------------------------------------------#
  def index=(new_index)
    $game_jukebox.index = new_index
  end

  #--------------------------------------------------------------------------#
  # * new-method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene()
    case @called_from
    when :title
      $scene = Scene_Title.new()
    when :map
      $scene = Scene_Map.new()
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    if $game_jukebox.index != @last_index
      Sound.play_cursor()
      update_juke_state()
    end
    @last_index = $game_jukebox.index
    super()
    update_menu_background()
    @jukebox.update()
    update_input() unless @input_disabled
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_input
  #--------------------------------------------------------------------------#
  def update_input()
    if Input.trigger?(Input::B)
      command_cancel()
    elsif Input.trigger?(Input::C)
      command_action()
    elsif Input.trigger?(Input::RIGHT)
      command_right()
    elsif Input.trigger?(Input::LEFT)
      command_left()
    elsif Input.repeat?(Input::UP)
      command_up()
    elsif Input.repeat?(Input::DOWN)
      command_down()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_cancel
  #--------------------------------------------------------------------------#
  def command_cancel()
    Sound.play_cancel()
    return_scene()
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_action
  #--------------------------------------------------------------------------#
  def command_action()
    Sound.play_decision()
    button_action($game_jukebox.index)
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_right
  #--------------------------------------------------------------------------#
  def command_right()
    cursor_right()
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_left
  #--------------------------------------------------------------------------#
  def command_left()
    cursor_left()
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_up
  #--------------------------------------------------------------------------#
  def command_up()
    Sound.play_cursor()
    state_action(:prev)
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_down
  #--------------------------------------------------------------------------#
  def command_down()
    Sound.play_cursor()
    state_action(:next)
  end

  #--------------------------------------------------------------------------#
  # * new-method :button_action
  #--------------------------------------------------------------------------#
  def button_action(index)
    execute_state($game_jukebox.button_at( index ))
  end

  #--------------------------------------------------------------------------#
  # * new-method :execute_state
  #--------------------------------------------------------------------------#
  def execute_state(state)
    @jukebox.run_new_state(state)
    state_action(state)
  end

  #--------------------------------------------------------------------------#
  # * new-method :state_action
  #--------------------------------------------------------------------------#
  def state_action(state)
    case state
    when :play
      $game_jukebox.play_song_at(@jukebox.song_index)
      @state = :playing
    when :stop
      $game_jukebox.stop_song()
      @state = :stopped
    when :next
      @jukebox.next_song()
      $game_jukebox.play_song_at(@jukebox.song_index) if @state == :playing
    when :prev
      @jukebox.prev_song()
      $game_jukebox.play_song_at(@jukebox.song_index) if @state == :playing
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :cursor_right
  #--------------------------------------------------------------------------#
  def cursor_right()
    $game_jukebox.index = [$game_jukebox.index + 1, $game_jukebox.buttons.size-1].min
  end

  #--------------------------------------------------------------------------#
  # * new-method :cursor_left
  #--------------------------------------------------------------------------#
  def cursor_left()
    $game_jukebox.index = [$game_jukebox.index - 1, 0].max
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_juke_state
  #--------------------------------------------------------------------------#
  def update_juke_state()
    case $game_jukebox.button_at($game_jukebox.index)
    when :play
      @jukebox.set_juke_state(:play_s)
    when :stop
      @jukebox.set_juke_state(:stop_s)
    when :next
      @jukebox.set_juke_state(:next_s)
    when :prev
      @jukebox.set_juke_state(:prev_s)
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

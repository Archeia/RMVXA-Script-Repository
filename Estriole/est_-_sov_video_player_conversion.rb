#==============================================================================
#
# [ACE]EST_SOV_Video_Player ++ Conversion
# 
# v1.4
#==============================================================================
# Author : Estriole
# (Conversion to ace and improving)
# VX version author: SuperOverlord
#
# also credit Crystal Noel for solution for title that have encoding problem character
# also credit ruin for fixes he made to this script.
#
# History :
# version 1.4 2013.05.16 - apply fixes from ruin. typo error and ability to use
#                          play video using battle event page.
# version 1.3 2013.03.05 - create configuration for people that have encoding character
#                          problem with their title. ex: Pokémon Ace. 
#                          set the IGNORE_TITLE to true inside module Sov::Video
# version 1.2 2012.09.27 - made if game at fullscreen automaticly become windowed
# version 1.1 2012.09.25 - some bug fix. now avi video can played at full screen mode(alt enter) with some position error.
#                        - can play other format such as mkv but it will play full screen and when played at full screen
#                          mode (alt enter) the size will be smaller and the game switched.
#                        - basicly this script not support full screen game yet. will try to fix this in next version
# version 1.0 2012.09.23 - finish converting + some change
#
#
#==============================================================================
# Features:
#------------------------------------------------------------------------------
# o Play video's on the map or in battle using a simple script event command.
#
# o Optionally pause or exit video's while they play.
#
# o View the video in the game window or in fullscreen.
#
# o Setup video skills, which show the video before damage effects.
#
# o ACE version also made not only video skill but can use video item too
# 
# o ACE version also can play video before title scene
# 
#==============================================================================
# Instructions:
#------------------------------------------------------------------------------
# o Place all videos in a folder with the same name as in configuration.
#   This folder is created automatically the first time the game is played if
#   it doesn't already exist.
#
# o Playing Videos when on the map.
#
#   - See script calls below.
#
# o Playing videos in battle.
#
#   - As when on the map the script event command can be used in battle also.
#
#   - As well as this you can setup skills as video skills which display
#     a video before damaging the enemy.
#
#     <now below setup can be also used for item video too>
#     To do this the following tags can be used in the skills notebox:
#     1) <video_name = "filename">
#        ~ name is the name of the video file. If the filename extension is
#          missing the first file matching that name is used.
#          (Quotes are necessary around the filename)
#
#      As well as the first tag 2 others are available. These tags will only
#      take effect if placed on a line below the first tag.
#      If these don't exist they are assumed true.
#
#      2) <video_exitable = n>   ~ Can the video be exited by the exit input?
#      3) <video_pausable = n>   ~ Can the video be paused?
#         ~ n is replaced with either t or f (t : true, f : false)
#
#      For other Video properties (x,y,width,height,fullscreen) the default
#      settings are used. (See script calls below)
#
# o Playing videos before title screen
# ctrl + f this : CONFIGURATION FOR VIDEO BEFORE TITLE
# and change the 
# @video_title = nil 
# to
# @video_title = "yourvideonamewithoutextensionhere"
#
#==============================================================================
# Script Calls:
#------------------------------------------------------------------------------
# Commands (From the script call command on page three of event commands)
#------------------------------------------------------------------------------
# o To change default values for video properties.
#
#  1) Video.default_x = n
#  2) Video.default_y = n
#  3) Video.default_width  = n
#  4) Video.default_height = n
#  5) Video.fullscreen = bool #disabled now since could make error
#  
#  In all 5 commands above:
#  ~ n is an integer value
#  ~ bool is either true or false
#
# o To play videos
#
#   play_video(filename,exitable,pausable)
#   ~ filename : name of video file             (Must be in quotes)
#   ~ exitable : Can the video be exited?       (When left out = true)
#   ~ pausable : Can the video be paused?       (When left out = true)
#  
#   For all other values the default's are used.
#==============================================================================
# Compatibility:
#------------------------------------------------------------------------------
# o Skill videos will depend on the battle system but sould work.
#==============================================================================
# Credit:
#------------------------------------------------------------------------------
# o Credit goes to Trebor and Berka whose scripts helped be figure out the
#   mci_send_stringA function.
#==============================================================================

module SOV
  module Video
  #--------------------------------------------------------------------------
  # Configuration
  #--------------------------------------------------------------------------
    # Name of folder for videos to be held in.
    DIR_NAME = "Videos"
    # Exit video input
    EXIT_INPUT  = Input::B
    # Pause video input
    PAUSE_INPUT = Input::C
    
    IGNORE_TITLE = true
    #set to true if your title contain strange character such as é or other.    
  #--------------------------------------------------------------------------
  # End Configuration
  #--------------------------------------------------------------------------
  end
end

module SceneManager
################ CONFIGURATION FOR VIDEO BEFORE TITLE #######################  
  @video_title = nil  # "example" # FILENAME OF THE VIDEO IN VIDEO FOLDER IN QUOTES
  #IF YOU DON'T WANT TO USE THIS FEATURE JUST CHANGE TO NIL
################ END CONFIGURATION ##########################################  
  def self.run
    DataManager.init
    Audio.setup_midi if use_midi?
    if @video_title != nil
    video = Cache.video(@video_title)
    video.exitable = true # True/False
    video.pausable = true # True/False
    Video.play(video)
    end
    @scene = first_scene_class.new
    @scene.main while @scene
  end
end

class << Graphics
  def Graphics.fullscreen? # Property
    screen_size = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    screen_width = screen_size.call(0);   screen_height = screen_size.call(1)    
    detect_fullscreen = false
    detect_fullscreen = true if screen_width == 640 and screen_height == 480
    return detect_fullscreen
  end
  def Graphics.toggle_fullscreen # Main function
    keybd = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
    keybd.call(0xA4, 0, 0, 0)
    keybd.call(13, 0, 0, 0)
    keybd.call(13, 0, 2, 0)
    keybd.call(0xA4, 0, 2, 0)    
  end
end

#==============================================================================
# Import
#------------------------------------------------------------------------------
$imported = {} if $imported == nil
$imported['Videos'] = true
#==============================================================================

#==============================================================================
# ** SOV::Video::Commands
#==============================================================================

module SOV::Video::Commands
  #--------------------------------------------------------------------------
  # * Play a video
  #  filename : video's filename (with or without extension)
  #  exitable : Can the video be exited
  #  pausable : Can the video be paused
  #--------------------------------------------------------------------------
  def play_video(filename,exitable=true,pausable=true)
    video = Cache.video(filename)
    video.exitable = exitable
    video.pausable = pausable
    $game_map.video = video
  end
  #---------------------------------------------------------------------------
  # Define as module function
  #---------------------------------------------------------------------------
  module_function :play_video
end

#==============================================================================
# ** SOV::Video::Regexp
#==============================================================================

module SOV::Video::Regexp
  #--------------------------------------------------------------------------
  # * Skill
  #--------------------------------------------------------------------------
  module Skill
    FILENAME   = /<video[_ ]?(?:file)?name = "(.+)">/i
    PAUSABLE   = /<video[_ ]?paus(?:e|able) = (t|f)>/i
    EXITABLE   = /<video[_ ]?exit(?:able)? = (t|f)>/i
  end
end

#==============================================================================
# ** SOV::Game
#==============================================================================

module SOV::Game
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------
  INI = 'Game'
  #--------------------------------------------------------------------------
  # * Get the game windows handle
  #--------------------------------------------------------------------------
  def self.hwnd
    unless defined?(@@hwnd)
      find_window = Win32API.new('user32','FindWindow','pp','i')
#      @@hwnd = find_window.call('RGSS Player',title)  
      gamefullscreen = Graphics.fullscreen?
      @@hwnd = find_window.call('RGSS Player',title)  
    end
    return @@hwnd
  end
  #--------------------------------------------------------------------------
  # * Get game title
  #--------------------------------------------------------------------------
  def self.title
    unless defined?(@@title)
      @@title = read_ini('title')
    end
    return @@title
  end
  #--------------------------------------------------------------------------
  # * Read ini (Returns nil or match)
  #--------------------------------------------------------------------------
  def self.read_ini(variable,filename=INI)
    return nil if variable == 'title' && SOV::Video::IGNORE_TITLE
    reg = /^#{variable}=(.*)$/
    File.foreach(filename+'.ini') { |line| break($1) if line =~ reg }
  end
end

#==============================================================================
# ** Cache
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # Class Variables
  #--------------------------------------------------------------------------
  @@vcache = {}
  #--------------------------------------------------------------------------
  # Define as class methods
  #--------------------------------------------------------------------------
  class << self
    #------------------------------------------------------------------------
    # Alias List
    #------------------------------------------------------------------------
    alias sov_video_clear clear unless $@
    #------------------------------------------------------------------------
    # * Get a video object
    #  filename : basename of file
    #------------------------------------------------------------------------
    def video(filename)
      # Get full filename if extension is missing
      if File.extname(filename) == ''
        files = Dir["#{SOV::Video::DIR_NAME}/#{filename}.*"]
        filename = File.basename(files[0]) # Set as first matching file
      end
      # Create or get the video object.
      if @@vcache.has_key?(filename)
        @@vcache[filename]
      else
        @@vcache[filename] = Video.new(filename)
      end
    end
    #------------------------------------------------------------------------
    # * Clear
    #------------------------------------------------------------------------
    def clear
      @@vcache.clear
      sov_video_clear
    end
  end
end

#==============================================================================
# ** RPG::Skill
#==============================================================================

class RPG::UsableItem
  #--------------------------------------------------------------------------
  # * Determine if skill has a video skill
  #--------------------------------------------------------------------------
  def video
    if @video == nil
      @note.each_line { |line|
        if @video == nil
          @video = Cache.video($1) if line =~ SOV::Video::Regexp::Skill::FILENAME
        else
          @video.pausable = ($1 == 't') if line =~ SOV::Video::Regexp::Skill::PAUSABLE
          @video.exitable = ($1 == 't') if line =~ SOV::Video::Regexp::Skill::EXITABLE
        end
      }
      @video = :invalid if @video == nil
    end
    return @video
  end
end

#==============================================================================
# ** Video
#------------------------------------------------------------------------------
#  Class handling playing videos.
#==============================================================================

class Video
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------
  TYPE_AVI  = 'avivideo'
  TYPE_MPEG = 'mpegvideo'
  #--------------------------------------------------------------------------
  # Class Variables
  #--------------------------------------------------------------------------
  @@default_x = 0
  @@default_y = 0
  @@default_width  = Graphics.width
  @@default_height = Graphics.height
  @@fullscreen = false
  #--------------------------------------------------------------------------
  # * Get and Set default_x/y/width/height
  #--------------------------------------------------------------------------
  for d in %w(x y width height)
    # Define setter method
    module_eval(%Q(def self.default_#{d}=(i); @@default_#{d} = i; end))
    # Define getter method
    module_eval(%Q(def self.default_#{d}; @@default_#{d}; end))
  end
  #--------------------------------------------------------------------------
  # * Get fullscreen
  #--------------------------------------------------------------------------
  def self.fullscreen
    @@fullscreen
  end  
  #--------------------------------------------------------------------------
  # * Set fullscreen
  #--------------------------------------------------------------------------
  def self.fullscreen=(val)
    @@fullscreen = val
  end
  #--------------------------------------------------------------------------
  # * Win32API
  #--------------------------------------------------------------------------
  @@mciSendStringA = Win32API.new('winmm','mciSendStringA','pplp','i')
  #--------------------------------------------------------------------------
  # * Video Command
  #  command_string : string following mci_command_string format
  #  buffer : string to retrieve return data
  #  buffer_size : number of characters in buffer
  #  callback_handle : handle of window to callback to. Used if notify is used
  #                    in the command string. (Not supported by game window)
  #--------------------------------------------------------------------------
  def self.send_command(cmnd_string,buffer='',buffer_size=0,callback_handle=0)
    # Returns error code. No error if NULL
    err = @@mciSendStringA.call(cmnd_string,buffer,buffer_size,callback_handle)
    if err != 0
      buffer = ' ' * 255
      Win32API.new('winmm','mciGetErrorString','LPL','V').call(err,buffer,255)
      raise(buffer.squeeze(' ').chomp('\000'))
    end
  end
    
  #--------------------------------------------------------------------------
  # * Play a video
  #--------------------------------------------------------------------------
  def self.play(video)
    # Make path and buffer
    path = "#{SOV::Video::DIR_NAME}/#{video.filename}"
    buffer = ' ' * 255
    # Initialize device and dock window with game window as parent.
    type = " type #{video.type}" if video.type != ''
    send_command("open #{path}#{type} alias VIDEO style child parent #{SOV::Game.hwnd}")
    # Display video in client rect at x,y with width and height.
    x = video.x
    y = video.y
    width  = video.width
    height = video.height
    send_command("put VIDEO window at #{x} #{y} #{width} #{height}")
    # Begin playing video
    screen = @@fullscreen ? 'fullscreen' : 'window'
    gamefullscreen = Graphics.fullscreen?
    case video.type
    when "avivideo"
      if gamefullscreen == true
      #send_command("put VIDEO window at #{x} #{y} 640 480")
      Graphics.toggle_fullscreen
      send_command("play VIDEO window")
      else
      send_command("play VIDEO window")
      end
    when "mpegvideo"
        if gamefullscreen == true
        Graphics.toggle_fullscreen
        send_command("play VIDEO window")
        else
        send_command("play VIDEO fullscreen")
        end
    else
    end
    flag = 0
    # Start Input and status processing loop
    while buffer !~ /^stopped/
      # Idle processing for a frame
      sleep(1.0/Graphics.frame_rate)
      # Get mode string
      send_command('status VIDEO mode',buffer,255)
      Input.update    
      if Input.trigger?(SOV::Video::PAUSE_INPUT) and video.pausable?
        Sound.play_cursor
        if buffer =~ /^paused/                 # If already paused
          send_command("resume VIDEO")         # Resume video
        else                                   # Otherwise
          send_command("pause VIDEO")          # Pause video
        end
      elsif Input.trigger?(SOV::Video::EXIT_INPUT) and video.exitable?
        Sound.play_cancel
        # Terminate loop on exit input
        break
      end
    end
    # Terminate the device
    send_command('close VIDEO')
  end
  #--------------------------------------------------------------------------
  # Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  attr_writer :exitable
  attr_writer :pausable
  attr_reader :filename
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(filename)
    unless FileTest.file?("#{SOV::Video::DIR_NAME}/#{filename}")
      raise(Errno::ENOENT,filename)
    end
    @filename = filename
    @x = @@default_x
    @y = @@default_y
    @width  = @@default_width
    @height = @@default_height
    @exitable = true
    @pausable = true
  end
  #--------------------------------------------------------------------------
  # * Get Type
  #--------------------------------------------------------------------------
  def type
    if @type == nil
      case File.extname(@filename)
      when '.avi'; @type = TYPE_AVI
      when '.mpeg'||'.mpg'; @type = TYPE_MPEG
      else
        @type = TYPE_MPEG#''
      end
    end
    @type
  end
  #--------------------------------------------------------------------------
  # * Is the video exitable?
  #--------------------------------------------------------------------------
  def exitable?
    @exitable
  end
  #--------------------------------------------------------------------------
  # * Is the video pausable?
  #--------------------------------------------------------------------------
  def pausable?
    @pausable
  end
  #--------------------------------------------------------------------------
  # Access
  #--------------------------------------------------------------------------
  private_class_method :send_command  
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # Import
  #--------------------------------------------------------------------------
  include(SOV::Video::Commands)
end

#==============================================================================
# ** Game_Map
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :video  
end

#==============================================================================
# ** Scene_Map
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # Alias List
  #--------------------------------------------------------------------------
  alias sov_video_update update unless $@
  #--------------------------------------------------------------------------
  # * Play Video
  #--------------------------------------------------------------------------
  def play_video(video)
    # Memorize and stop current bgm and bgs
    bgm = RPG::BGM.last
    bgs = RPG::BGS.last
    RPG::BGM.stop
    RPG::BGS.stop
    # Play video
    Video.play(video)
    # Restart bgm and bgs
    bgm.play
    bgs.play
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    if $game_map.video != nil
      play_video($game_map.video)
      $game_map.video = nil
      Input.update
    else
      sov_video_update
    end
  end
end

#==============================================================================
# ** Scene_Battle
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Alias list
  #--------------------------------------------------------------------------
  alias sov_video_update_battle update unless $@
  alias sov_video_use_item use_item unless $@
  #--------------------------------------------------------------------------
  # * Play Video
  #--------------------------------------------------------------------------
  def play_video(video)
    # Memorize and stop current bgm
    bgm = RPG::BGM.last
    RPG::BGM.stop
    # Play video
    Video.play(video)
    # Restart bgm
    bgm.play
  end
  #--------------------------------------------------------------------------
  # * Execute Action Skill
  #--------------------------------------------------------------------------
  def use_item
    skill = @subject.current_action.item    
    if skill.video.is_a?(Video)
      execute_action_video(skill)
      sov_video_use_item
    else
      sov_video_use_item
    end
  end
  #--------------------------------------------------------------------------
  # * Execute Action Video
  #--------------------------------------------------------------------------
  def execute_action_video(skill)
    br = Graphics.brightness
    120.times { |i| Graphics.brightness = 255 - 255/60 * i; Graphics.update }
    # Play video
    play_video(skill.video)
    # Reset brightness
    Graphics.brightness = br
  end
  #ADDED UPDATE FUNCTION FROM SCENE_MAP TO SCENE_BATTLE
  def update
    if $game_map.video != nil
      play_video($game_map.video)
      $game_map.video = nil
      Input.update
    else
      sov_video_update_battle
    end
  end
  
end





#==============================================================================
# Pre-Main Processing
#==============================================================================

unless FileTest.directory?(SOV::Video::DIR_NAME) # If directory doesn't exist.
  Dir.mkdir(SOV::Video::DIR_NAME)                # Make the directory
end

=begin
=end
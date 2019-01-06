#Basic Game Time + Night/Day v1.6.2b
#----------#
#Features: Provides a series of functions to set and recall current game time
#          as well customizable tints based on current game time to give the
#          appearance of night and day.
#
#Usage:   Script calls:
#           GameTime::minute?   - returns the current minute
#           GameTime::hour?     - returns the current hour
#           GameTime::set(time) - sets the game time to time, in frames (max:1440)
#           GameTime::change(time) - increments the game time! (can be negative)
#           GameTime::pause_time(set) - stops time for events and stuff, true or false
#           GameTime::pause_tint(set) - time runs, but tints do not update
#           GameTime::clock(set) - sets whether clock is visible or not
#        
#Customization: Set below, in comments.
#
#Examples: GameTime::set(360)
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

#---Game Clock---#
#USE_CLOCK to true to display game time clock
#CLOCK_POSITION for position of clock
#  1 = topleft, 2 = topright, 3 = bottomleft, 4 = bottomright
#CLOCK_TOGGLE is any input button available, see the INPUT help file for options
#------#
USE_CLOCK       = true
CLOCK_POSITION  = 4
CLOCK_TOGGLE    = :SHIFT

module GameTime
  #---Game Time Details---#
  #Number of frames in a game minute, 60 frames = 1 second
  TIME_COUNT      = 60
  #Sets whether to tint screen based on game time
  USE_TINT        = true

  #Switch to denote day or night time
  USE_SWITCH = false
  NIGHT_DAY_SWITCH = 1
  DAY_TIME_START = 6
  NIGHT_TIME_START = 18

  #True to pause time while not in map or while during a message
  PAUSE_IN_COMBAT  = false
  PAUSE_NOT_IN_MAP = true
  PAUSE_IN_MESSAGE = true

  #Sets time frames of tints by minute count, one day is 1440 minutes
  # 0 = 12am, 360 = 6am, 720 = 12pm, 1080 = 6pm  etc...
  PRESUNRISE_TIME = 240
  SUNRISE_TIME    = 360
  NOONSTART_TIME  = 660
  NOONEND_TIME    = 900
  PRESUNSET_TIME  = 1080
  SUNSET_TIME     = 1260
  MIDNIGHT_TIME   = 60  #Must be greater than 0

  #Sets custome tints
  PRESUNRISE_TONE = Tone.new(-75,-75,0,50)
  SUNRISE_TONE    = Tone.new(0,0,0,0)
  NOONSTART_TONE  = Tone.new(45,45,0,-25)
  NOONEND_TONE    = Tone.new(0,0,0,0)
  PRESUNSET_TONE  = Tone.new(-50,-50,0,25)
  SUNSET_TONE     = Tone.new(-75,-100,0,75)
  MIDNIGHT_TONE   = Tone.new(-125,-125,0,125)

  #Include the ids of any maps not to be tinted based on time
  # Usually reserved for indoor maps
  NOTINTMAPS = [2]
  
  #Store current time in a variable?
  USE_VARIABLE = false
  TIME_VARIABLE = 1

  #---END---#

  def self.init
    $game_time = 0
    $game_time_pause_time = false
    $game_time_pause_tint = false
  end
  def self.update
    old_time = $game_time
    if $game_time_pause_time then return else end
    case SceneManager::scene_is?(Scene_Map)
    when true
      if $game_message.visible == true && PAUSE_IN_MESSAGE then else
      $game_time += 1 if Graphics.frame_count % TIME_COUNT == 0 end
    when false

      if !PAUSE_NOT_IN_MAP and !SceneManager::scene_is?(Scene_Battle)
        $game_time += 1 if Graphics.frame_count % TIME_COUNT == 0 end
      if SceneManager::scene_is?(Scene_Battle) && PAUSE_IN_COMBAT != true
      $game_time += 1 if Graphics.frame_count % TIME_COUNT == 0 end
    end
    if $game_time == 1440 then $game_time = 0 end
    $game_variables[TIME_VARIABLE] = $game_time if USE_VARIABLE
    update_night_switch if USE_SWITCH
    GameTime::tint if $game_time_pause_tint != true
    if old_time != $game_time then $game_map.need_refresh = true end
  end
  def self.update_night_switch
    if hour? > DAY_TIME_START and hour? < NIGHT_TIME_START
      $game_switches[NIGHT_DAY_SWITCH] = true unless $game_switches[NIGHT_DAY_SWITCH] == true
    else 
      $game_switches[NIGHT_DAY_SWITCH] = false unless $game_switches[NIGHT_DAY_SWITCH] == false
    end
  end
  def self.hour?
    return $game_time / 60
  end
  def self.minute?
    return $game_time % 60
  end
  def self.time?
    meri = "AM"
    hour = GameTime::hour?
    minute = GameTime::minute?
    if hour > 11 then meri = "PM" end
    if hour == 0 then hour = 12; meri = "AM" end
    if hour > 12 then hour -= 12 end
    if hour < 10 then hour = " " + hour.to_s else hour.to_s end
    if minute < 10 then minute = "0" + minute.to_s else minute.to_s end
    return hour.to_s + ":" + minute.to_s + " " + meri
  end
  def self.set(number)
    $game_time = number if number < 1440
    GameTime::tint(0) if $game_time_pause_tint != true
  end
  def self.change(number)
    $game_time += number
    $game_time -= 1440 if $game_time > 1440
    $game_time += 1440 if $game_time < 0
    GameTime::tint(0) if $game_time_pause_tint != true
  end
  def self.tint(tint = 60)
    if USE_TINT != true then return end
    for i in NOTINTMAPS
      if $game_map.map_id == i
        $game_map.screen.start_tone_change(Tone.new(0,0,0,0),0)
        return
      end
    end
    if SceneManager::scene_is?(Scene_Map) then else return end
    case $game_time
    when PRESUNRISE_TIME .. SUNRISE_TIME
      $game_map.screen.start_tone_change(PRESUNRISE_TONE, tint)
    when SUNRISE_TIME .. NOONSTART_TIME
      $game_map.screen.start_tone_change(SUNRISE_TONE, tint)
    when NOONSTART_TIME .. NOONEND_TIME
      $game_map.screen.start_tone_change(NOONSTART_TONE, tint)
    when NOONEND_TIME .. PRESUNSET_TIME
      $game_map.screen.start_tone_change(NOONEND_TONE, tint)
    when PRESUNSET_TIME .. SUNSET_TIME
      $game_map.screen.start_tone_change(PRESUNSET_TONE, tint)
    when SUNSET_TIME .. 1440
      $game_map.screen.start_tone_change(SUNSET_TONE, tint)
    when 0 .. MIDNIGHT_TIME
      $game_map.screen.start_tone_change(SUNSET_TONE, tint)
    when MIDNIGHT_TIME .. PRESUNRISE_TIME
      $game_map.screen.start_tone_change(MIDNIGHT_TONE, tint)
    end
  end
  def self.pause_time(set)
    $game_time_pause_time = set
  end
  def self.pause_tint(set)
    $game_time_pause_tint = set
  end
  def self.clock(set)
    return unless SceneManager.scene.is_a?(Scene_Map)
    SceneManager.scene.clock_visible?(set)
  end

  class Window_Clock < Window_Base
    def initialize
      case CLOCK_POSITION
      when 1
        super(0,0,115,56)
      when 2
        super(Graphics.width-115,0,115,56)
      when 3
        super(0,Graphics.height-56,115,56)
      when 4
        super(Graphics.width-115,Graphics.height-56,115,56)
      end
      self.visible = $game_time_clock_visibility unless $game_time_clock_visibility.nil?
    end
    def update
      self.contents.clear
      self.contents.draw_text(0,0,100,24,GameTime::time?)
      $game_time_clock_visibility = self.visible
    end
  end

end

GameTime::init

module DataManager
  class << self
  alias gametime_msc make_save_contents
  alias gametime_esc extract_save_contents
  end
  def self.make_save_contents
    contents = gametime_msc
    contents[:gametime] = $game_time
    contents
  end
  def self.extract_save_contents(contents)
    gametime_esc(contents)
    $game_time = contents[:gametime]
  end
end


class Scene_Map < Scene_Base
  alias gametime_post_transfer post_transfer
  alias gametime_create_all_windows create_all_windows
  alias gametime_update_map update
  def post_transfer
    GameTime::tint(0) if $game_time_pause_tint != true
    gametime_post_transfer
  end
  def create_all_windows
    gametime_create_all_windows
    @gametimeclock = GameTime::Window_Clock.new if USE_CLOCK
  end
  def update
    gametime_update_map
    @gametimeclock.update if @gametimeclock.nil? == false
    if Input.trigger?(CLOCK_TOGGLE) and @gametimeclock.nil? == false
      @gametimeclock.visible ? @gametimeclock.visible = false : @gametimeclock.visible = true
    end
  end
  def clock_visible?(set)
    @gametimeclock.visible = set
  end
end

class Scene_Base
  alias gametime_update update
  def update
    gametime_update
    GameTime::update
  end
end
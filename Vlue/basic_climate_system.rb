#Basic Climate System v2.2
#----------#
#Features: Provides a basic weather system that will randomly weather!
#          Wooot!
#
#Usage:    Plug and play!
#          Script calls:
#           Climate::still(true/false)    #Stops weather changing
#           Climate::weather              #Returns 0 for clear, 1 for rain
#                                                  2 for storm, 3 for custom1
#                                                  4 for custom2
#        
#Customization: Set below, in comments.
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

#Approximate duration of weather effects in frames.
MAX_DURATION = 18000

#Chance for weather types to occur, higher numbers occure more then lower numbers
SUN     = 40
RAIN    = 30
STORM   = 15
CUSTOM1 = 0  #Custom weather effects chance, advanced
CUSTOM2 = 0  #Custom weather effects chance, advanced

#Array of special maps, format of [#,#,#] (I.e. [5,6,54,780])
#Maps where weather is not shown:
NOWEATHERMAPS   = [2]
#Maps where weather is not shown and bgs is played:
INDOORSOUNDMAPS = []
#Maps where it snows instead of rains:
SNOWYMAPS       = []

#BGS sound effects! Prefixed with I means Indoor sound effects.
#Format is ["Filename", Volume, Pitch]
USE_SOUND = true

RAIN_BGS    = ["Rain",  95, 100]
IRAIN_BGS   = ["Rain",  65, 100]

SNOW_BGS    = ["Rain", 0, 100]
ISNOW_BGS   = ["Rain", 0, 100]

STORM_BGS   = ["Storm", 75, 100]  
ISTORM_BGS  = ["Storm", 55, 100]  

BLIZZ_BGS   = ["Storm", 0, 100]  
IBLIZZ_BGS  = ["Storm", 0, 100]

CUSTOM1_BGS = ["Rain",  95, 100] #Custom weather effects sounds, ADVANCED
CUSTOM2_BGS = ["Rain",  95, 100] #Custom weather effects sounds, ADVANCED

#ADVANCED CUSTOMIZATION#
#Have a custom Weather System like Atelier's? Now you can use that weather!
#Just switch out these commands for the ones from that system, keep the quotes!
CLEARCOMMAND = "$game_map.screen.change_weather(:none, 0, 0)"
SUNCOMMAND = "$game_map.screen.change_weather(:none, 0, 120)"
RAINCOMMAND = "$game_map.screen.change_weather(:rain, 9, 120)"
SNOWCOMMAND = "$game_map.screen.change_weather(:snow, 5, 120)"
STORMCOMMAND = "$game_map.screen.change_weather(:storm, 9, 120)"
BLIZZCOMMAND = "$game_map.screen.change_weather(:snow, 9, 120)"
CUSTOM1COMMAND = ""
CUSTOM2COMMAND = ""

#Store current weather in a variable?
BCL_USE_VARIABLE = false
BCL_CLIMATE_VARIABLE = 1

#Have weather play in battle?
AC_BATTLE_WEATHER = false

module Climate
  def self.init
    @current_weather = -1
    @still = false
    @duration = MAX_DURATION / 4
    @need_refresh = false
    update
  end
  def self.update
    return if !SceneManager.scene.is_a?(Scene_Map)
    return if @still
    change_weather if @duration < 0
    @duration -= 1
    update_weather if @need_refresh
  end
  def self.change_weather
    arrayseed = []
    SUN.times { arrayseed.push(0) }
    RAIN.times { arrayseed.push(1) }
    STORM.times { arrayseed.push(2) }
    CUSTOM1.times { arrayseed.push(3) }
    CUSTOM2.times { arrayseed.push(4) }
    new_weather = arrayseed[rand(arrayseed.size-1)]
    sun if new_weather == 0
    rain if new_weather == 1
    storm if new_weather == 2
    custom1 if new_weather == 3
    custom2 if new_weather == 4
    $game_variables[BCL_CLIMATE_VARIABLE] = @current_weather if BCL_USE_VARIABLE
    @duration = MAX_DURATION * ((rand(40)+80)/100)
    @duration = @duration.to_i
    @need_refresh = true
  end
  def self.update_weather
    @need_refresh = false
    clear if no_weather_map
    play_weather_sound if indoor_map
    return if no_weather_map
    sun if @current_weather == 0
    rain if @current_weather == 1
    storm if @current_weather == 2
    custom1 if @current_weather == 3
    custom2 if @current_weather == 4
  end
  def self.clear
    $game_map.map.bgs.play
    eval(CLEARCOMMAND)
  end
  def self.sun
    @current_weather = 0
    play_weather_sound
    eval(SUNCOMMAND)
  end
  def self.rain
    snow = snowy_map
    @current_weather = 1
    play_weather_sound
    eval(RAINCOMMAND) unless snow
    eval(SNOWCOMMAND) if snow
  end
  def self.storm
    @current_weather = 2
    snow = snowy_map
    play_weather_sound
    eval(STORMCOMMAND) unless snow
    eval(BLIZZCOMMAND) if snow
  end
  def self.custom1
    @current_weather = 3
    play_weather_sound
    eval(CUSTOM1COMMAND)
  end
  def self.custom2
    @current_weather = 4
    play_weather_sound
    eval(CUSTOM2COMMAND)
  end
  def self.bgs_sound(name, volume, pitch)
    @audio = RPG::BGS.new(name, volume, pitch)
    @audio.play
  end
  def self.play_weather_sound
    return unless USE_SOUND
    indoor = indoor_map
    snowy = snowy_map
    weather = @current_weather
    weather += 10 if snowy and @current_weather == 1
    weather += 20 if snowy and @current_weather == 2
    case weather
    when 0
      Audio.bgs_stop
    when 1
      bgs_sound(RAIN_BGS[0],RAIN_BGS[1],RAIN_BGS[2]) unless indoor
      bgs_sound(IRAIN_BGS[0],IRAIN_BGS[1],IRAIN_BGS[2]) if indoor
    when 2
      bgs_sound(STORM_BGS[0],STORM_BGS[1],STORM_BGS[2]) unless indoor
      bgs_sound(ISTORM_BGS[0],ISTORM_BGS[1],ISTORM_BGS[2]) if indoor
    when 3
      bgs_sound(CUSTOM1_BGS[0],CUSTOM1_BGS[1],CUSTOM1_BGS[2]) unless indoor
      bgs_sound(ICUSTOM1_BGS[0],ICUSTOM1_BGS[1],ICUSTOM1_BGS[2]) if indoor
    when 4
      bgs_sound(CUSTOM2_BGS[0],CUSTOM2_BGS[1],CUSTOM2_BGS[2]) unless indoor
      bgs_sound(ICUSTOM2_BGS[0],ICUSTOM2_BGS[1],ICUSTOM2_BGS[2]) if indoor
    when 11
      bgs_sound(SNOW_BGS[0],SNOW_BGS[1],SNOW_BGS[2]) unless indoor
      bgs_sound(ISNOW_BGS[0],ISNOW_BGS[1],ISNOW_BGS[2]) if indoor
    when 22
      bgs_sound(BLIZZ_BGS[0],BLIZZ_BGS[1],BLIZZ_BGS[2]) unless indoor
      bgs_sound(IBLIZZ_BGS[0],IBLIZZ_BGS[1],IBLIZZ_BGS[2]) if indoor
    end
  end
  def self.no_weather_map
    return true if NOWEATHERMAPS.include?($game_map.map_id)
    return true if INDOORSOUNDMAPS.include?($game_map.map_id)
    return false
  end
  def self.indoor_map
    INDOORSOUNDMAPS.include?($game_map.map_id)
  end
  def self.snowy_map
    SNOWYMAPS.include?($game_map.map_id)
  end
  def self.need_refresh
    @need_refresh = true
    update
  end
  def self.still(set)
    @still = set
  end
  def self.weather
    return @current_weather
  end
end

class Scene_Battle
  alias basic_weather_start create_spriteset
  alias basic_weather_update update_basic
  alias basic_weather_dispose terminate
  def create_spriteset
    basic_weather_start
    @weather = Spriteset_Weather.new(@spriteset.viewport3) if AC_BATTLE_WEATHER
  end
  def update_basic
    basic_weather_update
    update_weather unless @weather.nil?
  end
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.power = $game_map.screen.weather_power
    @weather.ox = $game_map.display_x * 32
    @weather.oy = $game_map.display_y * 32
    @weather.update
  end
  def terminate
    basic_weather_dispose
    @weather.dispose unless @weather.nil?
  end
end
 
class Spriteset_Battle
 
  attr_accessor   :viewport3
 
end

class Game_Map
  attr_accessor   :map
end

class Scene_Map
  alias climate_update update
  alias climate_post_transfer post_transfer
  def update
    climate_update
    Climate::update
  end
  def post_start
    Climate::need_refresh
    super
  end
  def post_transfer
    Climate::need_refresh
    climate_post_transfer
  end
end

Climate::init
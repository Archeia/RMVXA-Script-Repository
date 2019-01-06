#Advanced Climate System v1.1.1b
#----------#
#Features: Provides a more advanced weather system! Yay for random weather.
#          This one has the ability to set multiple climates.
#
#Usage:    Plug and play and customize as needed!
#          Script calls:
#     Climate_Control.climate?    #returns the current climate of the map
#     Climate_Control.inside?     #returns true if in a map marked as inside
#     Climate_Control.change_weather(weather,duration = nil, climate = nil)
#           Weather can be an integer 0-howevermanyweathersintheclimate
#            or a symbol (:none,:rain,:snow,:storm)
#           Duration need not be specified
#           Climate will be the climate of the currentmap if unspecified
#     Climate_Control.current_weather    #returns the current weather as an integer
#     Climate_Control.still(true/false)  #pauses/unpauses weather
#     Climate_Control.season             #returns the name of the current season
#     Climate_Control.change_season(number) #Changes the season to whicher number
#
#
#     Climate maps and details are set in the note field of maps
#        C=#   specifies the climate of the map (i.e. C=0 or C=5)
#    nosound   will cause that map to not have any weather effect sounds
#     inside   will cause weather effects to not show
#
#     Any combination of the above effects can be placed in the map notes
#        
#Examples:
#    Climate_Control.change_weather(:rain,nil,1)
#    Climate_Control.change_weather(:snow)
#    Climate_Control.change_weather(1)
#    Climate_Control.still(true)
#    Climate_Control.change_season(2)
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
 
#Number of available Climates to be used
AC_CLIMATES = 2
#Hash of weather for each climate, add more for each additional climate, can have
#weathers as you want long as you keep up the format!
#
#Input weathers for each climate as:
#[symbol,power,season,min duration,max duration,chance,sound,inside sound]
#    Symbol can be: :none, :rain, :snow, or :storm
#    Sound and Inside Sound are: ["Filename",volume,pitch]
#    Season is the name of the season, set to nil to affect all seasons
AC_WEATHERS = { 0 => [
      [:none, 0, nil, 6000, 12000, 40, nil, nil],
      [:rain, 5, "Spring", 6000, 12000, 30, ["Rain",100,100], ["Rain",75,100]],
      [:rain, 4, "Summer", 6000, 12000, 30, ["Rain",100,100], ["Rain",75,100]],
      [:rain, 6, "Fall", 6000, 12000, 30, ["Rain",100,100], ["Rain",75,100]],
      [:storm, 6, "Spring", 6000, 12000, 10, ["Storm",100,100], ["Storm",75,100]],
      [:storm, 9, "Summer", 6000, 12000, 10, ["Storm",100,100], ["Storm",75,100]],
      [:snow, 3, "Winter", 6000, 12000, 30, nil, nil],
      [:snow, 9, "Winter", 6000, 12000, 10, nil, nil]
      ],
                1 => [
      [:none, 0, nil, 6000, 12000, 10, nil, nil],
      [:snow, 3, nil, 6000, 12000, 5, nil, nil],
      [:snow, 9, "Winter", 6000, 12000, 1, nil, nil]
      ]
              }
                 
#Seasons by name
AC_SEASONS = ["Spring","Summer","Fall","Winter"]
 
#Wether weather effects will dim screen or not                  
AC_NODIMNESS = false
#True to have weather effects during battle
AC_BATTLE_WEATHER = true
 
module Climate_Control
 
  def self.init
    $climates = []
    @current_season = 0
    AC_CLIMATES.times {|i| $climates.push(Climate.new(i))}
    @weather_playing = -1
    @still = false
  end
  def self.season
    @current_season = 0 if @current_season == nil
    return AC_SEASONS[@current_season]
  end
  def self.change_season(number)
    @current_season = number
  end
  def self.climate?
    note = $game_map.map_note
    /[C][=](?<climate>\d{1,3})/ =~ note
    return false unless $~
    return $~[1].to_i
  end
  def self.nosound?
    note = $game_map.map_note
    index = note.index("nosound")
    return true unless index.nil?
  end
  def self.inside?
    note = $game_map.map_note
    index = note.index("inside")
    return true unless index.nil?
  end
  def self.update
    return unless SceneManager.scene.is_a?(Scene_Map)
    return if @still
    $climates.each {|climate| climate.update}
    return unless climate?
    return if @weather_playing == $climates[climate?].current_weather
    auto_change_weather
  end
  def self.auto_change_weather(from_map = 120)
    clear unless climate?
    return unless climate?
    @weather_playing = $climates[climate?].current_weather
    play_audio unless nosound?
    clear if inside?
    return if inside?
    play_weather($climates[climate?].symbol,$climates[climate?].power,from_map)
  end
  def self.clear
    play_weather(:none,0,0)
  end
  def self.play_weather(symbol,power,duration = 120)
    $game_map.screen.change_weather(symbol,power,duration)
  end
  def self.play_audio
    audio = $climates[climate?].sound
    audio = $climates[climate?].isound if inside?
    if audio.nil?
      if $game_map.autoplay_bgs
        return $game_map.autoplay
      else
        return Audio.bgs_stop
      end
    end
    Audio.bgs_play('Audio/BGS/' + audio[0], audio[1], audio[2])
  end
  def self.change_weather(weather,duration = nil,climate = nil)
    climate = climate? if climate.nil?
    if weather.is_a?(Integer)
      $climates[climate].current_weather = weather
    elsif weather.is_a?(Symbol)
      type = $climates[climate?].weather
      type.size.times do |i|
        $climates[climate].current_weather = i if weather == type[i].symbol
      end
    end
    $climates[climate?].duration = duration unless duration.nil?
   end
   def self.still(set)
     @still = set
   end
   def self.current_weather
     return @weather_playing
   end
 
   
  class Climate
   
    attr_accessor :weather
    attr_accessor :current_weather
    attr_accessor :duration
   
    def initialize(id)
      @duration = 0
      @current_weather = 0
      @id = id
      @weather = []
      wth = AC_WEATHERS[id]
      wth.size.times do |i|
        @weather.push(Weather.new(wth[i][0],wth[i][1],wth[i][2],wth[i][3],
                                  wth[i][4],wth[i][5],wth[i][6],wth[i][7])) end
                                end
    def update
      @duration -= 1
      return unless @duration < 1
      new_weather
    end
    def new_weather
      ran = []
      @weather.size.times do |i|
        next if @weather[i].season != nil and @weather[i].season != Climate_Control.season
        @weather[i].chance.times {|q| ran.push(i)} end
      @current_weather = ran[rand(ran.size)]
      dmax = @weather[@current_weather].dmin
      dmin = @weather[@current_weather].dmax
      @duration = rand(dmax - dmin) + dmin
    end
    def symbol
      return @weather[@current_weather].symbol
    end
    def power
      return @weather[@current_weather].power
    end
    def sound
      return @weather[@current_weather].sound
    end
    def isound
      return @weather[@current_weather].isound
    end
  end        
 
  class Weather
   
    attr_accessor   :symbol
    attr_accessor   :season
    attr_accessor   :power
    attr_accessor   :dmin
    attr_accessor   :dmax
    attr_accessor   :chance
    attr_accessor   :sound
    attr_accessor   :isound
   
    def initialize(symbol,power,season,dmin,dmax,chance,sound,isound)
      @symbol = symbol
      @season = season
      @power = power
      @dmin = dmin
      @dmax = dmax
      @chance = chance
      @sound = sound
      @isound = isound
    end
  end
 
end
 
class Game_Map
  def map_note
    return @map.note unless @map.nil?
  end
  def autoplay_bgs
    return @map.autoplay_bgs
  end
end
 
class Scene_Map
  alias climate_update update
  alias climate_post_transfer post_transfer
  def update
    climate_update
    Climate_Control.update
  end
  def post_start
    Climate_Control.init if $climates.nil?
    Climate_Control.auto_change_weather
    super
  end
  def post_transfer
    Climate_Control.auto_change_weather(0)
    climate_post_transfer
  end
end
 
class Scene_Battle
  alias weather_start create_spriteset
  alias weather_update update_basic
  alias weather_dispose terminate
  def create_spriteset
    weather_start
    @weather = Spriteset_Weather.new(@spriteset.viewport3) if AC_BATTLE_WEATHER
  end
  def update_basic
    weather_update
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
    weather_dispose
    @weather.dispose unless @weather.nil?
  end
end
 
class Spriteset_Battle
 
  attr_accessor   :viewport3
 
end
 
class Spriteset_Weather
  def dimness
    return 0 if AC_NODIMNESS
    (@power * 6).to_i
  end
end
 
module DataManager
  class << self
  alias climate_msc make_save_contents
  alias climate_esc extract_save_contents
  end
  def self.make_save_contents
    contents = climate_msc
    contents[:climate] = $climates
    contents
  end
  def self.extract_save_contents(contents)
    climate_esc(contents)
    $climates = contents[:climate]
  end
end
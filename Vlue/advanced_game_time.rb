#Advanced Game Time + Night/Day v1.6e
#----------#
#Features: Provides a series of functions to set and recall current game time
#          as well customizable tints based on current game time to give the
#          appearance of night and day in an advanced and customizable way.
#
#Usage:   Script calls:
#           GameTime.sec?                      #current second
#           GameTime.min?                      #current minute
#           GameTime.hour?                     #current hour
#           GameTime.hour_nom?                 #current hour (12-hour)
#           GameTime.day?                      #current day of month
#           GameTime.day_week?                 #current day of the week
#           GameTime.day_year?                 #current day of the year
#           GameTime.month?                    #current month
#           GameTime.year?                     #current year
#           GameTime.year_post("set")          #changes the year post to set
#           GameTime.pause_tint(true/false)    #pauses/unpauses tint
#           GameTime.notime(true/false)        #stops time based on true/false
#           GameTime.change(s,m,h,d,dw,mn,y)      #manually set the time
#                                    seconds,minutes,hours,days,weekday,months,years
#                                              any can be nil to not be changed
#           GameTime.set("handle",n)           #increases a certain time portion
#                                             valid arguments are:
#                                               addsec,addmin,addhour,addday
#                                               addmonth,addyear
#                                             and:
#                                               remsec,remmin,remhour,remday
#                                               remmonth,remyear
#           GameTime.clock?(true/false)        #hides/shows the clock
#           GameTime.save_time                 #saves the current time
#           GameTime.load_time                 #loads the saved time
#
#         Message Codes:
#           GTSEC    #Inputs the current second
#           GTMIN    #Inputs the current minute
#           GTHOUR   #Inputs the current hour
#           GTMERI   #Inputs AM/PM depending
#           GTDAYN   #Inputs the day of the month
#           GTDAYF   #Inputs the day of the week (full)
#           GTDAYA   #Inputs the day of the week (abbreviated)
#           GTMONN   #Inputs the month of the year
#           GTMONF   #Inputs the name of the month (full)
#           GTMONA   #Inputs the name of the month (abbreviated)
#           GTYEAR   #Inputs the current year
#
#         Map Note Tags: (These go in the note box of Map Properties)
#           Notint   #These maps will not tint!
#           Notime   #Stops time from moving in that map
#        
#Customization: Set below, in comments.
#
#Examples: GameTime.pause_tint(false)
#          GameTime.change(nil,30,4,1,1,1,2012)
#          GameTime.set("addyear",5)
#          GameTime.clock?(true)
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
 
#_# BEGIN_CUSTOMIZATION #_#
 
 
#What time a new game starts at: [sec, min, hour, day, month, year]
START_TIME = [0,0,0,0,0,0]
#Wether or not to set time to PC (Real) Time
$USE_REAL_TIME = false
#Time does not increase while the message window is visible:
NOTIMEMESSAGE = false
#Time does not increase unless you are on the map
PAUSE_IN_MENUS = true
#Time does not increase if you are in battle
NOBATTLETIME = false
#Clock is shown
USECLOCK = true
#Set to true to have the clock show up in the menu!
USECLOCK_MENU = false
#Set the format for the clock both in and out of menu
#1. hh:mm am/pm
#2. Sun dd hh:mm am/pm
#3. Custom clock, see below
CLOCK_FORMAT = 3
MENU_CLOCK_FORMAT = 3
#Set to true for a Twenty four hour clock
TF_HOUR_CLOCK = false
#Clock window background opacity
CLOCK_BACK = 75
#Whether to use a special image for the back of the clock or not (Picture folder)
CUSTOM_CLOCK_BACKGROUND = false
#The name of the special image to use
CUSTOM_CLOCK_BACKGROUND_IMAGE = "Spider"
#The offset of the image on the x-axis
CUSTOM_CLOCK_BACKGROUND_X = 0
#The offset of the image on the y-axis
CUSTOM_CLOCK_BACKGROUND_Y = 0
#Button to be used to toggle the clock
CLOCK_TOGGLE = :SHIFT
#Toggle Options - :off, :hour12, :hour24
CLOCK_TOGGLE_OPTIONS = [:off,:hour12,:hour24]
#X and Y position of clock
CLOCK_X = Graphics.width - 175
CLOCK_Y = Graphics.height - 48 - 24 - 12
#Finetune the width of the clock window here:
CLOCK_WIDTH = 175
#Whether or not those little dots on the clock blink
USE_BLINK = true
#The speed at which they blink
BLINK_SPEED = 120
#Here is where you would insert the array of commands for the custom clock:
CUSTOM_CLOCK = ["weekshort"," ","day"," ","year","yearp"]
CUSTOM_CLOCK2 = ["hourtog","blinky","min"," ","meri"]
#Available commands for CUSTOM_CLOCK:
# "sec" - seconds         "min" - minutes
# "hour" - hour (24)      "hour12" - hour (12)
# "hourtog" - hour toggle (12, 24)
# "meri" - AM/PM          "day" - day of the month
# "weekshort" - day of the week abbr
# "weeklong" - day of the week long
# "month" - month         "monthshort" - month name abbr
# "monthlong" - month name
# "year" - year           "yearp" - year post
# "blinky" - those blinky dots
 
 
#Using KHAS lighting effects script? Turn this on to use that tint
USE_KHAS = false
#Using Victor Engine Light effects? Turn this on to use that tint
USE_VICTOR = false
#Variables that count down each gametime second/minute
TIMER_VARIABLES = []
 
#Use Tint in the Battles
BATTLE_TINT = false
 
#Time it takes for a second (or minute) to pass, in frames by default
#(Frame rate is 60 frames per second)
DEFAULT_TIMELAPSE = 60
#Variable ID containing the current speed of time!
TIMELAPSE_VARIABLE = 80
#Whether to use seconds or not
NOSECONDS = true
#Number of seconds in a minute
SECONDSINMIN = 60
#Number of minutes in an hour
MINUTESINHOUR = 60
#Number of hours in a day
HOURSINDAY = 24
#Names of the days (As little or as many days in the week as you want)
DAYNAMES = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
#Day name abbreviations
DAYNAMESABBR = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
#Number of days in each month (Also represents number of months in a year)
MONTHS = [31,28,31,30,31,30,31,31,30,31,30,31]
#Names of the months
MONTHNAMES = ["January","February","March","April","May","June",
              "July","August","September","October","November","December"]
#Abrreviated names of the months
MONTHNAMESABBR = ["Jan","Feb","Mar","Apr","May","Jun",
                  "Jul","Aug","Sep","Oct","Nov","Dec"]
#The default letters to be posted before the year in dates
DEFAULT_YEAR_POST = "AD"
#NOT YET IMPLEMENTED *IGNORE*
USE_PERIODS = true
                 
#Gradual tint effects! (The hardest part)
#It may look daunting, and it is, but here is where you put the tint
#to be shown at each hour (the actual tint is usually somewhere in between)
#The number of Color.new objects here must equal the number of hours in a day
#Starts from hour 0 (or 12am)
#A color object is -> Color.new(r,g,b,a)
# Where r is red,g is green,b is blue,and a is opacity and all are (0-255)
TINTS = [Color.new(30,0,40,155),
         Color.new(20,0,30,135),
         Color.new(20,0,30,135),
         Color.new(10,0,30,135),
         Color.new(10,0,20,125),
         Color.new(0,0,20,125),
         Color.new(80,20,20,125),
         Color.new(130,40,10,105),
         Color.new(80,20,10,85),
         Color.new(0,0,0,65),
         Color.new(0,0,0,35),
         Color.new(0,0,0,15),
         Color.new(0,0,0,0),
         Color.new(0,0,0,0),
         Color.new(0,0,0,5),
         Color.new(0,0,0,15),
         Color.new(0,0,0,25),
         Color.new(0,0,10,55),
         Color.new(80,20,20,85),
         Color.new(130,40,30,105),
         Color.new(80,20,40,125),
         Color.new(10,0,50,135),
         Color.new(20,0,60,135),
         Color.new(30,0,70,155)]
 
#NOT YET IMPLEMENTED *IGNORE*
PERIODS = [["Night",0,5],
           ["Morning",6,11],
           ["Afternoon",12,17],
           ["Evening",18,23]]
         
$gametimeclockvisible = false
#_# END CUSTOMIZATION #_#
         
module GameTime
  def self.run
    $game_time = Current_Time.new
    $game_time_tint = Sprite_TimeTint.new
  end
  def self.update
    return if $game_message.busy? and NOTIMEMESSAGE
    if !SceneManager.scene.is_a?(Scene_Map) and PAUSE_IN_MENUS
      return $game_time_tint.update if SceneManager.scene.is_a?(Scene_Title)
      return $game_time_tint.update if SceneManager.scene.is_a?(Scene_File)
      return unless SceneManager.scene.is_a?(Scene_Battle) and !NOBATTLETIME
    end
    $game_time.update
    $game_time_tint = Sprite_TimeTint.new if $game_time_tint.disposed?
    update_tint
  end
  def self.update_tint
    $game_time_tint.update unless @pause_tint
  end
  def self.sec?
    return $game_time.sec
  end
  def self.min?
    return $game_time.min
  end
  def self.mint?
    return $game_time.min if $game_time.min > 9
    return "0" + $game_time.min.to_s
  end
  def self.hour?
    return $game_time.hour
  end
  def self.hour_nom?
    hour = $game_time.hour
    hour -= 12 if hour > 11
    hour = 12 if hour == 0
    return hour
  end
  def self.meri?
    return "AM" if $game_time.hour < 12
    return "PM"
  end
  def self.day?
    return $game_time.day if $USE_REAL_TIME
    return $game_time.day + 1
  end
  def self.day_week?
    return $game_time.dayweek
  end
  def self.day_year?
    month = month? - 1
    day = day?
    while month > 0
      day += MONTHS[month]
      month -= 1
    end
    day
  end
  def self.day_name
    return DAYNAMES[$game_time.dayweek-1] if $USE_REAL_TIME
    return DAYNAMES[$game_time.dayweek]
  end
  def self.day_name_abbr
    return DAYNAMESABBR[$game_time.dayweek-1] if $USE_REAL_TIME
    return DAYNAMESABBR[$game_time.dayweek]
  end
  def self.month_name_abbr
    return MONTHNAMESABBR[$game_time.month-1] if $USE_REAL_TIME
    return MONTHNAMESABBR[$game_time.month]
  end
  def self.month?
    return $game_time.month if $USE_REAL_TIME
    return $game_time.month + 1
  end
  def self.month_name
    return MONTHNAMES[$game_time.month-1] if $USE_REAL_TIME
    return MONTHNAMES[$game_time.month]
  end
  def self.year?
    return $game_time.year
  end
  def self.pause_tint(set)
    @pause_tint = set
    $game_time_tint.visible = false if @pause_tint
    $game_time_tint.force_update if !@pause_tint
  end
  def self.tint_paused?
    @pause_tint
  end
  def self.change(s = nil,m = nil,h = nil,d = nil,dw = nil, mn = nil,y = nil)
    $game_time.manual(s,m,h,d,dw,mn,y)
  end
  def self.set(handle,n)
    $game_time.forward(handle,n)
  end
  def self.clock?(set)
    SceneManager.scene.clock_visible?(set)
  end
  def self.year_post(set)
    $game_time.year_post = set
  end
  def self.save_time
    $saved_game_time = $game_time.dup
  end
  def self.load_time
    $game_time = $saved_game_time.dup
  end
  def self.no_time_map
    note = $game_map.map_note
    /Notime/ =~ note
    return false unless $~
    return true
  end
  def self.notime(set)
    $game_time.notime = set
  end
 
  class Current_Time
   
    attr_reader     :sec
    attr_reader     :min
    attr_reader     :hour
    attr_reader     :day
    attr_reader     :dayweek
    attr_reader     :month
    attr_reader     :year
    attr_accessor   :year_post
    attr_accessor   :notime
    attr_accessor   :toggle
    attr_accessor   :hour24
   
    def initialize
      reset_all_values
    end
    def reset_all_values
      @sec = START_TIME[0]
      @min = START_TIME[1]
      @hour = START_TIME[2]
      @day = START_TIME[3]
      @dayweek = 0
      @month = START_TIME[4]
      @year = START_TIME[5]
      @notime = false
      @year_post = DEFAULT_YEAR_POST
      @toggle = 0
    end
    def update
      return realtime if $USE_REAL_TIME
      return if GameTime.no_time_map or @notime
      $game_variables[TIMELAPSE_VARIABLE] = DEFAULT_TIMELAPSE if $game_variables[TIMELAPSE_VARIABLE] <= 0
      return unless Graphics.frame_count % $game_variables[TIMELAPSE_VARIABLE] == 0
      NOSECONDS ? addmin(1) : addsec(1)
      update_timers
    end
    def update_timers
      return unless TIMER_VARIABLES.size > 0
      for i in TIMER_VARIABLES
        $game_variables[i] -= 1 unless $game_variables[i] == 0
      end
    end
    def get_next_toggle
      @toggle = 0 unless @toggle
      @toggle += 1
      @toggle = 0 if @toggle == CLOCK_TOGGLE_OPTIONS.size
      return CLOCK_TOGGLE_OPTIONS[@toggle]
    end
    def set_hour24(value)
      @hour24 = value
    end
    def realtime
      @sec = Time.now.sec
      @sec = 0 if @sec == 60
      @min = Time.now.min
      @hour = Time.now.hour
      @day = Time.now.day
      @dayweek = Time.now.wday
      @month = Time.now.month
      @year = Time.now.year
      0
    end
    def addsec(s)
      @sec += s
      return unless @sec == SECONDSINMIN
      @sec = 0
      addmin(1)
    end
    def addmin(m)
      @min += m
      return unless @min == MINUTESINHOUR
      @min = 0
      addhour(1)
    end
    def addhour(h)
      @hour += h
      return unless @hour == HOURSINDAY
      @hour = 0
      addday(1)
    end
    def addday(d)
      @day += d
      @dayweek += d
      @dayweek = 0 if @dayweek == DAYNAMES.size
      return unless @day == MONTHS[@month]
      @day = 0
      addmonth(1)
    end
    def addmonth(mn)
      @month += mn
      return unless @month == MONTHS.size
      @month = 0
      addyear(1)
    end
    def addyear(y)
      @year += y
    end
    def manual(s = nil,m = nil,h = nil,d = nil,dw = nil,mn = nil,y = nil)
      @sec = s if !s.nil?
      @sec = SECONDSINMIN - 1 if @sec >= SECONDSINMIN
      @min = m if !m.nil?
      @min = MINUTESINHOUR - 1 if @min >= MINUTESINHOUR
      @hour = h if !h.nil?
      @hour = HOURSINDAY - 1 if @hour >= HOURSINDAY
      @day = d if !d.nil?
      @day = MONTHS[@month] - 1 if @day >= MONTHS[@month]
      @dayweek = dw if !dw.nil?
      @dayweek = 0 if @dayweek >= DAYNAMES.size
      @month = mn if !mn.nil?
      @month = MONTHS.size - 1 if @month >= MONTHS.size
      @year = y if !y.nil?
    end
    def forward(handle,n)
      handle = handle.to_s + "(1)"
      n.times do |s| eval(handle) end
    end
    def remsec(s)
      @sec -= s
      return unless @sec == -1
      @sec = SECONDSINMIN
      remmin(1)
    end
    def remmin(m)
      @min -= m
      return unless @min == -1
      @min = MINUTESINHOUR
      remhour(1)
    end
    def remhour(h)
      @hour -= h
      return unless @hour == -1
      @hour = HOURSINDAY - 1
      remday(1)
    end
    def remday(d)
      @day -= d
      @dayweek -= d
      @dayweek = DAYNAMES.size - 1 if @dayweek == -1
      return unless @day == -1
      @day = MONTHS[@month] - 1
      remmonth(1)
    end
    def remmonth(mn)
      @month -= mn
      return unless @month == -1
      @month = MONTHS.size - 1
      remyear(1)
    end
    def remyear(y)
      @year -= y
    end
  end
 
  class Sprite_TimeTint < Sprite_Base
    def initialize(viewport = nil)
      super(viewport)
      self.z = 10
      create_contents
      update
      @old_tint = [0,0,0,0]
      @old_time = -1
    end
    def create_contents
      self.bitmap = Bitmap.new(Graphics.width,Graphics.height)
      self.visible = false
    end
    def force_update
      @old_time = -1
      @old_tint = [0,0,0,0]
      update
    end
    def update
      return true if GameTime.tint_paused?
      return use_default if SceneManager.scene.is_a?(Scene_Battle) and BATTLE_TINT
      return use_khas if USE_KHAS
      return use_victor if USE_VICTOR
      return use_default
    end
    def use_default
      return if self.disposed?
      create_contents if self.bitmap.height != Graphics.height
      create_contents if self.bitmap.width != Graphics.width
      self.visible = SceneManager.scene.is_a?(Scene_Map)
      self.visible = true if SceneManager.scene.is_a?(Scene_Battle) and BATTLE_TINT
      self.visible = false if SceneManager.scene.is_a?(Scene_Title)
      self.visible = false if no_tint
      return unless self.visible
      min = $game_time.min
      return if min == @old_time
      @old_time = min
      rgba = get_new_tint(min)
      return if rgba == @old_tint
      @old_tint = rgba
      self.bitmap.clear
      self.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(rgba[0],rgba[1],rgba[2],rgba[3]))
    end
    def use_khas      
      begin
      temp = $game_map.light_surface.opacity
      rescue
      return
      end
      self.visible = false
      if no_tint
        $game_map.effect_surface.set_color(0,0,0)
        $game_map.effect_surface.set_alpha(0)
      end
      return if no_tint
      min = $game_time.min
      return if min == @old_time
      @old_time = min
      rgba = get_new_tint(min)
      return if rgba == @old_tint
      @old_tint = rgba
      $game_map.effect_surface.set_color(rgba[0],rgba[1],rgba[2])
      $game_map.effect_surface.set_alpha(rgba[3])
    end
    def no_tint
      return if $game_map.nil?
      note = $game_map.map_note
      /Notint/ =~ note
      return false unless $~
      return true
    end
    def use_victor
      return if $game_map.nil?
      self.visible = false
      $game_map.screen.shade.change_color(0,0,0,0) if no_tint
      $game_map.screen.shade.change_opacity(0) if no_tint
      return if no_tint
      $game_map.screen.shade.show if !$game_map.screen.shade.visible
      min = $game_time.min
      return if min == @old_time
      @old_time = min
      rgba = get_new_tint(min)
      return if rgba == @old_tint
      @old_tint = rgba
      $game_map.screen.shade.change_color(rgba[0],rgba[1],rgba[2],0)
      $game_map.screen.shade.change_opacity(rgba[3],0)
    end
    def get_new_tint(min)
      ctint = TINTS[$game_time.hour]
      ntint = TINTS[$game_time.hour + 1] unless $game_time.hour + 1 == HOURSINDAY
      ntint = TINTS[0] if $game_time.hour + 1 == HOURSINDAY
      r = ctint.red.to_f - ((ctint.red.to_f - ntint.red) * (min.to_f / MINUTESINHOUR))
      g = ctint.green.to_f - ((ctint.green.to_f - ntint.green) * (min.to_f / MINUTESINHOUR))
      b = ctint.blue.to_f - ((ctint.blue.to_f - ntint.blue) * (min.to_f / MINUTESINHOUR))
      a = ctint.alpha.to_f - ((ctint.alpha.to_f - ntint.alpha) * (min.to_f / MINUTESINHOUR))
      return [r,g,b,a]
    end
  end
 
  class Window_GameClock < Window_Base
    def initialize
      super(CLOCK_X,CLOCK_Y,CLOCK_WIDTH,clock_height)
      self.opacity = CLOCK_BACK unless SceneManager.scene.is_a?(Scene_Menu)
      update
      self.visible = $gametimeclockvisible unless SceneManager.scene.is_a?(Scene_Menu)
    end
    def clock_height
      return 80 if !CUSTOM_CLOCK2.nil? and CLOCK_FORMAT == 3 and SceneManager.scene.is_a?(Scene_Map)
      return 80 if !CUSTOM_CLOCK2.nil? and MENU_CLOCK_FORMAT == 3 and SceneManager.scene.is_a?(Scene_Menu)
      return 56
    end
    def update
      if NOSECONDS && @set_minute == $game_time.min
        if Graphics.frame_count % BLINK_SPEED / 2 == 0 && USE_BLINK
          return
        end
      end
      contents.clear
      @set_minute = $game_time.min if NOSECONDS
      if SceneManager.scene.is_a?(Scene_Map)
        v = CLOCK_FORMAT
      else
        v = MENU_CLOCK_FORMAT
      end
      bon = TF_HOUR_CLOCK ? 2 : 0
      if $game_time.hour24
        bon = $game_time.hour24 ? 2 : 0
      end
      string = normal_clock if v + bon == 1
      string = dated_clock if v + bon == 2
      string = military_clock if v + bon == 3
      string = dated_military_clock if v + bon == 4
      string = custom(CUSTOM_CLOCK) if v == 3
      string2 = custom(CUSTOM_CLOCK2) if !CUSTOM_CLOCK2.nil? and v == 3
      contents.draw_text(0,0,contents.width,24,string,1)
      contents.draw_text(0,24,contents.width,24,string2,1) if !CUSTOM_CLOCK2.nil? and v == 3
    end
    def military_clock
      hour = $game_time.hour
      minute = $game_time.min
      if hour < 10 then hour = " " + hour.to_s else hour.to_s end
      if minute < 10 then minute = "0" + minute.to_s else minute.to_s end
      string =  hour.to_s + blinky + minute.to_s
      return string
    end
    def dated_military_clock
      hour = $game_time.hour
      minute = $game_time.min
      dayweek = DAYNAMESABBR[$game_time.dayweek]
      day = $game_time.day
      day += 1 unless $USE_REAL_TIME
      if hour < 10 then hour = " " + hour.to_s else hour.to_s end
      if minute < 10 then minute = "0" + minute.to_s else minute.to_s end
      if day < 10 then day = " " + day.to_s end
      string = dayweek.to_s + " " + day.to_s + " "
      string += hour.to_s + blinky + minute.to_s
      return string
    end
    def normal_clock
      meri = "AM"
      hour = $game_time.hour
      minute = $game_time.min
      if hour > 11 then meri = "PM" end
      if hour == 0 then hour = 12; meri = "AM" end
      if hour > 12 then hour -= 12 end
      if hour < 10 then hour = " " + hour.to_s else hour.to_s end
      if minute < 10 then minute = "0" + minute.to_s else minute.to_s end
      string =  hour.to_s + blinky + minute.to_s + " " + meri
      return string
    end
    def dated_clock
      meri = "AM"
      hour = $game_time.hour
      minute = $game_time.min
      dayweek = DAYNAMESABBR[$game_time.dayweek]
      day = $game_time.day
      day += 1 unless $USE_REAL_TIME
      if hour > 11 then meri = "PM" end
      if hour == 0 then hour = 12; meri = "AM" end
      if hour > 12 then hour -= 12 end
      if hour < 10 then hour = " " + hour.to_s else hour.to_s end
      if minute < 10 then minute = "0" + minute.to_s else minute.to_s end
      if day < 10 then day = " " + day.to_s end
      string = dayweek.to_s + " " + day.to_s + " "
      string += hour.to_s + blinky + minute.to_s + " " + meri
      return string
    end
    def blinky
      return ":" unless USE_BLINK
      return " " if Graphics.frame_count % BLINK_SPEED > (BLINK_SPEED / 2)
      return ":"
    end
    def custom(array)
      array = array.clone
      if array.include?("hourtog")
        bon = TF_HOUR_CLOCK
        bon = $game_time.hour24 if $game_time.hour24
        index = array.index("hourtog")
        array[index] = bon ? "hour" : "hour12"
      end
      string = ""
      for command in array
        case command
        when "sec"
          sec = $game_time.sec
          sec = "0" + sec.to_s if sec < 10
          string += sec.to_s
        when "min"
          minute = $game_time.min
          minute = "0" + minute.to_s if minute < 10
          string += minute.to_s
        when "hour"
          hour = $game_time.hour
          hour >= 12 ? meri = "PM" : meri = "AM"
          hour = " " + hour.to_s if hour < 10
          string += hour.to_s
        when "hour12"
          hour12 = $game_time.hour
          hour12 -= 12 if hour12 > 12
          hour12 = 12 if hour12 == 0
          string += hour12.to_s
        when "meri"
          hour = $game_time.hour
          hour >= 12 ? meri = "PM" : meri = "AM"
          string += meri.to_s
        when "weekshort"
          dayweek = DAYNAMESABBR[$game_time.dayweek]
          string += dayweek.to_s
        when "weeklong"
          dayweekn = DAYNAMES[$game_time.dayweek]
          string += dayweekn.to_s
        when "day"
          day = $game_time.day
          day += 1 unless $USE_REAL_TIME
          string += day.to_s
        when "month"
          month = $game_time.month
          month += 1 unless $USE_REAL_TIME
          string += month.to_s
        when "monthshort"
          monthna = MONTHNAMESABBR[$game_time.month]
          string += monthna.to_s
        when "monthlong"
          monthn = MONTHNAMES[$game_time.month]
          string += monthn.to_s
        when "year"
          year = $game_time.year
          string += year.to_s
        when "yearp"
          string += $game_time.year_post
        when "blinky"
          string += blinky
        else
          string += command.to_s
        end
      end
      return string
    end
  end
 
end
 
GameTime.run
 
class Window_Base < Window
  alias game_time_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = game_time_convert_escape_characters(text)
    result.gsub!(/GTSEC/) { GameTime.sec? }
    result.gsub!(/GTMIN/) { GameTime.mint? }
    result.gsub!(/GTHOUR/) { GameTime.hour? }
    result.gsub!(/GTMERI/) { GameTime.meri? }
    result.gsub!(/GTDAYN/) { GameTime.day? }
    result.gsub!(/GTDAYF/) { GameTime.day_name }
    result.gsub!(/GTDAYA/) { GameTime.day_name_abbr }
    result.gsub!(/GTMONF/) { GameTime.month? }
    result.gsub!(/GTMONN/) { GameTime.month_name }
    result.gsub!(/GTMONA/) { GameTime.month_name_abbr }
    result.gsub!(/GTYEAR/) { GameTime.year? }
    result
  end
end
 
class Scene_Base
  alias game_time_update update
  def update
    game_time_update
    GameTime.update
  end
  def clock_visible?(set)
    return
  end
end
 
class Scene_Map
  alias game_time_post_transfer post_transfer
  alias game_time_init create_all_windows
  alias game_time_map_update update
  alias game_time_start start
  def start
    game_time_start
    GameTime.update_tint
  end
  def create_all_windows
    game_time_init
    @gametimeclock = GameTime::Window_GameClock.new if USECLOCK
    if CUSTOM_CLOCK_BACKGROUND
      @clockbackground = Sprite.new(@gametimeclock.viewport)
      @clockbackground.bitmap = Cache.picture(CUSTOM_CLOCK_BACKGROUND_IMAGE)
      @clockbackground.x = @gametimeclock.x
      @clockbackground.x += CUSTOM_CLOCK_BACKGROUND_X
      @clockbackground.y = @gametimeclock.y
      @clockbackground.y += CUSTOM_CLOCK_BACKGROUND_Y
      @clockbackground.visible = @gametimeclock.visible
    end
  end
  def post_transfer
    $game_time_tint.force_update
    game_time_post_transfer
  end
  def update
    game_time_map_update
    return unless USECLOCK
    @gametimeclock.update unless SceneManager.scene != self
    if Input.trigger?(CLOCK_TOGGLE) and @gametimeclock.nil? == false
      option = $game_time.get_next_toggle
      if option == :off
        @gametimeclock.visible = false
      else
        @gametimeclock.visible = true
      end
      if option == :hour12
        $game_time.set_hour24(false)
      elsif option == :hour24
        $game_time.set_hour24(true)
      end
      $gametimeclockvisible = @gametimeclock.visible
      @clockbackground.visible = @gametimeclock.visible if @clockbackground
    end
  end
  def clock_visible?(set)
    @gametimeclock.visible = set
	@clockbackground.visible = @gametimeclock.visible if @clockbackground
    $gametimeclockvisible = set
  end
  def update_encounter
    if $game_player.encounter
      $game_time_tint.use_default if BATTLE_TINT
      SceneManager.call(Scene_Battle)
    end
  end
end
 
class Game_Map
  def map_note
    return @map.note unless @map.nil?
  end
end
 
class Scene_Menu
  alias gt_start start
  alias gt_update update
  def start
    gt_start
    @clock = GameTime::Window_GameClock.new if USECLOCK_MENU
    return if @clock.nil?
    @clock.x = 0
    @clock.y = @gold_window.y - @clock.height
    @clock.width = @gold_window.width
    @clock.create_contents
  end
  def update
    gt_update
    @clock.update unless @clock.nil?
    @clock.contents.clear if SceneManager.scene != self and !@clock.nil?
  end
end
 
class Scene_Battle
  alias gametime_pre_terminate pre_terminate
  def pre_terminate
    gametime_pre_terminate
    $game_time_tint.update
  end
end
 
module DataManager
  class << self
  alias gametime_msc make_save_contents
  alias gametime_esc extract_save_contents
  alias gametime_sng setup_new_game
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
  def self.setup_new_game
    gametime_sng
    $game_time = GameTime::Current_Time.new
  end
end
=begin
EST - AUTO TEXT COLOR PLUS
v.1.2
Author: Estriole

Changelog
 v1.0 2013.08.27    - Initial Release
 v1.1 2013.08.28    - Combine with regexp to recognize 'short' word.
                      now it won't color damage if you put mag in the config.
                      if there's bug report to me. since it's really hard dealing with regexp
 v1.2 2013.08.28    - Regexp sure is confusing. but manage to improve the regexp.
                      now it should accept any character beside a-z and 0-9 and _ (underscore).
                      and it just by removing one symbol from regexp that i have tried before and fail.

Introduction
  This script created because i got tired adding \c[4]Nobita\c[0] in the show
message box. so this script make it automatic. each time i wrote Nobita it will
change the color to what i set in the module. useful to color actor names or
places or important things. i also add capitalization correction too. so if you
write nobita. it could fixed to Nobita(what you set in the config) if you want.
both auto color and auto caps correct can be binded to switch too if you don't
want to always using it.

Feature
- auto change color text you defined in the module
- auto correct capitalization to what you defined in the module
- have switch function for both feature (set it to 0 to make it always active).

Author Note
Yes... I made doraemon games.

Feature

=end
module ESTRIOLE
  module AUTOCOLOR
    #PUT THE STRING YOU WANT TO AUTO COLOR BELOW. USEFUL FOR NAMES
    #FORMAT:   "STRING" => COLOR_ID,
    AUTO_SETTING = { #DO NOT TOUCH THIS LINE
    "Nobita" => 2,
    "Doraemon" => 3,
    "Giant" => 4,
    "Suneo" => 5,
    "Shizuka" => 6,
    "Mag" => 10,
    }#DO NOT TOUCH THIS LINE
    
    #return to this color after the text finished. # default 0
    RETURN_COLOR = 0
    
    #switch to activate the auto color. if switch off then don't autocolor
    #set it to 0. if you want to use switch (will always on)
    AUTO_COLOR_SWITCH = 0
    
    #switch to activate the auto capitalization correction. (will use what you define
    #in AUTOSETTING #if switch off then don't auto capitalization correction.
    #set it to 0. if you want to use switch (will always on)
    CORRECT_CAP_SWITCH = 0
    
    START_AUTO_COLOR = true
    START_CORRECT_CAP = true
  end
end

class Game_Switches
  include ESTRIOLE::AUTOCOLOR
  alias est_autocolor_switch_initialize initialize
  def initialize
    est_autocolor_switch_initialize
    @data[AUTO_COLOR_SWITCH] = START_AUTO_COLOR if AUTO_COLOR_SWITCH != 0
    @data[CORRECT_CAP_SWITCH] = START_CORRECT_CAP if CORRECT_CAP_SWITCH != 0
  end
end


class Window_Base < Window
  include ESTRIOLE::AUTOCOLOR
  alias est_auto_text_color_convert_escape_character convert_escape_characters
  def convert_escape_characters(*args, &block)
    result = est_auto_text_color_convert_escape_character(*args, &block)    
    return result if AUTO_COLOR_SWITCH != 0 && !$game_switches[AUTO_COLOR_SWITCH]
    AUTO_SETTING.each_key {|key|
    return_color = RETURN_COLOR
    color        = AUTO_SETTING[key]
    if CORRECT_CAP_SWITCH!= 0 && !$game_switches[CORRECT_CAP_SWITCH]
    result.gsub!(/(?<![\w])#{key}(?![\w])/i) {"\eC[#{color}]#{$&}\eC[#{return_color}]"}
    else
    result.gsub!(/(?<![\w])#{key}(?![\w])/i) {"\eC[#{color}]#{key}\eC[#{return_color}]"}
    end
    }
    result    
  end
end
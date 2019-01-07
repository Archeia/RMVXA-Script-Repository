=begin
#===============================================================================
 Title: Placeholder Maps
 Author: Hime
 Date: Jan 13, 2014
 URL: http://himeworks.com/2014/01/13/placeholder-maps/
--------------------------------------------------------------------------------
 ** Change log 
 Jan 13, 2014
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to create "placeholder maps", which are maps that are
 meant to be replaced with other maps when you load the map. It uses something
 called a "replace map formula", which is just a regular ruby formula.
 
 When you load a map such as transferring from one map to another, the engine
 first determines whether a different map should be loaded or not.
 
 The intention behind this script is to allow you to easily change a map's
 visuals (while keeping all transfer points basically the same) without having
 to find a way to set up your transfer events to check conditions to determine
 which map to go.
 
 For example, suppose you have a castle town map, and later on in the story,
 the castle town is destroyed. Two maps are used to achieve this: one is
 the original castle town, the other is the ruins map. Your castle town may
 have a number of transfer points within the town leading to building interiors,
 or to other maps in your world. This means that you will likely have a number
 of other transfer events that lead to the castle town.
 
 If all you want to do is change the way your castle town looks from the 
 original to your ruined version while keeping all of the transfer points the
 same, you can simply write a replace map formula to load the appropriate map. 
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 To define a replace map formula, note-tag a map with
 
   <replace map>
     FORMULA
   </replace map>
   
 Where the formula can be any valid ruby formula that returns a map ID.
 The following formula variables are available:
 
   p - game party
   t - game troop
   s - game switches
   v - game variables
   
--------------------------------------------------------------------------------
 ** Example
 
 Suppose that when our castle town is destroyed, switch 12 is turned ON.
 Assuming the castle town map is map ID 5, and the castle town ruins map is
 map ID 6, you would note-tag the castle town map with
 
   <replace map>
     if s[12]
       6
     else
       5
     end
   </replace map>
   
 For further organization, you might choose to create a placeholder map for the
 purpose of being replaced.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_PlaceholderMaps] = true
#===============================================================================
# ** Configuration
#=============================================================================== 
module TH
  module Placeholder_Maps
    Regex = /<replace[-_ ]map>(.*?)<\/replace[-_ ]map>/im
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Map
    def replace_map_formula
      load_notetag_replace_map_formula unless @replace_map_formula
      return @replace_map_formula
    end
    
    def load_notetag_replace_map_formula
      @replace_map_formula = ""
      res = self.note.match(TH::Placeholder_Maps::Regex)
      if res
        @replace_map_formula = res[1]
      end
    end
    
    def replace_map_id
      if self.replace_map_formula.empty?
        0
      else
        eval_replace_map_formula
      end
    end
    
    def eval_replace_map_formula(p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
      eval(self.replace_map_formula)
    end
  end
end

module Cache
  
  def self.map(map_id)
    @cache ||= {}
    path = sprintf("Data/Map%03d.rvdata2", map_id)
    @cache[path] = load_data(path) unless @cache.include?(path)
    @cache[path]
  end
end

class Game_Map
  
  alias :th_placeholder_maps_setup :setup
  def setup(map_id)
    new_map_id = get_replace_map_id(map_id)
    th_placeholder_maps_setup(new_map_id)
  end
  
  def get_replace_map_id(map_id)
    new_id = Cache.map(map_id).replace_map_id
    return new_id > 0 ? new_id : map_id
  end
end
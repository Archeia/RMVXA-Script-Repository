=begin
#===============================================================================
 Title: Troop Emerge Name
 Author: Hime
 Date: Nov 13, 2013
 URL: http://himeworks.com/2013/11/14/troop-emerge-name/
--------------------------------------------------------------------------------
 ** Change log
 Nov 13, 2013
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
 
 This script allows you to set a troop emerge name. By default, the troop
 emerge message lists all of the enemies that appear. You can change it to use
 the troop's name, or a custom name of your choice.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 To use the troop's name as the emerge name, create a comment with
 
   <emerge name>
   
 To specify your own custom emerge name, use
 
   <emerge name: your_name_here>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TroopEmergeName"] = true
#===============================================================================
# ** Rest of script
#===============================================================================
module TH
  module Troop_Emerge_Name
    
    Regex = /<emerge[-_ ]name(?::\s*(.+)?\s*)?>/i
  end
end

module RPG
  class Troop
    def emerge_name
      parse_emerge_name unless @emerge_name
      return @emerge_name
    end
    
    def parse_emerge_name
      @emerge_name = ""
      @pages[0].list.each do |cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Troop_Emerge_Name::Regex
          if $1
            @emerge_name = $1
          else
            @emerge_name = self.name
          end
        end
      end
    end
  end
end

class Game_Troop < Game_Unit
  
  alias :th_troop_emerge_message_enemy_names :enemy_names
  def enemy_names
    if !troop.emerge_name.empty?
      return [troop.emerge_name]
    else
      th_troop_emerge_message_enemy_names
    end
  end
end
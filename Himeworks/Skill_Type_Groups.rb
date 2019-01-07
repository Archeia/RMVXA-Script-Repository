=begin
#==============================================================================
 ** Skill Type Groups
 Author: Hime
 Date: Aug 29, 2013
------------------------------------------------------------------------------
 ** Change log
 Aug 29, 2013
   - updated script, changed name
 Jun 13, 2012
   - added multiple skill types
   - Initial release
------------------------------------------------------------------------------
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
 
 This script allows you to define skill groups based on skill type IDs.
 For example, "Black Magic" might consist of "fire", "ice", and "lightning".

 Some people might be able to use "black magic", whereas others can only
 use fire. Rather than displaying 3 separate commands for each type of
 magic, you can use a skill type category to specify that all fire, ice,
 and lightning magic should be grouped under "Black Magic"
 
 In summary:
 
 Skills with multiple skill types can appear under multiple lists.
 Skill types that contain other skill types can collect different lists.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 A single skill can also be assigned multiple skill types by
 tagging the notebox with
  
    <skill type: n>
    
 for some skill type ID n
 
 To assign skill types to different groups of skill categories, set up
 the Stype_Table in the configuration below.
 
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SkillTypeGroups"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module TH
  module Skill_Type_Groups
    
    # this lists the relationships between different skill types (stype)
    # for example, the sample entry says stype 2 contains stype 3, 4, and 5.
    # this means that if you can use stype 2, then you can use any skill
    # that is of type 2, 3, 4, or 5.
    Stype_Table = {
      2 => [3, 4, 5],
      8 => [6, 7]
    }
#==============================================================================
# ** Rest of the script
#==============================================================================
    Stype_Regex = /<skill[-_ ]type:\s*(\d+)\s*>/i

    def self.build_table
      @table = {}
      Stype_Table.each {|cat, stypes|
        @table[cat] = [cat]
        checked = []
        recurse_types(cat, stypes, checked)
      }
    end
    
    def self.recurse_types(cat, stypes, checked)
      return unless stypes
      stypes.each {|id|
        unless checked.include?(id)
          checked << id
          recurse_types(cat, Stype_Table[id], checked) 
        end
        @table[cat] << id
      }
    end

    def self.include?(category, stypes)
      build_table if @table.nil?
      list = @table[category]
      return false unless list
      return !(list & stypes).empty?
    end
  end
end

module RPG
  class Skill < UsableItem
    
    def stype_ids
      load_notetags_multiple_stypes if @stype_ids.nil?
      return @stype_ids
    end
    
    def load_notetags_multiple_stypes
      @stype_ids = [@stype_id]
      results = self.note.scan(TH::Skill_Type_Groups::Stype_Regex)
      p results
      results.each do |res|
        id = res[0].to_i
        @stype_ids << id
      end
    end
  end
end

class Window_SkillList < Window_Selectable
   
  alias :th_skill_type_groups_include? :include?
  def include?(item)  
    item && TH::Skill_Type_Groups.include?(@stype_id, item.stype_ids) || item.stype_ids.include?(@stype_id) || th_skill_type_groups_include?(item)
  end
end
=begin
#===============================================================================
 Title: Use Condition Tags
 Author: Hime
 Date: Nov 4, 2013
--------------------------------------------------------------------------------
 ** Change log
 Nov 4, 2013
   - Initial Release
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
 
 This script allows you to tag items and skills with "use condition" tags.
 For example, maybe "dragon-slaying potions" can only be used by actors that
 have the "dragon_slayer" tag.

--------------------------------------------------------------------------------
 ** Required
 
 Tag Manager
 (http://himeworks.com/2013/03/07/tag-manager/)

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Tag Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To add a "use condition" tag, note-tag any tag objects with
 
   <tag_use_cond: TAG_NAME>
  
#===============================================================================
=end
$imported["TH_TagUseConditions"] = true
#===============================================================================
unless $imported["TH_TagManager"]
  msgbox('"Tag Use Conditions" requires "Tag Manager" to be installed')
  exit
end
#===============================================================================
# ** Configuration
#===============================================================================
module TagManager
  module Use_Condition_Tags
    
    Tag_Use_Cond_Regex = /<tag[-_ ]use[-_ ]cond:\s*(.*)\s*>/i
    
#===============================================================================
# ** Rest of Script
#===============================================================================
    
    def use_condition_tags
      load_notetag_use_condition_tags if @use_cond_tags.nil?
      return @use_cond_tags
    end
    
    def load_notetag_use_condition_tags
      @use_cond_tags = []
      res = self.note.scan(Tag_Use_Cond_Regex)
      res.each {|group|
        @use_cond_tags.push(parse_condition_tags(group[0].downcase.split(Tag_Delimiter)))
      }
    end
  
    alias :use_cond_tags :use_condition_tags
  end
end

module RPG
  
  class BaseItem
    include TagManager::Use_Condition_Tags
  end
end

class Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # Returns true if all "tag usable" conditions are met.
  #-----------------------------------------------------------------------------
  def item_tag_use_conditions_met?(item)
    return true if item.use_cond_tags.empty?
    return false unless item.use_cond_tags.any? {|group|
      (group[0] - tags).empty? && (group[1] & tags).empty?
    }
    return true
  end
  
  alias :th_use_condition_tags_usable? :usable?
  def usable?(item)
    return false if item && !item_tag_use_conditions_met?(item)
    th_use_condition_tags_usable?(item)
  end
end

class Window_BattleItem < Window_ItemList
  
  #-----------------------------------------------------------------------------
  # Overwrite. Need to check whether the current actor can use it
  #-----------------------------------------------------------------------------
  def enable?(item)
    BattleManager.actor.usable?(item)
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Want it to show all items that can be used in battle
  #-----------------------------------------------------------------------------
  def include?(item)
    item ? item.is_a?(RPG::UsableItem) && BattleManager.actor.occasion_ok?(item) : false
  end
end
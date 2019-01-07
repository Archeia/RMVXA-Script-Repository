=begin
#==============================================================================
 Title: Tag Manager
 Author: Hime
 Date: Dec 14, 2013
------------------------------------------------------------------------------
 ** Change log
 1.5 Dec 14, 2013
   - increased compatibility for "equippable?" method
 1.4 Aug 28, 2013
   - fixed bug where actors can equip anything
 1.3 Mar 6, 2013 
   - added tags to Maps
   - integrated several plugins with this script
 1.2 Nov 3, 2012
   - made more compatible with th_core scripts and other managers
 1.1 Nov 1, 2012
   - fixed bug where multiple tags were not being parsed
 1.0 Oct 26, 2012
   - Initial Release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
------------------------------------------------------------------------------
 
 This script allows you to assign "database object tags", or basically "tags",
 to various database objects. These are simple strings that are stored with
 the object and can be referenced if needed.
 
 There are two types of tags:

 1. Object tags.
    - These are tags that will be stored with your objects.
 
 2. Condition tags.
    - These are special tags that can be used to filter objects by tags.
      For example, you can use them to prevent an actor from equipping something
    
 To add an object tag, notetag the database object with
    <tag: string1 string2 string3>
    
 Where each string is an arbitrary non-whitespace terminated sequence of
 characters (eg: male, female, dwarf, elf, blah, carrot)
 
 You may have multiple object tags for a single object.
    
 To add a condition tag, notetag the database object with
    <tag_cond: tag1 tag2 ... > 
    
 For special map conditions, you can use the notetag
    <map_cond: tag1 tag2 ... >
 
 Tag conditions are specified as logical expressions.
 Conditions of the form
    <tag_cond: tag1 tag2 tag3 ... >
 Mean that tag1 AND tag2 AND tag3 AND ... must all be satisfied.
 
 Conditions of the form
    <tag_cond: tag1>
    <tag_cond: tag2>
 Mean that the requirements are satisfied if tag1 OR tag2 are present.
 
 You also have the NOT operator, which can be specified using the ! sign,
 as shown:
    <tag_cond: !tag1>
    
 Which means the condition is satisfied only if tag1 does NOT exist.
 
 You can mix all three of the above operators to create all kinds of logical
 expressions. For example
 
    <tag_cond: male soldier !human>
    <tag_cond: female monk elf>
    
 This translates to
   (male AND soldier AND NOT human) OR (female AND monk AND elf)
   
 This script does not handle parentheses, so you are unable to say things
 like !(a or b). Instead, you should expand it to !a and !b and then
 apply the logic there.
    
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_TagManager"] = 1.5
$imported["TH_TagManager"] = 1.5
#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
module TagManager
  
  # delimiter to use to separate tags in a single line. 
  Tag_Delimiter = " "   
#-------------------------------------------------------------------------------
# Rest of Script
#-------------------------------------------------------------------------------
  Tag_Regex = /<tag:\s*(.*)\s*>/i
  Tag_Cond_Regex = /<tag[-_ ]cond:\s*(.*?)>/i
  Map_Cond_Regex = /<map[-_ ]cond:\s*(.*?)>/i
  
  def object_tags
    return @tags unless @tags.nil?
    load_notetag_object_tags
    return @tags
  end
  
  def condition_tags
    return @cond_tags unless @cond_tags.nil?
    load_notetag_condition_tags
    return @cond_tags
  end
  
  def map_condition_tags
    return @map_cond_tags unless @map_cond_tags.nil?
    load_notetag_map_condition_tags
    return @map_cond_tags
  end
  
  def load_notetag_object_tags
    @tags = []
    res = self.note.scan(Tag_Regex).flatten
    @tags = res ? res.map{|tag| tag.downcase.split(Tag_Delimiter)}.flatten : []
  end
  
  def load_notetag_condition_tags
    @cond_tags = []
    res = self.note.scan(Tag_Cond_Regex)
    res.each {|group|
      @cond_tags.push(parse_condition_tags(group[0].downcase.split(Tag_Delimiter)))
    }
  end
  
  def load_notetag_map_condition_tags
    @map_cond_tags = []
    res = self.note.scan(Map_Cond_Regex)
    res.each {|group|
      @map_cond_tags.push(parse_condition_tags(group[0].downcase.split(Tag_Delimiter)))
    }
  end
  
  # Use two lists to keep track of NOT conditions. The first list
  # holds all tags that must exist, and the second list holds
  # all tags that must not exist.
  def parse_condition_tags(conds)
    lists = [[],[]]
    conds.each {|cond|
      cond[0] == "!" ? lists[1] << cond[1..-1] : lists[0] << cond
    }
    return lists
  end
  
  alias :cond_tags :condition_tags
  alias :tags :object_tags
  alias :map_cond_tags :map_condition_tags
end

module RPG
  
  class BaseItem
    include TagManager
  end
  
  class Map
    include TagManager
  end
end

class Game_BattlerBase
  
  # Returns an array of tags that the battler has
  def tags
    tag_objects.inject([]) {|r, obj| r + obj.object_tags }
  end
  
  def has_tag?(tag)
    tags.include?(tag)
  end
  
  def tag_objects
    states
  end
  
  def map_tag_conditions_met?(item)
    return true if item.map_cond_tags.empty?    
    return item.map_cond_tags.any? {|group|
      (group[0] - $game_map.tags).empty? && (group[1] & $game_map.tags).empty?
    }
  end
  
  # Returns true if there are no tag conditions, or all tag conditions
  # are met, which means all required tags must be present and actor does not
  # have any restricted tags
  def item_tag_conditions_met?(item)
    return true if item.cond_tags.empty?
    return false unless item.cond_tags.any? {|group|
      (group[0] - tags).empty? && (group[1] & tags).empty?
    }
    return true
  end
  
  alias :th_tag_manager_equippable? :equippable?
  def equippable?(item)
    return false unless th_tag_manager_equippable?(item)
    return false if item.is_a?(RPG::Weapon) && !tag_equip_weapon_ok?(item) 
    return false if item.is_a?(RPG::Armor) && !tag_equip_armor_ok?(item)
    return true
  end 
  
  def tag_equip_weapon_ok?(item)
    return false if !map_tag_conditions_met?(item)
    return false if !item_tag_conditions_met?(item)
    return false unless equip_wtype_ok?(item.wtype_id)
    return true
  end
  
  def tag_equip_armor_ok?(item)
    return false if !map_tag_conditions_met?(item)
    return false if !item_tag_conditions_met?(item)
    return false unless equip_atype_ok?(item.atype_id)
    return true
  end
end

class Game_Battler < Game_BattlerBase
      
  alias :th_tag_manager_item_test :item_test
  def item_test(user, item)
    
    # Effects only valid if tag conditions met
    return false unless item_tag_conditions_met?(item)
    return false unless map_tag_conditions_met?(item)
    return th_tag_manager_item_test(user, item)
  end
end

class Game_Party < Game_Unit
    
end

class Game_Enemy < Game_Battler
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def tag_objects
    super + [enemy]
  end
end

class Game_Actor < Game_Battler
   
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def tag_objects
    super + [actor] + [self.class] + equips.compact
  end
end

class Game_Map
  
  def has_tag?(tag)
    tags.include?(tag)
  end
  
  #-----------------------------------------------------------------------------
  # Tags on the map
  #-----------------------------------------------------------------------------
  def tags
    @map.tags
  end
end
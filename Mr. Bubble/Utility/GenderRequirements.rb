# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Gender Requirements                                   │ v1.0 │ (1/07/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Yanfly, script and design references, suggesting to make this script
#--------------------------------------------------------------------------
# This is an add-on script for Gender Functions which allows developers to
# define gender requirements for equipment, skills, and items.
#
# Built-in support for Yanfly Engine Ace - Class System is included.
#--------------------------------------------------------------------------
# ++ Changelog ++
#--------------------------------------------------------------------------
# v1.0 : Initial release. (1/06/2012)
#--------------------------------------------------------------------------
# ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor. This script requires that Gender Functions is also 
# installed in your project.
#
# Place this script below YEA - Class System in your script editor list
# if you have that script installed as well.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following notetags are for Classes, Skills, Items, Weapons, 
# and Armors:
#
# <gender req: genderless>
# <gender requirement: genderless>
#   Requires that the actor be genderless in order to use/equip the skill, 
#   item, weapon, or armor. Each tag listed above has the same effect. 
#   Simply choose whichever one you prefer to type.
#  
# <gender req: m>
# <gender req: male>
# <gender requirement: male>
#   Requires that the actor be male in order to use/equip the skill, 
#   item, weapon, or armor. Each tag listed above has the same effect. 
#   Simply choose whichever one you prefer to type.
#  
# <gender req: f>
# <gender req: female>
# <gender requirement: female>
#   Requires that the actor be female in order to use/equip the skill, 
#   item, weapon, or armor. Each tag listed above has the same effect. 
#   Simply choose whichever one you prefer to type.
# 
# Multiple gender requirement tags may be added to the same notebox.
#
# Class gender requirements are currently only for YEA - Class System.
# Gender requirements for classes do not affect the "Change Class..." 
# event command.
#--------------------------------------------------------------------------
# The following notetags are for Actors, Classes, and Enemies:
#
# <gender req: ignore>
# <gender requirement: ignore>
#   Allows the actor, class, or enemy to ignore any imposed gender 
#   requirements for classes, skills, items, weapons, and armors. Each 
#   tag listed above has the same effect. Simply choose whichever one 
#   you prefer to type.
#
# If you need very specifc exceptions made regarding gender requirements,
# it is recommended that you create your own Armor Type(s) in your
# Database and define equip permissions through that.
#--------------------------------------------------------------------------
# ++ Compatibility ++
#--------------------------------------------------------------------------
# This script does not overwrite any default VXA methods. All default
# methods modified in this script are aliased.
#
# This script has built-in compatibility with the following scripts:
#     - Yanfly Engine Ace - Class System
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
# ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. Newest 
# versions of this script can be found at http://mrbubblewand.wordpress.com/
#==========================================================================

$imported = {} if $imported.nil?
$imported["BubsGenderRequirements"] = true

#==========================================================================
# ++ THIS SCRIPT CONTAINS NO USER CUSTOMIZATION MODULE ++
#==========================================================================

if $imported["BubsGenderFunctions"]
#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp 
    module BaseItem
      GENDER_REQUIREMENTS = 
        /<GENDER[_\s](?:REQUIREMENT[S]?|req):\s*(\w*)>/i
    end # module BaseItem
  end # module Regexp 
end # module Bubs


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_gender_requirements load_database; end
  def self.load_database
    load_database_bubs_gender_requirements # alias
    load_notetags_bubs_gender_requirements
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_gender_requirements
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_gender_requirements
    groups = [$data_actors, $data_classes, $data_skills, $data_items, 
      $data_weapons, $data_armors, $data_enemies]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_gender_requirements
      end
    end
  end
  
end # module DataManager


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :gender_requirements
  attr_accessor :ignore_gender_requirements
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_gender_requirements
  #--------------------------------------------------------------------------
  def load_notetags_bubs_gender_requirements
    @gender_requirements = []
    @ignore_gender_requirements = false
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::BaseItem::GENDER_REQUIREMENTS
        case $1.upcase
        when "IGNORE"
          next unless self.is_a?(RPG::Actor) || 
            self.is_a?(RPG::Class) || 
            self.is_a?(RPG::Enemy)
          @ignore_gender_requirements = true
          
        when "GENDERLESS", "NONE"
          next if self.is_a?(RPG::Actor) || self.is_a?(RPG::Enemy)
          @gender_requirements.push(0) unless @gender_requirements.include?(0)
        
        when "MALE", "M"
          next if self.is_a?(RPG::Actor) || self.is_a?(RPG::Enemy)
          @gender_requirements.push(1) unless @gender_requirements.include?(1)
          
        when "FEMALE", "F"
          next if self.is_a?(RPG::Actor) || self.is_a?(RPG::Enemy)
          @gender_requirements.push(2) unless @gender_requirements.include?(2)

        end # case 
      end # case
    } # self.note.split
    
  end # def
end # class RPG::BaseItem


#==============================================================================
# ++ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # new method : gender_conditions_met?
  #--------------------------------------------------------------------------
  def gender_conditions_met?(item)
    return true if item.gender_requirements.empty?
    if actor?
      return true if self.actor.ignore_gender_requirements
      # ensures being a class does not allow ignoring class gender reqs
      unless item.is_a?(RPG::Class)
        return true if self.class.ignore_gender_requirements
      end
      return true if item.gender_requirements.include?(self.actor.gender)
    else
      return true if self.enemy.ignore_gender_requirements
      return true if item.gender_requirements.include?(self.enemy.gender)
    end 
    return false
  end
  
  #--------------------------------------------------------------------------
  # alias : equippable?
  #--------------------------------------------------------------------------
  alias equippable_bubs_gender_requirements equippable?
  def equippable?(item) 
    return false unless equippable_bubs_gender_requirements(item) # alias
    return false unless gender_conditions_met?(item)
    return true
  end
  
  #--------------------------------------------------------------------------
  # alias : skill_conditions_met?
  #--------------------------------------------------------------------------
  alias skill_conditions_met_bubs_gender_requirements skill_conditions_met?
  def skill_conditions_met?(skill)
    return false unless gender_conditions_met?(skill)
    return skill_conditions_met_bubs_gender_requirements(skill) # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : item_conditions_met?
  #--------------------------------------------------------------------------
  alias item_conditions_met_bubs_gender_requirements item_conditions_met?
  def item_conditions_met?(item)
    return false unless gender_conditions_met?(item)
    return item_conditions_met_bubs_gender_requirements(item) # alias
  end

end # class Game_BattlerBase


#==============================================================================
# ++ Window_ClassList
#==============================================================================
if $imported["YEA-ClassSystem"]

class Window_ClassList < Window_Selectable
  #--------------------------------------------------------------------------
  # alias : include?
  #--------------------------------------------------------------------------
  alias include_bubs_gender_requirements include?
  def include?(item)
    return false unless @actor.gender_conditions_met?(item)
    return include_bubs_gender_requirements(item) # alias
  end
  
end # class Window_ClassList

end # if $imported["YEA-ClassSystem"]

end # if $imported["BubsGenderFunctions"]
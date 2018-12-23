# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Blood Magic                                           │ v1.1 │ (1/04/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks to:
#     Yanfly, whose scripts and designs I heavily referenced in order 
#              to learn RGSS3 and make this script
#     VXA Help File
#--------------------------------------------------------------------------
#   - What is Blood Magic? / What are Blood Mages?
#
# "Every mage can feel the dark lure of blood magic. Originally 
# learned from demons, these dark rites tap into the power of blood, 
# converting life into mana and giving the mage command over the minds 
# of others. Such power comes with a price, though; a blood mage must 
# sacrifice his/her own health, or the health of allies, to fuel these 
# abilities." - Dragon Age: Origins, Blood Mage specialization description
#
# Blood magic is a form of magic that uses the power inherent in blood to 
# fuel spellcasting. To put it simply, Blood Magic is the ability to use HP 
# to cast skills instead of MP. This essentially increases the battler's 
# effective MP.
#
#   - What makes Blood Magic different from giving skills a simple HP cost?
#
# The main reason why Blood Magic is incredibly effective in the Dragon Age
# series is the option to have the MP to HP conversion ratio become 
# even more efficient through passive skills or equipment bonuses. However,
# these pieces of gear were generally hard to come by.
#
# Blood Magic MP to HP conversions are done from a 1:x MP to HP ratio 
# where x is the total blood magic bonus value of the caster. This means that 
# the higher the bonus, the more "effective MP" the battler potentially has.
#
# For example, if the caster's Blood Magic MP to HP ratio is 3:1 and the 
# caster has 30 health, the battler's "effective MP" pool becomes 90.
#
#   - Does this mean battlers can just heal themselves for infinite HP?
#
# Not necessarily. In the Dragon Age series, Blood Magic is a sustained
# state that can be freely activated and deactivated by the user. When
# activated, the user gains a significant penalty to conventional healing. 
# In Dragon Age: Origins, the penalty is 90% reduced healing. In
# Dragon Age II, the user cannot be healed at all except through 
# very specific means. VX Ace already has built-in options to
# change recovery effect rates.
#
# Keep in mind that in the Dragon Age series, the maximum Health and Mana
# values for player characters were relatively small, never exceeding three 
# digits each. Spell costs were also relatively high. Using the default Blood 
# Magic settings in this script with the default VX Ace database 
# values/settings is not recommended. 
#
# Many of the Blood Magic mechanics provided in this script go beyond what
# was allowed in the Dragon Age series. It is up to developers to choose how 
# close they wish to stick to the source material.
#
# How balanced Blood Magic can be in a game is left up to the developer.
#--------------------------------------------------------------------------
# ++ Changelog ++
#--------------------------------------------------------------------------
# v1.1 : Bugfix update. (1/04/2012)
# v1.0 : Initial release. (1/03/2012)
#--------------------------------------------------------------------------
# ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Notetags are for Actors, Classes, Weapons, Armors, Enemies, 
# and States:
#
# <blood magic>
#   Activates Blood Magic for the given Actor, Class, or Enemy. If the Blood
#   Magic tag is applied to a piece of equipment, it will activate Blood Magic
#   when it is equipped. If the Blood Magic tag is applied to a State, it 
#   will activate Blood Magic when the battler is inflicted by it.
#
#   Be very cautious with what you add this tag to especially Actors and 
#   Classes since they will have no way to deactivate innate Blood Magic.
# 
# <blood magic bonus: +n>
# <blood magic bonus: -n>
#   Provides a bonus to the battler's Blood Magic Ratio for MP to HP 
#   conversions. n can be floating point values (ex. 1.3, 0.5, etc.).
#--------------------------------------------------------------------------
# The following Notetags are for Skills and Items only:
#
# <blood magic: required>
#   Forces the skill or item to only be usable when the battler has 
#   Blood Magic activated.
#
# <blood magic: ignore cost>
#   Allows the MP skill to ignore whenever Blood Magic is activated, 
#   allowing the skill to stick to its original MP cost. Tag has no 
#   effect on items.
#
# <blood magic: ignore penalty>
#   Allows the skill or item to ignore the Blood Magic healing penalty 
#   on the target. Use with discretion.
#--------------------------------------------------------------------------
# ++ Blood Magic Formula ++
#--------------------------------------------------------------------------
# This is a simplified internal formula used to calculate Blood Magic 
# costs.
#
#   hp_cost = (mp_cost * BASE_MP_MULTIPLIER) / blood_magic_bonuses
#
# Floating point value results are always rounded up.
#--------------------------------------------------------------------------
# ++ Compatibility ++
#--------------------------------------------------------------------------
# This script does not overwrite any default VXA methods. All default
# methods modified in this script are aliased.
#
# This script has built-in compatibility with the following scripts:
#     - Yanfly Engine Ace - Skill Cost Manager
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
# ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. Newest 
# versions of this script can be found at http://mrbubblewand.wordpress.com/
#==============================================================================

$imported = {} if $imported.nil?
$imported["BubsBloodMagic"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Blood Magic Settings
  #==========================================================================
  module BloodMagic

  #--------------------------------------------------------------------------
  # Global Base Blood Magic Ratio
  #--------------------------------------------------------------------------
  # This value sets the global base conversion ratio for MP to HP.
  BASE_BMR = 1.0
  
  #--------------------------------------------------------------------------
  # Blood Magic Ratio Bonus
  #--------------------------------------------------------------------------
  # These values adds a set Blood Magic Ratio bonus to actors and enemies.
  ACTOR_BMR_BONUS = 0.0       # BMR Bonus for all actors
  ENEMY_BMR_BONUS = 0.0       # BMR Bonus for all enemies
  
  #--------------------------------------------------------------------------
  # Minimum Blood Magic Ratio
  #--------------------------------------------------------------------------
  # This value sets the minimum threshold for MP to HP conversions
  MIN_BMR = 1.0
  
  #--------------------------------------------------------------------------
  # Use Maximum Blood Magic Ratio
  #--------------------------------------------------------------------------
  # true  : Use MAX_BMR as the maximum MP to HP ratio
  # false : Unlimited MP to HP ratio
  USE_MAX_BMR = false
  #--------------------------------------------------------------------------
  # Maximum Blood Magic Ratio
  #--------------------------------------------------------------------------
  # This value sets a maximum ratio limit for MP to HP blood magic conversion
  MAX_BMR = 10.0
  
  #--------------------------------------------------------------------------
  # Blood Magic Healing Penalty
  #--------------------------------------------------------------------------
  # Actors and Enemies with Blood Magic activated can receive a penalty to
  # their Recovery Effect Rate where 100.0 is normal healing rate (100%) 
  # and 0.0 is no healing rate (0%).
  #
  # Keep in mind that VX Ace already has a feature which can reduce overall
  # healing taken by the battler. This penalty stacks with those effects.
  BM_HEAL_PENALTY = 0.0
  
  #--------------------------------------------------------------------------
  # Base MP Multiplier for Blood Magic
  #--------------------------------------------------------------------------
  # This value sets an arbitrary multiplier to base MP costs when calculating
  # the HP cost through Blood Magic. This will not affect the actual base 
  # MP cost or the battler's MP cost rate (mcr). Results are rounded up.
  #
  # For example, if the multiplier is x2.0 and a skill costs 4 MP, then the
  # HP cost through Blood Magic will be as though the spell originally 
  # costs 8 MP.
  #
  # Leave this value at 1.0 for unmodified base MP calculations.
  MP_COST_MULTIPLIER = 1.0
  
  #--------------------------------------------------------------------------
  # Blood Magic General/SCM Settings
  #--------------------------------------------------------------------------
  # Some settings only apply when YEA - Skill Cost Manager is installed.
  BM_HP_COST_COLOR = 10         # Color used from "Window" skin.
  BM_HP_COST_SIZE   = 20        # Font size used for Blood Magic HP costs.
  BM_HP_COST_SUFFIX = "%sHP"    # Suffix used for Blood Magic HP costs.
  BM_HP_COST_ICON   = 0         # Icon used for BM HP costs. Set 0 to disable.
  
  end # module BloodMagic
end # module Bubs
  
#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    module BaseItem
      BLOOD_MAGIC_ACTIVE = /<(?:BLOOD_MAGIC|blood magic)>/i
      BLOOD_MAGIC_BONUS = 
            /<(?:BLOOD_MAGIC_BONUS|blood magic bonus):\s*([-+]?\d+\.?\d*)>/i
    end # module BaseItem
    
    module UsableItem
      BLOOD_MAGIC_REQUIRED = /<(?:BLOOD_MAGIC|blood magic):\s*require[d]?>/i
      BLOOD_MAGIC_IGNORE_COST = 
            /<(?:BLOOD_MAGIC|blood magic):\s*ignore cost[s]?>/i
      BLOOD_MAGIC_IGNORE_PENALTY = 
            /<(?:BLOOD_MAGIC|blood magic):\s*ignore penalty>/i
    end # module UsableItem
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_blood_magic load_database; end
  def self.load_database
    load_database_blood_magic # alias
    load_notetags_blood_magic
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_blood_magic 
  #--------------------------------------------------------------------------
  def self.load_notetags_blood_magic
    groups = [$data_actors, $data_classes, $data_skills, $data_items, 
      $data_weapons, $data_armors, $data_enemies, $data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_blood_magic
      end
    end
  end
  
end # module DataManager


#==========================================================================
# ++ Icon
#==========================================================================
module Icon
  #--------------------------------------------------------------------------
  # new method : self.blood_magic_hp_cost
  #--------------------------------------------------------------------------
  def self.blood_magic_hp_cost; return Bubs::BloodMagic::BM_HP_COST_ICON; end
end # module Icon


#==========================================================================
# ++ Window_Base
#==========================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # new method : cost_colours
  #--------------------------------------------------------------------------
  def blood_magic_hp_cost_color; text_color(Bubs::BloodMagic::BM_HP_COST_COLOR); end;
end # class Window_Base


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :blood_magic_active
  attr_accessor :blood_magic_bonus
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_blood_magic
  #--------------------------------------------------------------------------
  def load_notetags_blood_magic
    @blood_magic_active = false
    @blood_magic_bonus = 0.0
    
    self.note.split(/[\r\n]+/).each { |line|
      case line

      when Bubs::Regexp::BaseItem::BLOOD_MAGIC_ACTIVE
        @blood_magic_active = true
      when Bubs::Regexp::BaseItem::BLOOD_MAGIC_BONUS
        @blood_magic_bonus = $1.to_f
      end
    } # self.note.split
  end # def
end # RPG::BaseItem


#==========================================================================
# ++ RPG::UsableItem
#==========================================================================
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :blood_magic_required
  attr_accessor :blood_magic_ignore_cost
  attr_accessor :blood_magic_ignore_penalty
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_blood_magic
  #--------------------------------------------------------------------------
  def load_notetags_blood_magic
    @blood_magic_required = false
    @blood_magic_ignore_cost = false
    @blood_magic_ignore_penalty = false
  
    self.note.split(/[\r\n]+/).each { |line|
      case line

      when Bubs::Regexp::UsableItem::BLOOD_MAGIC_REQUIRED
        @blood_magic_required = true
      when Bubs::Regexp::UsableItem::BLOOD_MAGIC_IGNORE_COST
        @blood_magic_ignore_cost = true
      when Bubs::Regexp::UsableItem::BLOOD_MAGIC_IGNORE_PENALTY
        @blood_magic_ignore_penalty = true
      end
    } # self.note.split
    
  end # def
end


#==========================================================================
# ++ Game_BattlerBase
#==========================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # alias : skill_cost_payable?
  #--------------------------------------------------------------------------
  alias skill_cost_payable_blood_magic skill_cost_payable?
  def skill_cost_payable?(skill)
    if blood_magic_activated?
      return false if self.hp <= skill_blood_magic_hp_cost(skill)
    end
    return skill_cost_payable_blood_magic(skill) # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : skill_conditions_met?
  #--------------------------------------------------------------------------
  alias skill_conditions_met_blood_magic skill_conditions_met?
  def skill_conditions_met?(skill)
    return false unless blood_magic_conditions_met?(skill)
    return skill_conditions_met_blood_magic(skill) # alias
  end
	
  #--------------------------------------------------------------------------
  # alias : item_conditions_met?
  #--------------------------------------------------------------------------
  alias item_conditions_met_blood_magic item_conditions_met?
  def item_conditions_met?(item)
    return false unless blood_magic_conditions_met?(item)
		return item_conditions_met_blood_magic(item) # alias
  end

  #--------------------------------------------------------------------------
  # new method : blood_magic_conditions_met?
  #--------------------------------------------------------------------------
  def blood_magic_conditions_met?(item)
    return false if item.blood_magic_required && !blood_magic_activated?
    return true
  end
  
  #--------------------------------------------------------------------------
  # alias : pay_skill_cost
  #--------------------------------------------------------------------------
  alias pay_skill_cost_blood_magic pay_skill_cost
  def pay_skill_cost(skill)
    pay_skill_cost_blood_magic(skill) # alias
    self.hp -= skill_blood_magic_hp_cost(skill)
  end # def 

  #--------------------------------------------------------------------------
  # alias : skill_mp_cost
  #--------------------------------------------------------------------------
  alias skill_mp_cost_blood_magic skill_mp_cost
  def skill_mp_cost(skill)
    if !skill.blood_magic_ignore_cost && blood_magic_activated?
      return 0
    else
      skill_mp_cost_blood_magic(skill) # alias
    end
  end # def
  
  #--------------------------------------------------------------------------
  # new method : bmr        # Blood Magic Ratio
  #--------------------------------------------------------------------------
  def bmr
    n = Bubs::BloodMagic::BASE_BMR
    if actor?
      n += Bubs::BloodMagic::ACTOR_BMR_BONUS
      n += self.actor.blood_magic_bonus
      n += self.class.blood_magic_bonus
      for equip in equips
        next if equip.nil?
        n += equip.blood_magic_bonus
      end
    else
      n += Bubs::BloodMagic::ENEMY_BMR_BONUS
      n += self.enemy.blood_magic_bonus
    end
    for state in states
      next if state.nil?
      n += state.blood_magic_bonus
    end
    # determine minimum blood ratio
    n = [n, Bubs::BloodMagic::MIN_BMR].max
    # determine maximum blood ratio cap
    n = [n, Bubs::BloodMagic::MAX_BMR].min if Bubs::BloodMagic::USE_MAX_BMR
    return n
  end # def bmr
  
  #--------------------------------------------------------------------------
  # new method : blood_magic_activated?
  #--------------------------------------------------------------------------
  def blood_magic_activated?
    if actor?
      return true if self.actor.blood_magic_active
      return true if self.class.blood_magic_active
      for equip in equips
        next if equip.nil?
        return true if equip.blood_magic_active
      end
    else
      return true if self.enemy.blood_magic_active
    end
    for state in states
      next if state.nil?
      return true if state.blood_magic_active
    end
    return false
  end # def blood_magic_activated?
  
  #--------------------------------------------------------------------------
  # new method : skill_blood_magic_hp_cost
  #--------------------------------------------------------------------------
  # Determines the MP to HP cost conversion
  def skill_blood_magic_hp_cost(skill)
    return 0 if skill.blood_magic_ignore_cost
    
    # default mp cost
    n = (skill.mp_cost * mcr).to_i
    
    if $imported["YEA-SkillCostManager"]
      n += skill.mp_cost_percent * mmp * mcr
      n = [n.to_i, skill.mp_cost_max].min unless skill.mp_cost_max.nil?
      n = [n.to_i, skill.mp_cost_min].max unless skill.mp_cost_min.nil?
    end
    
    n = (n * Bubs::BloodMagic::MP_COST_MULTIPLIER).ceil
    n = (n / bmr).ceil
    n = [n, 0].max
    return n
  end # def skill_blood_magic_hp_cost(skill)

end # class Game_BattlerBase


#==========================================================================
# ++ Game_Battler
#==========================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # alias : make_damage
  #--------------------------------------------------------------------------
  alias make_damage_value_blood_magic make_damage_value
  def make_damage_value(user, item)
    make_damage_value_blood_magic(user, item) # alias
    
    apply_blood_magic_penalty(item)
  end

  #--------------------------------------------------------------------------
  # alias : apply_blood_magic_penalty
  #--------------------------------------------------------------------------
  def apply_blood_magic_penalty(item)
		if item.damage.recover? && self.blood_magic_activated?
			unless item.blood_magic_ignore_penalty    
				penalty = Bubs::BloodMagic::BM_HEAL_PENALTY * 0.01
				value = @result.hp_damage * penalty
				@result.make_damage(value.to_i, item)
			end
		end
  end
  
end


#==========================================================================
# ++ Window_SkillList
#==========================================================================
class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # alias : draw_skill_cost
  #--------------------------------------------------------------------------
  alias draw_skill_cost_blood_magic draw_skill_cost
  def draw_skill_cost(rect, skill)
    
    if @actor.blood_magic_activated? && 
          @actor.skill_blood_magic_hp_cost(skill) > 0
      
      if $imported["YEA-SkillCostManager"]
        draw_blood_magic_hp_skill_cost(rect, skill)
      else
        change_color(blood_magic_hp_cost_color, enable?(skill))
        draw_text(rect, @actor.skill_blood_magic_hp_cost(skill), 2)
      end # $imported
    
    end # end if
    
    draw_skill_cost_blood_magic(rect, skill) # alias
  end # def draw_skill_cost

  #--------------------------------------------------------------------------
  # new method : draw_blood_magic_hp_skill_cost
  #--------------------------------------------------------------------------
  # Used only when YEA - Skill Cost Manager is installed
  def draw_blood_magic_hp_skill_cost(rect, skill)
    return unless @actor.skill_blood_magic_hp_cost(skill) > 0
    change_color(blood_magic_hp_cost_color, enable?(skill))
    #---
    icon = Icon.blood_magic_hp_cost
    if icon > 0
      draw_icon(icon, rect.x + rect.width-24, rect.y, enable?(skill))
      rect.width -= 24
    end
    #---
    contents.font.size = Bubs::BloodMagic::BM_HP_COST_SIZE
    cost = @actor.skill_blood_magic_hp_cost(skill)
    text = sprintf(Bubs::BloodMagic::BM_HP_COST_SUFFIX, cost.group)
    draw_text(rect, text, 2)
    cx = text_size(text).width + 4
    rect.width -= cx
    reset_font_settings
  end # def draw_blood_magic_hp_skill_cost

end # class Window_SkillList
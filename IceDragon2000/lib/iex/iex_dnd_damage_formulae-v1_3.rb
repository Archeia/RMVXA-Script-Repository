#==============================================================================#
# ** IEX(Icy Engine Xelion) - DnD Damage Formulae 
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Item and Skill, Enemy)
# ** Script Type   : Damage Calulation Modifier
# ** Date Created  : 10/29/2010 (DD/MM/YYYY)
# ** Date Modified : 07/17/2011 (DD/MM/YYYY)
# ** Requested By  : lvlercenary
# ** Version       : 1.3
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# >.> ZOMG I don't know why I did this, okay!?
# This was a test to see how the DnD damage formulae works...
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Can be placed in Skill and Item and Enemy noteboxes
#------------------------------------------------------------------------------#
#  <dice: xdy> Dnd format thingy..
#  For those who don't know what that is
#  x is the Number of Dies
#  d is a placeholder... >.< Serves no particular purpose
#  y Is the number of sides on the die
#  You can use as many as this many as you like
# EG 
#   <dice: 2d6>
#  2 dies with 6 sides each
#------------------------------------------------------------------------------#
# V1.1
#------------------------------------------------------------------------------#
#  <crit mult: x>
#  Each weapons and enemies can have there own critical multiplier
#
#  The hit calculation is now done based in the 3.5 Players handbook
#  QUOTE --
#  An attack roll represents your attempt to strike your opponent on
#  your turn in a round. When you make an attack roll, you roll a d20
#  and add your attack bonus. (Other modifiers may also apply to this
#  roll.) If your result equals or beats the target’s Armor Class, you hit
#  and deal damage."
#
#  You can change the dice value if you want to in the customization section..
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# DO NOT USE WITH MELODY! Or you could, but... bad things may happen...
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   RPG::BaseItem, RPG::Enemy
#     new-method :iex_dnd_damage_formula_cache
#     new-method :iex_dnd_dice?
#     new-method :iex_dnd_dice_values
#     new-method :iex_dnd_critical_mod
#   Scene_Title
#     alias      :load_database
#     new-method :load_dndDice_database
#   Game_Battler
#     alias      :calc_hit
#     alias      :calc_eva
#     alias      :make_attack_damage_value
#     alias      :make_obj_damage_value
#     new-method :calculate_dice_value(number, sides)
#     new-method :dice_calc_hit
#     new-method :dice_calc_eva
#     new-method :dice_make_attack_damage_value
#     new-method :dice_make_obj_damage_value
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# 
# (DD/MM/YYYY)
#  10/29/2010 - V1.0  Finished Script
#  10/29/2010 - V1.0a Added the critical Multiplier for weapons
#  01/08/2011 - V1.2  Restored the old damage methods, to allow split formulae
#                     Added pre-caching (Setup on Startup)
#  07/17/2011 - V1.3  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  >.> Don't blame me... I never played DnD before so the damage may be a bit 
#  weird
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_DnD_Damage"] = true
#==============================================================================#
# ** IEX::DND_DAMAGE
#==============================================================================#
module IEX
  module DND_DAMAGE
#==============================================================================#
#                           Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#  
    # Amount Subtracted from any stat in the calculation
    STAT_SUBTRACT = 10 
    # Amount the stat is divided by after subtraction
    STAT_DIVISION = 2
    # Amount of Variance applied to the Damage
    STAT_VARIANCE = 5
    # Critical Multiplier
    CRITICAL_MULT = 3
    # Should Evasion be factored in?
    USE_EVASION = false
    # Dice used for caluclating Hits
    # HIT_DICE = [number of dies, sides]
    HIT_DICE = [1, 20]
#==============================================================================#
#                           End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#  
  end
end

#==============================================================================#
# ** IEX::REGEXP::DND_DAMAGE
#==============================================================================#
module IEX
  module REGEXP
    module DND_DAMAGE
      DICE = /<(?:DICE|die)s?:[ ]*(\d+)d(\d+)>/i
      CRIT_MULT = /<(?:CRITICAL_MULTIPLIER|critical multiplier|crit_mult|crit mult):[ ](\d+(?:.\d+)?)>/i
    end
  end
end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_damage_formula_cache
  #--------------------------------------------------------------------------#   
  def iex_dnd_damage_formula_cache()
    @iex_dnd_cache_complete = false
    @iex_dnd_dies = []
    @iex_dnd_crit_mult = nil
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when IEX::REGEXP::DND_DAMAGE::DICE
        die_val = [$1.to_i, $2.to_i]
        @iex_dnd_dies.push(die_val)
      when IEX::REGEXP::DND_DAMAGE::CRIT_MULT 
        @iex_dnd_crit_mult = $1.to_i
      end  
    }
    @iex_dnd_cache_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_dice?
  #--------------------------------------------------------------------------#   
  def iex_dnd_dice?()
    iex_dnd_damage_formula_cache unless @iex_dnd_cache_complete
    return !@iex_dnd_dies.empty?
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_dice_values
  #--------------------------------------------------------------------------#   
  def iex_dnd_dice_values()
    iex_dnd_damage_formula_cache unless @iex_dnd_cache_complete
    return @iex_dnd_dies
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_critical_mod
  #--------------------------------------------------------------------------#   
  def iex_dnd_critical_mod()
    iex_dnd_damage_formula_cache unless @iex_dnd_cache_complete
    return @iex_dnd_crit_mult
  end
  
end

#==============================================================================#
# ** RPG::Enemy
#==============================================================================#
class RPG::Enemy
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_damage_formula_cache
  #--------------------------------------------------------------------------#   
  def iex_dnd_damage_formula_cache()
    @iex_dnd_cache_complete = false
    @iex_dnd_dies = []
    @iex_dnd_crit_mult = nil
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when IEX::REGEXP::DND_DAMAGE::DICE
        die_val = [$1.to_i, $2.to_i]
        @iex_dnd_dies.push(die_val)
      when IEX::REGEXP::DND_DAMAGE::CRIT_MULT 
        @iex_dnd_crit_mult = $1.to_i
      end  
    }
    @iex_dnd_cache_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_dice?
  #--------------------------------------------------------------------------#   
  def iex_dnd_dice?()
    iex_dnd_damage_formula_cache unless @iex_dnd_cache_complete
    return !@iex_dnd_dies.empty?
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_dice_values
  #--------------------------------------------------------------------------# 
  def iex_dnd_dice_values()
    iex_dnd_damage_formula_cache unless @iex_dnd_cache_complete
    return @iex_dnd_dies
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_dnd_critical_mod
  #--------------------------------------------------------------------------# 
  def iex_dnd_critical_mod()
    iex_dnd_damage_formula_cache unless @iex_dnd_cache_complete
    return @iex_dnd_crit_mult
  end
  
end

#==============================================================================#
# ** Object
#==============================================================================#
class Object ; def min_rand(min = 0, max = 1) ; return rand(max-min) + min end end   

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler 
  
  #--------------------------------------------------------------------------#
  # * new-method :calculate_dice_value
  #--------------------------------------------------------------------------# 
  def calculate_dice_value( number = 1, sides = 6 )
    val = 0
    for i in 0..number ; val += min_rand(1, sides) ; end
    return val
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :calc_hit
  #--------------------------------------------------------------------------# 
  alias :iex_dnd_damage_formulae_calc_hit :calc_hit unless $@
  def calc_hit( user, obj = nil )
    if obj != nil
      if obj.iex_dnd_dice?
        return dice_calc_hit(user, obj)
      end
    end
    return iex_dnd_damage_formulae_calc_hit(user, obj) 
  end
  
  # Dice Method
  #--------------------------------------------------------------------------#
  # * new-method :dice_calc_hit
  #--------------------------------------------------------------------------# 
  def dice_calc_hit( user, obj = nil )
    dnd = IEX::DND_DAMAGE
    if obj == nil                           # for a normal attack
      die_val = calculate_dice_value(dnd::HIT_DICE[0], dnd::DND_DAMAGE::HIT_DICE[1])
      bonus_atk = (user.atk - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION
      targ_def = ((self.def - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION)
      if (die_val + bonus_atk) >= targ_def
        hit = 100
      else
        hit = 0
      end  
      physical = true
    elsif obj.is_a?(RPG::Skill)             # for a skill
      hit = obj.hit                         # get success rate
      physical = obj.physical_attack
    else                                    # for an item
      hit = 100                             # the hit ratio is made 100%
      physical = obj.physical_attack
    end
    if physical                             # for a physical attack
      hit /= 4 if user.reduce_hit_ratio?    # when the user is blinded
    end
    return hit
  end  
  
  #--------------------------------------------------------------------------#
  # * alias-method :calc_eva
  #--------------------------------------------------------------------------# 
  alias :iex_dnd_damage_formulae_calc_eva :calc_eva unless $@
  def calc_eva( user, obj = nil )
    if obj != nil
      if obj.iex_dnd_dice?
        return dice_calc_eva(user, obj)
      end
    end
    return iex_dnd_damage_formulae_calc_eva(user, obj)
  end
  
  # Dice Method
  #--------------------------------------------------------------------------#
  # * new-method :dice_calc_eva
  #--------------------------------------------------------------------------# 
  def dice_calc_eva( user, obj = nil )
    if IEX::DND_DAMAGE::USE_EVASION
      eva = self.eva
      unless obj == nil                       # if it is a skill or an item
        eva = 0 unless obj.physical_attack    # 0% if not a physical attack
      end
      unless parriable?                       # If not parriable
        eva = 0                               # 0%
      end
    else
      eva = 0
    end  
    return eva
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :make_attack_damage_value
  #--------------------------------------------------------------------------# 
  alias :iex_dnd_damage_formulae_make_attack_damage_value :make_attack_damage_value unless $@
  def make_attack_damage_value( attacker )
    if self.actor?
      obj = weapons[0]
      if obj != nil
        if obj.iex_dnd_dice?
          return dice_make_attack_damage_value(attacker)
        end
      end  
    end
    return iex_dnd_damage_formulae_make_attack_damage_value(attacker)
  end
  
  # Dice Method
  #--------------------------------------------------------------------------#
  # * new-method :dice_make_attack_damage_value
  #--------------------------------------------------------------------------# 
  def dice_make_attack_damage_value( attacker )
    dnd = IEX::DND_DAMAGE
    damage = 0
    damage += (attacker.atk - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION
    def_amt = (self.def - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION
    critical_mult = dnd::CRITICAL_MULT
    if attacker.actor?
      for eq in attacker.equips
        next if eq == nil
        critical_mult = eq.iex_dnd_critical_mod if eq.iex_dnd_critical_mod != nil
        dis = eq.iex_dnd_dice_values
        damage += eq.atk
        next if dis.empty?
        for com in dis
          next if com == nil
          damage += calculate_dice_value(com[0], com[1]) 
        end  
      end 
    else
      dis = attacker.enemy.iex_dnd_dice_values
      critical_mult = attacker.enemy.iex_dnd_critical_mod if attacker.enemy.iex_dnd_critical_mod != nil
      unless dis.empty?
        for com in dis
          next if com == nil
          damage += calculate_dice_value(com[0], com[1]) 
        end 
      end  
    end
    damage -= def_amt
    damage = 0 if damage < 0                        # if negative, make 0  
    if damage == 0                                  # if damage is 0,
      damage = rand(2)                              # half of the time, 1 dmg
    elsif damage > 0                                # a positive number?
      @critical = (rand(100) < attacker.cri)        # critical hit?
      @critical = false if prevent_critical         # criticals prevented?
      damage *= critical_mult if @critical          # critical adjustment
      damage = damage.to_i 
    end
    damage *= elements_max_rate(attacker.element_set)   # elemental adjustment
    damage /= 100
    damage = apply_variance(damage, IEX::DND_DAMAGE::STAT_VARIANCE)              # variance
    damage = apply_guard(damage)                    # guard adjustment
    @hp_damage = damage                             # damage HP
  end
  
  
  #--------------------------------------------------------------------------#
  # * alias-method :make_obj_damage_value
  #--------------------------------------------------------------------------# 
  alias :iex_dnd_damage_formulae_make_obj_damage_value :make_obj_damage_value unless $@
  def make_obj_damage_value( user, obj )   
    return dice_make_obj_damage_value( user, obj ) if obj.iex_dnd_dice? unless obj.nil?()
    return iex_dnd_damage_formulae_make_obj_damage_value( user, obj )
  end
  
  # Dice Method
  #--------------------------------------------------------------------------#
  # * new-method :dice_make_obj_damage_value
  #--------------------------------------------------------------------------# 
  def dice_make_obj_damage_value( user, obj )
    dnd = IEX::DND_DAMAGE
    damage = obj.base_damage                        # get base damage
    if damage > 0                                   # a positive number?
      damage += ((user.atk - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION) * 4 * obj.atk_f / 100      # Attack F of the user
      damage += ((user.spi - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION) * 2 * obj.spi_f / 100      # Spirit F of the user
      unless obj.ignore_defense                     # Except for ignore defense
        damage -= ((self.def - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION) * 2 * obj.atk_f / 100    # Attack F of the target
        damage -= ((self.spi - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION) * 1 * obj.spi_f / 100    # Spirit F of the target
      end
      damage = 0 if damage < 0                      # If negative, make 0
    elsif damage < 0                                # a negative number?
      damage += ((user.atk - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION) * 4 * obj.atk_f / 100      # Attack F of the user
      damage += ((user.spi - dnd::STAT_SUBTRACT) / dnd::STAT_DIVISION) * 2 * obj.spi_f / 100      # Spirit F of the user
    end
    damage *= elements_max_rate(obj.element_set)    # elemental adjustment
    damage /= 100
    damage = apply_variance(damage, obj.variance)   # variance
    damage = apply_guard(damage)                    # guard adjustment
    if obj.damage_to_mp  
      @mp_damage = damage                           # damage MP
    else
      @hp_damage = damage                           # damage HP
    end
  end
  
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#  
  alias :iex_dnd_damage_formulae_load_database :load_database unless $@
  def load_database()
    iex_dnd_damage_formulae_load_database()
    load_dndDice_database
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :load_dndDice_database
  #--------------------------------------------------------------------------#  
  def load_dndDice_database()
    ($data_items + $data_weapons + $data_enemies).compact.each { |obj|
      obj.iex_dnd_damage_formula_cache()
    }
  end  
  
end 

#==============================================================================#
# ** END OF FILE
#==============================================================================#
#==============================================================================#
# ** IEX(Icy Engine Xelion) - Attack Costs
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Weapons)
# ** Script Type   : Custom Costs
# ** Date Created  : 02/11/2011
# ** Date Modified : 07/17/2011
# ** Script Tag    : IEX - Attack Costs
# ** Difficulty    : Lunatic
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# *Note Most of the code for this script came from BEM
# (I was lazy, I couldn't bother writing all of it from scratch, since this 
#  is basically the same as BEMs custom skill costs)
# Anyway, Credit Me (IceDragon) and Yanfly if you use this.
#
# This script allows you to create custom attack costs for your weapons.
#
# If you are not using BEM, please get the "IEX - Attack Costs/Patch"
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# BEM, DBS (With Patch)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Battle Engines
#  Attack Cost/Patch
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# ** I'll put them in one day...
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  02/11/2011 - V1.0  Started and Finished Script
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_AttackCosts"] = true
#==============================================================================#
# ** IEX::ATTACK_COSTS
#==============================================================================#
module IEX
  module ATTACK_COSTS
#==============================================================================#
#                           Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#    
    # :attack, :skill, :item, :guard
    CLASS_COMMANDS = {
    # class_id => [:command]
      0 => [:attack, :skill, :item, :guard]
    } # Do Not Remove
    SKILL_COMMANDS = {}
    # ------------------------------------------------------------------------ #
    EQUIP_VOCAB = "Equip" # Not really used, but is dummied
    
    # Should the item/skill command be disabled if the player
    # doesn't have any items/skills
    DISABLE_EMPTY_COMMANDS = true
    
    # ------------------------------------------------------------------------ #
    # This hash determines the varioius settings applied to skills by default.
    # The settings are as follows:
    # Setting     Description
    #  _icon       Icon ID used with the skill. To not use an icon, set to 0.
    #  _colour     Font colour associated with cost type. Default is 0.
    #  _size       Font size associated with cost type. Default is 16.
    #  _suffix     Suffix associated with cost type. Appears if no icon used.
    ATTACK_SETTINGS = {
    # The following settings are used for MP cost skills. To alter the MP cost
    # of a skill to exceed 999, use <cost: x mp>. To alter MP cost to use a
    # percentile, use <cost: x% mp>. x is the cost value for both tags.
      :mp_icon   => 100,    # Icon used for MP cost skills.
      :mp_colour => 0,      # Colour used for MP cost skills.
      :mp_size   => 16,     # Font size used for MP cost skills.
      :mp_suffix => "%sSP", # Suffix used for MP cost skills.
      
    # The following settings are used for HP cost skills. To make skills cost
    # HP instead of MP, use the <cost: x hp> tag inside the notebox. To make
    # the skill cost a percentage of HP, use <cost: x% hp>.
      :hp_icon   => 99,     # Icon used for HP cost skills.
      :hp_colour => 0,      # Colour used for HP cost skills.
      :hp_size   => 16,     # Font size used for HP cost skills.
      :hp_suffix => "%sHP", # Suffix used for HP cost skills.
      
    # The following settings are used for Gold cost skills. To make skills cost
    # gold, use the <cost: x gold> or <cost: x% gold> tags inside of the
    # skill's notebox.
      :gold_icon    => 205,     # Icon used for gold cost skills.
      :gold_colour  => 0,       # Colour used for gold cost skills.
      :gold_size    => 16,      # Font size used for gold cost skills.
      :gold_suffix  => "%sG",   # Suffix used for set gold cost skills.
      :gold_suffixp => "%s%%G", # Suffix used for percentile gold cost skills.
    } # Do Not Remove
    
    # ------------------------------------------------------------------------ #
    # This weapon is used as a default for unarmed actors, as well as enemies.
    # Setting this to 0 will use no weapon for unarmed.
    # This weapon only affects the attack cost.
    UNARMED_WEAPON = 0
#==============================================================================#
#                           End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#    
  end
end

#===============================================================================#
# ** Game_Battler - Lunatic
#===============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * new-method :apply_attack_cost_changes
  #--------------------------------------------------------------------------#  
  def apply_attack_cost_changes( *args, &block )
    return *args[1] # Return Cost
  end
  
  #--------------------------------------------------------------------------#
  # new method: custom_attack_costs
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # In this section, you can modify the various attack cost types available or
  # create your own. By following the examples below, you can effectively
  # generate your own attack cost types and using this tag:
  #  
  #   <atkcost: phrase>
  # 
  # Match phrase with a case below and follow the examples below to meet and
  # match your custom costs.
  #--------------------------------------------------------------------------#
  def custom_attack_costs(obj, type)
    hash = IEX::ATTACK_COSTS::ATTACK_SETTINGS
    calc_cost = 0; use_icon = 0; suffix = "%s"; text_cost = "0"
    colour = hash[:mp_colour]; font_size = hash[:mp_size]
    can_use = true
    perform = (type == :perform)
    case obj.attack_cost
    #------------------------------------------------------------------------
    # <cost: x mp>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This allows you to manually adjust the MP costs attacks. Although its
    # ability is already present within the editor itself, this tag's purpose
    # is to allow you to create attacks with an MP cost of higher than 999.
    # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # <cost: 2000 mp>
    # --- WARNING --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This is a default-used template. Do not remove this.
    #------------------------------------------------------------------------
    when /(\d+)[ ](?:MP|SP)/i
      #---
      calc_cost = $1.to_i
      calc_cost = apply_attack_cost_changes(obj, calc_cost, "MP")
      calc_cost /= 2 if half_mp_cost
      #---
      text_cost = calc_cost.to_s
      use_icon = Icon.mp_cost
      suffix = hash[:mp_suffix]
      colour = hash[:mp_colour]
      font_size = hash[:mp_size]
      can_use = @mp >= calc_cost
      @mp -= calc_cost if perform
      
    #------------------------------------------------------------------------
    # <cost: x% maxmp>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # This tag allows you to create attacks that cost a percentage of the
    # battler's MaxMP. That said, this value will always fluctuate depending
    # on the MaxMP of the battler.
    # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # <cost: 20% maxmp>
    #------------------------------------------------------------------------
    when /(\d+)([%%])[ ](?:MP|SP|MAXMP|MAXSP)/i
      #---
      calc_cost = maxmp * $1.to_i / 100
      calc_cost = apply_attack_cost_changes(obj, calc_cost, "MP")
      calc_cost /= 2 if half_mp_cost
      #---
      text_cost = calc_cost.to_s
      use_icon = Icon.mp_cost
      suffix = hash[:mp_suffix]
      colour = hash[:mp_colour]
      font_size = hash[:mp_size]
      can_use = @mp >= calc_cost
      @mp -= calc_cost if perform
      
    #------------------------------------------------------------------------
    # <cost: x hp>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # If you wish for attacks to cost HP instead of MP, apply this tag to the
    # attack's notebox. Unlike MP attacks, HP attacks cannot bring HP to 0 so
    # they will stop short if the attack costs more than exact HP.
    # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # <cost: 2000 hp>
    #------------------------------------------------------------------------
    when /(\d+)[ ](?:HP|LP)/i
      #---
      calc_cost = $1.to_i
      calc_cost = apply_attack_cost_changes(obj, calc_cost, "HP")
      #---
      text_cost = calc_cost.to_s
      use_icon = Icon.hp_cost
      suffix = hash[:hp_suffix]
      colour = hash[:hp_colour]
      font_size = hash[:hp_size]
      can_use = @hp > calc_cost
      @hp -= calc_cost if perform
      
    #------------------------------------------------------------------------
    # <cost: x% maxhp>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # To make a attack cost a percentage of the user's MaxHP, use the above
    # tag. Just like the tag above, the attack cannot be used if it brings the
    # battler's HP to 0 or below.
    # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # <cost: 20% maxhp>
    #------------------------------------------------------------------------
    when /(\d+)([%%])[ ](?:HP|LP|MAXHP|MAXLP)/i
      #---
      calc_cost = maxhp * $1.to_i / 100
      calc_cost = apply_attack_cost_changes(obj, calc_cost, "HP")
      #---
      text_cost = calc_cost.to_s
      use_icon = Icon.hp_cost
      suffix = hash[:hp_suffix]
      colour = hash[:hp_colour]
      font_size = hash[:hp_size]
      can_use = @hp > calc_cost
      @hp -= calc_cost if perform
      
    #------------------------------------------------------------------------
    # <cost: x gold>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # To make attacks cost gold, use the tag above. x is the amount of gold
    # spent when the attack takes action. Note that enemies do not have any
    # restrictions on using gold cost attacks.
    # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # <cost: 2000 gold>
    #------------------------------------------------------------------------
    when /(\d+)[ ](?:GOLD|money)/i
      #---
      if self.actor?
        calc_cost = $1.to_i
        calc_cost = apply_attack_cost_changes(obj, calc_cost, "GOLD")
      else
        calc_cost = 0
      end
      #---
      text_cost = calc_cost.to_s
      use_icon = Icon.gold_cost
      suffix = hash[:gold_suffix]
      colour = hash[:gold_colour]
      font_size = hash[:gold_size]
      can_use = $game_party.gold > calc_cost
      $game_party.lose_gold(calc_cost) if perform
      
    #------------------------------------------------------------------------
    # <cost: x% gold>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # To cost a percentage of the player's total gold, use x%. Just like the
    # above tag, enemies using gold cost attacks will have no restrictions.
    # This attack will consume a percentage of the player's total gold.
    # --- Example --- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # <cost: 20% gold>
    #------------------------------------------------------------------------
    when /(\d+)([%%])[ ](?:GOLD|money)/i
      #---
      if self.actor?
        calc_cost = $game_party.gold * $1.to_i / 100
        calc_cost = apply_attack_cost_changes(obj, calc_cost, "GOLD")
      else
        calc_cost = 0
      end
      #---
      text_cost = $1.to_s
      use_icon = Icon.gold_cost
      suffix = hash[:gold_suffixp]
      colour = hash[:gold_colour]
      font_size = hash[:gold_size]
      can_use = $game_party.gold > calc_cost
      $game_party.lose_gold(calc_cost) if perform
    end  
    use_icon = obj.cost_icon if obj.cost_icon != nil
    case type
    when :perform;   return
    when :calc_cost; return calc_cost
    when :text_cost; return text_cost
    when :can_use;   return can_use
    when :use_icon;  return use_icon
    when :suffix;    return suffix
    when :font_size; return font_size
    when :colour;    return colour
    end  
  end

end

#===============================================================================#
# ** RPG::Weapon
#===============================================================================#
class RPG::Weapon
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_atk_cost_cache
  #--------------------------------------------------------------------------#
  def iex_atk_cost_cache()
    @iex_atk_cost_cache_complete = false
    @attack_cost = ""
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:ATTACK|ATK)(?:_COST| COST|COST):[ ](.*)>/i
      @attack_cost = $1
    end
    }
    @iex_atk_cost_cache_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :attack_cost
  #--------------------------------------------------------------------------#
  def attack_cost()
    iex_atk_cost_cache unless @iex_atk_cost_cache_complete 
    return @attack_cost
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :cost_icon
  #--------------------------------------------------------------------------#
  def cost_icon() ; return nil ; end
  
end

#===============================================================================
# Game_Battler
#===============================================================================
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * new-method :attack_object
  #--------------------------------------------------------------------------#
  unless method_defined?(:ac_can_attack?)
    def ac_can_attack? 
      return true
    end
  end  # // Patch for Can_Attack EX
  
  #--------------------------------------------------------------------------#
  # * alias-method :attack_object
  #--------------------------------------------------------------------------#
  alias :iex_atk_cost_ac_can_attack?() :ac_can_attack?() unless $@
  def ac_can_attack?()
    return false unless iex_atk_cost_ac_can_attack?()
    return custom_attack_costs(attack_object, :can_use)
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :attack_object
  #--------------------------------------------------------------------------#
  def attack_object ; return nil ; end
  
end

#===============================================================================#
# ** Game_Actor
#===============================================================================#
class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------#
  # * new-method :attack_object
  #--------------------------------------------------------------------------#
  def attack_object()
    eq = $data_weapons[IEX::ATTACK_COSTS::UNARMED_WEAPON]
    eq = weapons.compact[0] unless weapons.compact[0].nil?  
    return eq
  end
  
end

#===============================================================================#
# ** Game_Enemy
#===============================================================================#
class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------#
  # * new-method :attack_object
  #--------------------------------------------------------------------------#
  def attack_object()
    return $data_weapons[IEX::ATTACK_COSTS::UNARMED_WEAPON]
  end
  
end

#===============================================================================
# ** Game_BattleAction
#===============================================================================
class Game_BattleAction

  #--------------------------------------------------------------------------#
  # * alias-method :valid?
  #--------------------------------------------------------------------------#
  alias iex_atk_cost_valid? valid? unless $@
  def valid?( *args, &block )
    if attack?
      unless @battler.attack_object.nil?
        return false unless @battler.ac_can_attack?
      end  
    end 
    iex_atk_cost_valid?( *args, &block )
  end
  
end

#===============================================================================#
# ** Scene_Battle
#===============================================================================#
class Scene_Battle < Scene_Base 

  #--------------------------------------------------------------------------#
  # * alias-method :execute_action_attack
  #--------------------------------------------------------------------------#
  alias :iex_atk_cost_eaa :execute_action_attack unless $@
  def execute_action_attack( *args, &block )
    unless @active_battler.attack_object.nil?()
      @active_battler.custom_attack_costs( @active_battler.attack_object, :perform )
    end  
    iex_atk_cost_eaa( *args, &block )
  end
  
end

#===============================================================================#
# ** Window_Base
#===============================================================================#
class Window_Base < Window
  
  #--------------------------------------------------------------------------#
  # * new-method :draw_attack_obj_cost
  #--------------------------------------------------------------------------#
  def draw_attack_obj_cost( actor, obj, rect, enabled )
    return unless obj.kind_of?(RPG::BaseItem)
    return if actor.custom_attack_costs(obj, :calc_cost) <= 0
    dx = rect.x + rect.width - 48; dy = rect.y
    if actor.custom_attack_costs(obj, :use_icon) != 0
      icon = actor.custom_attack_costs(obj, :use_icon)
      draw_icon(icon, rect.x+rect.width-24, rect.y, enabled)
      text = actor.custom_attack_costs(obj, :text_cost)
      dw = 24
    else
      cost = actor.custom_attack_costs(obj, :text_cost)
      text = actor.custom_attack_costs(obj, :suffix)
      text = sprintf(text, cost)
      dw = 44
    end
    self.contents.font.size = actor.custom_attack_costs(obj, :font_size)
    colour_id = actor.custom_attack_costs(obj, :colour)
    self.contents.font.color = text_color(colour_id)
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, dw, WLH, text, 2)
  end
  
end

#===============================================================================#
# ** Window_ActorCommand
#===============================================================================#
class Window_ActorCommand < Window_Command

  #--------------------------------------------------------------------------#
  # * alias-method :enabled?
  #--------------------------------------------------------------------------#
  alias :iex_atk_cost_enabled? :enabled? unless $@
  def enabled?( obj = nil )
    return false unless @actor.ac_can_attack? if obj == :attack
    iex_atk_cost_enabled?(obj)
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item( index, enabled = true )
    rect = item_rect( index )
    rect.x += 4
    rect.width -= 8
    obj = @data[index]
    enabled = enabled?( obj )
    self.contents.clear_rect( rect )
    self.contents.font.size = 16
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text( rect, @commands[index], 0 )
    rect.width += 6
    if obj == :attack
      unless @actor.attack_object.nil?()
        draw_attack_obj_cost( @actor, @actor.attack_object, rect, @actor.ac_can_attack?() )
      end  
    end  
  end
  
end # Window_ActorCommand

#==============================================================================#
# ** END OF FILE
#==============================================================================#
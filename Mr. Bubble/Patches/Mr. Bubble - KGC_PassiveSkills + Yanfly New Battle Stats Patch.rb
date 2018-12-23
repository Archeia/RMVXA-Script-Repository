#==============================================================================
# KGC_PassiveSkills + Yanfly New Battle Stats Patch (DEX, RES, DUR, and LUK)
# v1.0 (August 24, 2011)
# By Mr. Bubble
#==============================================================================
# Installation: Insert this patch into its own page below all the
#               Yanfly Battle Stats scripts and KGC Passive Skills in
#               your script editor.
#------------------------------------------------------------------------------
#   This patch adds New Battle Stats functionality to KGC Passive Skills.
# Usage of these stats is generally no different than using default stats.
#-----------------------------------------------------------------------------
#  ++ Passive Skill New Battle Stats Parameter Tags ++
#-----------------------------------------------------------------------------
#   -----
#  | Key |
#   -----------------------------------------------------
#  |   n | A value/number. Can be positive or negative.  |
#  |   % | Changes n to a rate. Optional.                |
#   -----------------------------------------------------
#
#  -------- ----------------------------------------------------------------
#  Notetag | Description
#  -------- ----------------------------------------------------------------
#    DEX n | Increase/Decrease Dexterity
#    RES n | Increase/Decrease Resistance
#    DUR n | Increase/Decrease Durability
#    LUK n | Increase/Decrease Luck
#  -------- ----------------------------------------------------------------
#
#   Each stat tags can only be used if you have the appropriate Battle Stat
# or Class Stat installed in your script editor. Using notetags for these
# are no different than default stats.
#
#  Example:
#
#  <PASSIVE_SKILL>
#   ATK +5
#   DEX +10%
#   RES +7
#   DUR -33%
#   LUK -3
#  </PASSIVE_SKILL>
#------------------------------------------------------------------------------

#==============================================================================
#------------------------------------------------------------------------------
#------- Do not edit below this point unless you know what you're doing -------
#------------------------------------------------------------------------------
#==============================================================================


$imported = {} if $imported == nil

if $imported["PassiveSkill"]

module KGC
module PassiveSkill
  # DEX
  if $imported["BattlerStatDEX"] || $imported["DEX Stat"]
    PARAMS[:dex] = "DEX|dexterity" 
  end
  
  # RES
  if $imported["BattlerStatRES"] || $imported["RES Stat"]
    PARAMS[:res] = "RES|resistance"
  end
  
  # DUR
  if $imported["ClassStatDUR"]
    PARAMS[:dur] = "DUR|durability"
  end
  
  # LUK
  if $imported["ClassStatLUK"]
    PARAMS[:luk] = "LUK|luck" 
  end
  
end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # alias: base_dex
  #--------------------------------------------------------------------------
  if $imported["BattlerStatDEX"] || $imported["DEX Stat"]
    alias base_dex_KGC_PassiveSkill base_dex unless $@
    def base_dex
      n = base_dex_KGC_PassiveSkill + passive_params[:dex]
      n = n * passive_params_rate[:dex] / 100
      return n
    end
  end # if $imported["BattlerStatDEX"] || $imported["DEX Stat"]
  #--------------------------------------------------------------------------
  # alias: base_res
  #--------------------------------------------------------------------------
  if $imported["BattlerStatRES"] || $imported["RES Stat"]
    alias base_res_KGC_PassiveSkill base_res unless $@
    def base_res
      n = base_res_KGC_PassiveSkill + passive_params[:res]
      n = n * passive_params_rate[:res] / 100
      return n
    end
  end #   if $imported["BattlerStatRES"] || $imported["RES Stat"]
  #--------------------------------------------------------------------------
  # alias: base_dur
  #--------------------------------------------------------------------------
  if $imported["ClassStatDUR"]
    alias base_dur_KGC_PassiveSkill base_dur unless $@
    def base_dur
      n = base_dur_KGC_PassiveSkill + passive_params[:dur]
      n = n * passive_params_rate[:dur] / 100
      return n
    end
  end # if $imported["ClassStatDUR"]
  #--------------------------------------------------------------------------
  # alias: base_luk
  #--------------------------------------------------------------------------
  if $imported["ClassStatLUK"]
    alias base_luk_KGC_PassiveSkill base_luk unless $@
    def base_luk
      n = base_luk_KGC_PassiveSkill + passive_params[:luk]
      n = n * passive_params_rate[:luk] / 100
      return n
    end
  end # $imported["ClassStatLUK"]
end # class Game_Actor < Game_Battler
 
end # if $imported["PassiveSkill"]
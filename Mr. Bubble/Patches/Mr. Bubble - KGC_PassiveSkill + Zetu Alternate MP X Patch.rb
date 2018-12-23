#==============================================================================
# KGC_PassiveSkill + Zetu Alternate MP X Patch
# v1.0 (August 24, 2011)
# By Mr. Bubble
#==============================================================================
# Installation: Insert this patch into its own page below AMPX and 
#               KGC Passive Skills in your script editor.
#------------------------------------------------------------------------------
#   This patch adds AMPX options to KGC Passive Skills. Usage of these stats 
# for passive skills is no different than using default stats.
#-----------------------------------------------------------------------------
#  ++ Passive Skill AMPX Parameter Tags ++
#-----------------------------------------------------------------------------
#   -----
#  | Key |
#   -----------------------------------------------------
#  |   n | A value/number. Can be positive or negative.  |
#  |   % | Changes n to a rate. Optional.                |
#   -----------------------------------------------------
# 
#  ----------- -------------------------------------------------------------
#  Notetag    | Description
#  ----------- -------------------------------------------------------------
#      MANA n | Increase/Decrease Maximum Mana
#      RAGE n | Increase/Decrease Maximum Rage
#    ENERGY n | Increase/Decrease Maximum Energy
#     FOCUS n | Increase/Decrease Maximum Focus
#  ----------- -------------------------------------------------------------
#
#  The notetags listed here for AMPX are for the *default* resources provided
#  in that script. The notetag for KGC Passive Skill is determined by the
#  Vocab for the resource defined in the SPEC hash. For example, if you
#  have a resource defined as this:
#
#      :energy => ["Energy", "E", 14,  6, 14],
#
#  Then the notetag you want to use for KGC Passive Skill is ENERGY n
#  where n is a value or rate. This will work for any custom resource
#  you define in AMPX.
#
#  Using notetags for these is no different from default stats.
#
#  Example:
#
#  <PASSIVE_SKILL>
#   ATK +5
#   MANA +40%
#   RAGE -7
#   ENERGY +10
#   FOCUS +30%
#  </PASSIVE_SKILL>
#------------------------------------------------------------------------------

#==============================================================================
#------------------------------------------------------------------------------
#------- Do not edit below this point unless you know what you're doing -------
#------------------------------------------------------------------------------
#==============================================================================

$imported = {} if $imported == nil
$zsys = {} if $zsys.nil?

if $imported["PassiveSkill"]

module KGC
module PassiveSkill
  
  # Creates a regexp for each custom AMPX resource using the resource Vocab
  if $zsys[:ampx]
    Z11::SPEC.each_key { |key|
      PARAMS[key] = /#{Z11::SPEC[key][0]}/i
    }
  end
  
end # module PassiveSkill
end # module KGC


class Game_Actor < Game_Battler
if $zsys[:ampx]
  #--------------------------------------------------------------------------
  # alias: maxampx
  #--------------------------------------------------------------------------
  alias maxampx_KGC_PassiveSkill maxampx unless $@
  def maxampx(resource = Z11::DEF_RES)
    n = maxampx_KGC_PassiveSkill(resource) + passive_params[resource]
    n = n * passive_params_rate[resource] / 100
    return n
  end
end # if $zsys[:ampx]
end # class Game_Actor < Game_Battler

end # if $imported["PassiveSkill"]
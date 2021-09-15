#encoding:UTF-8
# 07/02/2011
# 07/02/2011
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-Support&Reaction"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[14, "Support&Reaction"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::SUPPORT_REACTION
#==============================================================================#
module IEO
  module SUPPORT_REACTION
  end
end

#==============================================================================#
# ** IEO::Reaction
#==============================================================================#
class IEO::Reaction

  attr_accessor :trigger
  attr_accessor :effect

  def initialize(trigger, effect)
    @trigger = trigger
    @effect  = effect
  end

end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler

  alias :ieo014_gb_initialize :initialize unless $@
  def initialize()
    ieo014_gb_initialize()
  end

  def reactions()

  end

  def supports()

  end

end
#==============================================================================#
IEO::REGISTER.log_script(14, "Support&Reaction", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

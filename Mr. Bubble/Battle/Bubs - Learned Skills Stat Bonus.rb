# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Learned Skills Stat Bonus                             │ v1.0 │ (7/30/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     YF, mass alias code reference
#--------------------------------------------------------------------------
# This script allows the ability to provide stat bonuses for any skills 
# learned by an actor. That's it.
#
# It doesn't matter if the skill is usable or not usable. As long as the
# actor has a skill learned, the actor will gain any stat bonuses it may
# provide. I guess this is akin to "passive skills", but I did not 
# want to name it as that since this will work even with active skills.
#
# This script has no effect on enemy stats.
#
# I made this script to study and practice mass method aliasing. I don't 
# think a lot of people will find this that useful.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.0 : Initial release. (7/30/2012) 
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetags are for Skills only:
#   
# <learn bonus>
# stat
# stat
# </learn bonus>
#
#   This tag allows you define the stat bonuses for learning the skill. 
#   You can add as many stats between the <learn bonus> tags as you like.
#   Stat names are not case-sensitive. The following stats are available:
#
#     mhp n
#     mmp n
#     atk n
#     def n
#     mat n
#     mdf n
#     agi n
#     luk n
#
#       There are the regular stats. The names should be self-explanatory. 
#       n can be any positive or negative number.
#
#     hit n%
#     eva n% 
#     cri n% 
#     cev n% 
#     mev n% 
#     mrf n% 
#     cnt n% 
#     hrg n% 
#     mrg n% 
#     trg n% 
#     tgr n% 
#     grd n% 
#     rec n% 
#     pha n% 
#     mcr n% 
#     tcr n% 
#     pdr n% 
#     mdr n% 
#     fdr n% 
#     exr n%
#
#       These are the xparams, the stats that you can't normally see.
#       It's important to note that all these stats deal with rates. That
#       means n% should be between 0.0% ~ 100.0% whether it's positive 
#       or negative.
#
# Here is an example of a <learn bonus> tag:
#
#     <learn bonus>
#     atk +10
#     cri +0.5%
#     </learn bonus>
#
# Learning this skill increases the actor's ATK by +10 and CRI by 0.5%
#
#--------------------------------------------------------------------------
#   Parameter Abbreviations
#--------------------------------------------------------------------------
#     MHP  Maximum Hit Points
#     MMP  Maximum Magic Points
#     ATK  ATtacK power
#     DEF  DEFense power
#     MAT  Magic ATtack power
#     MDF  Magic DeFense power
#     AGI  AGIlity
#     LUK  LUcK
#     HIT  HIT rate
#     EVA  EVAsion rate
#     CRI  CRItical rate
#     CEV  Critical EVasion rate
#     MEV  Magic EVasion rate
#     MRF  Magic ReFlection rate
#     CNT  CouNTer attack rate
#     HRG  Hp ReGeneration rate
#     MRG  Mp ReGeneration rate
#     TRG  Tp ReGeneration rate
#     TGR  TarGet Rate
#     GRD  GuaRD effect rate
#     REC  RECovery effect rate
#     PHA  PHArmacology
#     MCR  Mp Cost Rate
#     TCR  Tp Charge Rate
#     PDR  Physical Damage Rate
#     MDR  Magical Damage Rate
#     FDR  Floor Damage Rate
#     EXR  EXperience Rate
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     DataManager#load_database
#     Game_BattlerBase#params
#     All the xparams in Game_BattlerBase
#    
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported ||= {}
$imported["BubsLearnedSkillsStatBonus"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Learn Bonus Settings
  #==========================================================================
  module LearnBonus
  #--------------------------------------------------------------------------
  #   Param Strings
  #--------------------------------------------------------------------------
  # Do not alter any of the default parameter names here. You can,
  # however, add any custom stats provided by other scripts into the 
  # arrays if your project has them.
  #
  # PARAMS contain parameters that are flat values.
  # XPARAMS contain parameters that are rates (i.e. percentages, chance)
  PARAMS  = [:mhp, :mmp, :atk, :def, :mat, :mdf, :agi, :luk] 
  
  XPARAMS = [:hit, :eva, :cri, :cev, :mev, :mrf, :cnt, :hrg, 
             :mrg, :trg, :tgr, :grd, :rec, :pha, :mcr, :tcr, 
             :pdr, :mdr, :fdr, :exr]
  end # module LearnBonus
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_learn_bonus load_database; end
  def self.load_database
    load_database_bubs_learn_bonus # alias
    load_notetags_bubs_learn_bonus
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_learn_bonus
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_learn_bonus
    for obj in $data_skills
      next if obj.nil?
      obj.load_notetags_bubs_learn_bonus
    end # for obj
  end # def
  
end # module DataManager


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    LEARN_BONUS_START_TAG = /<learn[_\s]?bonus>/i
    LEARN_BONUS_END_TAG = /<\/learn[_\s]?bonus>/i
    LEARN_BONUS_PARAM_TAG = /(\w+)\s*([-+]?\d+\.?\d*)[%％]?/i
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :learn_bonus
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_learn_bonus
  #--------------------------------------------------------------------------
  def load_notetags_bubs_learn_bonus
    initialize_learn_bonus
    
    learn_bonus_tag = false
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::LEARN_BONUS_START_TAG
        learn_bonus_tag = true
      when Bubs::Regexp::LEARN_BONUS_END_TAG
        learn_bonus_tag = false

      else
        next unless learn_bonus_tag
        next unless line =~ Bubs::Regexp::LEARN_BONUS_PARAM_TAG ? true : false
        if Bubs::LearnBonus::PARAMS.include?($1.to_sym)
          @learn_bonus[$1.to_sym] = $2.to_i
        elsif Bubs::LearnBonus::XPARAMS.include?($1.to_sym)
          @learn_bonus[$1.to_sym] = $2.to_f
        end
        
      end # case
    } # self.note.split
  end
  
  #--------------------------------------------------------------------------
  # common cache : initialize_learn_bonus
  #--------------------------------------------------------------------------
  def initialize_learn_bonus
    @learn_bonus = {}
    symbols = Bubs::LearnBonus::PARAMS + Bubs::LearnBonus::XPARAMS
    symbols.each { |param|
      @learn_bonus[param] = 0
    }
  end
  
end # RPG::BaseItem


#==============================================================================
# ++ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # mass alias methods        # referenced from YF
  #--------------------------------------------------------------------------
  Bubs::LearnBonus::XPARAMS.each { |param|
    aString = %Q<
    alias #{param}_bubs_learned_skill_bonus #{param}
    def #{param}
      base = #{param}_bubs_learned_skill_bonus
      bonus = learned_skill_stat_bonus(:#{param})
      return base + bonus
    end
    >
    module_eval(aString)
  
  } # !!
  
  #--------------------------------------------------------------------------
  # alias : param
  #--------------------------------------------------------------------------
  alias param_bubs_learned_skill_bonus param
  def param(param_id)
    param_sym = {0 => :mhp, 1 => :mmp, 2 => :atk, 3 => :def, 4 => :mat,
    5 => :mdf, 6 => :agi, 7 => :luk}
    base = param_bubs_learned_skill_bonus(param_id)
    bonus = learned_skill_stat_bonus(param_sym[param_id])
    value = base + bonus
    return [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  
  #--------------------------------------------------------------------------
  # new method : learned_skill_stat_bonus
  #--------------------------------------------------------------------------
  def learned_skill_stat_bonus(symbol)
    n = 0
    return n unless actor?
    skills.each { |skill| n += skill.learn_bonus[symbol] }
    n *= 0.01 if Bubs::LearnBonus::XPARAMS.include?(symbol)
    return n
  end

end # class Game_BattlerBase
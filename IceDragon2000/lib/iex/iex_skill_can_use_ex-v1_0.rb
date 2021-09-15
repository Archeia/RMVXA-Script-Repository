#==============================================================================#
# ** IEX(Icy Engine Xelion) - Skill Can Use EX
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Skills)
# ** Script Type   : Skill Can Use?
# ** Date Created  : 01/09/2011
# ** Date Modified : 01/31/2011
# ** Script Tag    : IEX - Skill Can Use EX
# ** Difficulty    : Easy, Lunatic
# ** Version       : 1.0
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This allows special conditions for Skills.
# Such Hp/Mp needed to use the skill or an item which is needed.
# This is a lunatic script, meaning it requires scripting knowledge to use it
# to its fullest. 
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# 1.0
#  Notetags! Can be placed in Skill noteboxes.
#==============================================================================#
# <canuse: phrase>
# Replace phrase. (Game_Battler - Lunatic)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Most battle systems.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Battle Engines
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   RPG::Skill
#     new-method :scu_ex_cache
#     new-method :use_conditions
#   Game_Battler
#     alias      :skill_can_use?
#     new-method :ex_skill_can_use?
#   Scene_Title
#     alias      :load_database
#     new-method :load_scuex_database
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  01/09/2011 - V1.0  Started Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_SkillCanUseEX"] = true

#==============================================================================
# ** Game_Battler - Lunatic
#------------------------------------------------------------------------------
#==============================================================================
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * ex_skill_can_use?
  #--------------------------------------------------------------------------#
  # Runs through all the skills conditions and breaks if a false is found
  # <condition: cond_name> (or) <canuse: cond_name>
  # <condition: alwaystrue>
  #--------------------------------------------------------------------------#
  def ex_skill_can_use?(skill, tag = :can_use)
    can_use   = true
    icon      = nil
    need_text = nil
    for cond in skill.use_conditions
      case cond.to_s.upcase
    #--------------------------------------------------------------------------#
    # EDIT HERE
    #--------------------------------------------------------------------------#
    # ------------------------------------------------------------------------ #
    # <condition: alwaystrue>
    # The skill can always be used, as long as the other conditions (Hp/Mp Costs)
    # are acheived
    # ------------------------------------------------------------------------ #
      when "ALWAYSTRUE"
        can_use = true
    # ------------------------------------------------------------------------ #
    # <condition: alwaysfalse>
    # Opposite of alwaystrue
    # ------------------------------------------------------------------------ #
      when "ALWAYSFALSE" 
        can_use = false
    # ------------------------------------------------------------------------ #
    # <condition: state x>
    # Requires that the user have x state
    # ------------------------------------------------------------------------ #    
      when /(?:STATE)[ ](\d+)/i  
        can_use = @states.include?($1.to_i)
    # ------------------------------------------------------------------------ #
    # Hp/Mp Requirements
    # -Rate-
    # <condition: hp sign x%> <condition: mp sign x%>
    # EG. <condition: hp => 50%>  <condition: mp < 50%>
    #
    # -Set-
    # <condition: hp sign x> <condition: mp sign x>
    # EG. <condition: hp => 50>  <condition: mp < 50>
    #
    # sign can be:
    # == Equal to
    # >  Greater than
    # <  Less than
    # <= Less than or Equal to
    # >= Greater than or Equal to
    # != Not Equal to
    # ------------------------------------------------------------------------ #      
      when /(HP|MP)[ ](.*)[ ](\d+)([%%])/i
        val = $3.to_i
        sign = $2.to_s
        case $1.to_s.upcase
        when "HP"
          can_use = eval("self.hp #{sign} IEX::IMath.cal_percent(val, maxhp)")
        when "MP"  
          can_use = eval("self.mp #{sign} IEX::IMath.cal_percent(val, maxmp)")
        end  
      when /(HP|MP)[ ](.*)[ ](\d+)/i
        val = $3.to_i
        sign= $2.to_s
        sign= "==" if sign == "="
        case $1.to_s.upcase
        when "HP"
          can_use = eval("self.hp #{sign} val")
        when "MP"  
          can_use = eval("self.mp #{sign} val")
        end   
    # ------------------------------------------------------------------------ #
    # <condition: item x:y>
    # Requires that the user has x item, of y amount
    # ------------------------------------------------------------------------ #  
      when /ITEM[ ](\d+):(\d+)/i
        iid = $1.to_i
        amt = $2.to_i
        can_use = $game_party.item_number($data_items[iid]) >= amt
        
    # << You start adding here    
    #--------------------------------------------------------------------------#
    # STOP EDIT HERE
    #--------------------------------------------------------------------------#    
      else
        can_use = true
      end
      break if can_use == false
    end
    return can_use if tag == :can_use
  end
  
end

#==============================================================================
# ** IEX::IMath
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module IMath
    
    def self.cal_percent(perc, val)
      ans = val.to_i
      ans *= 100.0
      ans = ans * (perc.to_i / 100.0)
      ans /= 100.0
      return Integer(ans)
    end    
    
  end
end

#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Skill
  
  def scu_ex_cache
    @scu_ex_cache_complete = false
    @scu_conditions = []
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:CONDITION|cond|can use|canuse|can_use):[ ](.*)>/i
      @scu_conditions.push($1)
    end  
    }
    @scu_ex_cache_complete = true
  end
  
  def use_conditions
    scu_ex_cache unless @scu_ex_cache_complete
    return @scu_conditions 
  end
  
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias load_bt_database
  #--------------------------------------------------------------------------#
  alias iex_scuex_load_bt_database load_bt_database unless $@
  def load_bt_database
    iex_scuex_load_bt_database
    load_scuex_database
  end
  
  #--------------------------------------------------------------------------#
  # * alias load_database
  #--------------------------------------------------------------------------#
  alias iex_scuex_load_database load_database unless $@
  def load_database
    iex_scuex_load_database
    load_scuex_database
  end
  
  #--------------------------------------------------------------------------#
  # * load_scuex_database
  #--------------------------------------------------------------------------#
  # This loads all the trait caches so it doesn't have to during runtime
  #--------------------------------------------------------------------------#
  def load_scuex_database
    for st in $data_skills
      next if st == nil
      st.scu_ex_cache
    end
  end
  
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#==============================================================================
class Game_Battler
  
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  alias iex_skill_can_use_ex skill_can_use? unless $@
  def skill_can_use?(skill)
    return false unless ex_skill_can_use?(skill)
    return iex_skill_can_use_ex(skill)
  end
  
end

#==============================================================================#
# ** IEX(Icy Engine Xelion) - Item Can Use EX
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Items)
# ** Script Type   : Item Can Use?
# ** Date Created  : 01/31/2011
# ** Date Modified : 07/24/2011
# ** Script Tag    : IEX - Item Can Use EX
# ** Difficulty    : Lunatic
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# Basically a copy and paste job, using the Skill Can Use EX
# This allows special conditions for items.
# Such Hp/Mp needed to use the item or another item which is needed.
# This is a lunatic script, meaning it requires scripting knowledge to use it
# to its fullest.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# 1.0
#  Notetags! Can be placed in Item noteboxes.
#==============================================================================#
# <condition: phrase>
# Replace phrase. (Game_Battler - Lunatic)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Most battle systems, except GTBS
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
# * Unless Battle Engine Melody present
# Classes
#   RPG::Item
#     new-method :icu_ex_cache
#     new-method :use_conditions
#   Game_Battler
#    *new-method :item_can_use?
#     alias      :item_can_use?
#     new-method :ex_item_can_use?
#   Scene_Title
#     alias      :load_database
#     new-method :load_icuex_database
#  *Scene_Battle
#   *overwrite   :update_item_selection
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  01/09/2011 - V1.0  Started Script
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
$imported["IEX_ItemCanUseEX"] = true
#==============================================================================#
# ** Game_Battler - Lunatic
#==============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * ex_item_can_use?
  #--------------------------------------------------------------------------#
  # Runs through all the items conditions and breaks if a false is found
  # <condition: cond_name>
  # <condition: alwaystrue>
  #--------------------------------------------------------------------------#
  def ex_item_can_use?(item, tag = :can_use)
    can_use   = true
    icon      = nil
    need_text = nil
    for cond in item.use_conditions
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

#==============================================================================#
# ** IEX::IMath
#==============================================================================#
module IEX
  module IMath
    
    def self.cal_percent(perc, val)
      ans = val.to_f * perc.to_f / 100.o
      return Integer(ans)
    end  
    
  end
end

#==============================================================================#
# ** RPG::Item
#==============================================================================#
class RPG::Item

  #--------------------------------------------------------------------------#
  # * new-method :icu_ex_cache
  #--------------------------------------------------------------------------#  
  def icu_ex_cache()
    @icu_ex_cache_complete = false
    @scu_conditions = []
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:CONDITION|cond|can use|canuse|can_use):[ ](.*)>/i
      @scu_conditions.push($1)
    end  
    }
    @icu_ex_cache_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :use_conditions
  #--------------------------------------------------------------------------#  
  def use_conditions()
    icu_ex_cache() unless @icu_ex_cache_complete
    return @scu_conditions 
  end
  
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#
  alias iex_icuex_load_bt_database load_bt_database unless $@
  def load_bt_database
    iex_icuex_load_bt_database
    load_icuex_database
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#
  alias iex_icuex_load_database load_database unless $@
  def load_database
    iex_icuex_load_database
    load_icuex_database
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :load_icuex_database
  #--------------------------------------------------------------------------#
  def load_icuex_database()
    for st in $data_items.compact ; st.icu_ex_cache() ; end
  end
  
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * new-method :item_can_use?
  #--------------------------------------------------------------------------#  
  def item_can_use?(item) ; return false end unless $imported["BattleEngineMelody"]
  
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  
  unless $imported["BattleEngineMelody"]
    def item_can_use?(item) ; return $game_party.item_can_use?(item) end
  end  
    
  #--------------------------------------------------------------------------#
  # * alias-method :item_can_use?
  #--------------------------------------------------------------------------#
  alias iex_item_can_use_ex item_can_use? unless $@
  def item_can_use?(item)
    return false unless ex_item_can_use?(item)
    return iex_item_can_use_ex(item)
  end
  
end
  
#==============================================================================#
# ** Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * overwrite-method :update_item_selection
  #--------------------------------------------------------------------------#
  def update_item_selection()
    @item_window.active = true
    @item_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_item_selection
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if @active_battler.item_can_use?(@item)
        Sound.play_decision
        determine_item
      else
        Sound.play_buzzer
      end
    end
  end unless $imported["BattleEngineMelody"]
  
end  

#==============================================================================#
# ** END OF FILE
#==============================================================================#
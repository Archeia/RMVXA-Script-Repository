#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Skill Level System
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Skills)
# ** Script Type   : Skill Modifier
# ** Date Created  : 02/24/2011
# ** Date Modified : 10/01/2011
# ** Script Tag    : IEO-011(Skill Level System)
# ** Difficulty    : Medium, Hard, Lunatic
# ** Version       : 1.4
# ** IEO ID        : 011
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
# Huh? *Stares* Ohh your waiting for the intro.. Geez... Can't I get some rest!
# Okay here we go...
#
# IEO Script ID 011 - Skill Level System
# Based off an old idea I had when using GTBS, basically what this does is
# modify an existing skill and changing something on it, like the base damage,
# animation, scope etc.
# As with any IEO script, this is a very hard script to use.
#
# You can jump to the customization sections using these
# IEO011-Primary
# IEO011-Secondary
# IEO011-Lunatic
# Though I encourage reading everything.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
# Script Calls
# *--------------------------------------------------------------------------* #
# You can call the SkillForge scene with 1 on the following
# In a event's script call
# skill_forge(actor_index, lock_upgrade)
# Setting lock_upgrade as nil will use the $game_system.can_upgrade_skills
# value instead.
# EG.
# skill_forge(0, false)
# skill_forge(4, true)
#
# $scene = Scene_SkillForge.new(actor_index, [lock_upgrade, [return_type, [return_index]]])
# return_type s
#   :map
#   :menu
#
# *--------------------------------------------------------------------------* #
# You can enable/disable the skill uprade with
# $game_system.can_upgrade_skills
# EG:
# $game_system.can_upgrade_skills = true
# $game_system.can_upgrade_skills = false
#
# *--------------------------------------------------------------------------* #
# Place these "tags" in inside there respective noteboxes
# *--------------------------------------------------------------------------* #
# Item/Skill Notetags
# *--------------------------------------------------------------------------* #
# <skl_p: +/-x> (or) <skl p: +/-x>
#   This sets the skill point distribution for the item/skill by x
#   Positive values increase points, while negative decreases.
#
# EG:
# <skl_p: +24>
#
# *--------------------------------------------------------------------------* #
# Skill Notetags
# *--------------------------------------------------------------------------* #
# <perlevel phrase: change> (or) <atlevel(x) phrase: change>
#   perlevel will cause a set change to occur each for each level of the skill.
#   atlevel will allow you set whatever value at level (x) for the skill.
#   Replace phrase with one of the following
#     name
#     cost
#     subcost (with IEO003(CustomSkillCosts) 1.2)
#     basedamage
#     atk_f
#     spi_f
#     variance
#     speed
#     hit
#     scope
#     anim_id
#     icon_index
#     state_plus*
#     state_minus*
#     element*
#
#   NOTE* "name", "scope", "anim_id", "icon_index", "state_plus", "state_minus"
#         and "element" are unaffected by "perlevel"
#   NOTE* "state_plus", "state_minus", "element"
#        <atleveln element: +2, -4, 1>
#         The + operator will add the state/element to the current set
#         The - operator will remove the state/element from the current set
#         In other words, if your element set for the skill was:
#         [4, 6, 8]
#         After the operation:
#         [2, 6, 8]
#         1 was ignored because it had no forward operator.
#   NOTE "atlevel" will cause any level above it to obtain its changes
#        Meaning if you changed the scope at level 2, the scope will be kept
#        for levels 3, 4, 5, etc.. But level 1 and 0 will have there originals.
#
#   Replace change with one of the following formats
#     +/-x%
#     x%
#     +/-x
#     x
#   NOTE* "atk_f", "spi_f", "variance", "hit" Try to keep these positive.
#
# EG:
#   <perlevel basedamage: +200>
#   <perlevel atk_f: +10%>
#   <perlevel cost: 1>
#   <atlevel2 cost: 10>
#   <atlevel5 scope: 9>
#   <atlevel3 anim_id: 100>
# # //
# *--------------------------------------------------------------------------* #
# 1.2
# *--------------------------------------------------------------------------* #
# Listing:
#   <perlevel>
#   basedamage: +10%
#   cost: +10
#   </perlevel>
#
#   <atlevel2>
#   scope: 9
#   anim_id: 101
#   name: Fire III
#   </atlevel>
# *--------------------------------------------------------------------------* #
# <maxlevel: x>
#   This sets the skills maximum level(x).
#
# EG:
#   <maxlevel: 2>
#   <maxlevel: 90>
#
# *--------------------------------------------------------------------------* #
# <no edit>
#   This prevents the skill from being changed, or gaining levels
#
# *--------------------------------------------------------------------------* #
# <level cost x: y>
#    This allows you to overwrite the level(x) cost(y)
# NOTE* You must use this tag, AFTER you have changed the maxlevel, else the
#       changes will be lost.
#
# EG:
#   <level cost 2: 200>
#   <level cost 4: 1200>
#
# *--------------------------------------------------------------------------* #
# Enemy Notetags
# *--------------------------------------------------------------------------* #
# <skl_p: x> (or) <skl p: x>
#   This sets the skill point distribution for the enemy by x
# NOTE* This value can change during the game, from the skl_p_gain method.
#
# EG:
#   <skl_p: 60>
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Well has only been tested with the DBS.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#   CBS
#
# Above
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   RPG::Item
#     new-method :ieo011_itemcache
#   RPG::Skill
#     new-method :change_skill_cost
#     new-method :skillcache_set
#     new-method :ieo011_skillcache
#     new-method :ieo011_rebuild_levelcosts
#     new-method :ieo011_build_level0_cache
#     new-method :ieo011_build_mainsklcaches
#     new-method :level_up
#     new-method :level_down
#     new-method :change_level
#     new-method :skl_nextlevelcost
#     new-method :get_nextlevel
#     new-method :change_exp
#     new-method :exp=
#     new-method :next_exp
#     new-method :level_exp
#   RPG::Enemy
#     new-method :ieo011_enemycache
#   Game_System
#     alias      :initialize
#   Game_BattleAction
#     alias      :clear
#     alias      :set_skill
#     new-method :assign_skl_skill
#     overwrite  :skill
#   Game_Battler
#     alias      :skill_effect
#     alias      :item_effect
#   Game_Enemy
#     alias      :initialize
#     new-method :skl_p_limit
#     new-method :skl_p
#     new-method :skl_p=
#   Game_Actor
#     alias      :setup
#     new-method :create_skl_skills
#     new-method :match_skl_skill_to_id
#     new-method :skl_p_limit
#     new-method :skl_p
#     new-method :skl_p=
#     new-method :can_upgrade_skill?
#     new-method :upgrade_skill
#     overwrite  :learn_skill
#     overwrite  :skills
#     alias      :skill_can_use?
#   Game_Troop
#     new-method :distribute_skl_p
#   Window_Base
#     new-method :draw_actor_skl_p
#     new-method :draw_skl_p
#   Window_Skill
#     new-method :draw_obj_name
#     new-method :draw_obj_level
#     overwrite  :draw_item
#     new-method :enabled?
#   Scene_Title
#     alias      :load_database
#     alias      :load_bt_database
#     new-method :load_ieo011_cache
#   *Scene_File (Only in SKLMODE 3)
#     alias      :write_save_data
#     alias      :read_save_data
#   Scene_Battle
#     new-method :perform_skl_p_gain
#     alias      :execute_action_attack
#     alias      :execute_action_guard
#     alias      :execute_action_skill
#     alias      :execute_action_item
#     alias      :battle_end
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  02/26/2011 - V1.0  Finished Script
#  05/13/2011 - V1.0  Code rearrangement
#  05/14/2011 - V1.0  Minor Code Edits
#  06/01/2011 - V1.1  Major Bug Fix regarding the EXP Skill Mode
#  06/30/2011 - V1.2  Added Listing (So you can now use <atlevel2> and list the changes)
#  08/29/2011 - V1.3  Added Skill Level Struct (Increased performance)
#  10/01/2011 - V1.4  Rearranged Code, added MIXES
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Skills may not work correctly outside of the DBS and default scenes.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-SkillLevelSystem"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script ||= {})[[11, "SkillLevelSystem"]] = 1.4
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::SKILL_LEVEL - IEO011-Primary
#==============================================================================#
module IEO
  module SKILL_LEVEL
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#

  #--------------------------------------------------------------------------#
  # * ONSTART_UPGRADE
  #--------------------------------------------------------------------------#
  # Should the skill upgrade feature be active on newgame?
  # You can change this later with
  # $game_system.can_upgrade_skills
  # EG : $game_system.can_upgrade_skills = true
  #--------------------------------------------------------------------------#
    ONSTART_UPGRADE = true

  #--------------------------------------------------------------------------#
  # * SKILL_MODE
  #--------------------------------------------------------------------------#
  # This sets the skill levelling mode
  # 0 - Point based, players will buy the skill's level
  # 1 - Exp Based, skills will gain exp on use, and level accordingly
  #--------------------------------------------------------------------------#
    SKILL_MODE = 1

  #--------------------------------------------------------------------------#
  # * SLIDY_WINDOWS
  #--------------------------------------------------------------------------#
  # This only works if IEX_SceneActions is present
  #--------------------------------------------------------------------------#
    SLIDY_WINDOWS   = true

    module_function # DO NOT REMOVE
    #--------------------------------------------------------------------------#
    # skl_p_limit
    #--------------------------------------------------------------------------#
    # This method is called ONCE, at start up for each actor, enemies will
    # be setup as they are needed.
    # This will set there skl_p limit
    #--------------------------------------------------------------------------#
    def skl_p_limit(battler)
      return 5000
    end

    #--------------------------------------------------------------------------#
    # level_cost
    #--------------------------------------------------------------------------#
    # This is used to calculate the default skl_p growth for skills per level
    #--------------------------------------------------------------------------#
    def level_cost(skill, level)
      return Integer((level*10) + (level*16))
    end

    #--------------------------------------------------------------------------#
    # skl_p_gain
    #--------------------------------------------------------------------------#
    # This method is called from battle and battlers when a skill/item effect
    # is done.
    #--------------------------------------------------------------------------#
    def skl_p_gain(type, target, obj = nil, user = nil)
      result = 0
      case type
      # ---------------------------------------------------------------------- #
      when :attack # type and battler are valid
        result = 5
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :guard # type and battler are valid
        result = 2
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :skill # type and battler are valid
        result = (target.action.skill.skl_level+1) * 2 unless target.action.skill.nil?
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :item # type and battler are valid
        result = 10
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :use # type, battler, obj, user are all valid
        result = obj.skl_p + 15
        if SKILL_MODE == 1 and obj.is_a?(RPG::Skill) # // If skill mode is exp
          obj.skl_exp += result if obj.skl_skill? # // if skill is a valid skill level
        end
      # ---------------------------------------------------------------------- #
      end
      # ---------------------------------------------------------------------- #
      target.skl_p += result
      # ---------------------------------------------------------------------- #
      return result # Doesn't do anything really, but just for the sake of it
    end

    # // Exp Level Mode only
    #--------------------------------------------------------------------------#
    # skill_exp_max
    #--------------------------------------------------------------------------#
    # This method is used to set the maximum_exp obtainable by a skill
    #--------------------------------------------------------------------------#
    def skill_exp_max(skill)
      result = skill.skl_exp_list[skill.skl_maxlevel] + 10
      return result
    end

    #--------------------------------------------------------------------------#
    # skill_explist
    #--------------------------------------------------------------------------#
    # Used to create the explist for skills
    #--------------------------------------------------------------------------#
    def skill_explist(skill)
      lmax = skill.skl_maxlevel
      result = Array.new(lmax+1).map! { 0 }
      result[0] = result[lmax+1] = 0
      exp_basis     = skill.skl_exp_basis # 50 # 15
      exp_inflation = skill.skl_exp_inflation # 40 # 20
      m = exp_basis
      n = 0.75 + exp_inflation / 200.0;
      for i in 2..lmax
        result[i] = result[i-1] + Integer(m) #Integer((i*50)) #+(10.0+rand(20))*0.7) # //
        m *= 1 + n;
        n *= 0.9;
      end
      return result.clone
    end

#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# ** IEO::Vocab - IEO011-Secondary
#==============================================================================#
module IEO
  module Vocab
#==============================================================================#
#                      Start Secondary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    module_function # DO NOT REMOVE

    #--------------------------------------------------------------------------#
    # scope
    #--------------------------------------------------------------------------#
    def scope(num)
      case num
      when 0  ; return "No Target"        # (0:  None)
      when 1  ; return "1 Enemy"          # (1:  One Enemy)
      when 2  ; return "All Enemies"      # (2:  All Enemies)
      when 3  ; return "Dual Enemy"       # (3:  One Enemy Dual)
      when 4  ; return "1 Random Enemy"   # (4:  One Random Enemy)
      when 5  ; return "2 Random Enemies" # (5:  2 Random Enemies)
      when 6  ; return "3 Random Enemies" # (6:  3 Random Enemies)
      when 7  ; return "1 Ally"           # (7:  One Ally)
      when 8  ; return "All Allies"       # (8:  All Allies)
      when 9  ; return "Dead Ally"        # (9:  One Ally (Dead))
      when 10 ; return "Dead Allies"      # (10: All Allies (Dead))
      when 11 ; return "User"             # (11: The User)
      else    ; return ""
      end
    end

    module SKILL_LEVEL

      LEVEL_SUB     = "%s %d/%d"
      NEXT_COST_SUB = "%s%d Cost"

      HIT           = "Hit"
      HEAL          = "Heal"
      VARIANCE      = "Variance"
      DAMAGE        = "Damage"
      ACTION_SPEED  = "Speed"
      ATK_F         = "ATK Rate"
      SPI_F         = "SPI Rate"

      ADD_STATE     = "Add State:"
      MINUS_STATE   = "Minus State:"

      LEVEL_MAX     = "MAX"

    end
#==============================================================================#
#                        End Secondary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# ** RPG::Skill - IEO011-Lunatic
#==============================================================================#
class RPG::Skill
#==============================================================================#
#                      Start Lunatic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # change_skill_cost - This is used to properly do changes to
  # skill costs, this is mostly for compatability with IEO-003(Custom Skill Costs)
  #--------------------------------------------------------------------------#
  def change_skill_cost(oldcost, ratecost)
    # ---------------------------------------------------------------------- #
    return oldcost if ratecost.nil?
    # ---------------------------------------------------------------------- #
    result = oldcost
    # ---------------------------------------------------------------------- #
    case result
    # ---------------------------------------------------------------------- #
    when /(\d+)[ ](MP|SP)/i
      val = IEO::SKILL_LEVEL.change_numeric_value($1.to_i, ratecost)
      result = sprintf("%d %s", val, $2)
    # ---------------------------------------------------------------------- #
    when /(\d+)([%％])[ ](MP|SP|MAXMP|MAXSP)/i
      val = IEO::SKILL_LEVEL.change_numeric_value($1.to_i, ratecost)
      result = sprintf("%d%s %s", val, $2, $3)
    # ---------------------------------------------------------------------- #
    when /(\d+)[ ](HP|LP)/i
      val = IEO::SKILL_LEVEL.change_numeric_value($1.to_i, ratecost)
      result = sprintf("%d %s", val, $2)
    # ---------------------------------------------------------------------- #
    when /(\d+)([%％])[ ](HP|LP|MAXHP|MAXLP)/i
      val = IEO::SKILL_LEVEL.change_numeric_value($1.to_i, ratecost)
      result = sprintf("%d%s %s", val, $2, $3)
    # ---------------------------------------------------------------------- #
    when /ITEM[ ](\d+):(\d+)/i
      iid = $1.to_i
      val = IEO::SKILL_LEVEL.change_numeric_value($2.to_i, ratecost)
      result = sprintf("ITEM %d:%d", iid, val)
    end
    # ---------------------------------------------------------------------- #
    return result
    # ---------------------------------------------------------------------- #
  end
#==============================================================================#
#                        End Lunatic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
end

#==============================================================================#
# ** IEO::Icon
#==============================================================================#
module IEO
  module Icon

    module_function

    def stat(cstat) ; return 0 end
    def scope(num)  ; return 0 end

  end
end

#==============================================================================#
# ** IEO::REGEXP::SKILL_LEVEL
#==============================================================================#
module IEO
  module REGEXP
    module SKILL_LEVEL
      module BASE
        PER_P = /([\+\-]\d+)([%％])/i # Per Percent
        SET_P = /(\d+)([%％])/i       # Set Percent
        PER_S = /([\+\-]\d+)/i        # Per Set
      end
      module ITEM
        SKL_P = /<(?:SKL_P|skl p):[ ]*([\+\-]\d+)>/i
      end
      module SKILL
        LEVELMOD = /<(PERLEVEL|ATLEVEL.*)[ ](.*):[ ]*(.*)>/i
        MAXLEVEL = /<(?:MAXLEVEL|MAX_LEVEL|MAX LEVEL):[ ]*(\d+)>/i
        NOEDIT   = /<(?:NOTEDITABLE|NOT_EDITABLE|NOT EDITABLE|NOEDIT|NO_EDIT|NO EDIT)>/i
        LEVELCOST= /<(?:LEVELCOST|LEVEL_COST|LEVEL COST)[ ](\d+):[ ]*(\d+)>/i

        LEVELMOD_SET  = /<(ATLEVEL.*)>/i
        LEVELMOD_SET2 = /<\/ATLEVEL>/i
        PERLEVEL_SET  = /<PERLEVEL>/i
        PERLEVEL_SET2 = /<\/PERLEVEL>/i

        EXP_BASIS     = /<(EXP_BASIS|EXPBASIS|EXP BASIS):[ ]*(\d+)>/i
        EXP_INFLATE   = /<(EXP_INFLATE|EXPINFLATE|EXP INFLATE):[ ]*(\d+)>/i
      end
      module ENEMY
        SKL_P = /<(?:SKL_P|skl p):[ ]*(\d+)>/i
      end
    end
  end
end

#==============================================================================#
# ** IEO::SKILL_LEVEL
#==============================================================================#
module IEO
  module SKILL_LEVEL

    module_function

    #--------------------------------------------------------------------------#
    # * change_numeric_value
    #--------------------------------------------------------------------------#
    def change_numeric_value(oldvalue, mod)
      return oldvalue if mod.nil?
      result = oldvalue
      # ---------------------------------------------------------------------- #
      case mod
      when IEO::REGEXP::SKILL_LEVEL::BASE::PER_P
        result+= result * $1.to_i / 100
      when IEO::REGEXP::SKILL_LEVEL::BASE::SET_P
        result = result * $1.to_i / 100
      when IEO::REGEXP::SKILL_LEVEL::BASE::PER_S
        result+= $1.to_i
      else
        result = mod.to_i
      end
      # ---------------------------------------------------------------------- #
      return Integer(result)
    end

    #--------------------------------------------------------------------------#
    # * dup_skill # // Used by SKLMODE 3
    #--------------------------------------------------------------------------#
    def dup_skill(skill_id)
      new_id = $data_skills.size
      $data_skills[new_id] = $data_skills[skill_id].deep_clone
      $data_skills[new_id].id = new_id
      return $data_skills[new_id]
    end

    # // Uses a has for the skills instead of an array, increases performance
    # // But can't use multiple same skills
    # // 0 - Unsorted Array, 1 - Hash, 2 - Sorted Array, 3 - Dup Skill Array ($data_skills)
    SKLMODE       = 2
    LEVELPULLMODE = true

  end
end

#==============================================================================#
# ** IEO::SKILL_LEVEL::Level_Struct
#==============================================================================#
class IEO::SKILL_LEVEL::Level_Struct

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  (ATTRS = [:name, :cost, :subcost, :base_damage, :variance, :speed, :hit_ratio,
           :spi_f, :atk_f, :scope, :anim_id, :icon_index,
           :state_add, :state_rem, :elements]).each { |at|
    attr_accessor at
  }

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize
    ATTRS.each { |a| instance_variable_set("@#{a.to_s}", nil) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :attributes
  #--------------------------------------------------------------------------#
  def attributes ; return ATTRS ; end

  #--------------------------------------------------------------------------#
  # * new-method :[]
  #--------------------------------------------------------------------------#
  def [](value ) ; return self.send( value) ; end

  #--------------------------------------------------------------------------#
  # * new-method :[]=
  #--------------------------------------------------------------------------#
  def []=(value, set_value)
    return self.send(value.to_s+"=", set_value)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :to_s
  #--------------------------------------------------------------------------#
  def to_s
    return attributes.inject("") { |r, e| r + %Q(\n<#{e} = "#{self[e]}"/>) }
  end

end

#==============================================================================#
# ** IEO::SKILL_LEVEL::WIN_BASE
#==============================================================================#
module IEO::SKILL_LEVEL::WIN_BASE
  INCL = %Q(
  #--------------------------------------------------------------------------#
  # * Draw Actor Skill Points
  #     actor : Actor
  #     rect  : Rect
  #--------------------------------------------------------------------------#
  def draw_actor_skl_p(actor, crect)
    draw_skl_p(actor.skl_p, crect)
  end

  #--------------------------------------------------------------------------#
  # * Draw Skill Points
  #     points: Points
  #     rect  : Rect
  #--------------------------------------------------------------------------#
  def draw_skl_p(points, crect)
    self.contents.font.size = 14
    draw_icon(IEO::Icon.stat(:skl_p), crect.x+crect.width-32, crect.y)
    crect.y -= 4 ; crect.width -= 34
    self.contents.draw_text(crect, points, 2)
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_obj_name
  #--------------------------------------------------------------------------#
  def draw_obj_name(obj, rect, enabled)
    draw_icon(obj.icon_index, rect.x, rect.y, enabled)
    self.contents.font.size = 16 #Font.default_size
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    rect.width -= 48
    self.contents.draw_text(rect.x+24, rect.y-4, rect.width-24, WLH, obj.name)
    return self.contents.text_size(obj.name)
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_obj_level
  #--------------------------------------------------------------------------#
  def draw_obj_level(obj, rect, align=0, enabled=true)
    rect.width -= 8
    self.contents.font.size = 12
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    text = sprintf("%s%d", Vocab.level_a, obj.skl_level)
    self.contents.draw_text(rect, text, align)
  end
  )
end

#==============================================================================#
# ** IEO::SKILL_LEVEL::WIN_SKILL
#==============================================================================#
module IEO::SKILL_LEVEL::WIN_SKILL
  INCL = %Q(
  #--------------------------------------------------------------------------#
  # * overwrite-method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    skill = @data[index]
    return if skill == nil
    enabled = enabled?(skill)
    rect2 = rect.clone
    rect2.x += 28; rect2.y += 14 ; rect2.height = 8 ; rect2.width /= 3

    #draw_grad_bar
    draw_round_grad_bar( rect2.clone, skill.skl_unlocklevel, skill.skl_maxlevel,
      normal_color, Color.new(200, 200, 200), Color.new(20, 20, 20),
      2, enabled )
    draw_round_grad_bar( rect2.clone, skill.skl_level, skill.skl_maxlevel,
      mp_gauge_color1, mp_gauge_color2, Color.new(20, 20, 20),
      2, enabled )
    # //
    if IEO::SKILL_LEVEL::SKILL_MODE == 1
      rect2.x += rect2.width+16 ; rect2.width -= 16
      bc = skill.level_skl_exp ; bm = skill.next_skl_expr
      if bm > 0 && !skill.unlocked_level?(skill.skl_maxlevel)
        draw_grad_bar( rect2.clone, bc, bm,
          hp_gauge_color1, hp_gauge_color2, Color.new(20, 20, 20),
          2, enabled )
      end
      rect2.height = WLH  ; rect2.y -= 16
    end
    te = draw_obj_name(skill, rect.clone, enabled)
    rect2 = rect.clone
    rect2.y -= 6 ; rect2.height = WLH ; rect2.x += te.width+28
    draw_obj_level(skill, rect2.clone, 0, enabled)
    if $imported["IEO-CustomSkillCosts"]
      draw_obj_cost(skill, rect.clone, enabled)
    else
      rect.width -= 8 ; self.contents.draw_text(rect.clone, skill.mp_cost, 2)
    end
  end

  #--------------------------------------------------------------------------
  # * new-method :enabled?
  #--------------------------------------------------------------------------
  def enabled?(skill)
    return false if skill.nil?
    return false unless skill.editable if $scene.is_a?(Scene_SkillForge)
    return @actor.skill_can_use?(skill)
  end
  )
end

#==============================================================================#
# ** IEO::SKILL_LEVEL::MIXES
#==============================================================================#
module IEO::SKILL_LEVEL::MIXES ; end
#==============================================================================#
# ** IEO::SKILL_LEVEL::MIXES::Item
#==============================================================================#
module IEO::SKILL_LEVEL::MIXES::Item

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :skl_p

  #--------------------------------------------------------------------------#
  # * new-method :ieo011_itemcache
  #--------------------------------------------------------------------------#
  def ieo011_itemcache
    @skl_p = 0
    # ---------------------------------------------------------------------- #
    self.note.split(/[\r\n]+/).each { |line|
      case line
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::ITEM::SKL_P
        @skl_p = $1.to_i
      end
    }
    # ---------------------------------------------------------------------- #
    @ieo011_itemcache_complete = true
    # ---------------------------------------------------------------------- #
  end

end

#==============================================================================#
# ** IEO::SKILL_LEVEL::MIXES::Skill
#==============================================================================#
module IEO::SKILL_LEVEL::MIXES::Skill

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :original_id
  attr_accessor :editable
  attr_accessor :skl_skill       # Is this an skl_skill?
  attr_accessor :skl_level
  attr_accessor :skl_maxlevel
  attr_accessor :skl_atlevelmod
  attr_accessor :skl_perlevelmod
  attr_accessor :skl_levelcache
  attr_accessor :skl_openlevels
  attr_accessor :skl_levelcosts
  attr_accessor :skl_unlocklevel
  attr_accessor :skl_p

  attr_accessor :skl_exp_basis
  attr_accessor :skl_exp_inflation

  attr_reader   :skl_exp
  attr_reader   :skl_expmax
  attr_reader   :skl_exp_list

  #--------------------------------------------------------------------------#
  # * new-method :skl_skill?
  #--------------------------------------------------------------------------#
  def skl_skill?
    @skl_skill = false if @skl_skill.nil?
    return @skl_skill
  end

  #--------------------------------------------------------------------------#
  # * new-method :skillcache_set
  #--------------------------------------------------------------------------#
  def skillcache_set(base, type, val)
    config = []
    case type.upcase
    when "NAME"
      config = [:name, val]
    when "COST"
      config = [:cost, val]
    when "SUBCOST"
      config = [:subcost, val]
    when "BASE_DAMAGE", "BASEDAMAGE", "BASE DAMAGE"
      config = [:base_damage, val]
    when "ATK_F"
      config = [:atk_f, val]
    when "SPI_F"
      config = [:spi_f, val]
    when "VARIANCE"
      config = [:variance, val]
    when "SPEED"
      config = [:speed, val]
    when "HITRATIO", "HIT_RATIO", "HIT RATIO", "HIT"
      config = [:hit_ratio, val]
    when "SCOPE"
      config = [:scope, val]
    when "ANIM_ID", "ANIMID", "ANIM ID"
      config = [:anim_id, val]
    when "ICONINDEX", "ICON_INDEX", "ICON INDEX", "ICON"
      config = [:icon_index, val]
    when "SADD", "STATE_PLUS", "STATEPLUS", "STATE PLUS"
      config = [:state_add, val]
    when "SRMV", "STATE_MINUS", "STATEMINUS", "STATE MINUS"
      config = [:state_rem, val]
    when "ELEMENT"
      config = [:element, val]
    else
      config = setup_skl_custom_type(type, val)
      return if config.nil?
    end
    # -------------------------------------------------------------------- #
    case base.upcase
    when /ATLEVEL(.*)/i
      v = $1
      case v.upcase
      when "(MAX)" ; lvl = @skl_maxlevel
      else         ; lvl = v.to_i
      end
      (@skl_atlevelmod[lvl] ||= { })[config[0]] = config[1]
    when "PERLEVEL"
      (@skl_perlevelmod[config[0]] ||= []) << config[1]
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ieo011_skillcache
  #--------------------------------------------------------------------------#
  def ieo011_skillcache
    @original_id     = @id
    @editable        = true
    @skl_skill       = false
    @skl_level       = 1
    @skl_unlocklevel = 1
    @skl_min_level   = 1
    # ---------------------------------------------------------------------- #
    @skl_maxlevel    = 5
    @skl_atlevelmod  = { }
    @skl_perlevelmod = { }
    @skl_levelcosts  = { }
    @skl_openlevels  = [ ]
    @skl_p           = 0
    # ---------------------------------------------------------------------- #
    @skl_exp         = 0
    # ---------------------------------------------------------------------- #
    @skl_exp_basis   = 50
    @skl_exp_inflation = 40
    # ---------------------------------------------------------------------- #
    ieo011_rebuild_levelcosts
    # ---------------------------------------------------------------------- #
    @cabase = ""
    @level_caching = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when IEO::REGEXP::SKILL_LEVEL::SKILL::LEVELMOD_SET
        @cabase = $1
        @level_caching = true
      when IEO::REGEXP::SKILL_LEVEL::SKILL::LEVELMOD_SET2
        @cabase = ""
        @level_caching = false
      when IEO::REGEXP::SKILL_LEVEL::SKILL::PERLEVEL_SET
        @cabase = "PERLEVEL"
        @level_caching = true
      when IEO::REGEXP::SKILL_LEVEL::SKILL::PERLEVEL_SET2
        @cabase = ""
        @level_caching = false
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::SKILL::LEVELMOD
        base = $1
        type = $2
        val  = $3
        skillcache_set(base, type, val)
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::SKILL::MAXLEVEL
        @skl_maxlevel = $1.to_i
        ieo011_rebuild_levelcosts
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::SKILL::NOEDIT
        @editable = false
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::SKILL::LEVELCOST
        @skl_levelcosts[$1.to_i] = $2.to_i
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::ITEM::SKL_P
        @skl_p = $1.to_i
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::SKILL::EXP_BASIS
        @skl_exp_basis = $1.to_i
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::SKILL::EXP_INFLATE
        @skl_exp_inflation = $1.to_i
    # ---------------------------------------------------------------------- #
      else
        if @level_caching
          case line
          when /(.*):[ ](.*)/i
            skillcache_set(@cabase, $1, $2)
          end
        end
      end
    }
    # ---------------------------------------------------------------------- #
    ieo011_build_firstlevel_cache
    ieo011_build_mainsklcaches
    # ---------------------------------------------------------------------- #
    @ieo011_skillcache_complete = true
    # ---------------------------------------------------------------------- #
    @skl_exp_list   = IEO::SKILL_LEVEL.skill_explist(self)
    @skl_expmax     = IEO::SKILL_LEVEL.skill_exp_max(self)
    # ---------------------------------------------------------------------- #
    change_level(@skl_unlocklevel)
    # ---------------------------------------------------------------------- #
    #File.open("SkillLevelData/SK#{"%03d"%@id}#{@name}.xml", "w+") { |f|
    #  @skl_levelcache.each { |e| f.puts(e.to_s) }
    #}
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_skl_custom_type
  #--------------------------------------------------------------------------#
  def setup_skl_custom_type(type, value)
    return nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :ieo011_rebuild_levelcosts
  #--------------------------------------------------------------------------#
  def ieo011_rebuild_levelcosts
    @skl_levelcosts.clear
    @skl_openlevels.clear
    for i in 0..@skl_maxlevel
      @skl_levelcosts[i] = IEO::SKILL_LEVEL.level_cost(self, i)
      @skl_openlevels[i] = false
    end
    @skl_openlevels[@skl_min_level] = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :ieo011_build_firstlevel_cache
  #--------------------------------------------------------------------------#
  def ieo011_build_firstlevel_cache
    # ---------------------------------------------------------------------- #
    @skl_levelcache = {}
    tcost = "#{@mp_cost} MP"
    # ---------------------------------------------------------------------- #
    @skl_levelcache[@skl_min_level] = ::IEO::SKILL_LEVEL::Level_Struct.new
    # ---------------------------------------------------------------------- #
    @skl_levelcache[@skl_min_level][:name]        = @name
    @skl_levelcache[@skl_min_level][:cost]        = $imported["IEO-CustomSkillCosts"] ? @cost : tcost
    @skl_levelcache[@skl_min_level][:subcost]     = $imported["IEO-CustomSkillCosts"] ? @subcost : ""
    @skl_levelcache[@skl_min_level][:base_damage] = @base_damage
    @skl_levelcache[@skl_min_level][:variance]    = @variance
    @skl_levelcache[@skl_min_level][:speed]       = @speed
    @skl_levelcache[@skl_min_level][:hit_ratio]   = @hit
    @skl_levelcache[@skl_min_level][:spi_f]       = @spi_f
    @skl_levelcache[@skl_min_level][:atk_f]       = @atk_f
    @skl_levelcache[@skl_min_level][:scope]       = @scope
    @skl_levelcache[@skl_min_level][:anim_id]     = @animation_id
    @skl_levelcache[@skl_min_level][:icon_index]  = @icon_index
    @skl_levelcache[@skl_min_level][:state_add]   = @plus_state_set
    @skl_levelcache[@skl_min_level][:state_rem]   = @minus_state_set
    @skl_levelcache[@skl_min_level][:elements]    = @element_set
    build_firstlevel_cache_custom
    # ---------------------------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * new-method :build_firstlevel_cache_custom
  #--------------------------------------------------------------------------#
  def build_firstlevel_cache_custom
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :ieo011_build_mainsklcaches
  #--------------------------------------------------------------------------#
  def ieo011_build_mainsklcaches
    iskl = IEO::SKILL_LEVEL
    # ---------------------------------------------------------------------- #
    for i in (@skl_min_level+1)..@skl_maxlevel
      @skl_atlevelmod[i] ||= { }
      @skl_levelcache[i] ||= { }
      # ---------------------------------------------------------------------- #
      lastlevel = [@skl_min_level, i-1].max
      @skl_levelcache[i] = @skl_levelcache[lastlevel].clone
      # //
      level_proc = Proc.new { |clc, lvmods|
        result = clc
        lvmods.each { |r|
          result = IEO::SKILL_LEVEL.change_numeric_value(result, r)
        } unless lvmods.nil?
        result
      }
      atlevel_proc = Proc.new { |clc, lvmod|
        result = clc
        result = IEO::SKILL_LEVEL.change_numeric_value(clc, lvmod) unless lvmod.nil?
        result
      }
      # //
      level_proc_cost = Proc.new { |clc, lvmods|
        result = clc
        lvmods.each { |r|
          result = change_skill_cost(result, r)
        } unless lvmods.nil?
        result
      }
      atlevel_array_proc = Proc.new { |clc, lvmod|
        result = clc.clone
        lvmod.to_s.scan(/([\+\-])(\d+)/i).each { |d|
          op, val = $1, $2
          case $1
          when "+"
            result |= [$2.to_i]
          when "-"
            result -= [$2.to_i]
          end
        }
        result
      }
      # ---------------------------------------------------------------------- #
      @skl_levelcache[i][:cost]        = level_proc_cost.call(@skl_levelcache[i][:cost], @skl_perlevelmod[:cost])
      @skl_levelcache[i][:subcost]     = level_proc_cost.call(@skl_levelcache[i][:subcost], @skl_perlevelmod[:subcost])
      @skl_levelcache[i][:base_damage] = level_proc.call(@skl_levelcache[i][:base_damage], @skl_perlevelmod[:base_damage])
      @skl_levelcache[i][:variance]    = level_proc.call(@skl_levelcache[i][:variance]   , @skl_perlevelmod[:variance])
      @skl_levelcache[i][:speed]       = level_proc.call(@skl_levelcache[i][:speed]      , @skl_perlevelmod[:speed])
      @skl_levelcache[i][:hit_ratio]   = level_proc.call(@skl_levelcache[i][:hit_ratio]  , @skl_perlevelmod[:hit_ratio])
      @skl_levelcache[i][:spi_f]       = level_proc.call(@skl_levelcache[i][:spi_f]      , @skl_perlevelmod[:spi_f])
      @skl_levelcache[i][:atk_f]       = level_proc.call(@skl_levelcache[i][:atk_f]      , @skl_perlevelmod[:atk_f])
      # ---------------------------------------------------------------------- #
      @skl_levelcache[i][:name]        = @skl_atlevelmod[i][:name] unless @skl_atlevelmod[i][:name].nil?
      @skl_levelcache[i][:cost]        = change_skill_cost(@skl_levelcache[i][:cost], @skl_atlevelmod[i][:cost])
      @skl_levelcache[i][:subcost]     = change_skill_cost(@skl_levelcache[i][:subcost], @skl_atlevelmod[i][:subcost])
      @skl_levelcache[i][:base_damage] = atlevel_proc.call(@skl_levelcache[i][:base_damage], @skl_atlevelmod[i][:base_damage])
      @skl_levelcache[i][:variance]    = atlevel_proc.call(@skl_levelcache[i][:variance]   , @skl_atlevelmod[i][:variance])
      @skl_levelcache[i][:speed]       = atlevel_proc.call(@skl_levelcache[i][:speed]      , @skl_atlevelmod[i][:speed])
      @skl_levelcache[i][:hit_ratio]   = atlevel_proc.call(@skl_levelcache[i][:hit_ratio]  , @skl_atlevelmod[i][:hit_ratio])
      @skl_levelcache[i][:spi_f]       = atlevel_proc.call(@skl_levelcache[i][:spi_f]      , @skl_atlevelmod[i][:spi_f])
      @skl_levelcache[i][:atk_f]       = atlevel_proc.call(@skl_levelcache[i][:atk_f]      , @skl_atlevelmod[i][:atk_f])
      @skl_levelcache[i][:scope]       = atlevel_proc.call(@skl_levelcache[i][:scope]      , @skl_atlevelmod[i][:scope])
      @skl_levelcache[i][:anim_id]     = atlevel_proc.call(@skl_levelcache[i][:anim_id]    , @skl_atlevelmod[i][:anim_id])
      @skl_levelcache[i][:icon_index]  = atlevel_proc.call(@skl_levelcache[i][:icon_index] , @skl_atlevelmod[i][:icon_index])
      @skl_levelcache[i][:state_add]   = atlevel_array_proc.call(@skl_levelcache[i][:state_add] , @skl_atlevelmod[i][:state_add])
      @skl_levelcache[i][:state_rem]   = atlevel_array_proc.call(@skl_levelcache[i][:state_rem] , @skl_atlevelmod[i][:state_rem])
      @skl_levelcache[i][:elements]    = atlevel_array_proc.call(@skl_levelcache[i][:elements] , @skl_atlevelmod[i][:elements])
      # ---------------------------------------------------------------------- #
      build_custom_mainsklcache(i, [level_proc, atlevel_proc, atlevel_array_proc])
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :build_custom_mainsklcache
  #--------------------------------------------------------------------------#
  def build_custom_mainsklcache(index, procs)
  end

  #--------------------------------------------------------------------------#
  # * new-method :level_up
  #--------------------------------------------------------------------------#
  def level_up(change_only=false )   ; return change_level( @skl_level+1, change_only) end

  #--------------------------------------------------------------------------#
  # * new-method :level_down
  #--------------------------------------------------------------------------#
  def level_down(change_only=false ) ; return change_level( @skl_level-1, change_only) end

  #--------------------------------------------------------------------------#
  # * new-method :change_level
  #--------------------------------------------------------------------------#
  def change_level(new_level, change_only=false)
    if IEO::SKILL_LEVEL::SKILL_MODE == 1
      @skl_unlocklevel = [[new_level, @skl_maxlevel].min, @skl_min_level].max if new_level > @skl_unlocklevel unless change_only
    end
    # ---------------------------------------------------------------------- #
    new_level    = [[[new_level, @skl_unlocklevel].min, @skl_maxlevel].min, @skl_min_level].max
    # ---------------------------------------------------------------------- #
    @skl_level   = new_level
    # ---------------------------------------------------------------------- #
    @name            = @skl_levelcache[new_level][:name]
    @cost            = @skl_levelcache[new_level][:cost]
    @subcost         = @skl_levelcache[new_level][:subcost]
    @base_damage     = @skl_levelcache[new_level][:base_damage]
    @variance        = @skl_levelcache[new_level][:variance]
    @speed           = @skl_levelcache[new_level][:speed]
    @hit             = @skl_levelcache[new_level][:hit_ratio]
    @spi_f           = @skl_levelcache[new_level][:spi_f]
    @atk_f           = @skl_levelcache[new_level][:atk_f]
    @scope           = @skl_levelcache[new_level][:scope]
    @animation_id    = @skl_levelcache[new_level][:anim_id]
    @icon_index      = @skl_levelcache[new_level][:icon_index]
    @plus_state_set  = @skl_levelcache[new_level][:state_add]
    @minus_state_set = @skl_levelcache[new_level][:state_rem]
    @element_set     = @skl_levelcache[new_level][:elements]
    # ---------------------------------------------------------------------- #
    unless $imported["IEO-CustomSkillCosts"]
      @mp_cost = @cost.gsub(/(\d+)[ ]*(MP|SP)/i) { $1.to_i }
      @mp_cost = Integer(@mp_cost)
    end
    # ---------------------------------------------------------------------- #
    change_level_custom(new_level)
    # ---------------------------------------------------------------------- #
    @skl_exp = next_skl_exp(0 ) if @skl_exp < next_skl_exp( 0)
    return new_level
  end

  #--------------------------------------------------------------------------#
  # * new-method :change_level_custom
  #--------------------------------------------------------------------------#
  def change_level_custom(new_level)
  end

  #--------------------------------------------------------------------------#
  # * new-method :skl_nextlevelcost
  #--------------------------------------------------------------------------#
  def skl_nextlevelcost(n)
    return 0 if @skl_unlocklevel >= @skl_maxlevel
    level = get_nextlevel(n)
    return @skl_levelcosts[level]
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_nextlevel
  #--------------------------------------------------------------------------#
  def get_nextlevel(n=1)
    return [[@skl_unlocklevel+n, @skl_maxlevel].min, @skl_min_level].max
  end

  # // Level Skill Mode
  #--------------------------------------------------------------------------#
  # * new-method :change_skl_exp
  #--------------------------------------------------------------------------#
  def change_skl_exp(nexp)
    last_level = @skl_unlocklevel
    @skl_exp = [[nexp, @skl_expmax].min, 0].max
    while @skl_exp >= @skl_exp_list[@skl_unlocklevel+1] and @skl_exp_list[@skl_unlocklevel+1] > 0
      level_up
      break if @skl_unlocklevel == @skl_maxlevel
    end
    while @skl_exp < @skl_exp_list[@skl_unlocklevel]
      level_down
      break if @skl_unlocklevel == @skl_min_level
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :skl_exp=
  #--------------------------------------------------------------------------#
  def skl_exp=(val)
    change_skl_exp(val)
  end

  #--------------------------------------------------------------------------#
  # * new-method :next_skl_exp
  #--------------------------------------------------------------------------#
  def next_skl_exp(n=1)
    return @skl_exp_list[@skl_unlocklevel+n]
  end

  #--------------------------------------------------------------------------#
  # * new-method :next_expr
  #--------------------------------------------------------------------------#
  def next_skl_expr
    return @skl_exp_list[@skl_unlocklevel+1] - @skl_exp_list[@skl_unlocklevel]
  end

  #--------------------------------------------------------------------------#
  # * new-method :level_skl_exp
  #--------------------------------------------------------------------------#
  def level_skl_exp
    return @skl_exp - @skl_exp_list[@skl_unlocklevel]
  end

  #--------------------------------------------------------------------------#
  # * new-method :maxed_level?
  #--------------------------------------------------------------------------#
  def maxed_level? ; return (@skl_unlocklevel >= @skl_maxlevel) ; end

  #--------------------------------------------------------------------------#
  # * new-method :unlocked_level?
  #--------------------------------------------------------------------------#
  def unlocked_level?(level) ; return level < @skl_unlocklevel ; end

end

#==============================================================================#
# ** IEO::SKILL_LEVEL::MIXES::Enemy
#==============================================================================#
module IEO::SKILL_LEVEL::MIXES::Enemy

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :skl_p

  #--------------------------------------------------------------------------#
  # * new-method :ieo011_enemycache
  #--------------------------------------------------------------------------#
  def ieo011_enemycache
    @skl_p = 0
    # ---------------------------------------------------------------------- #
    self.note.split(/[\r\n]+/).each { |line|
      case line
    # ---------------------------------------------------------------------- #
      when IEO::REGEXP::SKILL_LEVEL::ENEMY::SKL_P
        @skl_p = $1.to_i
      end
    }
    # ---------------------------------------------------------------------- #
    @ieo011_enemycache_complete = true
    # ---------------------------------------------------------------------- #
  end

end

#==============================================================================#
# ** RPG::Item
#==============================================================================#
class RPG::Item

  include IEO::SKILL_LEVEL::MIXES::Item

end

#==============================================================================#
# ** RPG::Skill
#==============================================================================#
class RPG::Skill

  include IEO::SKILL_LEVEL::MIXES::Skill

  # // Level Pull Mode
if IEO::SKILL_LEVEL::LEVELPULLMODE
  #--------------------------------------------------------------------------#
  # * overwrite accessor method :cost
  #--------------------------------------------------------------------------#
  def cost(level = @skl_level)
    return @skl_levelcache[level][:cost]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :base_damage
  #--------------------------------------------------------------------------#
  def base_damage(level = @skl_level)
    return @skl_levelcache[level][:base_damage]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :variance
  #--------------------------------------------------------------------------#
  def variance(level = @skl_level)
    return @skl_levelcache[level][:variance]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :speed
  #--------------------------------------------------------------------------#
  def speed(level = @skl_level)
    return @skl_levelcache[level][:speed]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :hit
  #--------------------------------------------------------------------------#
  def hit(level = @skl_level)
    return @skl_levelcache[level][:hit_ratio]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :spi_f
  #--------------------------------------------------------------------------#
  def spi_f(level = @skl_level)
    return @skl_levelcache[level][:spi_f]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :atk_f
  #--------------------------------------------------------------------------#
  def atk_f(level = @skl_level)
    return @skl_levelcache[level][:atk_f]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :scope
  #--------------------------------------------------------------------------#
  def scope(level = @skl_level)
    return @skl_levelcache[level][:scope]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :animation_id
  #--------------------------------------------------------------------------#
  def animation_id(level = @skl_level)
    return @skl_levelcache[level][:anim_id]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :mp_cost
  #--------------------------------------------------------------------------#
  def mp_cost(level = @skl_level)
    return Integer(cost( level ).gsub( /(\d+)[ ]*(MP|SP)/i ) { $1.to_i })
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :icon_index
  #--------------------------------------------------------------------------#
  def icon_index(level = @skl_level)
    return @skl_levelcache[level][:icon_index]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :name
  #--------------------------------------------------------------------------#
  def name(level = @skl_level)
    return @skl_levelcache[level][:name]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :plus_state_set
  #--------------------------------------------------------------------------#
  def plus_state_set(level = @skl_level)
    return @skl_levelcache[level][:state_add]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :minus_state_set
  #--------------------------------------------------------------------------#
  def minus_state_set(level = @skl_level)
    return @skl_levelcache[level][:state_rem]
  end

  #--------------------------------------------------------------------------#
  # * overwrite accessor method :element_set
  #--------------------------------------------------------------------------#
  def element_set(level = @skl_level)
    return @skl_levelcache[level][:elements]
  end

end # // Level Pull Mode

end

#==============================================================================#
# ** RPG::Enemy
#==============================================================================#
class RPG::Enemy

  include IEO::SKILL_LEVEL::MIXES::Enemy

end

#==============================================================================#
# ** Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :can_upgrade_skills

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo011_gs_initialize :initialize unless $@
  def initialize
    ieo011_gs_initialize
    @can_upgrade_skills = IEO::SKILL_LEVEL::ONSTART_UPGRADE
  end

end

#==============================================================================#
# ** Game_BattleAction
#==============================================================================#
class Game_BattleAction

  #--------------------------------------------------------------------------#
  # * alias-method :clear
  #--------------------------------------------------------------------------#
  alias :ieo011_gba_clear :clear unless $@
  def clear
    ieo011_gba_clear
    @skl_skill = nil
  end

  #--------------------------------------------------------------------------#
  # * alias-method :set_skill
  #--------------------------------------------------------------------------#
  alias :ieo011_gba_set_skill :set_skill unless $@
  def set_skill(skill_id)
    ieo011_gba_set_skill(skill_id)
    assign_skl_skill(skill_id)
  end

  #--------------------------------------------------------------------------#
  # * new-method :assign_skl_skill
  #--------------------------------------------------------------------------#
  def assign_skl_skill(skill_id)
    @skl_skill = $data_skills[skill_id]
    @skl_skill = @battler.match_skl_skill_to_id(skill_id ) if @battler.actor? #.is_a?( Game_Actor)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :skill
  #--------------------------------------------------------------------------#
  def skill
    assign_skl_skill(@skill_id) if @skl_skill.nil?
    unless @skl_skill.nil?
      assign_skl_skill(@skill_id) if @skl_skill.id != @skill_id
    end
    return skill? ? @skl_skill : nil
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :valid?
  #--------------------------------------------------------------------------#
  def valid?
    return false if nothing?                    # Do nothing
    return true if @forcing                       # Force to act
    return false unless battler.movable?        # Cannot act
    if skill?                                   # Skill
      return false unless battler.skill_can_use?(skill)
    elsif item?                                 # Item
      return false unless friends_unit.item_can_use?(item)
    end
    return true
  end

end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :skill_effect
  #--------------------------------------------------------------------------#
  alias :ieo011_gb_skill_effect :skill_effect unless $@
  def skill_effect(user, skill)
    ieo011_gb_skill_effect(user, skill)
    return if @skipped || @missed || @evaded
    IEO::SKILL_LEVEL.skl_p_gain(:use, self, skill, user)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :item_effect
  #--------------------------------------------------------------------------#
  alias :ieo011_gb_item_effect :item_effect unless $@
  def item_effect(user, item)
    ieo011_gb_item_effect(user, item)
    return if @skipped || @missed || @evaded
    IEO::SKILL_LEVEL.skl_p_gain(:use, self, item, user)
  end

end

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo011_ge_initialize :initialize unless $@
  def initialize(index, enemy_id)
    @skl_p = 0 ; @skl_p_limit = 0
    ieo011_ge_initialize(index, enemy_id)
    @skl_p = enemy.skl_p ; @skl_p_limit = IEO::SKILL_LEVEL.skl_p_limit(self)
  end

  #--------------------------------------------------------------------------#
  # * new-method :skl_p_limit
  #--------------------------------------------------------------------------#
  def skl_p_limit ; return @skl_p_limit end

  #--------------------------------------------------------------------------#
  # * new-method :skl_p
  #--------------------------------------------------------------------------#
  def skl_p       ; return Integer(@skl_p) end

  #--------------------------------------------------------------------------#
  # * new-method :skl_p=
  #--------------------------------------------------------------------------#
  def skl_p=(val ) ; @skl_p = Integer( [[val, 0].max, skl_p_limit].min) end

end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :ieo011_ga_setup :setup unless $@
  def setup(actor_id)
    create_skl_skills
    @skl_p = 0 ; @skl_p_limit = 0
    ieo011_ga_setup(actor_id)
    @skl_p_limit = IEO::SKILL_LEVEL.skl_p_limit(self)
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_skl_skills
  #--------------------------------------------------------------------------#
  def create_skl_skills
    case IEO::SKILL_LEVEL::SKLMODE
    when 0
      @skl_skills = [ ]
    when 1
      @skl_skills = { }
    when 2
      @skl_skills = Array.new($data_skills.size, nil)
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :match_skl_skill_to_id
  #--------------------------------------------------------------------------#
case IEO::SKILL_LEVEL::SKLMODE
when 0, 2
  def match_skl_skill_to_id(skill_id)
    create_skl_skills if @skl_skills.nil?
    sklst = []
    sklst += @skl_skills.compact
    sklst += level_class(@class_id).skills if $imported["IEO-ClassSystem"]
    sklst.each { |ski| return ski if ski.id.eql?(skill_id) }
    return $data_skills[skill_id]
  end
when 1
  def match_skl_skill_to_id(skill_id)
    create_skl_skills if @skl_skills.nil?
    sklst = {}
    sklst.update(@skl_skills)
    sklst += level_class(@class_id).skills if $imported["IEO-ClassSystem"]
    return sklst[skill_id] if sklst.has_key?(skill_id)
    return $data_skills[skill_id]
  end
when 3
  def match_skl_skill_to_id(skill_id)
    return $data_skills[skill_id]
  end
end

  #--------------------------------------------------------------------------#
  # * new-method :skl_p_limit
  #--------------------------------------------------------------------------#
  def skl_p_limit ; return @skl_p_limit end

  #--------------------------------------------------------------------------#
  # * new-method :skl_p
  #--------------------------------------------------------------------------#
  def skl_p       ; return Integer(@skl_p) end

  #--------------------------------------------------------------------------#
  # * new-method :skl_p=
  #--------------------------------------------------------------------------#
  def skl_p=(val ) ; @skl_p = Integer( [[val, 0].max, skl_p_limit].min) end

  #--------------------------------------------------------------------------#
  # * new-method :can_upgrade_skill?
  #--------------------------------------------------------------------------#
  def can_upgrade_skill?(skill, level, bypasscost = false)
    return false if skill.nil?
    return false if skill.skl_maxlevel < level
    return false if skill.skl_nextlevelcost(1) > skl_p unless bypasscost
    return false if skill.skl_openlevels[skill.skl_unlocklevel+1]
    return false if skill.skl_unlocklevel >= skill.skl_maxlevel
    return false unless skill.editable
    return false unless skill.skl_skill?
    return false unless @skl_skills.include?(skill)
    return true
  end

  #--------------------------------------------------------------------------#
  # * new-method :upgrade_skill
  #--------------------------------------------------------------------------#
  def upgrade_skill(skill, level, bypasscost = false)
    return false unless can_upgrade_skill?(skill, level, bypasscost)
    self.skl_p -= skill.skl_nextlevelcost(1) unless bypasscost
    skill.skl_openlevels[level] = true
    skill.skl_unlocklevel = level
    return true
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :learn_skill
  #--------------------------------------------------------------------------#
  def learn_skill(skill_id)
    create_skl_skills if @skl_skills.nil?
    unless @skills.include?(skill_id)
      @skills.push(skill_id) ; @skills.sort!
      learn_skl_skill(skill_id)
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :learn_skl_skill
  #--------------------------------------------------------------------------#
case IEO::SKILL_LEVEL::SKLMODE
when 0
  def learn_skl_skill(skill_id)
    duski = $data_skills[skill_id].deep_clone ; duski.skl_skill = true
    @skl_skills << duski
  end
when 1, 2
  def learn_skl_skill(skill_id)
    duski = $data_skills[skill_id].deep_clone ; duski.skl_skill = true
    @skl_skills[skill_id] = duski
  end
when 3
  def learn_skl_skill(skill_id)
    duski = IEO::SKILL_LEVEL.dup_skill(skill_id) ; duski.skl_skill = true
    @skills.push(duski.id) ; @skills.sort!
  end

  #--------------------------------------------------------------------------#
  # * new-method :have_skill?
  #--------------------------------------------------------------------------#
  def have_skill?(skill_id)
    @skills.each { |i| return true if $data_skills[i].original_id == skill_id }
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :learn_skill
  #--------------------------------------------------------------------------#
  def learn_skill(skill_id)
    create_skl_skills if @skl_skills.nil?
    unless have_skill?(skill_id)
      learn_skl_skill(skill_id)
    end
  end

end

  #--------------------------------------------------------------------------#
  # * new-method :skl_skills
  #--------------------------------------------------------------------------#
case IEO::SKILL_LEVEL::SKLMODE
when 0
  def skl_skills
    create_skl_skills if @skl_skills.nil?
    return @skl_skills
  end
when 1, 2
  def skl_skills
    create_skl_skills if @skl_skills.nil?
    return @skills.inject([]) { |result, i| result << @skl_skills[i] }
  end
when 3
  def skl_skills
    return @skills.inject([]) { |r, s| r << $data_skills[s] }
  end
end

  #--------------------------------------------------------------------------#
  # * overwrite-method :skills
  #--------------------------------------------------------------------------#
  def skills
    result = skl_skills
    return result
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :skill_learn?
  #--------------------------------------------------------------------------#
  def skill_learn?(obj) ; return true ; end

  #--------------------------------------------------------------------------#
  # * alias-method :skill_can_use?
  #--------------------------------------------------------------------------#
  alias :ieo011_ga_skill_can_use? :skill_can_use? unless $@
  def skill_can_use?(skill)
    return true if $scene.is_a?(Scene_SkillForge)
    return ieo011_ga_skill_can_use?(skill)
  end

end

#==============================================================================#
# ** Game_Troop
#==============================================================================#
class Game_Troop < Game_Unit

  #--------------------------------------------------------------------------#
  # * new-method :distribute_skl_p
  #--------------------------------------------------------------------------#
  def distribute_skl_p
    skl_p = 0
    for member in dead_members.compact        ; skl_p += member.skl_p end
    for member in $game_party.members.compact ; member.skl_p += skl_p end
  end

end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new-method :skill_forge
  #--------------------------------------------------------------------------#
  def skill_forge(actor, lock_upgrade=nil)
    $scene = Scene_SkillForge.new(actor, lock_upgrade, :map)
  end

end

#==============================================================================#
# ** Window_Base
#==============================================================================#
class Window_Base < Window

  module_eval(IEO::SKILL_LEVEL::WIN_BASE::INCL)
  #--------------------------------------------------------------------------#
  # * new-method :__force_update
  #--------------------------------------------------------------------------#
  def __force_update ; return false end

end

#==============================================================================#
# ** Window_Skill
#==============================================================================#
class Window_Skill < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :actor
  attr_accessor :column_max

  module_eval(IEO::SKILL_LEVEL::WIN_SKILL::INCL)

end

#==============================================================================#
# ** Window_SKL_Help
#==============================================================================#
class Window_SKL_Help < Window_Base

  #--------------------------------------------------------------------------#
  # * method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @old_obj = nil
  end

  #--------------------------------------------------------------------------#
  # * method :draw_obj_stateset
  #--------------------------------------------------------------------------#
  def draw_obj_stateset(set, x, y, spacing=0)
    for i in 0...set.size
      sti = set[i]
      draw_icon($data_states[sti].icon_index, x+(i*24)+spacing, y)
    end
  end

  #--------------------------------------------------------------------------#
  # * method :set_obj
  #--------------------------------------------------------------------------#
  def set_obj(obj, bypass=false)
    return if @old_obj.eql?(obj) unless bypass
    #self.contents.clear
    create_contents
    @old_obj = obj
    return if obj.nil?
    self.contents.font.size = 18
    rect = Rect.new(4, 4, self.contents.width-24, WLH)
    brect = rect.dup ; brect.width /= 2
    draw_grad_bar( brect.clone, obj.skl_unlocklevel, obj.skl_maxlevel,
      normal_color, Color.new(200, 200, 200 ), Color.new( 20, 20, 20),
      2, true )
    draw_grad_bar( brect.clone, obj.skl_level, obj.skl_maxlevel,
      mp_gauge_color1, mp_gauge_color2, Color.new(20, 20, 20),
      2, true )
    brect.x += brect.width
    draw_obj_properties(obj, brect.clone, 4)
    brect.x = self.contents.width - 24
    draw_obj_occasion(obj, brect)
    draw_item_name(obj, 4, 4)
    rect.y += 24
    # ----------------------------------------------------------------------- #
    self.contents.font.size = 18
    self.contents.font.color = system_color
    zrect = rect.clone
    icon = IEO::Icon.stat(:skl_u)
    draw_icon(icon, zrect.x, zrect.y)
    zrect.x += 24 if icon > 0
    text = sprintf( IEO::Vocab::SKILL_LEVEL::LEVEL_SUB,
      Vocab.level_a, obj.skl_level, obj.skl_unlocklevel )
    self.contents.draw_text(zrect.clone, text)
    rect.y += 24
    rect.width -= 48
    # ----------------------------------------------------------------------- #
    ctw2 = (self.contents.width-48) / 2
    srect = rect.clone
    srect.width /= 2
    oolx = srect.x
    # ----------------- #
    ans = draw_obj_stat(obj, :based, srect) if obj.base_damage > 0
    ans = draw_obj_stat(obj, :heal_, srect) if obj.base_damage < 0
    srect.x += ctw2 if ans
    ans = draw_obj_stat(obj, :varia, srect)
    srect.x = oolx if ans
    srect.y += 24 if ans
    # ----------------- #
    ans = draw_obj_stat(obj, :atk_f, srect)
    srect.x += ctw2 if ans
    ans = draw_obj_stat(obj, :spi_f, srect)
    srect.x = oolx if ans
    srect.y += 24 if ans
    # ----------------- #
    ans = draw_obj_stat(obj, :hit_r, srect)
    srect.x += ctw2 if ans
    ans = draw_obj_stat(obj, :speed, srect)
    srect.x = oolx
    srect.y += 24
    # ----------------------------------------------------------------------- #
    icon = IEO::Icon.scope(obj.scope)
    draw_icon(icon, srect.x, srect.y)
    trect = srect.clone ; trect.x += 24 if icon > 0
    self.contents.draw_text(trect, IEO::Vocab.scope(obj.scope))
    # ----------------------------------------------------------------------- #
    self.contents.font.size = 18
    self.contents.font.color = normal_color
    trect = srect.clone
    trect.y += 24
    self.contents.draw_text(trect, IEO::Vocab::SKILL_LEVEL::ADD_STATE)
    trect.y += 16
    draw_obj_stateset(obj.plus_state_set, rect.x, trect.y, 4)
    trect.y += 24
    self.contents.draw_text(trect, IEO::Vocab::SKILL_LEVEL::MINUS_STATE)
    trect.y += 16
    draw_obj_stateset(obj.minus_state_set, rect.x, trect.y, 4)
    # ----------------------------------------------------------------------- #
    zrect.y = trect.y + 32
    zrect.x = 0
    zrect.width = self.contents.width
    if $game_system.can_upgrade_skills
      if obj.skl_unlocklevel != obj.skl_maxlevel
        self.contents.draw_text(zrect.clone, sprintf(IEO::Vocab::SKILL_LEVEL::NEXT_COST_SUB,
          Vocab.level, obj.get_nextlevel))
        self.contents.font.color = normal_color
        draw_skl_p(obj.skl_nextlevelcost(1), zrect.clone)
      else
        self.contents.draw_text(zrect.clone, sprintf("%s %s", Vocab.level,
          IEO::Vocab::SKILL_LEVEL::LEVEL_MAX))
      end
    end

  end

  #--------------------------------------------------------------------------#
  # * method :draw_obj_occasion
  #--------------------------------------------------------------------------#
  def draw_obj_occasion(obj, rect)
    draw_icon(IEO::Icon.stat(:alway), rect.x, rect.y ) if obj.occasion.eql?( 0)
    draw_icon(IEO::Icon.stat(:battl), rect.x, rect.y ) if obj.occasion.eql?( 1)
    draw_icon(IEO::Icon.stat(:menuo), rect.x, rect.y ) if obj.occasion.eql?( 2)
    draw_icon(IEO::Icon.stat(:never), rect.x, rect.y ) if obj.occasion.eql?( 3)
  end

  #--------------------------------------------------------------------------#
  # * method :draw_obj_properties
  #--------------------------------------------------------------------------#
  def draw_obj_properties(obj, rect, spacing=0)
    i = 0 ; draw_icon(IEO::Icon.stat( :physa),
      rect.x+(24*i )+spacing, rect.y) if obj.physical_attack
    i += 1 ; draw_icon(IEO::Icon.stat( :dam_m),
      rect.x+(24*i )+spacing, rect.y) if obj.damage_to_mp
    i += 1 ; draw_icon(IEO::Icon.stat( :dam_a),
      rect.x+(24*i )+spacing, rect.y) if obj.absorb_damage
    i += 1 ; draw_icon(IEO::Icon.stat( :i_def),
      rect.x+(24*i )+spacing, rect.y) if obj.ignore_defense
  end

  #--------------------------------------------------------------------------#
  # * method :draw_obj_stat
  #--------------------------------------------------------------------------#
  def draw_obj_stat(obj, stat, rect, draw0=false, enabled=true)
    case stat
    when :spi_f # (Spi_F)
      vocab= IEO::Vocab::SKILL_LEVEL::SPI_F
      val  = obj.spi_f
      icon = IEO::Icon.stat(:spi_f)
    when :atk_f # (Atk_F)
      vocab= IEO::Vocab::SKILL_LEVEL::ATK_F
      val  = obj.atk_f
      icon = IEO::Icon.stat(:atk_f)
    when :speed # (Action Speed)
      vocab= IEO::Vocab::SKILL_LEVEL::ACTION_SPEED
      val  = obj.speed
      icon = IEO::Icon.stat(:speed)
    when :hit_r # (Hit Rate)
      vocab= IEO::Vocab::SKILL_LEVEL::HIT
      val  = obj.hit
      icon = IEO::Icon.stat(:hit_r)
    when :based # (Base Damage)
      vocab= IEO::Vocab::SKILL_LEVEL::DAMAGE
      val  = obj.base_damage
      icon = IEO::Icon.stat(:based)
    when :varia # (Variance)
      vocab= IEO::Vocab::SKILL_LEVEL::VARIANCE
      val  = obj.variance
      icon = IEO::Icon.stat(:varia)
    when :heal_ # (Heal Type - Base Damage)
      vocab= IEO::Vocab::SKILL_LEVEL::HEAL
      val  = obj.base_damage.abs
      icon = IEO::Icon.stat(:heal_)
    else ; return false
    end
    return false unless draw0 if val.eql?(0)
    if icon > 0
      draw_icon(icon, rect.x, rect.y)
      rect.x += 24
    end
    self.contents.font.size = 16
    self.contents.font.color = system_color
    self.contents.draw_text(rect, vocab)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, val, 2)
    return true
  end

end

#==============================================================================#
# ** Window_SKL_ActorStrip
#==============================================================================#
class Window_SKL_ActorStrip < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  ITEM_RECT      = Rect.new(0, 0, 40, 40)
  CHARACTER_RECT = Rect.new(4, 4, 32, 32)

  #--------------------------------------------------------------------------#
  # * method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y)
    super(x, y, Graphics.width, CHARACTER_RECT.height+ITEM_RECT.height) # 64
    self.index = 0
    @spacing = 4 ; @item_max = 1 ; @column_max = 1
    refresh
  end

  #--------------------------------------------------------------------------#
  # * method :actor
  #--------------------------------------------------------------------------#
  def actor ; return @data[self.index] end

  #--------------------------------------------------------------------------#
  # * method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = ITEM_RECT.width*2
    rect.height = ITEM_RECT.height

    wd = (rect.width + @spacing) * @column_max
    ofx = (self.contents.width - wd) / 2

    rect.x = index % @column_max * (rect.width + @spacing) + ofx
    rect.y = (index / @column_max * rect.height)

    return rect
  end

  #--------------------------------------------------------------------------#
  # * method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    @data = $game_party.members.compact
    @item_max = @data.size
    @column_max = [[1, @item_max].max, 12].min
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    irect = item_rect(index)
    crect = irect.clone
    crect.x    += CHARACTER_RECT.x     ; crect.y     += CHARACTER_RECT.y
    crect.width = CHARACTER_RECT.width ; crect.height = CHARACTER_RECT.height
    self.contents.clear_rect(irect)
    mem = @data[index]
    return if mem.nil?
    # ---------------------------------------------------- #
    draw_actor_sprite(mem, crect.x, crect.y, enabled)
    crect.width = irect.width
    # ---------------------------------------------------- #
    draw_actor_skl_p(mem, crect.clone)
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * method :__force_update
  #--------------------------------------------------------------------------#
  def __force_update ; return true end

end

#==============================================================================#
# ** Window_SKL_Level
#==============================================================================#
class Window_SKL_Level < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :refresh_call
  attr_accessor :skill

  #--------------------------------------------------------------------------#
  # * method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @skill = nil
    self.index = 0
    @item_max = 1
  end

  #--------------------------------------------------------------------------#
  # * method :change_skill
  #--------------------------------------------------------------------------#
  def change_skill(new_skill)
    if @skill != new_skill
      @skill = new_skill
      refresh
    end
  end

  #--------------------------------------------------------------------------#
  # * method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    return Rect.new(3, 37, self.contents.width - 26, 10)
  end

  #--------------------------------------------------------------------------#
  # * method :create_contents
  #--------------------------------------------------------------------------#
  def create_contents
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dh = [[height - 32, row_max * WLH].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end

  #--------------------------------------------------------------------------#
  # * method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    rect2 = Rect.new(4, 4, self.contents.width - 28, WLH)
    create_contents
    return if @skill.nil?
    enabled = true
    rect = rect2.clone
    rect.height = 8
    rect.y += 34
    # Limit Bar
    draw_grad_bar( rect, @skill.skl_unlocklevel, @skill.skl_maxlevel,
      normal_color, Color.new(200, 200, 200), Color.new(20, 20, 20),
      2, enabled )
    draw_grad_bar( rect, @skill.skl_level, @skill.skl_maxlevel,
      mp_gauge_color1, mp_gauge_color2, Color.new(20, 20, 20),
      2, enabled )
    self.contents.font.size = 16
    self.contents.font.color = normal_color
    draw_item_name(@skill, rect2.x, rect2.y)
    self.contents.font.size = 16
    self.contents.font.color = normal_color
    rect.height = 24
    rect.width -= 24
    rect.y -= 8
    text = sprintf(IEO::Vocab::SKILL_LEVEL::LEVEL_SUB, Vocab.level_a, @skill.skl_level, @skill.skl_unlocklevel)
    self.contents.draw_text(rect, text, 2)
  end

  #--------------------------------------------------------------------------#
  # * method :update
  #--------------------------------------------------------------------------#
  def update
    super
    if Input.trigger?(Input::RIGHT)
      return if @skill.nil?
      Sound.play_cursor
      oldlevel = @skill.skl_level
      @skill.level_up(true)
      Sound.play_buzzer if @skill.skl_level == oldlevel
      @refresh_call = true
    elsif Input.trigger?(Input::LEFT)
      return if @skill.nil?
      Sound.play_cursor
      oldlevel = @skill.skl_level
      @skill.level_down(true)
      Sound.play_buzzer if @skill.skl_level == oldlevel
      @refresh_call = true
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
  alias :ieo011_sct_load_database :load_database unless $@
  def load_database
    ieo011_sct_load_database
    load_ieo011_cache
  end

  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo011_sct_load_bt_database :load_database unless $@
  def load_bt_database
    ieo011_sct_load_bt_database
    load_ieo011_cache
  end

  #--------------------------------------------------------------------------#
  # * new-method :load_ieo011_cache
  #--------------------------------------------------------------------------#
  def load_ieo011_cache
    objs = [$data_items, $data_skills, $data_enemies]
    objs.each { |group| group.each { |obj| next if obj.nil?
      obj.ieo011_itemcache  if obj.is_a?(RPG::Item)
      obj.ieo011_skillcache if obj.is_a?(RPG::Skill)
      obj.ieo011_enemycache if obj.is_a?(RPG::Enemy) } }
  end

end

if $imported["ISS-MGPAS"]
#==============================================================================#
# ** ISS::MGPAS
#==============================================================================#
module ISS::MGPAS

  class << self
    #--------------------------------------------------------------------------#
    # * alias-method :write_save_data
    #--------------------------------------------------------------------------#
    alias :ieo011_scf_write_save_data :write_save_data unless $@
    def write_save_data(file)
      ieo011_scf_write_save_data(file)
      Marshal.dump($data_skills, file)
    end

    #--------------------------------------------------------------------------#
    # * alias-method :read_save_data
    #--------------------------------------------------------------------------#
    alias :ieo011_scf_read_save_data :read_save_data unless $@
    def read_save_data(file)
      ieo011_scf_read_save_data(file)
      $data_skills = Marshal.load(file)
    end
  end

end

else
#==============================================================================#
# ** Scene_File
#==============================================================================#
class Scene_File < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :write_save_data
  #--------------------------------------------------------------------------#
  alias :ieo011_scf_write_save_data :write_save_data unless $@
  def write_save_data(file)
    ieo011_scf_write_save_data(file)
    Marshal.dump($data_skills, file)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :read_save_data
  #--------------------------------------------------------------------------#
  alias :ieo011_scf_read_save_data :read_save_data unless $@
  def read_save_data(file)
    ieo011_scf_read_save_data(file)
    $data_skills = Marshal.load(file)
  end

end

end if IEO::SKILL_LEVEL::SKLMODE == 3

#==============================================================================#
# ** Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * new-method :perform_skl_p_gain
  #--------------------------------------------------------------------------#
  def perform_skl_p_gain(type = :attack, battler = nil)
    return if battler.nil?
    IEO::SKILL_LEVEL.skl_p_gain(type, battler)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :execute_action_attack
  #--------------------------------------------------------------------------#
  alias :ieo011_scb_execute_action_attack :execute_action_attack unless $@
  def execute_action_attack
    ieo011_scb_execute_action_attack
    perform_skl_p_gain(:attack, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :execute_action_guard
  #--------------------------------------------------------------------------#
  alias :ieo011_scb_execute_action_guard :execute_action_guard unless $@
  def execute_action_guard
    ieo011_scb_execute_action_guard
    perform_skl_p_gain(:guard, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :execute_action_skill
  #--------------------------------------------------------------------------#
  alias :ieo011_scb_execute_action_skill :execute_action_skill unless $@
  def execute_action_skill
    ieo011_scb_execute_action_skill
    perform_skl_p_gain(:skill, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :execute_action_item
  #--------------------------------------------------------------------------#
  alias :ieo011_scb_execute_action_item :execute_action_item unless $@
  def execute_action_item
    ieo011_scb_execute_action_item
    perform_skl_p_gain(:item, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :battle_end
  #--------------------------------------------------------------------------#
  alias :ieo011_scb_battle_end :battle_end unless $@
  def battle_end(result)
    $game_troop.distribute_skl_p
    ieo011_scb_battle_end(result)
  end

end

#==============================================================================#
# ** Scene_SkillForge
#==============================================================================#
class Scene_SkillForge < Scene_Base

  include IEX::SCENE_ACTIONS if $imported["IEX_SceneActions"]

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  SLIDY_WINDOWS = IEO::SKILL_LEVEL::SLIDY_WINDOWS
  SLIDY_WINDOWS = ($imported["IEX_SceneActions"] && SLIDY_WINDOWS)

  #--------------------------------------------------------------------------#
  # * method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor, lock_upgrade = nil, called = :map, return_index=0)
    super
    unless $imported["ICY_Bitmap_Xtended"]
      raise "ICY - BitmapExtended Not Present, cannot continue"
      exit
    end
    lock_upgrade = !$game_system.can_upgrade_skills if lock_upgrade.eql?(nil)
    # ---------------------------------------------------- #
    @calledfrom = called
    @return_index = return_index
    # ---------------------------------------------------- #
    @actor = nil
    @act_index = 0
    @index_call = false
    # ---------------------------------------------------- #
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil
      @actor = $game_party.members[actor]
      @act_index = actor
      @index_call = true
    end
    # ---------------------------------------------------- #
    lock_upgrade = !$game_system.can_upgrade_skills if lock_upgrade.nil?
    @lock_upgrade = lock_upgrade
  end

  #--------------------------------------------------------------------------#
  # * method :start
  #--------------------------------------------------------------------------#
  def start
    # ---------------------------------------------------- #
    super
    create_menu_background
    # ---------------------------------------------------- #
    @iwps = [Graphics.width / 2, Graphics.height / 2,
      Graphics.width, Graphics.height]
    iwps  = @iwps
    # ---------------------------------------------------- #
    @windows = { }
    # ---------------------------------------------------- #
    @windows["Party"] = Window_SKL_ActorStrip.new(0, 0)
    @windows["Party"].active = false
    @windows["Party"].index = @act_index
    @windows["Party"].update_cursor
    # ---------------------------------------------------- #
    sh = iwps[1]
    @windows["Skill"] = Window_Skill.new( 0, @windows["Party"].height,
      iwps[0], sh, @windows["Party"].actor )
    @windows["Skill"].column_max = 1
    @windows["Skill"].refresh
    @windows["Skill"].update_cursor
    # ---------------------------------------------------- #
    @windows["SStat"] = Window_SKL_Help.new(
      @windows["Skill"].width, @windows["Party"].height,
      iwps[0], iwps[3]-@windows["Party"].height )
    @windows["SStat"].set_obj(@windows["Skill"].skill)
    # ---------------------------------------------------- #
    @windows["Level"] = Window_SKL_Level.new(
      0, @windows["Skill"].y + @windows["Skill"].height,
      iwps[0], iwps[3] - (@windows["Skill"].y + @windows["Skill"].height))
    # ---------------------------------------------------- #

    # ---------------------------------------------------- #
    #(windows, value, rates=[DROP_RATE, RETURN_RATE], mult=1)
    if SLIDY_WINDOWS
      # ---------------------------------------------------- #
      pull_windows_right(["SStat"], @windows["SStat"].width, [1, 1])
      pull_windows_left(["Level", "Skill"], @windows["Skill"].width, [1, 1])
      pull_windows_up(["Party"], @windows["Party"].height, [1, 1])
      # ---------------------------------------------------- #
    end
    @startup = true
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * method :terminate
  #--------------------------------------------------------------------------#
  def terminate
    # ---------------------------------------------------- #
    super
    # ---------------------------------------------------- #
    dispose_menu_background
    # ---------------------------------------------------- #
    @windows.values.compact.each { |win| win.dispose }
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    if SLIDY_WINDOWS
      # ---------------------------------------------------- #
      pull_windows_right(["SStat"], @windows["SStat"].width)
      pull_windows_left(["Level", "Skill"], @windows["Skill"].width)
      pull_windows_up(["Party"], @windows["Party"].height)
      # ---------------------------------------------------- #
    end
    case @calledfrom
    when :map
      $scene = Scene_Map.new
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  #--------------------------------------------------------------------------#
  # * method :update
  #--------------------------------------------------------------------------#
  def update
    # ---------------------------------------------------- #
    super
    # ---------------------------------------------------- #
    update_party_shift
    # ---------------------------------------------------- #
    if Input.trigger?(Input::C) and !@lock_upgrade
    # ---------------------------------------------------- #
      skill = @windows["Skill"].skill
      actor = @windows["Party"].actor
      # ---------------------------------------------------- #
      unless skill.nil? or actor.nil?
        if actor.can_upgrade_skill?(skill, skill.get_nextlevel(1), false)
        # ---------------------------------------------------- #
          Sound.play_recovery
          actor.upgrade_skill(skill, skill.get_nextlevel(1), false)
          @windows["Level"].refresh
          @windows["Skill"].draw_item(@windows["Skill"].index)
          @windows["Party"].refresh
          @windows["SStat"].set_obj(@windows["Skill"].skill, true)
        # ---------------------------------------------------- #
        else ; Sound.play_buzzer
        # ---------------------------------------------------- #
        end
      # ---------------------------------------------------- #
      else ; Sound.play_buzzer
      # ---------------------------------------------------- #
      end
    # ---------------------------------------------------- #
    elsif Input.trigger?(Input::B)
    # ---------------------------------------------------- #
      Sound.play_cancel
      return_scene
    # ---------------------------------------------------- #
    end
    # ---------------------------------------------------- #
    if @startup
      if SLIDY_WINDOWS
        pull_windows_down(["Party"], @windows["Party"].height)
        pull_windows_right(["Level", "Skill"], @windows["Skill"].width)
        pull_windows_left(["SStat"], @windows["SStat"].width)
      end
      @startup = false
    end
    # ---------------------------------------------------- #
    if @windows["Level"].refresh_call
      @windows["Level"].refresh_call = false
      @windows["Level"].refresh
      @windows["Skill"].draw_item(@windows["Skill"].index)
      @windows["SStat"].set_obj(@windows["Skill"].skill, true)
    end
    # ---------------------------------------------------- #
    @windows["SStat"].set_obj(@windows["Skill"].skill)
    @windows["Level"].change_skill(@windows["Skill"].skill)
    # ---------------------------------------------------- #
    @windows.values.compact.each { |win|
      win.update if win.active or win.__force_update
    }
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * method :update_party_shift
  #--------------------------------------------------------------------------#
  def update_party_shift
    # ---------------------------------------------------- #
    if Input.trigger?(Input::Y)
    # ---------------------------------------------------- #
      Sound.play_cursor
      @windows["Party"].index = @windows["Party"].index + 1
      @windows["Party"].index%= @windows["Party"].item_max
      @windows["Skill"].actor = @windows["Party"].actor
      @windows["Skill"].index = 0
      @windows["Skill"].refresh
      Graphics.frame_reset
    # ---------------------------------------------------- #
    elsif Input.trigger?(Input::X)
    # ---------------------------------------------------- #
      Sound.play_cursor
      @windows["Party"].index = @windows["Party"].index - 1
      @windows["Party"].index%= @windows["Party"].item_max
      @windows["Skill"].actor = @windows["Party"].actor
      @windows["Skill"].index = 0
      @windows["Skill"].refresh
      Graphics.frame_reset
    # ---------------------------------------------------- #
    end
  end

end
#==============================================================================#
IEO::REGISTER.log_script(11, "SkillLevelSystem", 1.4) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Custom Skill Costs
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Skills)
# ** Script Type   : Skill Costs
# ** Date Created  : 02/14/2011
# ** Date Modified : 08/31/2011
# ** Script Tag    : IEO-003(Custom Skill Costs)
# ** Difficulty    : Easy, Lunatic
# ** Version       : 1.2
# ** IEO ID        : 003
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# Some code was taken from BEM (Created by Yanfly)
# Please credit him also if you use this script.
#
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
# Huh? *Stares* Ohh your waiting for the intro.. Well sorry come back tommorrow.
# What? You need it now!? Oh... *Shakes head* Oh alright.
#
# IEO Script ID 003 - Custom Skill Costs
# Based off the BEM custom skill costs, this script allows you to define custom
# costs for yer skills, such as items, hp/mp and pretty much anything
# your crazy enough to put in.
#
# You can jump to the customization section using this
# IEO003-Lunatic
# Though I encourage reading everything.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Well has only been tested with the DBS. No need for this with BEM.
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
#   Anything that makes changes to:
#   execute_action_skill (Scene_Battle), and skill_can_use? (Game_Battler)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   RPG::Skill
#     new-method :ieo003_skillcache
#   Game_Battler
#     new-method :custom_skill_cost
#     overwrite  :skill_can_use?
#   Window_Skill
#     new-method :draw_obj_name (Copied from BEM)
#     new-method :draw_obj_cost (Copied from BEM)
#     overwrite  :draw_item
#   Scene_Title
#     alias      :load_database
#     alias      :load_bt_database
#     new-method :load_ieo003_cache
#   Scene_Skill
#     overwrite  :use_skill_nontarget
#   Scene_Battle
#     overwrite  :execute_action_skill
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  02/14/2011 - V1.0  Started Script and Finished Script
#  05/13/2011 - V1.0  Code rearrangement
#  05/14/2011 - V1.0  Minor Code Edits
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Well this here script overwrites the execute_action_skill in the scene_battle
#  so... A lot of bad things might happen.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-CustomSkillCosts"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script ||= {})[[3, "CustomSkillCosts"]] = 1.2
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
module IEO
  module CustomSkillCosts
    def self.post_load_database
      [$data_skills].each do |group|
        group.reject(&:nil?).each do |obj|
          obj.ieo003_skillcache
        end
      end
    end
  end
end
#==============================================================================#
# Game_Battler - IEO003-Lunatic
#==============================================================================#
class Game_Battler
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * new method :custom_skill_cost
  # Credit to Yanfly for the main idea behind custom skill costs.
  # You place <cost: phrase> in a skill's notebox. Okay.
  # IN THE NOTEBOX, and common sense, replace phrase with the stuff found here.
  #--------------------------------------------------------------------------#
  def custom_skill_cost(skill, type, stacklevel=0)
    cost = type == :calc_mincost ? skill.mincost : skill.cost
    type = :calc_cost if type == :calc_mincost
    calc_custom_cost(cost, skill, type, stacklevel)
  end

  #--------------------------------------------------------------------------#
  # * new method :custom_skill_subcost
  #--------------------------------------------------------------------------#
  def custom_skill_subcost(skill, type)
    calc_custom_cost(skill.subcost, skill, type, true, 0)
  end

  #--------------------------------------------------------------------------#
  # * new method :calc_custom_cost
  #--------------------------------------------------------------------------#
  def calc_custom_cost(cost, obj, type, sub=false, stacklevel=0)
    raise "Cost Stack too deep" if stacklevel == 5
    # ** ------ ** #
    calc_cost = 0 ; use_icon = 0 ; can_use = true ; text_cost = ""
    suffix = "%s" ; font_size = 16 ; colour = 0
    perform = type == :perform
    # ** ------ ** #
    case cost
    #-***-------------------------------------------------------------***-#
    # Start editing here
    #-*-----------------------------------------------------------------*-#
    # <cost: x mp>
    # Skills will cost a set amount of mp marked by x.
    # Eg. <cost: 24 mp>
    #-*-----------------------------------------------------------------*-#
    when /(\d+)[ ](MP|SP)/i
      calc_cost = $1.to_i
      calc_cost/= 2 if half_mp_cost
      # ** ------ ** #
      colour    = 0
      font_size = 16
      suffix    = "%s#{Vocab.mp_a}"
      use_icon  = IEO::Icon.cost(:mp)
      text_cost = calc_cost.to_s
      can_use   = self.mp >= calc_cost
      # ** ------ ** #
      self.mp  -= calc_cost if perform
    #-*-----------------------------------------------------------------*-#
    # <cost: x% mp>
    # Skills will cost a percentage of maxmp marked by x.
    # Eg. <cost: 90% mp>
    #-*-----------------------------------------------------------------*-#
    when /(\d+)([%％])[ ](MP|SP|MAXMP|MAXSP)/i
      calc_cost = Integer(maxmp * $1.to_i / 100.0)
      calc_cost/= 2 if half_mp_cost
      if calc_cost == 0
        calc_cost = custom_skill_cost(obj, :calc_mincost, stacklevel+1)
      end unless sub
      # ** ------ ** #
      colour    = 0
      font_size = 16
      suffix    = "%s#{Vocab.mp_a}"
      use_icon  = IEO::Icon.cost(:mp)
      text_cost = calc_cost.to_s
      can_use   = self.mp >= calc_cost
      # ** ------ ** #
      self.mp  -= calc_cost if perform
    #-*-----------------------------------------------------------------*-#
    # <cost: x hp>
    # Skills will cost a set amount of hp marked by x.
    # Eg. <cost: 4 hp>
    #-*-----------------------------------------------------------------*-#
    when /(\d+)[ ](HP|LP)/i
      calc_cost = $1.to_i
      # ** ------ ** #
      colour    = 0
      font_size = 16
      suffix    = "%s#{Vocab.hp_a}"
      use_icon  = IEO::Icon.cost(:hp)
      text_cost = calc_cost.to_s
      can_use   = self.hp >= calc_cost
      # ** ------ ** #
      self.hp  -= calc_cost if perform
    #-*-----------------------------------------------------------------*-#
    # <cost: x% hp>
    # Skills will cost a percentage of maxhp marked by x.
    # Eg. <cost: 27% hp>
    #-*-----------------------------------------------------------------*-#
    when /(\d+)([%％])[ ](HP|LP|MAXHP|MAXLP)/i
      calc_cost = Integer(maxhp * $1.to_i / 100.0)
      if calc_cost == 0
        calc_cost = custom_skill_cost(obj, :calc_mincost, stacklevel+1)
      end unless sub
      # ** ------ ** #
      colour    = 0
      font_size = 16
      suffix    = "%s#{Vocab.hp_a}"
      use_icon  = IEO::Icon.cost(:hp)
      text_cost = calc_cost.to_s
      can_use   = self.hp >= calc_cost
      # ** ------ ** #
      self.hp  -= calc_cost if perform
    #-*-----------------------------------------------------------------*-#
    # <cost: item id:amt>
    # Skills will cost the item marked by id, using amt as the cost.
    # Eg. <cost: item 2:3>
    #-*-----------------------------------------------------------------*-#
    when /ITEM[ ](\d+):(\d+)/i
      calc_cost = $2.to_i
      # ** ------ ** #
      colour    = 0
      font_size = 16
      suffix    = "%s"
      use_icon  = $data_items[$1.to_i].icon_index
      text_cost = calc_cost.to_s
      can_use   = $game_party.item_number($data_items[$1.to_i]) >= calc_cost
      # ** ------ ** #
      $game_party.lose_item($data_items[$1.to_i], calc_cost) if perform
    #-*-----------------------------------------------------------------*-#
    # <cost: amt ammo>
    # Eg. <cost: 2 ammo>
    # Eg. <cost: 1 round>
    #-*-----------------------------------------------------------------*-#
    when /(\d+)[ ](?:AMMO|ROUND|ROUNDS)/i
      calc_cost = $1.to_i
      # ** ------ ** #
      font_size = 16
      suffix    = "%sR"
      use_icon  = IEO::Icon.cost(:ammo)
      text_cost = "#{calc_cost.to_s}/#{self.get_ammo(obj.id).value}"
      can_use   = self.get_ammo(obj.id).value >= calc_cost
      colour    = can_use ? 0 : 18
      # ** ------ ** #
      self.change_ammo(:sub, obj.id, calc_cost) if perform
    when /(\d+)[ ]EN/i
      calc_cost = $1.to_i
      # ** ------ ** #
      font_size = 16
      suffix    = "%sEN"
      use_icon  = IEO::Icon.cost(:en)
      text_cost = calc_cost.to_s
      can_use   = self.en >= calc_cost
      colour    = can_use ? 0 : 18
      # ** ------ ** #
      self.en -= calc_cost if perform
    #-***-------------------------------------------------------------***-#
    # Stop editing here
    #-***-------------------------------------------------------------***-#
    end
    icon = obj.cost_icon unless obj.cost_icon.nil?
    case type
    when :perform   ; return            # Just return if performing.
    when :can_use   ; return can_use    # Can the skill be used?
    when :calc_cost ; return calc_cost  # Interger cost
    when :text_cost ; return text_cost  # Used in skill windows, for visual cost
    when :use_icon  ; return use_icon   # Cost Icon
    when :suffix    ; return suffix
    when :colour    ; return colour     # Text color used for skill cost
    when :font_size ; return font_size  #
    end
  end

#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
end

#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    module_function ; def cost(stat) ; return 0 end
  end
end

#==============================================================================#
# IEO::REGEX::CSC
#==============================================================================#
module IEO
  module REGEXP
    module CSC
      module SKILL
        MINCOST   = /<MINCOST:[ ](.*)>/i # // Minimum Cost Fix
        COST      = /<COST:[ ](.*)>/i
        SUBCOST   = /<SUBCOST:[ ](.*)>/i
        COST_ICON = /<(?:COST_ICON|COST ICON|COSTICON):[ ](\d+)>/i
      end
    end
  end
end

#==============================================================================#
# IEO::CSC
#==============================================================================#
module IEO::CSC ; end
#==============================================================================#
# IEO::CSC::WIN_BASE
#==============================================================================#
module IEO::CSC::WIN_BASE
  INCL = %Q(
  #--------------------------------------------------------------------------#
  # * new method :draw_obj_name
  #--------------------------------------------------------------------------#
  def draw_obj_name(obj, rect, enabled)
    draw_icon(obj.icon_index, rect.x, rect.y, enabled)
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    rect.width -= 48
    self.contents.draw_text(rect.x+24, rect.y, rect.width-24, WLH, obj.name)
  end

  #--------------------------------------------------------------------------#
  # * new method :draw_obj_cost
  #--------------------------------------------------------------------------#
  def draw_obj_cost(obj, rect, enabled)
    draw_obj_cost2(obj, rect.clone, :normal, enabled)
    drect = rect.clone ; drect.x -= 48
    draw_obj_cost2(obj, drect.clone, :sub, enabled)
  end

  #--------------------------------------------------------------------------#
  # * new method :draw_obj_cost2
  #--------------------------------------------------------------------------#
  def draw_obj_cost2(obj, rect, type, enabled)
    dx = rect.x + rect.width - 48; dy = rect.y
    return unless obj.is_a?(RPG::Skill)
    font_size = Font.default_size
    colour_id  = 0
    case type
    when :normal
      return if @actor.custom_skill_cost(obj, :calc_cost) <= 0
      font_size = @actor.custom_skill_cost(obj, :font_size)
      colour_id = @actor.custom_skill_cost(obj, :colour)
      if @actor.custom_skill_cost(obj, :use_icon) != 0
        icon = @actor.custom_skill_cost(obj, :use_icon)
        draw_icon(icon, rect.x+rect.width-24, rect.y, enabled)
        text = @actor.custom_skill_cost(obj, :text_cost)
        dw = 24
      else
        cost = @actor.custom_skill_cost(obj, :text_cost)
        text = @actor.custom_skill_cost(obj, :suffix)
        text = sprintf(text, cost)
        dw = 44
      end
    when :sub
      return if @actor.custom_skill_subcost(obj, :calc_cost) <= 0
      font_size = @actor.custom_skill_subcost(obj, :font_size)
      colour_id = @actor.custom_skill_subcost(obj, :colour)
      if @actor.custom_skill_subcost(obj, :use_icon) != 0
        icon = @actor.custom_skill_subcost(obj, :use_icon)
        draw_icon(icon, rect.x+rect.width-24, rect.y, enabled)
        text = @actor.custom_skill_subcost(obj, :text_cost)
        dw = 24
      else
        cost = @actor.custom_skill_subcost(obj, :text_cost)
        text = @actor.custom_skill_subcost(obj, :suffix)
        text = sprintf(text, cost)
        dw = 44
      end
    end
    self.contents.font.size = font_size
    self.contents.font.color = text_color(colour_id)
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, dw, WLH, text, 2)
  end
  )
end

#==============================================================================#
# IEO::CSC::WIN_SKILL
#==============================================================================#
module IEO::CSC::WIN_SKILL
  INCL = %Q(
  #--------------------------------------------------------------------------
  # * overwrite method :draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    skill = @data[index]
    return if skill == nil
    enabled = enabled?(skill)
    draw_obj_name(skill, rect.clone, enabled)
    draw_obj_cost(skill, rect.clone, enabled)
  end

  #--------------------------------------------------------------------------
  # * new method :enabled?
  #--------------------------------------------------------------------------
  def enabled?(skill)
    return @actor.skill_can_use?(skill)
  end
  )
end

#==============================================================================#
# RPG::Skill
#==============================================================================#
class RPG::Skill

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :mincost
  attr_accessor :cost
  attr_accessor :subcost
  attr_accessor :cost_icon

  #--------------------------------------------------------------------------#
  # * new method :ieo003_skillcache
  #--------------------------------------------------------------------------#
  def ieo003_skillcache
    @mincost  = "0 MP"
    @cost     = "#{@mp_cost} MP" # Support for old MP costs.
    @subcost  = ""
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when IEO::REGEXP::CSC::SKILL::SUBCOST   then @subcost = $1
      when IEO::REGEXP::CSC::SKILL::MINCOST   then @mincost = $1
      when IEO::REGEXP::CSC::SKILL::COST      then @cost = $1
      when IEO::REGEXP::CSC::SKILL::COST_ICON then @cost_icon = $1.to_i
      end
    end
    @ieo003_skillcache_complete = true
  end

end

#==============================================================================#
# Game_Battler
#==============================================================================#
class Game_Battler
  #--------------------------------------------------------------------------#
  # * overwrite method :skill_can_use?
  #--------------------------------------------------------------------------#
  def skill_can_use?(skill)
    return false unless skill.is_a?(RPG::Skill)
    return false unless movable?
    return false if silent? and skill.spi_f > 0
    #---
    return false unless custom_skill_cost(skill, :can_use)
    return false unless custom_skill_subcost(skill, :can_use)
    #---
    return ($game_temp.in_battle) ? skill.battle_ok? : skill.menu_ok?
  end
end

#==============================================================================#
# Window_Base
#==============================================================================#
class Window_Base < Window

  module_eval(IEO::CSC::WIN_BASE::INCL)

end

#==============================================================================#
# Window_Skill
#==============================================================================#
class Window_Skill < Window_Selectable

  module_eval(IEO::CSC::WIN_SKILL::INCL)

end

#==============================================================================#
# Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo003_sct_load_database :load_database unless $@
  def load_database
    ieo003_sct_load_database
    IEO::CustomSkillCosts.post_load_database
  end

  #--------------------------------------------------------------------------#
  # * alias method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo003_sct_load_bt_database :load_database unless $@
  def load_bt_database
    ieo003_sct_load_bt_database
    IEO::CustomSkillCosts.post_load_database
  end
end

#==============================================================================#
# Scene_Skill
#==============================================================================#
class Scene_Skill < Scene_Base

  #--------------------------------------------------------------------------
  # * overwrite method :use_skill_nontarget
  #--------------------------------------------------------------------------
  def use_skill_nontarget
    Sound.play_use_skill
    @actor.custom_skill_cost(@skill, :perform)
    @actor.custom_skill_subcost(@skill, :perform)
    @status_window.refresh
    @skill_window.refresh
    @target_window.refresh
    if $game_party.all_dead?
      $scene = Scene_Gameover.new
    elsif @skill.common_event_id > 0
      $game_temp.common_event_id = @skill.common_event_id
      $scene = Scene_Map.new
    end
  end

end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action_skill
  #--------------------------------------------------------------------------#
  def execute_action_skill
    skill = @active_battler.action.skill
    text = @active_battler.name + skill.message1
    @message_window.add_instant_text(text)
    unless skill.message2.empty?
      wait(10)
      @message_window.add_instant_text(skill.message2)
    end
    targets = @active_battler.action.make_targets
    display_animation(targets, skill.animation_id)
    @active_battler.custom_skill_cost(skill, :perform)
    @active_battler.custom_skill_subcost(skill, :perform)
    $game_temp.common_event_id = skill.common_event_id
    for target in targets
      target.skill_effect(@active_battler, skill)
      display_action_effects(target, skill)
    end
  end

end

#==============================================================================#
IEO::REGISTER.log_script(3, "CustomSkillCosts", 1.2) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

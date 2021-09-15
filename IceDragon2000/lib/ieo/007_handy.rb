#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Handy
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Actor, Battle)
# ** Script Type   : Battle Weapon
# ** Date Created  : 03/20/2011
# ** Date Modified : 05/31/2011
# ** Script Tag    : IEO-007(Handy)
# ** Difficulty    : Easy
# ** Version       : 1.0
# ** IEO ID        : 007
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
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
#
# Inspired by Ogre Tactics: Knight Of Lodis.
# This script adds the feature to select your equipment to attack with.
# This means weapons and armor alike.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
# Plug 'n' Play
# Well has only been tested with the DBS, and Ohmerion.
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
#   RPG::Armor
#     new-method :ieo007_armorcache
#   Game_Battler
#     alias      :initialize
#     new-method :act_weapon
#     new-method :clear_actionobject
#     new-method :set_actionobject
#   Game_Actor
#     new-method :act_objects
#     overwrite  :base_maxhp
#     overwrite  :base_maxmp
#     overwrite  :base_atk
#     overwrite  :base_def
#     overwrite  :base_spi
#     overwrite  :base_agi
#     overwrite  :atk_animation_id
#   Game_Party
#     alias      :clear_actions
#   Scene_Title
#     alias      :load_database
#     alias      :load_bt_database
#     new-method :load_ieo007_cache
#   Scene_Battle
#     new-method :start_weapon_selection
#     new-method :update_weapon_selection
#    *overwrite  :update_actor_command_selection
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  05/31/2011 - V1.0 Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Non Yet.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-Handy"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[7, "Handy"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# RPG::Armor
#==============================================================================#
class RPG::Armor

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :animation_id

  #--------------------------------------------------------------------------#
  # * new method :ieo007_armorcache
  #--------------------------------------------------------------------------#
  def ieo007_armorcache
    @animation_id = 0
  end

end

#==============================================================================#
# Game_Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :action_object

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo007_gb_initialize :initialize unless $@
  def initialize
    @action_object = nil
    ieo007_gb_initialize
  end

  #--------------------------------------------------------------------------#
  # * new method :act_weapon
  #--------------------------------------------------------------------------#
  def act_weapon
    return @action_object
  end

  #--------------------------------------------------------------------------#
  # * new method :clear_actionobject
  #--------------------------------------------------------------------------#
  def clear_actionobject
    @action_object = nil
  end

  #--------------------------------------------------------------------------#
  # * new method :set_actionobject
  #--------------------------------------------------------------------------#
  def set_actionobject(obj)
    @action_object = obj
  end

end

#==============================================================================#
# Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * new method :act_objects
  #--------------------------------------------------------------------------#
  def act_objects
    return weapons if two_swords_style
    return weapons[0], armors[0]
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :base_maxhp
  #--------------------------------------------------------------------------#
  def base_maxhp
    return actor.parameters[0, @level]
  end
  #--------------------------------------------------------------------------#
  # * overwrite method :base_maxmp
  #--------------------------------------------------------------------------#
  def base_maxmp
    return actor.parameters[1, @level]
  end
  #--------------------------------------------------------------------------#
  # * overwrite method :base_atk
  #--------------------------------------------------------------------------#
  def base_atk
    n = actor.parameters[2, @level]
    for item in armors.compact do n += item.atk end
    n += act_weapon.atk unless act_weapon.nil?
    return n
  end
  #--------------------------------------------------------------------------#
  # * overwrite method :base_def
  #--------------------------------------------------------------------------#
  def base_def
    n = actor.parameters[3, @level]
    for item in armors.compact do n += item.def end
      n += act_weapon.def unless act_weapon.nil?
    return n
  end
  #--------------------------------------------------------------------------#
  # * overwrite method :base_spi
  #--------------------------------------------------------------------------#
  def base_spi
    n = actor.parameters[4, @level]
    for item in armors.compact do n += item.spi end
    n += act_weapon.spi unless act_weapon.nil?
    return n
  end
  #--------------------------------------------------------------------------#
  # * overwrite method :base_agi
  #--------------------------------------------------------------------------#
  def base_agi
    n = actor.parameters[5, @level]
    for item in armors.compact do n += item.agi end
    n += act_weapon.agi unless act_weapon.nil?
    return n
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :atk_animation_id
  #--------------------------------------------------------------------------#
  def atk_animation_id
    return act_weapon.nil? ? 1 : act_weapon.animation_id
  end

end

#==============================================================================#
# Game_Party
#==============================================================================#
class Game_Party < Game_Unit

  #--------------------------------------------------------------------------
  # * alias method :clear_actions
  #--------------------------------------------------------------------------
  alias :ieo007_gpty_clear_actions :clear_actions unless $@
  def clear_actions
    ieo007_gpty_clear_actions
    for mem in members.compact
      mem.clear_actionobject
    end
  end

end

#==============================================================================#
# Window_WeaponSelection
#==============================================================================#
class Window_WeaponSelection < Window_Command

  #--------------------------------------------------------------------------#
  # * super method :draw_item
  #--------------------------------------------------------------------------#
  def initialize(*args)
    super(*args)
    @__adapt = false
  end

  #--------------------------------------------------------------------------#
  # * new method :selected_obj
  #--------------------------------------------------------------------------#
  def selected_obj ; return @commands[index] end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    rect        = item_rect(index)
    rect.x     += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.size        = 16
    self.contents.font.color       = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    unless @commands[index].nil?
      draw_item_name( @commands[index], rect.x, rect.y)
    else
      self.contents.draw_text(rect, "-")
    end
  end

end

#==============================================================================#
# Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo007_sct_load_database :load_database unless $@
  def load_database
    ieo007_sct_load_database
    load_ieo007_cache
  end

  #--------------------------------------------------------------------------#
  # * alias method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo007_sct_load_bt_database :load_database unless $@
  def load_bt_database
    ieo007_sct_load_bt_database
    load_ieo007_cache
  end

  #--------------------------------------------------------------------------#
  # * new method :load_ieo007_cache
  #--------------------------------------------------------------------------#
  def load_ieo007_cache
    objs = [ $data_armors, $data_weapons ]
    objs.each { |group| group.each { |obj|
      next if obj.nil?
      obj.ieo007_armorcache if obj.is_a?(RPG::Armor)
    } }
  end

end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * new method :start_weapon_selection
  #--------------------------------------------------------------------------#
  def start_weapon_selection
    @weapon_selection = Window_WeaponSelection.new(@actor_command_window.width+64,
      @active_battler.act_objects)
    @weapon_selection.viewport = @info_viewport
    @weapon_selection.x = @actor_command_window.x - @weapon_selection.width
    @weapon_selection.y = @actor_command_window.y
    res = :cancel
    loop do
      update_basic
      update_weapon_selection
      if Input.trigger?(Input::C)
        Sound.play_decision
        @active_battler.action.set_attack
        @active_battler.clear_actionobject
        @active_battler.set_actionobject(@weapon_selection.selected_obj)
        res = :set
        break
      elsif Input.trigger?(Input::B)
        Sound.play_cancel
        @active_battler.action.clear
        @active_battler.clear_actionobject
        res = :cancel
        break
      end
    end
    @weapon_selection.dispose
    return res
  end

  #--------------------------------------------------------------------------#
  # * new method :update_weapon_selection
  #--------------------------------------------------------------------------#
  def update_weapon_selection
    @weapon_selection.update
  end

  unless $imported["IEO-CustomActorCommand"]
    #--------------------------------------------------------------------------#
    # * overwrite method :update_actor_command_selection
    #--------------------------------------------------------------------------#
    def update_actor_command_selection
      if Input.trigger?(Input::B)
        Sound.play_cancel
        prior_actor
      elsif Input.trigger?(Input::C)
        case @actor_command_window.index
        when 0  # Attack
          Sound.play_decision
          return if start_weapon_selection == :cancel
          start_target_enemy_selection
        when 1  # Skill
          Sound.play_decision
          start_skill_selection
        when 2  # Guard
          Sound.play_decision
          @active_battler.action.set_guard
          next_actor
        when 3  # Item
          Sound.play_decision
          start_item_selection
        end
      end
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

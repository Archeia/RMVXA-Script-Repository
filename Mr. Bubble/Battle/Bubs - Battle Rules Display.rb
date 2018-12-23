# ╔══════════════════════════════════════════════════════╤═══════╤═══════════╗
# ║ Battle Rules Display                                 │ v1.00 │ (5/05/13) ║
# ╚══════════════════════════════════════════════════════╧═══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Requested by:
#     Tsukihime ( http://himeworks.wordpress.com/ )
# Thanks:
#     tomy, for base code ( http://ytomy.sakura.ne.jp/ )
#--------------------------------------------------------------------------
# Displays battles rules as defined with Tsukihime's Battle Rules script.
#
# The bulk of the code in this script was taken from the VX
# script "KGC_TalesStyleEffect" by tomy. As stated in tomy's terms of 
# use, people are allowed to freely modify/re-utilize KGC code. I do not 
# claim this script to be completely of my own creation.
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v1.00 : Initial release. (5/05/2013)
#--------------------------------------------------------------------------
#      Installation & Requirements
#--------------------------------------------------------------------------
# Requires Tsukihime's Battle Rules script. http://wp.me/p3aSgk-iv
#
# Default settings require two images called "VictoryBack" and
# "DefeatBack". Any graphics related to this script must be placed
# in the System/Graphics folder of your project
#
# Install this script in the Materials section in your project's
# script editor below Battle Rules most other battle-related scripts.
#--------------------------------------------------------------------------
#      Compatibility   
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     Window_PartyCommand#make_command_list
#     Spriteset_Battle#initialize
#     Spriteset_Battle#update
#     Spriteset_Battle#dispose
#     Scene_Battle#battle_start
#     Scene_Battle#create_party_command_window
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Free for commercial and non-commercial use.
#
# Newest versions of this script can be found at 
#                                          http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["BubsBattleRulesDisplay"] = 1.00

#==========================================================================
#    START OF USER CUSTOMIZATION MODULE 
#==========================================================================
module Bubs
  module BattleRulesDisplay
  #--------------------------------------------------------------------------
  #   Victory Display Settings
  #--------------------------------------------------------------------------
  VICTORY_SETTINGS = {
    :text           => "Victory Condition:",
    :back_image     => "victoryback",  # Image in "Graphics/System" folder
    :cond_met_color => Color.new(128,255,128),  # (red, green, blue)
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Defeat Display Settings
  #--------------------------------------------------------------------------
  DEFEAT_SETTINGS = {
    :text           => "Defeat Condition:",
    :back_image     => "defeatback",  # Image in "Graphics/System" folder
    :cond_met_color => Color.new(255,128,128),  # (red, green, blue)
  } # <- Do not delete.
  
  # Game Switch ID that controls whether battle rules are
  # displayed in battle. If set to 0, rules are always shown.
  GAME_SWITCH = 0
  
  # Name of "Rules" command in Party Command window.
  RULES_COMMAND_NAME = "Rules"
  
  # Vertical spacing between each rule.
  Y_SPACING = 32
  
  # Visible duration of battle rules in frames.
  DURATION = 300  # 1 second = 60 frames
  
  
  end # module BattleRulesDisplay
end # module Bubs


#==========================================================================
#    END OF USER CUSTOMIZATION MODULE 
#==========================================================================




if $imported["TH_BattleRules"]
#==============================================================================
# ** BattleManager
#==============================================================================
# Had to make my own access methods.
module BattleManager
  #--------------------------------------------------------------------------
  # new : defeat_conditions
  #--------------------------------------------------------------------------
  def self.defeat_conditions
    @defeat_conditions
  end
  
  #--------------------------------------------------------------------------
  # new : victory_conditions
  #--------------------------------------------------------------------------
  def self.victory_conditions
    @victory_conditions
  end
  
end


#==============================================================================
# ** Sprite_BattleRulesDisplay
#==============================================================================
class Sprite_BattleRulesDisplay < Sprite_Base
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(Graphics.width, 288)
    reset
  end
  
  #--------------------------------------------------------------------------
  # reset
  #--------------------------------------------------------------------------
  def reset
    self.x  = width
    self.y  = 4
    self.ox = width
    self.zoom_x  = 4
    self.opacity = 0
    self.visible = true
    @duration = 0
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # victory_setting
  #--------------------------------------------------------------------------
  def victory_setting(symbol)
    Bubs::BattleRulesDisplay::VICTORY_SETTINGS[symbol]
  end
  
  #--------------------------------------------------------------------------
  # defeat_setting
  #--------------------------------------------------------------------------
  def defeat_setting(symbol)
    Bubs::BattleRulesDisplay::DEFEAT_SETTINGS[symbol]
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    bitmap.clear
    v_img = Cache.system(victory_setting(:back_image))
    d_img = Cache.system(defeat_setting(:back_image))
    v_text = victory_setting(:text)
    d_text = defeat_setting(:text)
    
    white = Color.new(255,255,255)
    
    ys = Bubs::BattleRulesDisplay::Y_SPACING
    ci = 0
    
    # Victory
    BattleManager.victory_conditions.each_with_index do |rule, i|
      ci += 1
      dy = ci * ys
      bitmap.blt(0, dy, v_img, v_img.rect)
      wlh = 24  #Window_Base::WLH
      bitmap.font.color.set(white)
      bitmap.draw_text(24, dy + 4, 200, wlh, v_text, 2)
      if eval(rule.condition)
        bitmap.font.color.set(victory_setting(:cond_met_color))
      end
      bitmap.draw_text(width - 296, dy + 4, 256, wlh, rule.description)
    end
    
    # Defeat
    BattleManager.defeat_conditions.each_with_index do |rule, i|
      ci += 1
      dy = ci * ys
      bitmap.blt(0, dy, d_img, d_img.rect)
      wlh = 24  #Window_Base::WLH
      bitmap.font.color.set(white)
      bitmap.draw_text(24, dy + 4, 200, wlh, d_text, 2)
      if eval(rule.condition)
        bitmap.font.color.set(defeat_setting(:cond_met_color))
      end
      bitmap.draw_text(width - 296, dy + 4, 256, wlh, rule.description)
    end

    v_img.dispose
    d_img.dispose
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    update_animation if visible
  end
  
  #--------------------------------------------------------------------------
  # update_animation
  #--------------------------------------------------------------------------
  def update_animation
    visible_time = Bubs::BattleRulesDisplay::DURATION #400
    prefade_buffer = 30

    if @duration < 12
      self.opacity += 12
      self.zoom_x  = (12 - @duration) / 3.0 + 1.0
    elsif @duration == 12
      self.opacity = 256
      self.x  = 0
      self.ox = 0
      self.zoom_x  = 1
    elsif @duration >= (visible_time - prefade_buffer)
      self.zoom_x += 0.05
      self.opacity -= 12   #(157 - @duration) * 8
    elsif @duration >= visible_time
       self.visible = false
    end 
    @duration += 1
  end
  
end # class Sprite_BattleRulesDisplay



#==============================================================================
# ** Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # alias : initialize
  #--------------------------------------------------------------------------
  alias :initialize_bubs_battle_rules_display :initialize
  def initialize
    initialize_bubs_battle_rules_display # alias

    create_battle_rules_display
  end
  
  #--------------------------------------------------------------------------
  # alias : dispose
  #--------------------------------------------------------------------------
  alias :dispose_bubs_battle_rules_display :dispose
  def dispose
    dispose_bubs_battle_rules_display # alias

    dispose_battle_rules_display
  end

  #--------------------------------------------------------------------------
  # alias : update
  #--------------------------------------------------------------------------
  alias :update_bubs_battle_rules_display :update
  def update
    update_bubs_battle_rules_display # alias

    update_battle_rules_display
  end

  #--------------------------------------------------------------------------
  # new : create_battle_rules_display
  #--------------------------------------------------------------------------
  def create_battle_rules_display
    @battle_rules_sprite = Sprite_BattleRulesDisplay.new
    @battle_rules_sprite.z = 90
  end
  
  #--------------------------------------------------------------------------
  # new : dispose_battle_rules_display
  #--------------------------------------------------------------------------
  def dispose_battle_rules_display
    @battle_rules_sprite.dispose
  end
  
  #--------------------------------------------------------------------------
  # new : update_battle_rules_display
  #--------------------------------------------------------------------------
  def update_battle_rules_display
    @battle_rules_sprite.update if @battle_rules_sprite != nil
  end
  
  #--------------------------------------------------------------------------
  # new : refresh_battle_rules_display
  #--------------------------------------------------------------------------
  def refresh_battle_rules_display
    @battle_rules_sprite.refresh
  end
  
  #--------------------------------------------------------------------------
  # new : reset_battle_rules_display
  #--------------------------------------------------------------------------
  def reset_battle_rules_display
    @battle_rules_sprite.reset
  end
  
end # class Spriteset_Battle


#==============================================================================
# ** Window_PartyCommand
#==============================================================================
class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # alias : make_command_list
  #--------------------------------------------------------------------------
  alias :make_command_list_bubs_br_display :make_command_list
  def make_command_list
    make_command_list_bubs_br_display # alias
    
    name = Bubs::BattleRulesDisplay::RULES_COMMAND_NAME
    switch_id = Bubs::BattleRulesDisplay::GAME_SWITCH
    if switch_id > 0
      add_command(name, :rules, $game_switches[switch_id])
    else
      add_command(name, :rules)
    end
  end
  
end



#==============================================================================
# ** Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # alias : battle_start
  #--------------------------------------------------------------------------
  alias :battle_start_bubs_battle_rules_display :battle_start
  def battle_start
    switch_id = Bubs::BattleRulesDisplay::GAME_SWITCH
    if switch_id <= 0 || $game_switches[switch_id]
      @spriteset.refresh_battle_rules_display
    end
    
    battle_start_bubs_battle_rules_display # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : create_party_command_window
  #--------------------------------------------------------------------------
  alias :cpcw_battle_rules_display :create_party_command_window
  def create_party_command_window
    cpcw_battle_rules_display # alias
    
    @party_command_window.set_handler(:rules, method(:command_rules))
  end
  #--------------------------------------------------------------------------
  # new : command_rules     # Displays rules at player command
  #--------------------------------------------------------------------------
  def command_rules
    @spriteset.reset_battle_rules_display
    @spriteset.refresh_battle_rules_display
    @party_command_window.activate
  end
  
end

end # if $imported["TH_BattleRules"]
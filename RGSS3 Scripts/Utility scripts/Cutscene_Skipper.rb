#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Cutscene Skipper
#  Author: Kread-EX
#  Version 1.03
#  Release date: 21/03/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 15/01/2013. Fixed another bug with message windows.
# # 14/01/2013. Fixed another major bug.
# # 22/03/2012. Fixed a critical bug!
#------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#------------------------------------------------------------------------------
# # Allows the player to skip cutscenes by pressing a button. Only dialogue and
# # graphic processing is skipped - switch and variable control, or other back
# # end operations are still processed.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # Wrap your cutscene between two labels: "Cutscene" and "End Cutscene". While
# # the contents are processed, the player will be able to skip it by pressing
# # the button you chose in the config module.
# # Some commands will still be processed:
# # - Switches/Variables/Self Switches
# # - Gain gold/items/weapons/armors
# # - Change actor parameters
# # - Start/stop timer
# # - Show/erase picture
# # - Enable/disable menus
# # - Set vehicle location
# #
# # Other commands will be downright ignored and will have to be put outside of
# # the skippable cutscene.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # Input
# # self.trigger? (alias)
# #
# # Game_Temp
# # skip_cutscene (new attr method)
# #
# # Game_Interpreter
# # command_118 (alias)
# # cutscene? (new method)
# # execute_command (alias)
# #
# # Scene_Map
# # check_skip_hotkey (new method)
#------------------------------------------------------------------------------

($imported ||= {})['KRX-CutsceneSkipper'] = true

puts 'Load: Cutscene Skipper v1.03 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================  
  SKIP_BUTTON = :CTRL
  SKIP_FADE_TIME = 20
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
end

class Game_Temp; attr_accessor(:skip_cutscene); end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● Sets a label
  #--------------------------------------------------------------------------
  alias_method(:krx_nocutscene_gi_118, :command_118)
  def command_118
    krx_nocutscene_gi_118
    @cutscene = true if @params[0] === 'Cutscene'
    @cutscene = false if @params[0] === 'End Cutscene'
  end
  #--------------------------------------------------------------------------
  # ● Determines if a cutscene is played
  #--------------------------------------------------------------------------
  def cutscene?
    @cutscene
  end
  #--------------------------------------------------------------------------
  # ● Execute command
  #--------------------------------------------------------------------------
  alias_method(:krx_nocutscene_gi_ec, :execute_command)
  def execute_command
    if @list[@index].code == 118 && @list[@index].parameters[0] === 'End Cutscene'
      $game_temp.skip_cutscene = false
      @cutscene = false
      Graphics.fadein(KRX::SKIP_FADE_TIME)
    end
    if cutscene? && $game_temp.skip_cutscene
      no_skip = (121..138).to_a + [201, 202, 231, 235, 236]
      return unless no_skip.include?(@list[@index].code)
    end
    krx_nocutscene_gi_ec
  end
end

#==============================================================================
# ■ Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● Frame Update
  #--------------------------------------------------------------------------
  alias_method(:krx_nocutscene_sm_update, :update)
  def update
    check_skip_hotkey(KRX::SKIP_BUTTON)
    krx_nocutscene_sm_update
  end
  #--------------------------------------------------------------------------
  # ● Checks the input
  #--------------------------------------------------------------------------
  def check_skip_hotkey(sym)
    if $game_map.interpreter.cutscene?
      if Input.trigger?(sym)
        $game_temp.skip_cutscene = true 
        $game_message.clear
        @message_window.clear_instance_variables
        @message_window.close
        Graphics.fadeout(KRX::SKIP_FADE_TIME)
      end
    end
  end
end
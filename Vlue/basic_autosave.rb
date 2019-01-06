#Basic Autosave v1.1
#----------#
#Features: Autosaves to the first slot every time the map changes. Can't
#           get any simpler then that!
#          Comes with option to rename first slot to whatever you want.
#
#Usage:    Plug and play.
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
 
#Sets whether to rename first file to denote Autosaveness and what to name it
NAME_AUTOSAVE_FILE = true
AUTOSAVE_FILE_NAME = "Autosave"
AUTOSAVE_ON_MAP = true
AUTOSAVE_AFTER_BATTLE = false
 
$auto_save = true
 
class Scene_Map
  alias auto_post_transfer post_transfer
  def post_transfer
    auto_post_transfer
    return unless AUTOSAVE_ON_MAP
    if Module.const_defined?(:Game_Options)
      DataManager.save_game(0) if $game_options.auto_save
    else
      DataManager.save_game(0) if $auto_save
    end
  end
end

module BattleManager
  def self.battle_end(result)
    @phase = nil
    @event_proc.call(result) if @event_proc
    $game_party.on_battle_end
    $game_troop.on_battle_end
    SceneManager.exit if $BTEST
    return unless AUTOSAVE_AFTER_BATTLE
    if Module.const_defined?(:Game_Options)
      DataManager.save_game(0) if $game_options.auto_save
    else
      DataManager.save_game(0) if $auto_save
    end
  end
end
 
class Window_SaveFile
  alias auto_refresh refresh
  def refresh
    if NAME_AUTOSAVE_FILE
      contents.clear
      change_color(normal_color)
      if @file_index == 0
        name = AUTOSAVE_FILE_NAME
      else
        name = Vocab::File + " #{@file_index}"
      end
      draw_text(4, 0, 200, line_height, name)
      @name_width = text_size(name).width
      draw_party_characters(152, 58)
      draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
    else
      auto_refresh
    end
  end
end
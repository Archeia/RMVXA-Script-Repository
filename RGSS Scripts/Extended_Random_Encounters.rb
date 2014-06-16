#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Extended Random Encounters (ERE)
# Author: Kread-EX
# Version 1.0
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
#-------------------------------------------------------------------------------------------------
 
 
#===========================================================
# INTRODUCTION
#
# For the random encounters lovers out there (bleh), here is a simple script to make them slightly
# more interesting.
# First, a colorful circle to know when the fight will start. More red the circle is, closer the battle is.
# Secondly, a Gust-ish system to allow a maximum number of battles for each area.
#
# INSTRUCTIONS
#
# By default, the maximum number of battles are 10. For all the game. Of course, you want to change
# this. There are two ways:
# 1. In the map name, put this: #EC[number]. The number represent the maximum allowed random
# encounters for an area. It is set until you change it, without another map for instance.
# 2. With a Call Script command: $game_system.set_encounter_ratio(number).
# The most efficient way is to set a number for an entire area via map name.
#
# You can hide the circle with this command: $game_system.display_encounter_dot = false.
#===========================================================
 
 
#===========================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles data surrounding the system. Backround music, etc.
#  is managed here as well. Refer to "$game_system" for the instance of
#  this class.
#===========================================================
 
class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :display_encounter_dot
  attr_accessor :max_encounter
  attr_accessor :current_encounter
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_ERE_game_system_initialize)
    alias_method :kread_ERE_game_system_initialize, :initialize
  end
  def initialize
    kread_ERE_game_system_initialize
    @display_encounter_dot = true
    @max_encounter = 10
    @current_encounter = 0
  end
  #--------------------------------------------------------------------------
  # * Reinitialize encounter ratio
  #--------------------------------------------------------------------------
  def set_encounter_ratio(max = 10)
    @max_encounter = max
    @current_encounter = 0
  end
  #--------------------------------------------------------------------------
end
 
#===========================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc.
#  It's used within the Scene_Map class.
#===========================================================
 
class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_ERE_spriteset_map_dispose)
    alias_method :kread_ERE_spriteset_map_dispose, :dispose
  end
  def dispose
    unless @encounter_dot == nil
     @encounter_dot.dispose
     @encounter_tex.dispose
    end
    kread_ERE_spriteset_map_dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_ERE_spriteset_map_update)
    alias_method :kread_ERE_spriteset_map_update, :update
  end
  def update
    update_encounter_dot unless $game_map.encounter_list.empty?
    kread_ERE_spriteset_map_update
  end
  #--------------------------------------------------------------------------
  # * Update the encounter dot
  #--------------------------------------------------------------------------
  def update_encounter_dot
    if @encounter_dot == nil && $game_system.max_encounter != @last_max
      @encounter_dot.bitmap.dispose if @encounter_dot != nil
      @encounter_dot = Sprite.new(@viewport3)
      @encounter_dot.bitmap = Bitmap.new('Graphics/Pictures/Dot_Fill')
      @encounter_dot.x = 491
      @encounter_dot.y = 348
      @blink_dot = 0
    end
    if @encounter_tex == nil
      @encounter_tex = Sprite.new(@viewport3)
      @encounter_tex.bitmap = RPG::Cache.picture('Dot_Texture')
      @encounter_tex.x, @encounter_tex.y = @encounter_dot.x, @encounter_dot.y
      @encounter_tex.z = @encounter_dot.z + 1
    end
    @encounter_dot.visible = @encounter_tex.visible = ($game_system.display_encounter_dot &&
    !$game_system.encounter_disabled)
    w, h = @encounter_dot.bitmap.width, @encounter_dot.bitmap.height
    if $game_player.encounter_count != @last_count
      rate = [(($game_map.encounter_step.to_f - $game_player.encounter_count.to_f) /
      $game_map.encounter_step.to_f), 0].max
      case rate
      when 0...0.4
        @encounter_dot.src_rect.set(0, 0, 133, 116)
      when 0.4...0.5
        @encounter_dot.src_rect.set(133, 0, 133, 116)
      when 0.5...0.6
        @encounter_dot.src_rect.set(266, 0, 133, 116)
      when 0.6...0.7
        @encounter_dot.src_rect.set(399, 0, 133, 116)
      when 0.7...0.8
        @encounter_dot.src_rect.set(0, 116, 133, 116)
      when 0.8...0.9
        @encounter_dot.src_rect.set(133, 116, 133, 116)
      when 0.9...1
        @encounter_dot.src_rect.set(266, 116, 133, 116)
      end
    end
    unless $game_system.current_encounter == $game_system.max_encounter
      @encounter_dot.tone = Tone.new(@blink_dot * 4, @blink_dot * 4, @blink_dot * 4)
      if @blink_dot == 25
        @sign = 'sub'
      elsif @blink_dot == -25
        @sign = 'add'
      end
      @blink_dot += @sign == 'sub' ? -1 : 1
    end
    crop_dot
  end
  #--------------------------------------------------------------------------
  # * Crop the encounter dot
  #--------------------------------------------------------------------------
  def crop_dot
    if $game_system.current_encounter > 0
      rect = @encounter_dot.src_rect
      ratio = (116 * $game_system.current_encounter.to_f / $game_system.max_encounter.to_f).round
      @encounter_dot.bitmap.fill_rect(rect.x, (rect.y + 116) - ratio, 133, ratio, Color.new(0, 0, 0, 0))
    end
  end
  #--------------------------------------------------------------------------
end
 
#===========================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles the map. It includes scrolling and passable determining
#  functions. Refer to "$game_map" for the instance of this class.
#===========================================================
 
class Game_Map
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_ERE_game_map_setup)
    alias_method :kread_ERE_game_map_setup, :setup
  end
  def setup(map_id)
    kread_ERE_game_map_setup(map_id)
    name = load_data('Data/MapInfos.rxdata')[map_id].name
    name.split.each {|line|
      if line =~ /#EC\[([0-9]+)\]/i && $1 != $game_system.max_encounter
        $game_system.set_encounter_ratio($1.to_i)
      end
    }
  end
  #--------------------------------------------------------------------------
end
 
#===========================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs map screen processing.
#===========================================================
 
class Scene_Map
  #--------------------------------------------------------------------------
  # * Battle Call
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_ERE_scene_map_call_battle)
    alias_method :kread_ERE_scene_map_call_battle, :call_battle
  end
  def call_battle
    if $game_system.current_encounter == $game_system.max_encounter &&
    !$game_system.map_interpreter.running?
      $game_temp.battle_calling = false
      $game_player.make_encounter_count
      return
    end
    $game_system.current_encounter += 1 if $game_player.encounter_count == 0
    kread_ERE_scene_map_call_battle
  end
  #--------------------------------------------------------------------------
end
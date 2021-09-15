#==============================================================================#
# ** IEX(Icy Engine Xelion) - Random Enemy Hues
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Enemy)
# ** Script Type   : Enemy Hue
# ** Date Created  : 9/09/2010
# ** Date Modified : 01/01/2010
# ** Version       : 1.0a
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# Everyone loves a little variation!
# Lets make one slime in a vast of colors!
# This script allows you to create hue sets that enemies can use every battle
# 
# So one enemy, 16 Hues, sounds nice!
# This is also Compatable with GTBS! >.> Believe it or not.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Can be placed in Enemy noteboxes
#------------------------------------------------------------------------------#
#  <HUESET: x> (or) <HUESSET: x>
#  Use this tag when you have a defined Hue set here in the script
#  Note x must be a number.
#
#  <RANDOM_HUE: x> (or) <RANDOM_HUES: x, x, x> 
#  Use this tag to create an array of possible hue changes
#  x is a number between 0 and 255
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# 
#  9/09/2010 - V1.0 Finished Script
#  
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Random_Enemy_Hues"] = true

#==============================================================================
# ** IEX::RAND_ENMY_HUES
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module RAND_ENMY_HUES
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#==============================================================================    
    HUESETS = {
    #GeneralSet
    0 => [0, 50, 100, 150, 200],
    1 => [0, 10, 20, 30, 40, 50],
    2 => [60, 70, 80, 90, 100],
    3 => [110, 120, 130, 140, 150],
    #This is about 16 colors.
    4 => [0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240]
    }
#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================    
  end
end

#==============================================================================
# ** IEX::REGEXP::RAND_ENMY_HUES
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module REGEXP
    module RAND_ENMY_HUES
      HUESET = /<(?:HUESET|HUESSET):[ ]*(\d+)>/i
      RANDHUES = /<(?:RANDOM_HUE|random hue)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
    end
  end
end

#==============================================================================
# ** RPG::Enemy
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Enemy
  
  alias iex_rand_hue_initialize initialize unless $@
  def initialize(*args)
    iex_rand_hue_initialize(*args)
    iex_rand_hue_cache
  end
  
  def iex_rand_hue_cache
    @iex_random_hue = []
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEX::REGEXP::RAND_ENMY_HUES::RANDHUES
      $1.scan(/\d+/).each { |num| 
      @iex_random_hue.push(num.to_i) if num.to_i > 0 }
    when IEX::REGEXP::RAND_ENMY_HUES::HUESET
      if IEX::RAND_ENMY_HUES::HUESETS.has_key?($1.to_i)
        @iex_random_hue = IEX::RAND_ENMY_HUES::HUESETS[$1.to_i]
      end
    end
    }
  end
  
  def get_random_hue
    iex_rand_hue_cache if @iex_random_hue == nil
    return @iex_random_hue
  end
  
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================
class Game_Enemy
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     index    : index in troop
  #     enemy_id : enemy ID
  #--------------------------------------------------------------------------
  alias icy_rand_hues_initialize initialize unless $@
  def initialize(index, enemy_id) 
    icy_rand_hues_initialize(index, enemy_id)
    @icy_huesset = setup_enemy_hues
    set_icy_hue
  end
  
  def setup_enemy_hues
    bat_hue = enemy.get_random_hue
    return bat_hue
  end
  
  def set_icy_hue
    @battler_hue = enemy.battler_hue
    unless @icy_huesset.empty?
      huerand = rand(@icy_huesset.size)
      @battler_hue = @icy_huesset[huerand]
    end
    return @battler_hue
  end
  
end

################################################################################
#------------------------------------------------------------------------------#
#END\\\END\\\END\\\END\\\END\\\END\\\END///END///END///END///END///END///END///#
#------------------------------------------------------------------------------#
################################################################################
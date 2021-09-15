#==============================================================================#
# ** IEX(Icy Engine Xelion) - Random Enemy Names
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Enemy)
# ** Script Type   : Enemy Naming
# ** Date Created  : 9/09/2010
# ** Date Modified : 11/07/2010
# ** Version       : 1.0
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# Everyone loves a little spice in there games!
# And we can all agree that attacking slime A boring..
# I originally created this script for use with TBS games.
# To give them that FFT or Ogre Battle feel.
# This script is meant to apply random names to every enemy, every battle
# You have the options to create naming groups and to void name changes
# for certain enemies.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Can be placed in Enemy noteboxes
#------------------------------------------------------------------------------#
#  <VOID_NAME> (or) <void name>
#  An enemy with this notetag will not have its name changed
#  Use this with bosses
#
#  <CATERGORY_NAME: x> (or) <catergory name: x> (or) <NAME_SET: x> (or) <name set: x>
#  You can change the catergory from which the name should be pulled using this
#  tag.
# 
#  So if you have a name Catergory "Monster"
#  You would put
#  <Name Set: Monster>
#  In the enemy notebox
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
$imported["IEX_Random_Enemy_Names"] = true

#==============================================================================
# ** IEX::ENEMY_NAMES
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module ENEMY_NAMES
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#==============================================================================
  #--------------------------------------------------------------------------#
  # * Name Catergories
  #--------------------------------------------------------------------------#
  # You can create new catergories by simply doing this
  # "Catergory name" => [Array of names]
  #--------------------------------------------------------------------------#
    NAME_CATERGORIES = {
    # Females
    "Female" => ['Silene', 'Arisa', 'Kyla', 'Lyn', 'Laren', 'Elisa', 'El', 
                 'Caren', 'Carlene'], 
    # Males
    "Male" =>   ['Markin', 'Josh', 'Phoros', 'Craig', 'Dermin', 'Lyri', 'Fagan',
                 'Germion'],
    # Monters
    #These are the names used for other enemies not stated in the Males or Females Array
    "Monster" =>['Grygos', 'Gripio', 'Leios', 'Marras', 'Leerio', 'Luse', 'Mordin',
                 'Lezwert', 'Golbine', 'Zector', 'Arkests', 'Banel', 'Cerpio',
                 'Damin', 'Eggress', 'Filion', 'Heron', 'Isil', 'Jackern', 'Kuing',
                 'Norin', 'Olof', 'Porun', 'Restanz', 'Sori', 'Tampi', 'Unlim'],
   } # Do Not Remove
   
   DEFAULT_NAME_SET = "Monster"
#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================
  end
end
#==============================================================================
# ** IEX::REGEXP::ENEMY_NAMES
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module REGEXP
    module ENEMY_NAMES
      VOID_NAME = /<(?:VOID_NAME|void name)>/i
      NAME_CATE = /<(?:CATERGORY_NAME|catergory name|NAME_SET|name set):[ ]*(.*)>/i
    end
  end
end 

#==============================================================================
# ** IEX::ENEMY_NAMES
#------------------------------------------------------------------------------
#==============================================================================
module IEX::ENEMY_NAMES
  
  def self.get_random_name(catergory, arrayz)
    cat_name = nil
    for key in NAME_CATERGORIES.keys
      case key.to_s
      when /(?:#{catergory.to_s})/i
        cat_name = NAME_CATERGORIES[key]
        break
      end
    end  
    new_name = nil
    return nil if cat_name == nil
    loop do
      new_name = cat_name[rand(cat_name.size)]
      if arrayz.include?(new_name) == false
        break 
      elsif cat_name.include?(arrayz)
        new_name = nil
        break
      end
    end
    return new_name
  end
  
end

#==============================================================================
# ** RPG::Enemy
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Enemy
  
  alias iex_ran_name_initialize initialize unless $@
  def initialize
    iex_ran_name_initialize(*args)
    iex_ran_name_cache
  end
  
  def iex_ran_name_cache
    @iex_void_name = false
    @iex_name_cat = IEX::ENEMY_NAMES::DEFAULT_NAME_SET
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEX::REGEXP::ENEMY_NAMES::VOID_NAME
      @iex_void_name = true
    when IEX::REGEXP::ENEMY_NAMES::NAME_CATE
      @iex_name_cat = $1.to_s
    end
    }
  end
  
  def void_name?
    iex_ran_name_cache if @iex_void_name == nil
    return @iex_void_name
  end
  
  def get_name_catergory
    iex_ran_name_cache if @iex_name_cat == nil
    return @iex_name_cat
  end
  
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================
class Game_Enemy
  
  attr_accessor :icy_ran_name
  attr_accessor :void_name_change
  attr_reader :name_catergory
  
  alias iex_random_enemy_names_initialize initialize unless $@
  def initialize(*args)
    iex_random_enemy_names_initialize(*args)
    iex_setup_name
  end
  
  def iex_setup_name
    @void_name_change = enemy.void_name?
    @name_catergory = enemy.get_name_catergory
    @icy_ran_name = ''
  end
  
  #--------------------------------------------------------------------------
  # * Get Display Name
  #--------------------------------------------------------------------------
  def name
    if @plural
      if @void_name_change
        return @original_name + letter
      else
        return @icy_ran_name 
      end
    else
      if @void_name_change
        return @original_name
      else
        return @icy_ran_name 
      end
    end
  end
  
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================
class Game_Troop < Game_Unit
  
  #--------------------------------------------------------------------------
  # * Creates the name for the enemies
  #--------------------------------------------------------------------------
  alias icy_make_unique_more_names make_unique_names unless $@
  def make_unique_names
    list_o_names = []
    #runs original
    icy_make_unique_more_names
    for enemy in members 
      next if enemy == nil
      if enemy.name_catergory == nil
        enemy.void_name_change = true
        next 
      end
      rand_name = IEX::ENEMY_NAMES.get_random_name(enemy.name_catergory, list_o_names)
      if rand_name == nil
        enemy.void_name_change = true
        next
      end
      enemy.icy_ran_name = rand_name
      list_o_names.push(rand_name)
    end
  end
  
end
################################################################################
#------------------------------------------------------------------------------#
#END\\\END\\\END\\\END\\\END\\\END\\\END///END///END///END///END///END///END///#
#------------------------------------------------------------------------------#
################################################################################
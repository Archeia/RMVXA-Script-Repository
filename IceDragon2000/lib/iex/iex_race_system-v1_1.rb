#==============================================================================#
# ** IEX(Icy Engine Xelion) - Race System
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Actors)
# ** Script Type   : Actor Modifier
# ** Date Created  : 11/05/2010
# ** Date Modified : 08/07/2011
# ** Requested By  : phropheus
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script adds a new feature to your game, called races.
# (@_@ I said something wrong didn't I...)
# Anyway currently these races only affect stats, feel free to drop a line
# of suggestion.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#------------------------------------------------------------------------------#
# Races can fully, alter base stats, and get stat bonuses on level up..
# Not much..
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#  If you have YEM New Battle Stats, this script allows you to alter those stats
#  as well..
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  11/05/2010 - V1.0  Finished Script
#  08/07/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_Race_System"] = true
#==============================================================================#
# ** IEX::RACE_SYSTEM
#==============================================================================#
module IEX
  module RACE_SYSTEM
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * Races
  #--------------------------------------------------------------------------#
  # Define the races here, note use numbers on the left (They serve as Ids)
  # And a string on the right (Race's Name)
  # **Note Race 0 is the default
  #--------------------------------------------------------------------------#
    RACES = {
    # Race_Id => String
    0 => "", # Do not Remove
    1 => "Hume",
    2 => "Neko",
    3 => "Dragon",
    4 => "Elf"
    } # Do not Remove
  #--------------------------------------------------------------------------#
  # * Race Icons
  #--------------------------------------------------------------------------#
  # Race Id on the left and an IconIndex on the right
  # This is used in the status window
  # **Note Race 0 is the default
  #--------------------------------------------------------------------------#
    RACE_ICONS = {
    # Race_Id => Icon_Index
    0 => 0, # Do not Remove
    1 => 1,
    2 => 11,
    3 => 201,
    4 => 16,
    } # Do not Remove

  #--------------------------------------------------------------------------#
  # * Race Base Stat Modifier
  #--------------------------------------------------------------------------#
  # This is where you configure the Race Base Stat Mods
  # You can turn this feature off if you like..
  # **Note Race 0 is the default, therefore anything you edit for it
  # will affect actors who didn't have there race changed
  #--------------------------------------------------------------------------#
    RACE_AFFECT_STATS = true
    RACE_BASE_STAT_RATE = 100

    RACE_BASE_STAT = {
   #Race_Id => [maxhp, maxmp, atk, def, spi, agi, dex, res]
      0 =>     [100,   100,   100, 100, 100, 100, 100, 100], # Do not Remove
      2 =>     [100,   100,   100, 80 , 100, 120, 100, 100],
    } # Do not Remove

  #--------------------------------------------------------------------------#
  # * Race Bonus Level Up Stat Modifier
  #--------------------------------------------------------------------------#
  # This is where you configure the Race Bonus Stat Mods
  # You can turn this feature off if you like..
  # **Note Race 0 is the default, therefore anything you edit for it
  # will affect actors who didn't have there race changed
  #--------------------------------------------------------------------------#
    RACE_LEVEL_UP_BONUS = true
    RACE_GROWTH_RATE = 100
    GROWTH_STAT_BONUS = {
    #Race_Id => [maxhp, maxmp, atk, def, spi, agi, dex, res]
      0 =>     [0   ,   0  ,   0  , 0  , 0  , 0  , 0  , 0  ], # Do not Remove
    } # Do not Remove

    RACE_STAT_RANDOM_BONUS = true
    GROWTH_STAT_BONUS_RAN = {
    #Race_Id => [maxhp, maxmp, atk, def, spi, agi, dex, res]
      0 =>     [0   ,   0  ,   0  , 0  , 0  , 0  , 0  , 0  ], # Do not Remove
    } # Do not Remove

  #--------------------------------------------------------------------------#
  # * Actor Starting Race
  #--------------------------------------------------------------------------#
  # You can set the starting race of an actor here
  # **Note Actor 0 is the default, any race set to that, will be the default
  # for actors who aren't specified here.
  #--------------------------------------------------------------------------#
    ACTOR_STARTING_RACES = {
    # Actor_id => Race_Id
    0 => 0, # Do not Remove
    1 => 1,
    2 => 1,
    4 => 2,
    5 => 4,
    6 => 3,
    7 => 2,
    8 => 3,
    9 => 1,
    } # Do not Remove

  #--------------------------------------------------------------------------#
  # * Race Status Window Stuff
  #--------------------------------------------------------------------------#
  #--------------------------------------------------------------------------#
    DRAW_RACE = true
    #           x, y, width, height
    RACE_POS = [256, 0, 128, 24]

    RACE_FORMAT = "%1s : %2s"
    RACE_TEXT = "Race"
#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  ACTOR_STARTING_RACES.default = ACTOR_STARTING_RACES[0]

  end
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iex_races_ga_initialize :initialize unless $@
  def initialize( *args, &block )
    iex_races_ga_initialize( *args, &block )
    setup_race
  end

  #--------------------------------------------------------------------------#
  # * alias-method :setup_race
  #--------------------------------------------------------------------------#
  def setup_race
    @race_id = IEX::RACE_SYSTEM::ACTOR_STARTING_RACES[@actor_id]
  end

  #--------------------------------------------------------------------------#
  # * alias-methods :setup_race
  #--------------------------------------------------------------------------#
  if IEX::RACE_SYSTEM::RACE_AFFECT_STATS
    a = ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi']
    a += ['dex'] if $imported["DEX Stat"]
    a += ['res'] if $imported["RES Stat"]
    a.each_with_index do |m, i|
      base_method = "base_#{m}"
      iex_base_method = "iex_race_#{base_method}"
      alias_method iex_base_method, base_method

      define_method(base_method) do |*args, &block|
        bs = send(iex_base_method)
        racarra = IEX::RACE_SYSTEM::RACE_BASE_STAT.fetch(@race_id) do
          IEX::RACE_SYSTEM::RACE_BASE_STAT[0]
        end
        bs *= 100.0 + (racarra[i] - 100.0) * IEX::RACE_SYSTEM::RACE_BASE_STAT_RATE.to_f / 100.0
        bs /= 100.0

        bs.to_i
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :level_up
  #--------------------------------------------------------------------------#
  alias :iex_races_ga_level_up :level_up unless $@
  def level_up( *args, &block )
    race_rate = IEX::RACE_SYSTEM::RACE_GROWTH_RATE

    if IEX::RACE_SYSTEM::RACE_LEVEL_UP_BONUS
      if IEX::RACE_SYSTEM::GROWTH_STAT_BONUS.has_key?(@race_id)
        racarra = IEX::RACE_SYSTEM::GROWTH_STAT_BONUS[@race_id]
        self.maxhp += (racarra[0] * race_rate) / 100
        self.maxmp += (racarra[1] * race_rate) / 100
        self.atk   += (racarra[2] * race_rate) / 100
        self.def   += (racarra[3] * race_rate) / 100
        self.spi   += (racarra[4] * race_rate) / 100
        self.agi   += (racarra[5] * race_rate) / 100
        if $imported["DEX Stat"]
          self.dex += (racarra[6] * race_rate) / 100
        end
        if $imported["RES Stat"]
          self.res += (racarra[7] * race_rate) / 100
        end
      end
    end

    if IEX::RACE_SYSTEM::RACE_STAT_RANDOM_BONUS
      if IEX::RACE_SYSTEM::GROWTH_STAT_BONUS_RAN.has_key?(@race_id)
        racarra = IEX::RACE_SYSTEM::GROWTH_STAT_BONUS_RAN[@race_id]
        self.maxhp += (rand(racarra[0]) * race_rate) / 100 unless racarra[0] == 0
        self.maxmp += (rand(racarra[1]) * race_rate) / 100 unless racarra[1] == 0
        self.atk   += (rand(racarra[2]) * race_rate) / 100 unless racarra[2] == 0
        self.def   += (rand(racarra[3]) * race_rate) / 100 unless racarra[3] == 0
        self.spi   += (rand(racarra[4]) * race_rate) / 100 unless racarra[4] == 0
        self.agi   += (rand(racarra[5]) * race_rate) / 100 unless racarra[5] == 0
        if $imported["DEX Stat"]
          self.dex += (rand(racarra[6]) * race_rate) / 100 unless racarra[6] == 0
        end
        if $imported["RES Stat"]
          self.res += (rand(racarra[7]) * race_rate) / 100 unless racarra[7] == 0
        end
      end
    end
    iex_races_ga_level_up( *args, &block )
  end

  #--------------------------------------------------------------------------#
  # * new-method :race_name
  #--------------------------------------------------------------------------#
  def race_name()
    setup_race() if @race_id.nil?()
    return IEX::RACE_SYSTEM::RACES[@race_id]
  end

end

#==============================================================================#
# ** Window_Base
#==============================================================================#
class Window_Base

  #--------------------------------------------------------------------------#
  # * new-method :draw_race
  #--------------------------------------------------------------------------#
  def draw_race( actor, x, y, width = 128, height = 24, align = 0 )
    format = IEX::RACE_SYSTEM::RACE_FORMAT
    race_text = IEX::RACE_SYSTEM::RACE_TEXT
    race_text = sprintf(format, race_text, actor.race_name.to_s)
    self.contents.draw_text(x, y, width, height, race_text)
  end

end

#==============================================================================#
# ** Window_Status
#==============================================================================#
class Window_Status < Window_Base

  #--------------------------------------------------------------------------#
  # * alias-method :refresh
  #--------------------------------------------------------------------------#
  alias :iex_races_ws_refresh :refresh unless $@
  def refresh( *args, &block )
    iex_races_ws_refresh( *args, &block )
    if IEX::RACE_SYSTEM::DRAW_RACE
      tx = IEX::RACE_SYSTEM::RACE_POS[0]
      ty = IEX::RACE_SYSTEM::RACE_POS[1]
      tw = IEX::RACE_SYSTEM::RACE_POS[2]
      th = IEX::RACE_SYSTEM::RACE_POS[3]
      draw_race(@actor, tx, ty, tw, th)
    end
  end

end

#==============================================================================#
# ** END OF FILE
#==============================================================================#

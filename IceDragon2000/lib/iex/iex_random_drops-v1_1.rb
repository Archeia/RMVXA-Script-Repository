#==============================================================================#
# ** IEX(Icy Engine Xelion) - More Drops + Lucky Finish
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon
# ** Script-Type   : (Battle) Drops Modifier, Gold Modifier
# ** Date Created  : 9/12/2010
# ** Date Modified : 11/7/2010
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script has two main features
# 1. Lucky Finish System 
#    There is a chance that the player will get a lucky finish that
#    will alter the gold by an amount set by you. There are two modes for this.
#
# 2. More Drops
#    Rpg Maker by default limits you to 2 drops
#    I have added a feature that allows you have more drops, with some simple 
#    notetags.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#------------------------------------------------------------------------------#
# Two Modes of Lucky Finish
# Counter Mode
# Every time you get a lucky finish 1 is added to the counter.
# This the gold you receive is then multiplied by it.
# Lucky Rate
# You set up lucky rates in the LUCKY RATE Constant * More info when reading
#
#------------------------------------------------------------------------------#
#  Notetags! Can be placed in Enemy noteboxes
#------------------------------------------------------------------------------#
# Enemy Gold Rates
# Put <gold rate x%> (replace x with a percentage). 
# This is the chance of the enemy dropping any gold.
# By default it is 100%
# EG. <gold rate 75%>
#
# Enemy Gold Range
# Put <gold range x:y> (replace x and y with intergers).
# This is a range for which enemy gold will be given
# If not set it will use the enemies default gold
# EG. <gold range 50:150> Enemy will drop between 50 and 150 gold
#
# Enemy Lucky Rate
# put <lucky rate x%> (replace x with a percentage).
# This will be added to the Lucky Rate, only in Counter Mode
#
#------------------------------------------------------------------------------#
# Drops
# <more items x:y-z> 
# <more armors x:y-z>
# <more weapons x:y-z>
# Replace x with the Objects Id
# Replace y with an interger (Used instead of a percent so 1 would mean always
#                              2 is a 50% 3 is a 33% and so on)
# Replace z with an interger (Used for how many of the objects should be dropped)
# Note it will be calculated everytime for the amount.
# You can stack as many as these tags as you want.
# EG <more items 1:1-4> This will drop 4 potions
# EG2 <more items 1:4-50> 25% chance that 1 to 50 potions can be dropped.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# V 1.0 9/12/2010 Finished Script.
# V 1.1 9/14/2010 Added 3rd Mode - Steady Rate
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Rand_Drop"] = true

#==============================================================================
# ** IEX::RAND_DROP
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module RAND_DROP
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#==============================================================================
    LUCKY_ON = false
    # Lucky Count Mode 
    # 0 - Increase Rate
    # 1 - Steady Rate
    # 2 - Controlled Rate
    
    LUCKY_COUNT_MODE = 0 
    LUCKY_SET_RATE = 3 # Used if working with steady rate
    LUCKY_DROP_RATE = 60 # Ignore this if LUCKY_COUNT_MODE = false
    LUCKY_GOLD_LIMIT = 21000 # Max gold obtainable from one battle
    LUCKY_RATES = {
  # Rate => [Multiplier, "Name", "SE_Filename"],
    10 => [2, "Lucky", 'Coin 1'],
    5  => [4, "Super Lucky", 'Coins 5'],
    1  => [10, "Impossible Lucky", 'Coins 4'],
    }
    DEFAULT_LUCKY_SE = 'Coins 4'
    DEFAULT_LUCK_TEXT = "Lucky Fight!"
#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================
  end
end

#==============================================================================
# ** IEX REGEX Module - Icy Engine Xelion
# ** Don't touch ma stuff!!! >.< Unless ya know what ya doing! TuT
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module REGEXP
    module RAND_DROP
      GOLD_RATE = /<(?:GOLD_RATE|gold rate)[ ]*(\d+)(?:%|%)>/i
      GOLD_RANGE = /<(?:GOLD_RANGE|gold range)[ ]*(\d+):(\d+)>/i
      
      MORE_ITEMS = /<(?:MORE_ITEMS|more items)[ ]*(\d+):(\d+)-(\d+)>/i
      MORE_ARMORS = /<(?:MORE_ARMORS|more armors)[ ]*(\d+):(\d+)-(\d+)>/i
      MORE_WEAPONS = /<(?:MORE_WEAPONS|more weapons)[ ]*(\d+):(\d+)-(\d+)>/i
      
      LUCKY_RATE_ADD = /<(?:LUCKY_RATE|lucky rate)[ ]*(\d+)(?:%|%)>/i
    end
  end
end

# This allows the Minimum Range Random Function
# Still to use it you must call Math.min_rand(min , max)
module Math ; def self.min_rand(min = 0, max = 1) ; return rand(max) + min end end

#==============================================================================
# ** RPG::Enemy
#------------------------------------------------------------------------------
#==============================================================================  
class RPG::Enemy
  
  alias iex_rand_drop_rates_rpg_enm_initialize initialize unless $@
  def initilaize(*args)
    iex_rand_drop_rates_rpg_enm_initialize(*args)
    iex_rand_drop_cache
  end
  
  def iex_rand_drop_cache
    @gold_range = []
    @gold_rate = 100
    @lucky_rate_add = 0
    @more_drops = []
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEX::REGEXP::RAND_DROP::GOLD_RANGE
      @gold_range = [$1.to_i, $2.to_i]
    when IEX::REGEXP::RAND_DROP::GOLD_RATE
      @gold_rate = [$1.to_i, 100].min
    when IEX::REGEXP::RAND_DROP::MORE_ITEMS
      @more_drops.push([0, $1.to_i, $2.to_i, [$3.to_i, 50].min])
    when IEX::REGEXP::RAND_DROP::MORE_ARMORS
      @more_drops.push([2, $1.to_i, $2.to_i, [$3.to_i, 50].min])
    when IEX::REGEXP::RAND_DROP::MORE_WEAPONS
      @more_drops.push([1, $1.to_i, $2.to_i, [$3.to_i, 50].min])  
    when IEX::REGEXP::RAND_DROP::LUCKY_RATE_ADD
      @lucky_rate_add = [@lucky_rate_add + $1.to_i, 100].min
    end
    }
  end
  
  def gold_drop_rate
    iex_rand_drop_cache if @gold_rate == nil
    return @gold_rate
  end
  
  def gold_drop_range
    iex_rand_drop_cache if @gold_range == nil
    return @gold_range
  end
  
  def get_more_drops
    iex_rand_drop_cache if @more_drops == nil
    return @more_drops
  end
  
  def lucky_rate_add
    iex_rand_drop_cache if @lucky_rate_add == nil
    return @lucky_rate_add
  end
  
end
 
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================
class Game_Enemy < Game_Battler
  
  alias iex_rand_drop_rates_ge_initialize initialize unless $@
  def initilaize(*args)
    iex_rand_drop_rates_ge_initialize(*args)
    prep_gold_drop
  end
  
  def prep_gold_drop
    @gold_amount = 0
    rate = (100 - [enemy.gold_drop_rate, 100].min)
    if rand(rate).to_i == 0
      unless enemy.gold_drop_range.empty?
        gomin = enemy.gold_drop_range[0]
        gomax = enemy.gold_drop_range[1]
        @gold_amount = Math.min_rand(gomin, gomax)
      else
        @gold_amount = enemy.gold
      end
    end
  end
  
  def lucky_rate_add
    return enemy.lucky_rate_add
  end
  
  #--------------------------------------------------------------------------
  # * Get Gold
  #--------------------------------------------------------------------------
  def gold
    prep_gold_drop if @gold_amount == nil
    return @gold_amount
  end
  
  def more_drops
    result = []
    for dro in enemy.get_more_drops
      next if dro == nil
      case dro[0]
      when 0
        result.push([$data_items[dro[1]], dro[2], dro[3]])
      when 1
        result.push([$data_weapons[dro[1]], dro[2], dro[3]])
      when 2
        result.push([$data_armors[dro[1]], dro[2], dro[3]])
      end  
    end  
    return result
  end
  
end
 
#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================
class Game_Troop < Game_Unit
  
  attr_accessor :lucky_fight
  attr_accessor :lucky_name
  attr_accessor :lucky_se
  
  alias iex_lucky_rate_initialize initialize unless $@
  def initialize(*args)
    iex_lucky_rate_initialize(*args)
    @lucky_rate = IEX::RAND_DROP::LUCKY_DROP_RATE
    @lucky_multi = 1
    @lucky_name = IEX::RAND_DROP::DEFAULT_LUCK_TEXT
    @lucky_se = IEX::RAND_DROP::DEFAULT_LUCKY_SE
  end
  
  alias iex_lucky_rate_setup setup unless $@
  def setup(*args)
    iex_lucky_rate_setup(*args)
    @lucky_rate = IEX::RAND_DROP::LUCKY_DROP_RATE
    for enemy in members
      @lucky_rate = [@lucky_rate + enemy.lucky_rate_add, 100].min
    end
    rate = 100 - @lucky_rate
    @lucky_name = IEX::RAND_DROP::DEFAULT_LUCK_TEXT
    @lucky_se = IEX::RAND_DROP::DEFAULT_LUCKY_SE
    if IEX::RAND_DROP::LUCKY_COUNT_MODE == 0
      if rand(rate).to_i == 0
        @lucky_fight = true
        @lucky_multi += 1
      else
        @lucky_fight = false
        @lucky_multi = 1
      end
    elsif IEX::RAND_DROP::LUCKY_COUNT_MODE == 1
      if rand(rate).to_i == 0
        @lucky_fight = true
        @lucky_multi = IEX::RAND_DROP::LUCKY_SET_RATE
      else
        @lucky_fight = false
        @lucky_multi = 1
      end
    elsif IEX::RAND_DROP::LUCKY_COUNT_MODE == 2
      stack = []
      thres_rate = rand(100).to_i
      for rae in IEX::RAND_DROP::LUCKY_RATES.keys
        if rae >= thres_rate
          stack.push(true)
          @lucky_multi = IEX::RAND_DROP::LUCKY_RATES[rae][0]
          @lucky_name = IEX::RAND_DROP::LUCKY_RATES[rae][1]
          @lucky_se = IEX::RAND_DROP::LUCKY_RATES[rae][2]
        end
      end
      if stack.any?
        @lucky_fight = true
      else
        @lucky_fight = false
      end
      stack.clear
    end
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Total Gold
  #--------------------------------------------------------------------------
  def gold_total
    gold = 0
    for enemy in dead_members
      next if enemy == nil
      gold += enemy.gold unless enemy.hidden
    end
      gold = [gold * @lucky_multi, IEX::RAND_DROP::LUCKY_GOLD_LIMIT].min if IEX::RAND_DROP::LUCKY_ON
    return gold
  end
  
  #--------------------------------------------------------------------------
  # * Create Array of Dropped Items
  #--------------------------------------------------------------------------
  alias iex_drop_more_make_drop_items make_drop_items unless $@
  def make_drop_items
    drop_items_more = iex_drop_more_make_drop_items
    for enemy in dead_members
      dro = []
      for mri in enemy.more_drops 
        next if mri == nil
          for num in 1..mri[2]
            rate = mri[1]
            if rand(rate).to_i == 0
             drop_items_more.push(mri[0])
            end
          end
        end
      end
    return drop_items_more
  end
  
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================
class Scene_Battle < Scene_Base
  
  alias iex_rand_drop_sb_process_victory process_victory unless $@
  def process_victory(*args)
    if $game_troop.lucky_fight and IEX::RAND_DROP::LUCKY_ON
      lucky_sprite = Sprite.new
      lucky_sprite.bitmap = Bitmap.new(Graphics.width, 96)
      lucky_sprite.bitmap.clear
      lucky_sprite.bitmap.font.size = 64
      lucky_sprite.bitmap.font.color = Color.new(255, 255, 255)
      lucky_sprite.bitmap.draw_text(0,0,lucky_sprite.bitmap.width, 72, $game_troop.lucky_name, 1)
      lucky_sprite.x = 0
      lucky_sprite.y = (Graphics.height - lucky_sprite.bitmap.height)/ 2
      lucky_sprite.z = 200
      lucky_sprite.visible = true
      lf_se = RPG::SE.new($game_troop.lucky_se)
      lf_se.play
    end
      iex_rand_drop_sb_process_victory(*args)
    if $game_troop.lucky_fight
      if lucky_sprite != nil
        lucky_sprite.dispose
        lucky_sprite = nil
      end
    end
  end
  
end

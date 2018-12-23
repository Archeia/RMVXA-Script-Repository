#==============================================================================
#    Drop Options
#    Version: 1.1.0
#    Author: modern algebra (rmrk.net)
#    Date: 23 September 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script is very simple. All it does is allow you to make item drops a
#   little less static in some very simple ways: 
#
#     (a) you can make more than three drops for each enemy, so enemies can  
#       drop a greater variety of loot; 
#     (b) you can place a cap on the amount of these extra drops, so if you 
#       want a boss to have a 100% chance of dropping one of three items, but  
#       only one, then you can do that; 
#     (c) you can use percentile rather than denominator based drops; and
#     (d) you can randomize the amount of gold dropped by setting a range
#       within which it can fall.
#
#    If you are using any scripts that show loot drops of enemies (such as a 
#   bestiary), the effects of this script will not be correctly reflected in 
#   that without direct modifications. If you are using such a script, please 
#   feel free to post a link to it in this script's thread in RMRK and I will 
#   write a patch for it.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Place this script above Main and below any other scripts in the Script 
#   Editor (F11).
#
#    All configuration happens in the note boxes of enemies. If you wish to add
#   a new drop, place this code in a note box for the enemy:
#
#      \drop[type id, probability]
#        type        : the type, either I (for Item), W (for Weapon), or A (for
#                     Armor).
#        id          : This is the ID of the item, weapon, or armor.
#        probability : This is the probability the item, weapon, or armor will
#                     drop. If you put a % sign after the number, then it will
#                     drop that percentage of the time. If not, then the number
#                     you put here will be the denominator, same as with 
#                     regular drops. The number has to be an integer.
#    EXAMPLES:
#      \drop[i1, 65%]
#          This will mean that the item with ID 1 (Potion by default) will drop
#         65% of the time when you kill this enemy.
#      \drop[a5, 8]
#          This will mean that the armor with ID 5 (Mithril Shield by default)
#         will drop 1/8 times you kill this enemy.
#
#    Those are the mandatory arguments, but you can also make it so that the 
#   drop will only be available if a specific switch is on by adding s0 after
#   the probability, where 0 is replaced by the ID of the switch.
#
#      \drop[type id, probability, s0]
#  EXAMPLES:
#
#      \drop[w4, 4, s2]
#          This will mean that the weapon with ID 4 will drop 1/4 times you 
#         kill the enemy, but only if switch 2 is currently on. Otherwise, it
#         will never drop.
#
#    Finally, if you want it to be possible that more than one of the same item
#   will drop (with the same conditions), you can simply add *n after the drop
#   code, where n is replaced by the number of items you want it to be possible
#   to drop.
#
#  EXAMPLES:
#      \drop[a2, 10%]*2
#          This gives two chances to get Armor 2 at 10% probability. 
#
#    To set a maximum on the number of extra drops (note that this only applies
#   to extra drops set up in the note field - the two default drops are exempt 
#   from this cap), you can use the code:
#
#      \max_drop[x]
#         x : the maximum amount of extra drops that you want.
#   EXAMPLE:
#    If an enemy is set up like this:
#      \drop[w3, 100%]
#      \drop[w4, 100%]
#      \max_drop[1]
#    Then that means that the enemy will definitely drop either Weapon 3 
#   (Spear) or Weapon 4 (Short Sword), but will not drop both since 
#   the \max_drop code prevents it from dropping more than one of the notebox
#   drops.
#
#    To randomize the amount of gold an enemy drops, place the following code 
#   in its note box:
#
#      \gold[variance]
#        variance : this is an integer, and the amount of gold dropped is 
#          calculated by randomly selecting a number between 0 and this value,
#          and then adding it to the regular gold drop you set in the database.
#    EXAMPLE:
#      If an enemy has 5 gold set as its drop in the database, then the 
#     following note:
#        \gold[12]
#      will mean that the enemy will drop anywhere between 5 and 17 gold upon
#     its death.
#==============================================================================

$imported = {} unless $imported
$imported[:MADropOptions] = true

#==============================================================================
# ** RPG::Enemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - gold
#    new method - random_gold; extra_drops; max_drop
#==============================================================================

class RPG::Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gold
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_drpopt_gold_2go9 gold
  def gold(*args, &block)
    (rand(ma_random_gold + 1)) + ma_drpopt_gold_2go9(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Random Gold
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_random_gold
    (@ma_rand_gold = self.note[/\\GOLD\[(\d+)\]/i] != nil ? $1.to_i : 0) if !@ma_rand_gold
    @ma_rand_gold
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Extra Drops
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_extra_drops
    if @ma_extra_drops.nil?
      @ma_extra_drops = []
      self.note.scan(/\\DROP\[\s*([IWA])\s*(\d+)\s*[,;:]?\s*(\d+)(%?)\s*[,;:]?\s*S?\s*(\d*)\]\*?(\d*)/i).each { |match|
        drop = RPG::Enemy::DropItem.new
        i = ['I', 'W', 'A'].index(match[0].upcase)
        drop.kind = i.nil? ? 0 : i + 1
        drop.data_id = match[1].to_i
        drop.denominator = match[3].empty? ? match[2].to_i : match[2].to_f
        num = match[5].empty? ? 1 : match[5].to_i
        num.times do @ma_extra_drops.push([match[4].to_i, drop]) end
      }
    end
    @ma_extra_drops.select {|di| di[0] == 0 || $game_switches[di[0]] }.collect {|di| di[1] }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Max Drops
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_max_drops
    if !@ma_max_drops
      @ma_max_drops = self.note[/\\MAX[ _]DROPS?\[(\d+)\]/i].nil? ? 999 : $1.to_i
    end
    @ma_max_drops
  end
end

#==============================================================================
# ** Game_Enemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - make_drop_items
#    new method - ma_make_extra_drops
#==============================================================================

class Game_Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Make Drop Items
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mlg_dropopt_makedrops_5rx9 make_drop_items
  def make_drop_items(*args, &block)
    # Run Original Method and add the new drops
    mlg_dropopt_makedrops_5rx9(*args, &block) + ma_make_extra_drops
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Make Extra Drops
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_make_extra_drops
    result = []
    enemy.ma_extra_drops.each { |di|
      if di.kind > 0 
        bool = di.denominator.is_a?(Integer) ? (rand * di.denominator < drop_item_rate) : (rand(100) < (di.denominator * drop_item_rate))
        result.push(item_object(di.kind, di.data_id)) if bool
      end
    }
    while result.size > enemy.ma_max_drops
      result.delete_at(rand(result.size))
    end
    result
  end
end

#==============================================================================
# ** Game_Troop
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - setup; gold_total
#==============================================================================

class Game_Troop
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mado_setp_3ra2 setup
  def setup(*args, &block)
    @mado_gold_total = nil # Clear gold total
    mado_setp_3ra2(*args, &block) # Call original method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gold Total
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mado_goldtot_2tg5 gold_total
  def gold_total(*args, &block)
    #  Save first calculation to ensure consistency between amount received and
    # amount reported to the player
    @mado_gold_total = mado_goldtot_2tg5(*args, &block) unless @mado_gold_total
    @mado_gold_total # Return the saved total
  end
end
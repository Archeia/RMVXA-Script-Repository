=begin
#===============================================================================
 Title: Drop-Item Sets
 Author: Hime
 Date: Jul 28, 2014
--------------------------------------------------------------------------------
 ** Change log
 Jul 28, 2014
   - sets are no longer mutually exclusive. All possible items are pooled
     together from all eligible sets.
 Jul 24, 2013
   - added `game party` and `game troop` as variables for drop condition 
 Apr 23, 2013
   - last hit action and battler now store the action and battler upon death
 Apr 22, 2013
   - added support for manually adding drop items to drop item sets
 Apr 21, 2013
   - initial release
--------------------------------------------------------------------------------  
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to set up "drop item sets". A drop item set is simply
 a collection of drop items: at the end of battle, you can potentially receive
 drops from any eligible set.
 
 A drop item set is eligible when its condition has been met.
 The drop item set condition can be anything related to the state of the game
 when the enemy dies, such as the skill that was used to defeat the enemy, or
 certain properties of the battler that defeated the enemy, or the values of
 game variables or switches.
 
 Drop item sets allow you to further control which drops are available for the
 party to obtain after winning a battle.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Start by setting the drop items for the enemy.
 Then create drop item sets. By default, there are no sets, so none of the
 enemies will drop anything.
 
 To create a drop item set, use a note-tag of the format
 
   <drop-item set>
     drops: 1, 2, 3
     priority: 7
     condition: formula
     drop: w1 0.6
     drop: a4 0.23
     drop: i7 1
   </drop-item set>
   
 The drops is a list of drop item ID's, corresponding to each drop in the
 enemy's list of drop items. The editor provides 3 drop items, so the first
 drop is numbered 1. You can repeat the same drop multiple times in the list
 if you want it to be dropped multiple times.
   
 In addition to pulling drop items from a list, you can also manually add drops
 to each group using the `drop` option. The drop option takes an object ID,
 where you choose "w" for weapon, "a" for armor, and "i" for item, followed
 by the database ID. The second value is the droprate, as a percentage. So
 0.6 means 60%, 0.23 means 23%, and 1 means 100%
   
 Priority determines whether the drop set should be checked before other sets.
 For example, a priority 10 set is checked before a priorty 5 set.
 
 The condition is a ruby statement that determines whether the set will be
 chosen or not. When the set is chosen, then those drops are the ones that you
 can potentially receive at the end of battle.
 
 The condition comes with 5 variables for you to use
 
   a - the Game_Battler that defeated this enemy
   b - this enemy
   c - the Game_Action used by the battler in `a`
   p - game party
   t - game troop
   v - game variables
   s - game switches
   
 Because drops, by default, are only rewarded when the enemy has been killed,
 we only need to keep track of who killed the enemy. It's possible that an event
 kills the enemy, in which case `a` would be nil, and your formula will not
 work as you expect (it will return false in these cases, so no errors).
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_DropItemSets"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module DropItem_Sets
    
    Drop_Kinds = { "i" => 1, "w" => 2, "a" => 3 }
    Regex = /<drop[-_ ]item[-_ ]set>(.*?)<\/drop[-_ ]item[-_ ]set>/im
  end
end

class DropItemSet
  
  attr_accessor :drops
  attr_accessor :priority
  attr_accessor :condition
  
  def initialize
    @drops = []
    @priority = 1
    @condition = "true"
  end
end

module RPG
  class Enemy < BaseItem
    
    def drop_items
      @drop_item_set ? @drop_item_set.collect {|set| set.drops }.flatten : []
    end
    
    def drop_item_sets
      return @drop_item_sets unless @drop_item_sets.nil?
      load_notetag_drop_item_sets
      return @drop_item_sets
    end
    
    def load_notetag_drop_item_sets
      @drop_item_sets = []
      res = self.note.scan(TH::DropItem_Sets::Regex)
      res.each do |result|
        data = result[0].strip.split("\r\n")
        dropset = DropItemSet.new
        data.each do |option|
          case option
          when /priority:\s*(\d+)/i
            dropset.priority = $1.to_i
          when /drops:\s*(.*)/i
            dropset.drops.concat($1.strip.split(",").collect {|id| @drop_items[id.to_i - 1] }.compact)
          when /condition:\s*(.*)/i
            dropset.condition = $1
          when /drop:\s*(w|a|i)(\d+) (.*)/i
            di = RPG::Enemy::DropItem.new
            di.kind = TH::DropItem_Sets::Drop_Kinds[$1.downcase] || 0
            di.data_id = $2.to_i
            di.denominator = 1.0 / $3.to_f
            dropset.drops.push(di)
          end
        end
        @drop_item_sets.push(dropset)
      end
      @drop_item_sets.sort_by! {|dropset| dropset.priority}.reverse!
    end
    
    def drop_item_set_id
      @drop_item_set_id
    end
    
    def find_drop_item_set(user, target, action)
      @drop_item_set = drop_item_sets.select {|set|
        eval_drop_item_set(set.condition, user, target, action) 
      }
    end
    
    def eval_drop_item_set(formula, a, b, c, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
      eval(formula) rescue false
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_dropitem_sets_initialize :initialize
  def initialize
    th_dropitem_sets_initialize
    @last_hit_battler = nil
    @last_hit_action = nil
  end
  
  alias :th_dropitem_sets_execute_damage :execute_damage
  def execute_damage(user)
    @last_hit_battler = user
    @last_hit_action = user.current_action
    th_dropitem_sets_execute_damage(user)
  end
  
  alias :th_dropitem_sets_die :die
  def die
    @last_hit_battler = Marshal.load(Marshal.dump(@last_hit_battler))
    @last_hit_action = Marshal.load(Marshal.dump(@last_hit_action))
    th_dropitem_sets_die
  end
end
  
class Game_Enemy < Game_Battler
  
  def find_drop_item_set
    enemy.find_drop_item_set(@last_hit_battler, self, @last_hit_action)
  end
  
  alias :th_dropitem_sets_make_drop_items :make_drop_items
  def make_drop_items
    find_drop_item_set
    th_dropitem_sets_make_drop_items
  end
end
#==============================================================================
#    Item Drop Ranks
#    Version: 1.0.2
#    Author: modern algebra (rmrk.net)
#    Date: 28 September, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    In effect, this script is designed to make it easy to create random drops.
#   Basically, it allows you to give items, weapons, and armors drop ranks, 
#   which are just IDs that you set. Then, you set up other items, called 
#   rank distribution items, which you set to contain a particular rank or 
#   ranks, and when that rank distribution item is given to the party, it 
#   randomly selects an item with that rank and gives that instead.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    As mentioned above, this script essentially works by setting ranks to some
#   items, and then creating dummy items which, when received by the party, 
#   randomly select an item of the rank specified and gives it to the party. 
#
#    To set a rank for an item, just put the following code in the notebox of 
#   the Item, Weapon, or Armor:
#
#      \rank[n]
#        n : a non-negative integer - the rank of this item when distributing
#
#    To create a rank distribution item use the following code in the notebox
#   of the Item, Weapon, or Armor:
#
#      \drop_rank[n]
#        n : a non-negative integer and the rank of items to select from
#
#    You can also set it so that the rank to distribute is actually the value 
#   of a variable, vy simply putting a v right before the n. Then, it will
#   take the value of that variable and distribute the corresponding rank.
#``````````````````````````````````````````````````````````````````````````````
#  EXAMPLE:
#
#    The easiest way to explain this script is through an example. Let's say 
#   you have four items: Potion; High Potion; Antidote; and a Cure All.
#
#    In the notebox of the Potion and High Potion, you put:
#       \rank[1]
#    In the notebox of the High Potion and Cure All, you put:
#       \rank[2]
#
#    Now, let's say the player opens a chest and you want to give him either a
#   Potion or an Antidote, but not both. You can create a new item in the 
#   Database (let's just name it Drop 1), and in its notebox, you put:
#      \drop_rank[1]
#
#    Then, in the chest event, all you need to do give the player Drop 1, and 
#   the player will receive either the potion or the antidote.
#
#    Now, let's pretend it is the same situation, except you want the rank of 
#   the item dropped to be different depending on how far the player is in the
#   game when he or she approaches the chest. In that case, in your Drop 1 
#   notebox, you could put this instead:
#      \drop_rank[v8]
#
#    Then, the rank distributed would depend on the value of Variable 8. So,
#   if the value of Variable 8 is 1 when the player approaches the chest, he or
#   she will receive a Potion or Antidote. If the value of variable 8 is 2, 
#   then the player will receive a High Potion or a Cure All.
#``````````````````````````````````````````````````````````````````````````````
#    Now, there is an additional feature to the script - let's say, instead of
#   the player always receiving a rank 1 item, you want the situation to be 
#   that 80% of the time, the player will receive a rank 1 item, but 20% of the
#   time you want the player to receive a rank 2 item. You can do that by 
#   putting the following code into the notebox of Drop 1:
#
#      \drop_rank[1, 80]
#      \drop_rank[2, 20]
#
#    In other words, you can set it so that a rank distribution item can 
#   potentially drop items of different ranks, and you set the percentage by
#   putting another integer after the rank.
#``````````````````````````````````````````````````````````````````````````````
#  Message Codes:
#
#    One last thing to note is that you can use the following message codes:
#      \ii[x] - Shows the icon of Item x.
#      \ni[x] - Shows the name of Item x.
#      \iw[x] - Shows the icon of Weapon x.
#      \nw[x] - Shows the name of Weapon x.
#      \ia[x] - Shows the icon of Armor x.
#      \na[x] - Shows the name of Armor x.
#
#    When you use those codes on a rank distribution item, then it will show 
#   the name or icon of the last item distributed by it.
#
#    This is useful so that, in the above chest event, if you want to say what
#   the party got, you can put a message directly below it that makes use of
#   these codes and references the rank distribution item. 
#
#    If you are using Yanfly's Victory Aftermath script, then you need to put 
#   Item Drop Ranks below it in the script editor. You will also need to update 
#   your copy of Item Drop Ranks if you are using a version previous to 1.0.2.
#==============================================================================

$imported ||= {}
$imported[:MA_ItemDropRanks] = true

MAIDR_MAX_DATABASE_IWA = 1000

#==============================================================================
# ** RPG::BaseItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - maidr_last_type; maidr_last_id
#    aliased methods - name; icon_index; description
#    new method - maidr_last_item; maidr_drop_rank; maidr_dropping_ranks
#==============================================================================

class RPG::BaseItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :maidr_last_type
  attr_accessor :maidr_last_id
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Last Distributed Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maidr_last_item
    return case maidr_last_type
    when 0 then $data_items[maidr_last_id]
    when 1 then $data_weapons[maidr_last_id]
    when 2 then $data_armors[maidr_last_id]
    else nil
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Drop Rank
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maidr_drop_rank
    self.note[/\\RANK\[(\d+)\]/i].nil? ? -1 : $1.to_i 
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dropping Ranks
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maidr_dropping_ranks
    if !@maidr_dropping_ranks
      @maidr_dropping_ranks = []
      percent_total = 0
      self.note.scan(/\\(DISTRIBUTE|DROP)[ _]RANKS?\[\s*([Vv]?)(\d+)[^\d]*(\d*)\s*\]/i) { |dist, v, rank, perc|
        perc = perc.empty? ? 100 : perc.to_i
        @maidr_dropping_ranks.push([!v.empty?, rank.to_i, perc])
        percent_total += perc
      }
      unless @maidr_dropping_ranks.empty?
        # Make sure percentage adds up to 100.
        variance = 100.0 / percent_total
        @maidr_dropping_ranks.each { |drop| drop[2] = (drop[2].to_f * variance).floor }
        # Alias name, icon_index, and description to give last item
        class << self
          #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # * Name/Icon Index/Description 
          #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          [:name, :icon_index, :description].each { |method_name|
            alias_method(:"maidr_#{method_name}_3hj1", method_name)
            define_method(method_name) { |*args|
              idr = maidr_last_item
              return idr.send(method_name) if idr
              send(:"maidr_#{method_name}_3hj1", *args) # Call Original Method
            }
          }
        end
      end
    end
    @maidr_dropping_ranks
  end
end

#==============================================================================
# *** Data Manager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new constant - MAIDR_MAX_DATABASE_IWA
#    aliased method - self.load_database
#==============================================================================

class << DataManager
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Load Database
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maidr_lddata_3rv6 load_database
  def load_database(*args, &block)
    maidr_lddata_3rv6(*args, &block) # Call Original Method
    # Create a globally accessible hash which holds every item in each rank
    $data_dropranks = {}
    i = 0
    # Go through all Items, Weapons, and Armors
    [$data_items, $data_weapons, $data_armors].each {|data|
      for j in 1...data.size
        next if data[j].nil? || data[j].maidr_drop_rank < 0
        $data_dropranks[data[j].maidr_drop_rank] ||= []
        $data_dropranks[data[j].maidr_drop_rank].push(MAIDR_MAX_DATABASE_IWA*i + j)
      end
      i += 1
    }
    $data_dropranks.default = []
  end
end

#==============================================================================
# ** Game Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - gain_item
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maidr_gainitm_3dk9 gain_item
  def gain_item(item, amount, *args, &block)
    # If not a rank dropping item
    if item.nil? || item.maidr_dropping_ranks.empty? || amount < 1
      maidr_gainitm_3dk9(item, amount, *args, &block) # Call Original Method
    else
      gain_rankdrop_item(item, amount, *args, &block)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Rank Dropping Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def gain_rankdrop_item(item, *args, &block)
    # Select which rank to drop, depending on percentile.
    d = rand(100)
    count = 0
    for i in 0...item.maidr_dropping_ranks.size
      drop = item.maidr_dropping_ranks[i]
      count += drop[2]
      break if d < count
    end
    rank = drop[0] ? $game_variables[drop[1]] : drop[1]
    if $data_dropranks[rank].nil? || $data_dropranks[rank].empty?
      # Accomodate for errors where there are no items of the requested rank
      if !drop[0]
        item.maidr_dropping_ranks.delete(drop) # Delete; no items with rank
        if item.maidr_dropping_ranks.empty?
          p "ERROR: Item Drop Ranks - Rankdrop for #{item.class} #{item.id}: '#{item.maidr_name_3hj1}' fails since no items exist with the rank requested."
          item.maidr_dropping_ranks.push(drop) # Add it back so that this rankdrop item is not received by party next time
        else
          gain_rankdrop_item(item, *args, &block) 
        end
      else
        p "ERROR: Item Drop Ranks - Rankdrop for #{item.class} #{item.id}: '#{item.maidr_name_3hj1}' fails since Variable #{drop[1]}: '#{$data_system.variables[drop[1]]}' is equal to #{rank} and no items with that rank exist."
      end
    else
      # Randomly select an item from the array for that rank
      real_drop = $data_dropranks[rank].sample
      # Set details of drop item to those of the actual item dropped
      item.maidr_last_type = real_drop / MAIDR_MAX_DATABASE_IWA 
      item.maidr_last_id = real_drop % MAIDR_MAX_DATABASE_IWA
      # Get the actual item
      gain_item(item.maidr_last_item, *args, &block) # Potential Recursion error
    end
  end
end

unless $imported[:ATS_SpecialMessageCodes]
  #============================================================================
  # ** Window_Base
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - convert_escape_characters
  #============================================================================
  
  class Window_Base
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Convert Escape Characters
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias maidr_convrteschr_2rj6 convert_escape_characters
    def convert_escape_characters(*args, &block)
      result = maidr_convrteschr_2rj6(*args, &block) # Call  Original Method
      # Add ability to use message codes to retrieve icon and name
      result.gsub!(/\eII\[(\d+)\]/i)  { "\eI\[#{$data_items[$1.to_i].icon_index}\]" rescue "" }
      result.gsub!(/\eIW\[(\d+)\]/i)  { "\eI\[#{$data_weapons[$1.to_i].icon_index}\]" rescue "" }
      result.gsub!(/\eIA\[(\d+)\]/i)  { "\eI\[#{$data_armors[$1.to_i].icon_index}\]" rescue "" }
      result.gsub!(/\eNI\[(\d+)\]/i)  { $data_items[$1.to_i].name rescue "" }
      result.gsub!(/\eNW\[(\d+)\]/i)  { $data_weapons[$1.to_i].name rescue "" }
      result.gsub!(/\eNA\[(\d+)\]/i)  { $data_armors[$1.to_i].name rescue "" }
      result
    end
  end
end

# Compatibility Fix for Yanfly's Victory Aftermath
if $imported["YEA-VictoryAftermath"]
  module BattleManager
    #--------------------------------------------------------------------------
    # overwrite method: self.gain_drop_items
    #--------------------------------------------------------------------------
    def self.gain_drop_items
      drops = []
      $game_troop.make_drop_items.each do |item|
        $game_party.gain_item(item, 1)
        drops.push(item.maidr_dropping_ranks.empty? ? item : item.maidr_last_item)
      end
      SceneManager.scene.show_victory_spoils($game_troop.gold_total, drops)
      set_victory_text(@victory_actor, :drops)
      wait_for_message
    end
  end
end
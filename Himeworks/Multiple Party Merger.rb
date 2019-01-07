=begin
#===============================================================================
 Title: Multiple Party Merger
 Author: Hime
 Date: Feb 12, 2015
--------------------------------------------------------------------------------
 ** Change log
 Feb 12, 2015 
   - changed order of switching and deletion
 Dec 29, 2014
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
 
 This script allows you to merge two parties together. A merge involves 
 transferring all of the members, inventories, and gold from one party to
 another. The original party will be deleted, resulting in one combined party.

--------------------------------------------------------------------------------
 ** Required
 
 Party Manager
 (http://www.himeworks.com/2013/08/party-manager/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Install this script below Party Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Assuming two parties already exist, use the script call
 
    merge_parties(id1, id2)
    
 Where id1 and id2 are the ID's of the parties that you want to merge.
 The second party will be merged into the first.
 
 The first party will be set as the active party, and the second will be
 deleted.
 
--------------------------------------------------------------------------------
 ** Example
 
 To merge party 5 into party 3, use the script call
 
   merge_parties(3, 5)
 
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script assumes that only members, inventory, and gold need to be merged.
 It also assumes the default implementation of party members, inventory, and
 gold are used. If you have scripts that add new properties to parties, you
 may need to add logic to merge those as well.
 
 You can add new logic to the Game_Party#merge method as needed.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_PartyMerger] = 1.00
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Multiple_Party_Merger
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Interpreter
  def merge_parties(id1, id2)
    $game_parties.merge(id1, id2)
  end
end

class Game_Parties
 
  #-----------------------------------------------------------------------------
  # Merges party2 into party1, if both exist
  #-----------------------------------------------------------------------------
  def merge(id1, id2)
    party1 = @data[id1]
    party2 = @data[id2]
    return unless party1 && party2
    party1.merge(party2)
    
    # Delete the second party, as it has been merged
    delete_party(id2)
    
    # Make first party the active party
    switch_party(id1)
  end
end

class Game_Party
  def merge(party2)
    merge_actors(party2)
    merge_inventory(party2)
    merge_gold(party2)
  end
  
  def merge_actors(party2)
    party2.members.each do |mem|  
      add_actor(mem.id)
    end
  end
  
  def merge_inventory(party2)
    party2.items.each {|item| gain_item(item, party2.item_number(item)) }
    party2.weapons.each {|item| gain_item(item, party2.item_number(item)) }
    party2.armors.each {|item| gain_item(item, party2.item_number(item)) }
  end
  
  def merge_gold(party2)
    gain_gold(party2.gold)
  end
end
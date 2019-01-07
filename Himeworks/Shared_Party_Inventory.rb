=begin
#===============================================================================
 Title: Shared Party Inventory
 Author: Hime
 Date: Aug 23, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 23, 2013
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
 
 This script allows you to share your inventory across all parties. This
 includes anything in the inventory (weapons, armors, items) as well as gold.

--------------------------------------------------------------------------------
 ** Required
 
 Party Manager
 (http://himeworks.com/2013/08/19/party-manager/)
 
 Core: Inventory
 (http://himeworks.com/2013/07/27/core-inventory/)
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Party Manager, Core - Inventory, and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Plug and play.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SharedPartyInventory"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Party
  attr_accessor :inventory
  attr_accessor :gold
end

class Game_Parties
  
  alias :th_shared_party_inventory_pre_switch_processing :pre_switch_processing
  def pre_switch_processing(id)
    @data[id].inventory = $game_party.inventory
    @data[id].gold = $game_party.gold
    th_shared_party_inventory_pre_switch_processing(id)
  end
end


=begin
#===============================================================================
 Title: Transform Use Items
 Author: Hime
 Date: Aug 24, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 24, 2013
   - added support for conditions
 Aug 3, 2013
   - added support for multiple transform uses
 Feb 2, 2013
   - Initial release
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
 
 This script allows you to transform one item into another when the item
 is used.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Note-tag items with

   <transform use: ID amount condition>
   
 Where
   `ID` is the ID of the item to add to your inventory
   `amount` is how much will be given
   `condition` is a formula that determines whether it will be added or not
    
 When the item is used, you will lose the item, but then gain the specified
 amount of new items. So for example
 
   <transform use: 12 2>
   
 Will give two of item 12 when the tagged item is used.

 If you want to place conditions on whether the item will be transformed or not,
 you can use a condition
 
   <transform use: 12 5 s[1]>
   
 This will only give item 12 if switch 1 is ON.
 
 The following variables are available for your condition formula:
 
   a - user of the item
   p - current party
   v - game variables
   s - game switches
 
 A single item can have multiple tags, and whenever the item is used, all of
 those new items will be added.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TransformUseItems"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Transform_Use_Items
    Regex = /<transform[-_ ]use:\s*(\d+)\s+(\d+)\s*(.*)>/i
  end
end
#===============================================================================
# ** Rest of the script
#===============================================================================
module RPG
  class Item
    def transform_items
      load_notetag_transform_items if @transform_items.nil?
      return @transform_items
    end
    
    def load_notetag_transform_items
      @transform_items = []
      res = self.note.scan(TH::Transform_Use_Items::Regex)
      res.each do |data|
        transItem = TransformItem.new
        transItem.id = data[0].to_i
        transItem.amount = data[1].to_i
        transItem.condition = data[2]
        @transform_items << transItem
      end
    end
  end  
end

class TransformItem
  
  attr_accessor :id
  attr_accessor :amount
  attr_accessor :condition
  
  def initialize
    @id = 0
    @amount = 0
    @condition = ""
  end
  
  def condition_met?(a, p=$game_party, v=$game_variables, s=$game_switches)
    return true if @condition.empty?
    return eval(@condition)
  end
end


class Game_Battler < Game_BattlerBase
  
  alias :th_transform_use_item_consume_item :consume_item
  def consume_item(item)
    th_transform_use_item_consume_item(item)
    if item.consumable
      item.transform_items.each do |transItem|
        new_item = $data_items[transItem.id]
        $game_party.gain_item(new_item, transItem.amount) if transItem.condition_met?(self)
      end
    end
  end
end
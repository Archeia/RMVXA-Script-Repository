=begin
#===============================================================================
 Title: Gamble Item Shop
 Author: Hime
 Date: May 28, 2013
--------------------------------------------------------------------------------
 ** Change log
 May 28, 2013
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
 
 This script allows you to create a shop that sells "gamble items". Gamble items
 are shop goods where the player has a random chance of obtaining an item from
 a pre-determined set of items.
 --------------------------------------------------------------------------------
 ** Required
 
 Shop Manager
 (http://himeworks.com/2013/02/22/shop-manager/)
 
 Scene Interpreter - to display messages in shop scene
 (http://himeworks.com/2013/03/30/scene-interpreter/)
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Shop Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 -- Setup gamble items --
 
 To setup an item as a gamble item, go to the Items tab in the database
 editor and note-tag an item with a tag of the form
 
   <gamble item>
     i23: 0.5
     w4: 0.2
     a17: 0.4
   </gamble item>
   
 The ID on the left indicates the type of item (item, weapon, armor), and the
 corresponding database ID. The number on the right is the probability of
 obtaining that item, as a weight. So the example note-tag shows that there is
 a relatively higher chance of obtaining item 23 compared to weapon 4.
 
 -- Setup shop --

 In the event, before the "Shop Processing" command, make a script call
 
   @shop_type = "GambleItemShop"
   
 The list of items should be a list of gamble items that have been set up
 appropriately above.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_GambleItemShop"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Gamble_Item_Shop
    
    # Message to display when you buy an item.
    Buy_Message = "Obtained %s"
    
    Regex = /<gamble item>(.*?)<\/gamble item>/im

#===============================================================================
# ** Rest of Script
#===============================================================================
    def gamble_items
      return @gamble_items unless @gamble_items.nil?
      load_notetag_gamble_items
      return @gamble_items
    end
    
    def gamble_item?
      return @is_gamble_item unless @is_gamble_item.nil?
      load_notetag_gamble_items
      return @is_gamble_item
    end
    
    def load_notetag_gamble_items
      @gamble_items = {}
      results = self.note.scan(Regex)
      results.each do |res|
        data = res[0].strip.split("\r\n")
        data.each do |option|
          item, prob = option.split(":")
          type, id = item[0], item[1..-1].to_i
          prob = prob.to_f
          case type
          when "w"
            @gamble_items[$data_weapons[id]] = prob
          when "a"
            @gamble_items[$data_armors[id]] = prob
          when "i"
            @gamble_items[$data_items[id]] = prob.to_f
          end
        end
      end
      @is_gamble_item = !results.empty?
    end
    
    def get_gamble_item
      prob_rand = rand * gamble_items.values.inject(0.0) {|r, val| r += val}
      gamble_items.each do |item, chance|
        prob_rand -= chance
        return item if prob_rand < 0
      end
      gamble_items[0]
    end
  end
end

module RPG
  class Item < UsableItem
    include TH::Gamble_Item_Shop
  end
end

class Game_GambleItemShop < Game_Shop
end

class Window_ShopBuy < Window_Selectable
  
  alias :th_gamble_item_shop_include? :include?
  def include?(shopGood)
    return false unless shopGood.item.is_a?(RPG::Item) && shopGood.item.gamble_item?
    th_gamble_item_shop_include?(shopGood)
  end
end

class Scene_GambleItemShop < Scene_Shop
  
  def do_buy(number)
    number.times do |i|
      $game_party.lose_gold(buying_price)
      item = @item.get_gamble_item
      $game_party.gain_item(item, 1)
      $game_message.add(sprintf(TH::Gamble_Item_Shop::Buy_Message, item.name)) if $imported["TH_SceneInterpreter"]
    end
  end
end
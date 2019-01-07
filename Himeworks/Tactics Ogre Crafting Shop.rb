=begin
#===============================================================================
 Title: Tactics Ogre Crafting Shop
 Author: Hime
 Date: Mar 13, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 13
   - fixed bug where not having recipe book in inventory made it impossible
     to craft in a shop
 Mar 12, 2013
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
 ** Required
 
 Shop Manager
 (http://himeworks.com/2013/02/22/shop-manager/)
 
 Tactics Ogre PSP Crafting system
 (http://mrbubblewand.com/rgss3/tactics-ogre-psp-crafting-system/)
--------------------------------------------------------------------------------
 ** Description
 
 This script provides a shop scene for the Tactics Ogre PSP Crafting
 system.
 
--------------------------------------------------------------------------------
 ** Usage 
 
 Setup crafting recipes and ingredients according to the crafting system
 script.
 
 In an event, set the shop type using a script call

   @shop_type = "TOCraftingShop"
   
 Then create a shop processing command and select the recipes that will
 be available to choose from.

--------------------------------------------------------------------------------
 ** Credits
 
 Mr. Bubble, for the crafting system
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TOCraftingShop"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_TOCraftingShop < Game_Shop
end

class Window_TOCraftingShopRecipeList < Window_TOCraftingRecipeList
  
  def shop_goods=(goods)
    @shop_goods = goods
    refresh
  end
  
  def make_item_list
    @data = []
    @shop_goods.each do |shopGood|
      next unless include?(shopGood.item)
      @data.push(shopGood.item)
    end
  end
end

class Window_TOCraftingShopItemList < Window_TOCraftingItemList
  
  #-----------------------------------------------------------------------------
  # The shop always has it
  #-----------------------------------------------------------------------------
  def has_recipebook?
    return true
  end
end

#-------------------------------------------------------------------------------
# This is the same as Scene_TOCrafting basically
#-------------------------------------------------------------------------------
class Scene_TOCraftingShop < Scene_Shop
  
  alias :th_TOcrafting_shop_prepare :prepare
  def prepare(shop)
    th_TOcrafting_shop_prepare(shop)
    @categories = []
  end
  
  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    Object.const_get("Scene_MenuBase").instance_method(:start).bind(self).call
    create_help_window
    create_gold_window
    create_cover_window
    create_info_window
    create_itemlist_header_window
    create_itemlist_window
    create_recipelist_window
    create_number_window
    create_result_window
  end
  
  #--------------------------------------------------------------------------
  # create_gold_window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_TOCraftingGold.new
    @gold_window.viewport = @viewport
    @gold_window.hide.close
    @gold_window.x = 0
    @gold_window.y = Graphics.height - @gold_window.height
  end
  
  #--------------------------------------------------------------------------
  # create_recipelist_window
  #--------------------------------------------------------------------------
  def create_recipelist_window
    wx = 0
    wy = @help_window.height
    wh = Graphics.height - wy
    @recipelist_window = Window_TOCraftingShopRecipeList.new(wx, wy, wh)
    @recipelist_window.viewport = @viewport
    @recipelist_window.help_window = @help_window
    @recipelist_window.info_window = @info_window
    @recipelist_window.header_window = @itemlist_header_window
    @recipelist_window.cover_window = @cover_window
    @recipelist_window.categories = @categories
    @recipelist_window.set_handler(:ok,     method(:on_recipelist_ok))
    @recipelist_window.set_handler(:cancel, method(:on_recipelist_cancel))
    @recipelist_window.shop_goods = @goods
    @recipelist_window.show.activate.select(0)
    
  end
  
  #--------------------------------------------------------------------------
  # on_recipelist_ok
  #--------------------------------------------------------------------------
  def on_recipelist_ok
    @recipelist_window.close
    @itemlist_window.item = @recipelist_window.item
    @gold_window.show.open if gold_window?
    @cover_window.hide
    @info_window.show
    @info_window.set_page_keys
    activate_itemlist_window
  end
  
  #--------------------------------------------------------------------------
  # on_recipelist_cancel
  #--------------------------------------------------------------------------
  def on_recipelist_cancel
    refresh
    return_scene
  end
  
  #--------------------------------------------------------------------------
  # activate_recipelist_window
  #--------------------------------------------------------------------------
  def activate_recipelist_window
    refresh
    @recipelist_window.show.open.activate
  end
  
  #--------------------------------------------------------------------------
  # create_itemlist_window
  #--------------------------------------------------------------------------
  def create_itemlist_window
    wx = 0
    wy = @help_window.height + @itemlist_header_window.height
    wh = Graphics.height - wy
    wh = wh - @gold_window.height if gold_window?
    @itemlist_window = Window_TOCraftingShopItemList.new(wx, wy, wh)
    @itemlist_window.viewport = @viewport
    @itemlist_window.help_window = @help_window
    @itemlist_window.info_window = @info_window
    @itemlist_window.gold_window = @gold_window
    @itemlist_window.hide
    @itemlist_window.close
    @itemlist_window.set_handler(:ok,     method(:on_itemlist_ok))
    @itemlist_window.set_handler(:cancel, method(:on_itemlist_cancel))
    @itemlist_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # on_itemlist_ok
  #--------------------------------------------------------------------------
  def on_itemlist_ok
    @item = @itemlist_window.item
    @itemlist_window.close.hide
    @number_window.set(@item, max_craft, crafting_fee)
    @info_window.page_change = false
    @info_window.set_page_keys
    @number_window.show.open.activate
  end
  
  #--------------------------------------------------------------------------
  # on_itemlist_cancel
  #--------------------------------------------------------------------------
  def on_itemlist_cancel
    @itemlist_window.close
    @itemlist_header_window.close
    @gold_window.close.hide if gold_window?
    @info_window.hide
    @cover_window.show
    activate_recipelist_window
  end
  
  #--------------------------------------------------------------------------
  # activate_itemlist_window
  #--------------------------------------------------------------------------
  def activate_itemlist_window
    refresh
    @itemlist_header_window.show.open
    @itemlist_window.show.open.activate.select(0)
  end
  
  #--------------------------------------------------------------------------
  # create_number_window
  #--------------------------------------------------------------------------
  def create_number_window
    wx = 0
    wy = @itemlist_header_window.y + @itemlist_header_window.height
    wh = Graphics.height - wy
    wh = wh - @gold_window.height if gold_window?
    @number_window = Window_TOCraftingNumber.new(wx, wy, wh)
    @number_window.viewport = @viewport
    @number_window.info_window = @info_window
    @number_window.gold_window = @gold_window
    @number_window.hide.close
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
  
  #--------------------------------------------------------------------------
  # on_number_ok
  #--------------------------------------------------------------------------
  def on_number_ok
    @number_window.close.hide
    @number_window.number
    do_crafting(@item, @number_window.number)
    @result_window.set(@item, @number_window.number)
    @result_window.show.open.activate
    @itemlist_window.show.open
    @info_window.page_change = true
    
    @gold_window.number = @info_window.number = 1
    refresh
    @result_window.show.open.activate
  end
  
  #--------------------------------------------------------------------------
  # on_number_cancel
  #--------------------------------------------------------------------------
  def on_number_cancel
    @number_window.close.hide
    @gold_window.number = @info_window.number = 1
    @info_window.page_change = true
    @itemlist_window.show.open.activate
  end

  #--------------------------------------------------------------------------
  # create_result_window
  #--------------------------------------------------------------------------
  def create_result_window
    wx = Graphics.width / 4
    wy = 0
    @result_window = Window_TOCraftingResult.new(wx, wy)
    @result_window.y = (Graphics.height / 2) - (@result_window.height / 2)
    @result_window.viewport = @viewport
    @result_window.hide.close
    @result_window.set_handler(:ok,     method(:on_result_ok))
    @result_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # on_result_ok
  #--------------------------------------------------------------------------
  def on_result_ok
    @result_window.close.hide
    @itemlist_window.activate
  end
  
  #--------------------------------------------------------------------------
  # create_itemlist_header_window
  #--------------------------------------------------------------------------
  def create_itemlist_header_window
    wx = 0
    wy = @help_window.height
    @itemlist_header_window = Window_TOCraftingItemListHeader.new(wx, wy)
    @itemlist_header_window.viewport = @viewport
    @itemlist_header_window.hide
    @itemlist_header_window.close
    @itemlist_header_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # create_cover_window
  #--------------------------------------------------------------------------
  def create_cover_window
    wx = Graphics.width / 2
    wy = @help_window.height
    wh = Graphics.height - @help_window.height
    ww = Graphics.width - wx
    @cover_window = Window_TOCraftingCover.new(wx, wy, ww, wh)
    @cover_window.viewport = @viewport
    @cover_window.refresh
    @cover_window.show
  end
  
  #--------------------------------------------------------------------------
  # create_info_window
  #--------------------------------------------------------------------------
  def create_info_window
    wx = Graphics.width / 2
    wy = @help_window.height
    ww = Graphics.width - wx
    wh = Graphics.height - @help_window.height
    @info_window = Window_TOCraftingInfo.new(wx, wy, ww, wh)
    @info_window.viewport = @viewport
    @info_window.hide
    @info_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @info_window.refresh
    @help_window.refresh
    @itemlist_window.refresh
    @recipelist_window.refresh
    @result_window.refresh
    @itemlist_header_window.refresh
    @gold_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # do_crafting
  #--------------------------------------------------------------------------
  def do_crafting(item, number)
    return unless item
    play_crafting_se(item)
    lose_ingredients(item, number)
    pay_crafting_fee(item, number)
    gain_crafted_item(item, number)
  end
  
  #--------------------------------------------------------------------------
  # play_crafting_se
  #--------------------------------------------------------------------------
  def play_crafting_se(item)
    if item.tocrafting_se.empty?
      Sound.play_tocrafting_result
    else
      se = item.tocrafting_se
      Sound.play_custom_tocrafting_result(se[0], se[1], se[2])
    end
  end
  
  #--------------------------------------------------------------------------
  # lose_ingredients
  #--------------------------------------------------------------------------
  def lose_ingredients(item, number)
    item.ingredient_list.each do |ingredient|
      $game_party.lose_item(ingredient, number)
    end
  end
  
  #--------------------------------------------------------------------------
  # pay_crafting_fee
  #--------------------------------------------------------------------------
  def pay_crafting_fee(item, number)
    $game_party.lose_gold(item.tocrafting_gold_fee * number)
  end
  
  #--------------------------------------------------------------------------
  # gain_crafted_item
  #--------------------------------------------------------------------------
  def gain_crafted_item(item, number)
    $game_party.gain_item(item, number)
  end
  
  #--------------------------------------------------------------------------
  # crafting_fee
  #--------------------------------------------------------------------------
  def crafting_fee
    @item.tocrafting_gold_fee
  end
  
  #--------------------------------------------------------------------------
  # gold_window?
  #--------------------------------------------------------------------------
  def gold_window?
    Bubs::TOCrafting::USE_GOLD_WINDOW
  end

  #--------------------------------------------------------------------------
  # party_gold
  #--------------------------------------------------------------------------
  def party_gold
    $game_party.gold
  end
  
  #--------------------------------------------------------------------------
  # max_craft
  #--------------------------------------------------------------------------
  def max_craft
    max = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    max = crafting_fee == 0 ? max : [max, party_gold / crafting_fee].min
    for ingredient in @item.ingredient_list.uniq.each
      break if max == 0
      count = @item.ingredient_list.count(ingredient)
      temp_max = 0
      for i in 1..max
        break if (i * count) > $game_party.item_number(ingredient)
        temp_max += 1
      end # for
      max = temp_max if max > temp_max
    end # for
    return max
  end
end
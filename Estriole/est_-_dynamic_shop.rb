=begin

 ** EST - DYNAMIC SHOP v1.3
  
 author : estriole 
 
 requested by Adon from rpgmakerweb.com
 extra credits:
 Nate McCloud for pointing bugs in v 1.2
 
 licences:
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
 
 version history
 v 1.0 - 2013.01.04 => finish the script
 v 1.1 - 2013.01.05 => add sell add goods to shop feature. (can be based on category)
 v 1.2 - 2013.01.05 => add notetags for custom item/wep/armor category (to use to shop sell add goods feature)
 v 1.3 - 2014.05.28 => rewritten part of the script. change the logic to make sure no duplicated items.
                       also compacting the method, and changing the shop from $game_temp to $game_system
                       so it can carry on save files. also create game_interpreter method
                       to shorten the script calls.
 
 introduction:
 this script can make dynamic shop. what is dynamic shop?
 it's shop that the item can be added freely. example usage:
 suikoden game:
 you have armor shop in your castle. then after visiting certain town armor shop...
 your armor shop will sell all armor that town armor shop sell too.
 from v1.1 above... ds games- master of monster lair:
 when you sell weapon/armor in weapon shop. you'll able to buy it in buy list. 
 
 v1.1 : added feature to create shop that will add what party sold to buy list.
        can also set the type that will be added (ex: only item, only weapon, only armor)
 v1.2 : added feature for custom type (category) by adding notetags to item/weapon/armor

 feature:
 - multiple "dynamic" shop. you can name them
 - add and remove goods to dynamic shop freely
 - can set the shop to behave this way. when the item sold. it will add item
   to buy list. can also set to only add certain category ("ALL","Item","Weapon","Armor")
   and also can set to use custom category assigned in notetags
 
 how to use:
 ===============================================================================
 1)to call dynamic shop. use script call:
 
 d_shop(shop_name,purchase_only,sell_add_goods_type)
 
 shop_name[required] => the name you assign for that dynamic shop
 purchase only => set this to true if you want the shop to cannot sell item
                  default set to false
 sell_add_goods_type => "All" => will add all item/weapon/armor sold to buy list
                        "Item" => will add only item sold to buy list
                        "Weapon" => will add only weapon sold to buy list
                        "Armor" => will add only armor sold to buy list
                        not case sensitive. if left nil/blank it will not add 
                        anything to buy list
                        
                        you could also create your custom category
                        by adding notetags to item/weapon/armor. example in item1
                        we add notetags:
                        <shop_cat: potion>
                        notetags not needed to case sensitive with category.
                        then when we set sell_add_goods_type to "Potion" then
                        when we sell item1. it will add it to buy list. other item don't
                        
                        and of course we have reserved word not to use:
                        all, item, weapon, armor, none
                        
 some example usage:
 -) since only shop_name is required you can skip the other
 d_shop("Castle Ugly Shop")
 will call "Castle Ugly Shop" and party can sell items. 
 if "Castle Ugly Shop" not exist then it will call empty shop (sell only)
 
 -) can set the sold item to added to buy list
 d_shop("Castle Ugly Shop",false,"ALL")
 will call "Castle Ugly Shop" and party can sell items. 
 if "Castle Ugly Shop" not exist then it will call empty shop (sell only)
 then every item/weapon/armor sold will added to buy list.

 -) can set to add only "item" sold to added to buy list. weapon and armor not
 d_shop("Castle Ugly Shop",false,"Item")
 will call "Castle Ugly Shop" and party can sell items. 
 if "Castle Ugly Shop" not exist then it will call empty shop (sell only)
 then every item (only) sold will added to buy list. weapon and armor will be ignored
 
 -) can use custom category you defined in notetags.
 d_shop("Castle Ugly Shop",false,"Sword")
 will call "Castle Ugly Shop" and party can sell items. 
 if "Castle Ugly Shop" not exist then it will call empty shop (sell only)
 then every item/weapon/armor that have notetags <shop_cat: sword> 
 sold will added to buy list.
   
 ===============================================================================
 
 2)to add goods to your dynamic shop.
 
 use this script call:

 d_shop_add_goods(shop_name,goods,price)

 shop_name[required] => the name you assign for the dynamic shop. if the name haven't been assigned it will create new one
 goods [required] => item you want to add for example $data_items[1], $data_weapons[1], $data_armors[1], etc.
 price => if you want to set the price. if blank it will use default price set in database

 example usage:
 d_shop_add_goods("Goldsmith",$data_weapons[10],1000)
 will add to "Goldsmith" shop. weapon id 10 in database. with the price 1000.
 
 ===============================================================================
 
 3) to remove goods for you dynamic shop.
 
 use this script call:
 
 d_shop_rem_goods(shop_name,goods)
 
 shop_name[required] => the name you assign for the dynamic shop. if the name haven't been assigned it will create new one
 goods [required] => item you want to remove for example $data_items[1], $data_weapons[1], $data_armors[1], etc.

 example usage:
 d_shop_rem_goods("Goldsmith",$data_weapons[10])
 will remove weapon id 10 in database from "Goldsmith" shop.
 
 ===============================================================================
 
 4) profit $$$
 
 ===============================================================================
 
 i also set that whenever you add item/weapon/armor to certain dynamic shop.
 it will search for that shop goods. if it contain same item/weapon/armor it will
 be overwritten. so if you first add item1 for 100 gold. shop will sell it for 100 gold
 later you add item1 for 10 gold. then the price will be changed to 10 gold.

 Author Note
 none
 
=end

class Game_System
  attr_accessor :dynamic_shop
  alias est_dynamic_shop_game_temp_init initialize
  def initialize
    est_dynamic_shop_game_temp_init
    @dynamic_shop = {}
  end
end

class Game_Interpreter
  def d_shop(shop_name,purchase_only = false, sell_add_goods_type = nil)
    ESTRIOLE.call_special_shop(shop_name,purchase_only, sell_add_goods_type)
  end
  def d_shop_add_goods(shop_name,goods,price=nil)
    ESTRIOLE.shop_add_goods(shop_name,goods,price)
  end
  def d_shop_rem_goods(shop_name,goods)
    ESTRIOLE.shop_rem_goods(shop_name,goods)
  end
  def d_shop_reset_all
    ESTRIOLE.shop_reset_all
  end
  def d_shop_reset(shop_name)
    ESTRIOLE.shop_reset(shop_name)
  end
end

module ESTRIOLE
  def self.call_special_shop(shop_name,purchase_only = false, sell_add_goods_type = nil)
    goods = $game_system.dynamic_shop[shop_name]
    goods = [] if !goods
    SceneManager.call(Scene_Shop)
    SceneManager.scene.prepare(goods, purchase_only)
    SceneManager.scene.sell_add_new_goods(shop_name,sell_add_goods_type) if sell_add_goods_type
  end

  def self.shop_add_goods(shop_name,goods,price=nil)
    id = goods.id
    type = 0 if goods.is_a?(RPG::Item)
    type = 1 if goods.is_a?(RPG::Weapon)
    type = 2 if goods.is_a?(RPG::Armor)
    
    use_def_price = price.nil?? 0 : 1
    specify_price = price.nil?? 0 : price
    flag = false
    
    array = [type,id,use_def_price,specify_price,flag]
    
    $game_system.dynamic_shop[shop_name] = [] if !$game_system.dynamic_shop[shop_name]
    old_goods = false
    
      $game_system.dynamic_shop[shop_name].each do |item|
      item = array if item[0] == type && item[1] == id
      old_goods = true if item[0] == type && item[1] == id
      end
    return if @old_goods
    $game_system.dynamic_shop[shop_name].push(array) if !chk = old_goods rescue false
  end
    
  def self.shop_rem_goods(shop_name,goods)
    id = goods.id
    type = 0 if goods.is_a?(RPG::Item)
    type = 1 if goods.is_a?(RPG::Weapon)
    type = 2 if goods.is_a?(RPG::Armor)
    $game_system.dynamic_shop[shop_name] = [] if !$game_system.dynamic_shop[shop_name]
      $game_system.dynamic_shop[shop_name].each do |item|
      $game_system.dynamic_shop[shop_name].delete(item) if item[0] == type && item[1] == id
      end
  end
      
  def self.shop_reset_all
  $game_system.dynamic_shop={}
  end

  def self.shop_reset(shop_name)
  $game_system.dynamic_shop[shop_name]=[]
  end  
end

class Window_ShopBuy < Window_Selectable
  def data_list;return @data;end
  def add_new_goods(goods)
    id = goods.id
    type = 0 if goods.is_a?(RPG::Item)
    type = 1 if goods.is_a?(RPG::Weapon)
    type = 2 if goods.is_a?(RPG::Armor)
    array = [type,goods.id,0,0,false]
    old_goods = false
    @shop_goods.each do |item|
      item = array if item[0] == type && item[1] == id
      old_goods = true if item[0] == type && item[1] == id      
    end
    return if @old_goods
    @shop_goods.push(array)
  end
end

class Scene_Shop < Scene_MenuBase
  def sell_add_new_goods(shop_name,category = "None")
    @sell_add_new_goods = shop_name
    @shop_dynamic_category = category
  end
  
  alias est_dynamic_shop_do_sell do_sell
  def do_sell(number)
    est_dynamic_shop_do_sell(number)
    return if !@sell_add_new_goods
    case @shop_dynamic_category.upcase
    when "ALL"
      ESTRIOLE.shop_add_goods(@sell_add_new_goods,@item)
      add_new_item = true
    when "ITEM"
      ESTRIOLE.shop_add_goods(@sell_add_new_goods,@item) if @item.is_a?(RPG::Item)
      add_new_item = true if @item.is_a?(RPG::Item)
    when "WEAPON"
      ESTRIOLE.shop_add_goods(@sell_add_new_goods,@item) if @item.is_a?(RPG::Weapon)
      add_new_item = true if @item.is_a?(RPG::Weapon)
    when "ARMOR"
      ESTRIOLE.shop_add_goods(@sell_add_new_goods,@item) if @item.is_a?(RPG::Armor)
      add_new_item = true if @item.is_a?(RPG::Armor)
    else 
      ESTRIOLE.shop_add_goods(@sell_add_new_goods,@item) if @shop_dynamic_category.upcase == @item.shop_category
      add_new_item = true if @shop_dynamic_category.upcase == @item.shop_category
    end
    
    @buy_window.add_new_goods(@item) if !@buy_window.data_list.include?(@item) && add_new_item
    @buy_window.refresh
  end
end

class RPG::BaseItem
  def shop_category
    if @shop_category.nil?
      if @note =~ /<shop_cat: (.*)>/i
        @shop_category = $1.to_s.upcase
      else
        @shop_category = nil
      end
    end
    @shop_category
  end  
end
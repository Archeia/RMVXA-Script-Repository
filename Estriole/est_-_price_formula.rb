=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - PRICE FORMULA
 by Estriole
 v.1.1
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.10.13     >     Initial Release
 v1.1 2013.10.24     >     Add shop sell formula feature so you can custom each shop how
                           much the shop will pay for the item (ex: 10x original price, etc)
                           
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
   This script make us able to create formula for item / equip price. for example
 item like seltzer from star ocean where it become more expensive as the game time
 increases
 
 ■ Requirement     ╒═════════════════════════════════════════════════════════╛
   Just RPG MAKER VX ACE program :D

 ■ How to Use     ╒═════════════════════════════════════════════════════════╛
 1) to set buying price formula (affect selling too but divided by two if you
 don't set the shop sell formula)
 put this notetags to your item/armor/weapon:
 <price_formula>
 your price formula here
 </price_formula>
 the formula need to be valid ruby that return number.
 there's also a shortcut variable that i set for you:
      s = $game_switches
      v = $game_variables
      p = $game_party
      a = $game_actors
      gs = $game_system
      pt = $game_system.playtime
      bc = $game_system.battle_count
      sc = $game_system.save_count
      i = the item itself (for checking type or id)
      @price = default price in database
 so if you want to make item real price is 100 but become 1000000 if switch 99 is on
 <price_formula>
 s[99] ? 1000000 : 100
 </price_formula>
 or if you confuse on above technique
 <price_formula>
 if s[99] == true
   1000000
 else
   100
 end
 </price_formula>  

 2) new feature *** shop sell formula ***
 with this feature you can custom each shop sell formula. 
 ex: trading shop pay full price of the item
 while normal shop pay only 10% of the price value.
 there's two way to use the feature. 
 a) direct usage... script call BEFORE calling a shop:
 
 @a = "your formula in string here"
 $game_temp.sell_formula = @a
 
 formula is ruby command that return number. there's some variable help too for this:
    s = $game_switches
    v = $game_variables
    p = $game_party
    a = $game_actors
    gs = $game_system
    pt = $game_system.playtime
    bc = $game_system.battle_count
    sc = $game_system.save_count
    i = @item (used to check the kind of item or item id perhaps. ex: weapon shop pay less for armor and potion)
    price = item price affected by formula you set in number 1 above
    o_price = item original price set in database
 after the shop scene closed it will reset the shop formula (using default sell formula).
 so if you want to call normal shop just don't use the script call above.
 
 some example usage: Script call:
 @a = "
 case p.leader.name
 when 'Estriole'
   price
 when 'Tsukihime'
   price / sc
 when 'Victor'   
   o_price
 else
   o_price / 10
 end "
 then script call again:
 $game_temp.sell_formula = @a
 
 (i use @ so it can pass on to next script call. but you might want to use
 Tsukihime large script call script too if your formula is really long)
 
 above formula means. if party leader name is 'Estriole' then the selling formula is
 price that affected by formula you set in notetags
 if party leader name is 'Tsukihime' then the selling formula is
 price that affected by formula you set in notetags divided by save count
 if party leader name is 'Victor' then the selling formula is
 original price you set in database  
 other than that then the selling formula is
 original price you set in database divided by 10
 
 WARNING: the formula is in string so you might need to use ' if you want to
 compare with string.
 
 b) pre-write formula in this script first and reference it in script call
 write your shop type and formula in the S_F hash below.
 and later script call BEFORE calling your shop:
 $game_temp.sell_formula = S_F[yourhashkey]
 
=end


module ESTRIOLE
  module PRICE_FORMULA
    # assign switch to activate the formula price. if that switch off then use default price
    ACTIVATE_SWITCH = 10   # change to 0 to always activate
    # start condition of the switch above. true means it will on at start of the game.
    START_SWITCH = true
  end
  module SELL_FORMULA
    S_F = {
    "trade" => "price",
    "normal" => "o_price / 2",
    "rich man" => "price * 2",
    }
  end
end

class Game_Interpreter
  include ESTRIOLE::SELL_FORMULA
end

class Game_Switches
  include ESTRIOLE::PRICE_FORMULA
  alias est_price_formula_switch_initialize initialize
  def initialize
    est_price_formula_switch_initialize
    @data[ACTIVATE_SWITCH] = START_SWITCH if ACTIVATE_SWITCH != 0
  end
end

class Game_Temp
  def sell_formula
    @sell_formula
  end
  def sell_formula=(formula = nil)
    return if @sell_formula == formula
    @sell_formula = formula
  end
end

class Scene_Shop < Scene_MenuBase
  alias est_sell_formula_sell_price selling_price
  def selling_price
    s = $game_switches
    v = $game_variables
    p = $game_party
    a = $game_actors
    gs = $game_system
    pt = $game_system.playtime
    bc = $game_system.battle_count
    sc = $game_system.save_count
    i = @item
    price = @item.price
    o_price = @item.orig_price
    return eval($game_temp.sell_formula) if $game_temp.sell_formula
    est_sell_formula_sell_price
  end
  alias est_sell_formula_terminate terminate
  def terminate
    $game_temp.sell_formula = nil
    est_sell_formula_terminate
  end
end

class RPG::EquipItem < RPG::BaseItem
  include ESTRIOLE::PRICE_FORMULA
    def price
      return @price if ACTIVATE_SWITCH != 0 && !$game_switches[ACTIVATE_SWITCH]
      return @price rescue 0 if !note[/<price_formula?>(?:[^<]|<[^\/])*<\/price_formula?>/i]
      grab = note[/<price_formula?>(?:[^<]|<[^\/])*<\/price_formula?>/i].scan(/(?:!<price_formula?>|(.*)\r)/)
      grab.delete_at(0)    
      noteargs = grab.join("\r\n")    
      s = $game_switches
      v = $game_variables
      p = $game_party
      a = $game_actors
      gs = $game_system
      pt = $game_system.playtime
      bc = $game_system.battle_count
      sc = $game_system.save_count
      i = self
      return price = eval(noteargs) rescue @price rescue 0
    end
    def orig_price
      @price
    end
end
class RPG::Item < RPG::UsableItem
 include ESTRIOLE::PRICE_FORMULA
    def price
      return @price if ACTIVATE_SWITCH != 0 && !$game_switches[ACTIVATE_SWITCH]
      return @price rescue 0 if !note[/<price_formula?>(?:[^<]|<[^\/])*<\/price_formula?>/i]
      grab = note[/<price_formula?>(?:[^<]|<[^\/])*<\/price_formula?>/i].scan(/(?:!<price_formula?>|(.*)\r)/)
      grab.delete_at(0)    
      noteargs = grab.join("\r\n")    
      s = $game_switches
      v = $game_variables
      p = $game_party
      a = $game_actors
      gs = $game_system
      pt = $game_system.playtime
      bc = $game_system.battle_count
      sc = $game_system.save_count
      i = self
      return price = eval(noteargs) rescue @price rescue 0
    end
    def orig_price
      @price
    end
end
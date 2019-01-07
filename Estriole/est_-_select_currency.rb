=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - SELECT_CURRENCY v1.3
 by Estriole
 
 ■ License          ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE). 
  
 ■ Support          ╒═════════════════════════════════════════════════════════╛
 While I'm flattered and I'm glad that people have been sharing and asking
 support for scripts in other RPG Maker communities, I would like to ask that
 you please avoid posting my scripts outside of where I frequent because it
 would make finding support and fixing bugs difficult for both of you and me.
   
 If you're ever looking for support, I can be reached at the following:
 ╔═════════════════════════════════════════════╗
 ║       http://www.rpgmakervxace.net/         ║
 ╚═════════════════════════════════════════════╝
 pm me : Estriole.
 
 ■ Requirement     ╒═════════════════════════════════════════════════════════╛
 Mandatory : EST - CONSTANT CHANGER
 http://pastebin.com/H0UjHukK
 
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
 This script make you able to choose active currency. you can set anything
 like variables and any other variable that have writer method (can be + or - or =)
 useful for scenario where you have multiple countries. and when entering country A.
 any money gained there will add to variable 1 (we can call it Dollar). any money 
 spent will substract from variable 1...
 
 another usage maybe for guild system. where we can purchase item using guild points
 or city system where we purchase using city treasury.
 
 this script also make us can change the vocab for the buy, sell, cancel command.
 so we can custom the shop a little. for better customization of the shop including
 command, behavior when buying, etc. you might need another custom shop script.
 
 ■ Features         ╒═════════════════════════════════════════════════════════╛
 - select your active currency
 - purchase item using active currency
 - active currency can be anything that have writer method
 - gold gain will add to active currency IF active currency set
 - gold lost will substract from active currency IF active currency set
 - minor compatibility for yanfly jp manager (only able to select one actor and one class)
   you can try mixing it with eventing if you want something complex.
 - able to mod shop command vocab for different shop 'feel'
 - compatibility with most shop script (for vocab change feature)
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.10.27           Initial Release
 v1.1 2013.11.19           Updated the script with cleaner vocabulary changing.
                           now more compatible with custom shop script. :D
 v1.2 2013.11.19           some typo causing error and reseting currency not working
 v1.3 2013.11.20           change the vocab changing method again since previous
                           one don't work on saved files.
                           NOW this script REQUIRE EST - CONSTANT CHANGER script
                           http://pastebin.com/H0UjHukK
                     
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 should be compatible with most script now...
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 0) some basic knowledge... ALL thing that store NUMBER and have WRITER method
 can be used as active currency. if you're curious what is WRITER method.
 means you can write code: yourvariablename += 10 and not throw error.
 
 all Array element already have writer method. so $game_variables[10] can be used
 as active currency. because we can script call $game_variables[10] += 10 and not
 throw error.
 
 so basically ALL $game_variables member can be used as your active currency.
 
 yanfly JP Manager script store jp in $game_actors[actor_id] array @jp[class_id] 
 so i add compatibility patch so you can use:
 $game_actors[1].jp[1] to use actor 1 class 1 jp
 
 1) to set active currency. script call:
 
 active_currency("your currency ruby code in string")
 
 ex:
 active_currency("$game_variables[1]")
 will use variable 1 as active currency.
 
 active_currency("$game_actors[1].jp[1]") 
 will use actor 1 class 1 jp as active currency
 
 after you set active currency. any ADDITION / REDUCTION to gold will add to 
 active currency instead. this including:
 > buy or sell goods at shop
 > get money from battle
 > get money from event
 
 2) to back using plain old gold. just script call anytime:
 
 reset_currency
 
 it will also reset the vocab changes
 
 
 3) to change the shop vocab for different 'feel'. script call:
 
 currency_unit("String")
 buy_vocab("String")
 sell_vocab("String")
 cancel_vocab("String")
 possession_vocab("String")
 
 ex:
 currency_unit("Soul")
 buy_vocab("Create")
 sell_vocab("Convert")
 cancel_vocab("End Sermon")
 possession_vocab("Owned")
 will change currency unit to Soul, buy vocab to Create, sell vocab to Convert,
 cancel vocab to End Sermon, and possession vocab to Owned
 
 4) ** profit **
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 
=end

module ESTRIOLE
  module SELECT_CURRENCY
  ESTRIOLE_SCRIPTS_ARE_AWESOME = true
  # LOL just kidding.
  end
end

#game interpreter method for shorter call
class Game_Interpreter
  def active_currency(cur)
    $game_party.active_currency = cur
  end
  def currency_unit(unit)
    $game_party.currency_unit = unit
  end
  def buy_vocab(str)
    est_change_vocab("ShopBuy", str)
  end
  def sell_vocab(str)
    est_change_vocab("ShopSell", str)
  end
  def cancel_vocab(str)
    est_change_vocab("ShopCancel", str)
  end
  def possession_vocab(str)
    est_change_vocab("Possession", str)
  end
  def reset_buy_vocab
    est_reset_vocab("ShopBuy")
  end
  def reset_sell_vocab
    est_reset_vocab("ShopSell")
  end
  def reset_cancel_vocab
    est_reset_vocab("ShopCancel")
  end
  def reset_possession_vocab
    est_reset_vocab("Possession")
  end
  def reset_currency
    $game_party.active_currency = nil
    $game_party.currency_unit = nil
    reset_buy_vocab
    reset_sell_vocab
    reset_cancel_vocab
    reset_possession_vocab
  end
end

class Game_Party < Game_Unit
  #attr_reader active currency variable
  def active_currency
    @active_currency
  end
  #attr_write active currency variable
  def active_currency=(cur)
    return if @active_currency == cur
    @active_currency = cur
  end
  #alias method gold so it can use active currency if exist
  alias est_select_currency_gold gold
  def gold
    return eval(active_currency) if active_currency
    est_select_currency_gold
  end
  #alias method attr_writer gold to use active currency instead
  def gold=(gold)
    return eval("#{active_currency} = #{gold}") if active_currency
    @gold = gold
  end
  #alias method gold gain to add to active currency instead
  alias est_select_currency_gain_gold gain_gold
  def gain_gold(amount)
    return eval("#{active_currency} = [[#{active_currency} + amount, 0].max, max_gold].min")if active_currency
    est_select_currency_gain_gold(amount)
  end

  #attr_reader and writer for the currency unit vocab
  def currency_unit
    @currency_unit
  end
  def currency_unit=(unit)
    return if @currency_unit == unit
    @currency_unit = unit
  end
end

module Vocab
  class << self
    alias est_select_currency_currency_unit currency_unit
  end
  #alias method currency unit to return active currency unit instead
  def self.currency_unit
    return $game_party.currency_unit if $game_party.currency_unit
    est_select_currency_currency_unit
  end
end

#yanfly jp system compatibility
class Game_Actor < Game_Battler
  alias est_select_currency_jp jp
  def jp(class_id = nil)
    return @jp if !class_id
    est_select_currency_jp(class_id)
  end
end
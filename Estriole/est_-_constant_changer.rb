=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - CONSTANT CHANGER v1.0
 by Estriole
 
 ■ License          ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE). 
 
 ■ Extra Credits    ╒═════════════════════════════════════════════════════════╛
 if you're using this script you also must credit these person:
 - TheoAllen / Theodoric
 
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
 RPG Maker VX Ace
 
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
 by default constant is hard to change. this script make us able to change
 the constant without throwing dynamic constant assignment.
 
 ■ Features         ╒═════════════════════════════════════════════════════════╛
 - change constant in any module
 - premade command to change constant vocab module
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.11.20           Initial Release
                     
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 should be compatible with most script...

 ■ How to use     ╒═════════════════════════════════════════════════════════╛
  1) changing vocab constant  
  script call:
  a = "CONSTANTNAME"
  b = "VALUE"
  est_change_vocab(a,b)

  ex:

  a = "ShopBuy"
  b = "Purchase"
  est_change_vocab(a,b)

  will change module Vocab constant ShopBuy value to "Purchase"

  2) reseting vocab constant
  script call:
  a = "CONSTANTNAME"
  est_reset_vocab(a)

  ex:

  a = "ShopBuy"
  est_reset_vocab(a)

  will reset module Vocab constant ShopBuy value to what yu define in script editor.

  3) reseting ALL vocab constant
  script call:
  est_reset_all_vocab

  will reset all constants in module Vocab

  X1) changing CONSTANT in ANY MODULE / CLASS
  script call:
  a = "MODULENAME/CLASSNAME"
  b = "CONSTANTNAME"
  c = "VALUE"
  est_change_const(a,b,c)

  value can also integer / array
  example

  a = "Vocab"
  b = "ShopBuy"
  c = "Purchase"
  est_change_const(a,b,c)
  will change module Vocab constant ShopBuy value to "Purchase"

  X2) resetting CONSTANT in ANY MODULE / CLASS
  script call:
  a = "MODULENAME/CLASSNAME"
  b = "CONSTANTNAME"
  est_reset_const(a,b)

  ex:

  a = "Vocab"
  b = "ShopBuy"
  est_reset_const(a,b)
  will reset module Vocab constant ShopBuy value to default value

  X3) resetting ALL CONSTANT in ANY MODULE / CLASS
  script call:
  a = "MODULENAME/CLASSNAME"
  est_reset_all_const(a)

  ex:
  a = "Vocab"
  est_reset_all_const(a)

  will reset all constants in module Vocab

 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 None
  
=end
class Game_System
 def default_constant
   @default_constant = {} if !@default_constant
   @default_constant
 end
 def used_constant
   @used_constant = {} if !@used_constant
   @used_constant
 end
end

class Scene_Load < Scene_File
  alias est_const_changer_on_load_success on_load_success
  def on_load_success
    est_const_changer_on_load_success
    $game_system.used_constant.each_key do |cls|
      $game_system.used_constant[cls].each do |sym,val|
        est_change_const(cls,sym,val)
      end
    end    
  end
end

def est_change_vocab(sym, value)
  cls = "Vocab"
  est_change_const(cls,sym,value)
end
def est_reset_vocab(sym)
  cls = "Vocab"
  est_reset_const(cls,sym)
end  
def est_reset_all_vocab
  cls = "Vocab"
  est_reset_all_const(cls)
end
def est_change_const(cls, sym, value)
  orivalue = eval("#{cls}::#{sym}.dup") rescue eval("#{cls}::#{sym}") rescue return
  $game_system.default_constant[cls] = {} if !$game_system.default_constant[cls]
  $game_system.default_constant[cls][sym] =  orivalue if !$game_system.default_constant[cls][sym]
  $game_system.used_constant[cls] = {} if !$game_system.used_constant[cls]
  $game_system.used_constant[cls][sym] =  value
  eval("#{cls}::#{sym} = \"#{value}\"") if value.is_a?(String)
  eval("#{cls}::#{sym} = #{value}") if !value.is_a?(String)
end
def est_reset_const(cls, sym)
  return if chk = !$game_system.default_constant[cls][sym] rescue true
  $game_system.used_constant[cls] = {} if !$game_system.used_constant[cls]
  $game_system.used_constant[cls].delete(sym)
  $game_system.used_constant.delete(cls) if $game_system.used_constant[cls].empty?
  eval("#{cls}::#{sym} = \"#{$game_system.default_constant[cls][sym]}\"") if $game_system.default_constant[cls][sym].is_a?(String)
  eval("#{cls}::#{sym} = #{$game_system.default_constant[cls][sym]}") if !$game_system.default_constant[cls][sym].is_a?(String)    
end
def est_reset_all_const(cls)
  eval("
  #{cls}.constants.each do |sym|
    est_reset_const(#{cls}.to_s,sym.to_s)
  end
  ")
end
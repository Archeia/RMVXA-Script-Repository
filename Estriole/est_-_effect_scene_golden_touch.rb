=begin
#==============================================================================
 ** Effect: Golden Touch
 Author: Tsukihime
 Date: Oct 30, 2012
 HEAVILY MODDED by Estriole (almost rewrite it in fact >.<)
 you must credit me Tsukihime and Estriole if you're using it
 
 requirement :
  -Tsukihime Effect Manager
  (http://xtsukihime.wordpress.com/2012/10/05/effects-manager)
 -Yanfly Gab Window
 -Estriole Effect Scene Core

------------------------------------------------------------------------------
 ** Change log
 v1.1 Nov 05, 2012
   - Split the script and make the Effect Scene Core so now any scene
     can work fine in victor animated battle (of course must be set the last
     skill executed). with the core scene equip, scene party could be possible
     to use with victor animated battle
   - Estriole effect scene core also repair problem with turn restart to 1
 v1.0 Nov 04, 2012
   - modded so it can work as normal scene call
   - heavily modded so work in battle using victor animated battle
     (but don't forget to set the speed fix to make the skill act last)
   - compatibility with moghunter popup damage script
   - compatibility with yami combo count script
   - compatibility with yanfly enemy hp bar script
   - compatibility with mog wallpaper ex script
   
 v0.1 Nov 03, 2012
   - modded by estriole
 
 Oct 30, 2012
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in commercial/non-commercial projects
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
------------------------------------------------------------------------------
 ** Required
 -Tsukihime Effect Manager
  (http://xtsukihime.wordpress.com/2012/10/05/effects-manager)
 -Yanfly Gab Window
 -Estriole Effect Scene Core
------------------------------------------------------------------------------
 ** Description
 
 This script adds a "golden touch" effect to your skill.
 When this effect is activated, you can select an item from your inventory
 and turn it into gold.
 
 The amount of gold received is based on the price of the item times the
 multiplier of the effect.
 
 Tag your item/skills with
    <eff: golden_touch x>
    
 Where x is some float representing the gold multiplier
 
 estriole mod -  could become scene
 can be used as scene also (for sell only shop event?)
 - golden touch also could be called as scene by using script call
 SceneManager.call(Scene_GoldenTouch)
 by default it will use 1.0 multiplier if you want to change that
 use script call:
 $game_temp.golden_touch_multiplier = x
 where x is float or integer
 if the scene called by skill using effect notetag above. the multiplier will 
 follow the skill setting instead and ignore other.
 
 estriole mod - use in victor animated battle
 set the notetags. then set the skill speed fix to make the skill act last
 because after returning from scene any action after the actor calling the
 scene will not executed.
 and if you're using other script that i'm not making compatibility with...
 the compatibility i made is only for hiding the naughty images that still
 shown when changing scene (because i don't dispose them - because i can't)
 
 so if you're planning make compatibility yourself... (since i maybe 
 won't make it if i'm not using that script)
 
 remember that you must not dispose any object that shown in the battle if you can.
 you must just change the visible to false or opacity to 0 (depending the type). 
 
#==============================================================================
=end
module Effects
  module Golden_Touch
    Effect_Manager.register_effect(:golden_touch, 1.6)
  end
end

module ESTRIOLE
  TEXT_GOLDEN_TOUCH_GAINED_MONEY = "You reconstruct %s and turn it to %d %s!"
  #by order %s %d %s -> item name, money number, gold vocab
  TEXT_GOLDEN_TOUCH_CANNOT_CONVERT = "<cannot reconstruct>"
  TEXT_GOLDEN_TOUCH_VALUE_SHOW = "%s\nValue: %d gold"
end

class RPG::UsableItem
  
  # Check whether the operator is valid
  def add_effect_golden_touch(code, data_id, args)
    args[0] = args[0] ? args[0].to_f : 1
    add_effect(code, data_id, args)
  end
end

class Game_Temp
  attr_accessor :golden_touch_multiplier
end

class Game_Battler < Game_BattlerBase  
  def item_effect_golden_touch_global(user,target,effect)
    SceneManager.scene.call_scene(Scene_GoldenTouch, :effect_golden_touch, effect)
  end
end

# Just a custom window for my effect
class Window_ItemList_GoldenTouch < Window_ItemList

  # everything should be available for almost everything
  def enable?(item)
    return false if item.is_a?(RPG::Item) && item.key_item?
    return false if item.is_a?(RPG::Item) && item.price == 0 #will not convert item with 0 price
    return true
  end
  
  # Let's just show the price of the item
  def update_help
    return unless item
    name = item.name
    if item.price == 0 || item.key_item?
    @help_window.set_text(ESTRIOLE::TEXT_GOLDEN_TOUCH_CANNOT_CONVERT)
    else
    text = sprintf(ESTRIOLE::TEXT_GOLDEN_TOUCH_VALUE_SHOW,name,item.price)    
    @help_window.set_text(text)
    end
  end
end

# A new scene for selecting an item for the effect

class Scene_GoldenTouch < Scene_Item  

#~   def effect_scene_mark
#~   return true
#~   end
  
#~   def return_scene
#~     effect_return_scene
#~   end
  
  def create_item_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @gab_window = Window_Gab.new
    @gab_window.z = 200 #to put the order on top other window
    @gab_window.y += 300 #move the gab window to bottom
    @item_window = Window_ItemList_GoldenTouch.new(0, wy, Graphics.width, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
  end
    
  def on_item_ok
    if @effect_callback
    send(@effect_callback)
    elsif $game_temp.golden_touch_multiplier
    effect_golden_touch($game_temp.golden_touch_multiplier)
    else
    effect_golden_touch(1.0)
    end
    @item_window.refresh
    @item_window.activate
    #back to window after converting one item for more converting
  end
  
  def effect_golden_touch(rate = 1)
    return if item.nil? #escape code when you convert the last of the item and click again
    gained = item.price * rate
    gained = item.price * @effect.value1[0] if @effect_callback
    name   = item.name
    $game_party.gain_gold(gained.to_i)
    $game_party.lose_item(item, 1)
    text = sprintf(ESTRIOLE::TEXT_GOLDEN_TOUCH_GAINED_MONEY,name,gained.to_i,Vocab.currency_unit)
    @gab_window.clear
    @gab_window.setup(text,nil,nil)

  end
end
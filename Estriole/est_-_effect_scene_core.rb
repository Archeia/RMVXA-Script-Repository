=begin

EST - SCENE CORE
v.2.1

credit
Estriole
Yanfly

Version History
v.2.1 - 2013.03.30  - add compatibility patch for yanfly command party script
                      with victor animated battle. so we can change party
                      in battle using victor animated battle (before it will crash
v.2.0 - forget date - rewrite the script
v.1.0 - forget date - initial script

Introduction
this is FULL rewrite of my effect scene core script.
i use some of yanfly command equip script to recreate this script.

this script is tend to work for supporting switching scene for 
TSUKIHIME EFFECT MANAGER.

now we can make skill that have effect that call scene when the skill EXECUTED.
the different with yanfly command equip. the scene is called when the command used.
waste no turn at all. while this script called the scene when the skill EXECUTED.
so it wasting that Actor turn. (also no way to abuse it by choosing command, canceling it)

and the difference with my old version... in old version skill need to be set
to executed last (by modifying speed). since if it executed before another skill.
all other skill inputted AFTER it will erased. (since i restarted the battle).

in this version the battle not restarted. but resumed from where it left of. so all
action will work. it's only pausing the scene. run another scene. then resume the scene again.


Also come with some compatibility patches

Compatibility
built in compatibility patches for:
1) yanfly ace battle engine popup
2) moghunter popup script
3) yami combo counter script
4) yanfly enemy hp bar script
5) yanfly party system + yanfly command party (put this script below command party)

if you use another script that show sprites / window in battle it might need
compatibility patch. since i don't know what script you used. i will explain
how to make compatibility patch for this instead.
basically:
a) make compatibility patches by aliasing this method:
class: Scene_Battle, method: thing_to_hide
put compatibility patch there to hide that sprites/window

b) make compatibility patches by aliasing this method:
class: Scene_Battle, method: thing_to_show_again
put compatibility patch there to show that sprites/window IF needed
(for example window battle log need to be shown again but popup have auto shown later).

so far tested work with Default Battle, Ace battle engine, Victor Animated Battle.

How to use
first of all you need to understand how to use TSUKIHIME effect manager.
put this code inside the 'correct' effect method:

 SceneManager.scene.call_scene(SceneName, effect_callback_symbol, effect)
 
 #the only required is SceneName. you could not pass another two if you use
 that function without effect callback function from tsukihime effect manager
 
 for easier explaining i'll use example instead.. we see golden touch script.
 before code:
  class Game_Battler < Game_BattlerBase
    def item_effect_golden_touch_global(user,target,effect)
      SceneManager.call(Scene_GoldenTouch)
      SceneManager.scene.set_effect_callback(:effect_golden_touch, effect)
    end
  end
 change it to to make it works using scene core:
  class Game_Battler < Game_BattlerBase
    def item_effect_golden_touch_global(user,target,effect)
      SceneManager.scene.call_scene(Scene_GoldenTouch, :effect_golden_touch, effect)
    end
  end 

=end

# yanfly force recall code
module SceneManager  
  #--------------------------------------------------------------------------
  # new method: self.force_recall
  #--------------------------------------------------------------------------
  def self.force_recall(scene_class)
    @scene = scene_class
  end
  
end # SceneManager

class Scene_Battle < Scene_Base
  def call_scene(scene_class, eff_callback = nil, effect = nil)
    saved_scene = self
    Graphics.freeze
    thing_to_hide
    SceneManager.snapshot_for_background
    SceneManager.call(scene_class)
    SceneManager.scene.set_effect_callback(eff_callback.to_sym, effect) if eff_callback
    SceneManager.scene.main
    SceneManager.force_recall(saved_scene) #yanfly force recall technique
    thing_to_show_again
    @status_window.refresh
    perform_transition        
  end
  
  #you could alias this method if you have something to make compatible with
  def thing_to_hide
    @log_window.hide_background_box #hide log window black box background
    @log_window.hide #hide log window
    hide_extra_gauges if $imported["YEA-BattleEngine"] #hide extra gauges
    @info_viewport.visible = false #hide info viewport
    @spriteset.hide_enemy_hp_gauges if $imported["YEA-EnemyHPBars"] == true #hide hp bar
    @spriteset.hide_popup if $imported["YEA-BattleEngine"] == true && YEA::BATTLE::ENABLE_POPUPS #hide yanfly popup
    @spriteset.dispose_damage_sprites if $mog_rgss3_damage_pop == true #hide mog damage pop up
    if $imported["YSE-PartyComboCounter"] == true #hide yami combo counter
      @sprite_combo_count.opacity = 0
      @sprite_combo_damage.opacity = 0
      @sprite_combo_congrat.opacity = 0
    end
  end
  
  #you could alias this method if you have something to make compatible with
  def thing_to_show_again
    @log_window.show_background_box #show log window black box background
    @log_window.show #show log window
    show_extra_gauges if $imported["YEA-BattleEngine"] #show extra gauge
    @info_viewport.visible = true #show info viewport
  end

  #compatibility patch for yanfly party system - command party
  def command_party
    Graphics.freeze
    @info_viewport.visible = false
    hide_extra_gauges if $imported["YEA-BattleEngine"]
    SceneManager.snapshot_for_background
    previous_party = $game_party.battle_members.clone
    index = @party_command_window.index
    oy = @party_command_window.oy
    #---
    SceneManager.call(Scene_Party)
    SceneManager.scene.main
    victor_battle_sprite_patch
    SceneManager.force_recall(self)
    #---
    show_extra_gauges if $imported["YEA-BattleEngine"]
    if previous_party != $game_party.battle_members
      $game_party.make_actions
      $game_party.set_party_cooldown
    end
    @info_viewport.visible = true
    @status_window.refresh
    @party_command_window.setup
    @party_command_window.select(index)
    @party_command_window.oy = oy
    perform_transition
  end
  
  def victor_battle_sprite_patch
    return if !$imported[:ve_animated_battle]
    @spriteset.dispose_actors
    @spriteset.create_actors
    setup_spriteset
  end  
  
end

class Spriteset_Battle  
  
  #--------------------------------------------------------------------------
  # ● Dispose yea enemy hp bar
  #--------------------------------------------------------------------------             
  def hide_enemy_hp_gauges
      battler_sprites.each {|sprite| sprite.hide_enemy_hp_gauges }
  end
  #--------------------------------------------------------------------------
  # ● Dispose yea popup text
  #--------------------------------------------------------------------------             
  def hide_popup
      battler_sprites.each {|sprite| sprite.hide_popup }
  end
  
end

class Sprite_Battler < Sprite_Base
  def hide_enemy_hp_gauges
     @back_gauge_viewport.visible = false if @back_gauge_viewport
     @hp_gauge_viewport.visible = false if @hp_gauge_viewport
  end
  
  def hide_popup
      for popup in @popups
      popup.bitmap.dispose
      popup.dispose
      @popups.delete(popup)
      popup = nil
      end
  end
end

class Window_BattleLog < Window_Selectable
  def hide_background_box
    @back_sprite.visible = false
  end
  def show_background_box
    @back_sprite.visible = true
  end
end
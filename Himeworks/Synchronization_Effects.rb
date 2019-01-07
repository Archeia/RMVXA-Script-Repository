=begin
#===============================================================================
 Title: Synchronization Effects
 Author: Hime
 Date: Nov 13, 2013
 URL: http://himeworks.com/2013/11/12/synchronization-effects/
--------------------------------------------------------------------------------
 ** Change log
 Nov 13, 2013
   - moved some logic into the synchronized battler script
 Nov 12, 2013
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
 
 This script provides additional "synchronization effects", or simply
 "sync effects", for synchronized battlers. The default sync effect is when the
 parent dies, its children also die, which is called "sync death" effect.
 
 You can set additional sync effects with this script, such as setting
 the exp or gold rate for any enemies that die from "sync death" effect. You
 can synchronize HP, MP, or TP for any linked actors or enemies.
 
 Using sync effects can greatly customize your synchronized battlers.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Synchronized Battlers and
 above Main

--------------------------------------------------------------------------------
 ** Usage
 
 Sync effects can be set with note-tags or using script calls during the
 battle.
 
 To set sync effects using note-tag, note-tag actors or enemies with

   <sync effect: name value1 value2 ... >
   
 Where the `name` is the name of the effect from the list of effects below, and
 the values are the arguments for the effect.
 
 To set sync effects using script calls, you need to first get the actor or
 enemy that you want to set the effect for and then make the appropriate script
 call like this
 
   enemy = get_enemy(index)
   set_sync_effect(enemy, name, value1, value2, ... )
   
   actor = get_actor(index)
   set_sync_effect(actor, name, value1, value2, ... )
   
 Where the parameters are the same as above, and the index is the index
 of the enemy.
 
 Note that for the actor index, a positive index is the ID of the actor, while
 a negative index is the position of the party (eg: -1 is the first position
 in the party)
 
--------------------------------------------------------------------------------
 ** Example
 
 A simple sync effect is to receive no exp from any enemies that died due to
 sync effects, for example you killed the parent and all children died. This
 is accomplished using the "death_exr" sync effect, which sets the experience
 rate of the enemy when it dies due to "sync death". By setting the rate to 0,
 you are saying we should get no exp from that enemy.
 
 To set the death_exr effect using note-tag, you would note-tag the enemy with
 
   <sync effect: death_exr 0>
   
 To set the death_exr effect using script calls, in a troop event, use
 
   set_sync_effect(1, :death_exr, 0)
 
--------------------------------------------------------------------------------
 ** Reference
 
 This is a list of all of the sync effects currently available.
 
 Name: death_exr
 Args: one number
 Desc: Sets the exp rate for the enemy if it died due to "sync death"
 Example: Half-exp for sync death
 
   <sync effect: death_exr 0.5>
   
 Name: death_gdr
 Args: one number
 Desc: Sets the gold rate for the enemy if it died due to "sync death"
 Example: Half-gold for sync death
 
   <sync effect: death_gdr 0.5>
   
 Name: hp_sync
 Args: true/false
 Desc: Synchronizes the parent and child's HP. Two-way link required.
 
 Name: mp_sync
 Args: true/false
 Desc: Synchronizes the parent and child's MP. Two-way link required.
       
 Name: tp_sync
 Args: true/false
 Desc: Synchronizes the parent and child's TP. Two-way link required.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SynchronizationEffects"] = true
#===============================================================================
# ** Rest of script
#===============================================================================
module TH
  module Sync_Effects
    
    Regex = /<sync[-_ ]effect:\s*(\w+)\s*(.*)\s*>/i
  end
end

module RPG
  
  class BaseItem
    
    def sync_effects
      load_notetag_sync_effects unless @sync_effects
      return @sync_effects
    end
    
    def load_notetag_sync_effects
      @sync_effects = {}
      res = self.note.scan(TH::Sync_Effects::Regex)
      res.each do |data|
        name = data[0].downcase
        values = data[1..-1]
        method_name = "load_sync_effect_#{name}"
        send(method_name, values) if respond_to?(method_name)
      end
    end
    
    def load_sync_effect_death_exr(args)
      @sync_effects[:death_exr] = args[0].to_f
    end
    
    def load_sync_effect_death_gdr(args)
      @sync_effects[:death_gdr] = args[0].to_f
    end
    
    def load_sync_effect_hp_sync(args)
      @sync_effects[:hp_sync] = args[0].downcase == "true"
    end
    
    def load_sync_effect_mp_sync(args)
      @sync_effects[:mp_sync] = args[0].downcase == "true"
    end
  end
end

class Game_BattlerBase
  
  def clear_sync_effects
    @sync_effects = {}
    @sync_effects[:death_exr] = 1
    @sync_effects[:death_gdr] = 1
  end
  
  def set_sync_effect(opt, *args)
    case opt
    when :death_exr
      @sync_effects[opt] = args[0]
    when :death_gdr
      @sync_effects[opt] = args[0]
    when :hp_sync
      @sync_effects[opt] = args[0]
    when :mp_sync
      @sync_effects[opt] = args[0]
    when :tp_sync
      @sync_effects[opt] = args[0]
    end
  end
  
  def sync_option(opt)
    @sync_effects[opt]
  end
  
  alias :th_sync_effects_hp= :hp=
  def hp=(hp)
    @sync_check = true
    self.th_sync_effects_hp = hp
    @sync_links.each do |link|
      child = link.child
      next unless !child.sync_check && link.two_way? && (sync_option(:hp_sync) || child.sync_option(:hp_sync))      
      child.hp = hp
    end
    @sync_check = false
  end
  
  alias :th_sync_effects_mp= :mp=
  def mp=(mp)
    @sync_check = true
    self.th_sync_effects_mp = mp
    @sync_links.each do |link|
      child = link.child
      next unless !child.sync_check && link.two_way? && (sync_option(:mp_sync) || child.sync_option(:mp_sync))
      child.mp = mp
    end
    @sync_check = false
  end
  
  alias :th_sync_effects_tp= :tp=
  def tp=(tp)
    @sync_check = true
    self.th_sync_effects_tp = tp
    @sync_links.each do |link|
      child = link.child
      next unless !child.sync_check && link.two_way? && (sync_option(:tp_sync) || child.sync_option(:tp_sync))
      child.tp = tp
    end
    @sync_check = false
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_sync_effects_initialize :initialize
  def initialize(index, enemy_id)
    th_sync_effects_initialize(index, enemy_id)
    clear_sync_effects
  end
  
  def clear_sync_effects
    super
    @sync_effects.merge!(enemy.sync_effects)
  end
  
  alias :th_sync_effects_exp :exp
  def exp
    death_exr = sync_death? ? sync_option(:death_exr) : 1
    (th_sync_effects_exp * death_exr).to_i
  end
  
  alias :th_sync_effects_gold :gold
  def gold
    death_gdr = sync_death? ? sync_option(:death_gdr) : 1
    (th_sync_effects_gold * death_gdr).to_i
  end
end

class Game_Actor < Game_Battler
  
  alias :th_sync_effects_initialize :initialize
  def initialize(actor_id)
    th_sync_effects_initialize(actor_id)
    clear_sync_effects
  end
  
  def clear_sync_effects
    super
    @sync_effects.merge!(actor.sync_effects)
  end
end

class Game_Interpreter
  
  def set_sync_effect(battler, name, *values)
    battler.set_sync_effect(name, *values)
  end
end
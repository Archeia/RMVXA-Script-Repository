=begin
#==============================================================================
 ** Effect Manager
 Version: 2.6
 Author: Hime
 Date: Dec 10, 2012
------------------------------------------------------------------------------
 ** Change log
 2.6 Dec 10, 2012
   - Added "pre_attack" and "pre_guard" triggers.
 2.5 Nov 23, 2012
   - Added "troop" trigger for battle event effect triggers
   - Added "add_effect_message" method to Game_ActionResult
   - Added small delay between each effect message
   - Crit_attack triggers and normal attack triggers are mutually exclusive now
 2.4 Nov 17, 2012
   - Renamed "critical" trigger to "crit_attack" trigger
   - Added "crit_guard" trigger
 2.3
   - Removed global effect overwrite. Replaced with a proper global effect check
 2.2
   - Added effect conditions
 2.1 Nov 3, 2012
   - Implemented "equip" and "unequip" triggers
   - Implemented "turn_start", "battle_start", and "battle_end" triggers
   - Implemented "level_up", "level_down" triggers
   - Refactored code so that triggers are easy to implement for all effect objects
 2.0 Oct 31, 2012
   - Standardized method name format for effect triggers
   - Provided effect triggers for note tags
 1.6  Oct 30, 2012
   - Added experimental "Effect Callback" for scenes
 1.52 Oct 28, 2012
   - Fixed bug where the wrong value was being checked during effect loading
 Oct 21, 2012
   - added weapon/armor turn end effects
   - Fixed issue where turn end effect results weren't displayed
 Oct 20, 2012
   - fixed bug where "Common event" effect wasn't activating
 Oct 16, 2012
   - Added support for global item/skill effects.
 Oct 11, 2012
   - Redefined effect categories. Restructured code to reflect the new design
   - added signatures for class, weapon, armor passive effects
 Oct 10, 2012
   - added signatures for class effects: class_attack, class_guard
 Oct 8, 2012
   - added "initial" values to the action result
   - dying no longer clears states or buffs
   - added two types of state effects: state_attack and state_guard
   - added two types of state effects: state_add and state_remove
 Oct 7, 2012
   - added duplicate code to UsableItem to force it to run note checking.
   - note parser now sends add_effect method an array of arguments rather than
     just a string for the arguments
   - Extended effects to all RPG::BaseItem classes, including actors, classes,
     weapon, armors, items, skills, enemies, and states
 Oct 6, 2012
   - Effect code can now be anything that you want as long as it is
     a valid hash key. I would recommend symbols or strings. You can still
     use a number
 Oct 5, 2012
   - added logic to allow users to define how the Effect object should
     be created
 Oct 4, 2012
   - changed regex to allow arbitrary number of arguments for the effect.
 Oct 3, 2012
   - added effect messages
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
------------------------------------------------------------------------------
 ** Compatibility
 
 Should be compatible with most systems.
 This script replaces one method
   -Game_Battler # item_effect_apply  
 
------------------------------------------------------------------------------
 ** Description
 
 This script replaces the default Effects handlers with a plugin-based
 effect system. It is meant to allow developers to easily develop new
 effects without having to concern with the minor details.
 
 You can define new effects by simply registering it, defining a method,
 and then note-tagging your database objects.
 
 Additional item/skill effects can be easily added.
 This script extends effects to all RPG::BaseItem classes, although only
 some have been implemented.

------------------------------------------------------------------------------
 ** Terminology
 
 This script uses specific terminology that I have defined.
 
 *   Effect plugin
   Any script that is registered to the Effect Manager are called "plugins".
 
 *   Effect objects
   Or simply "objects". These are any objects that you can add effects to.
   The default engine allows items and skills to have effects. This script
   extends this to actors, class, weapons, armors, enemies, and states.
 
 *   Id String   
   The name of an effect. Used throughout your script and notetags.
   Every plugin must have a unique idstring.
 
 *   Effect Type
   Determined by the object the effect is assigned to.
   For example, effects that are assigned to a weapon are "weapon effects"
   
 *   Effect Triggers
   Specifies when an effect will be activated.
   For example, an "attack trigger" requires your battler to be "attacking"
   another target.
   
 *   Effect Conditions
   Conditions that must be met in order for an effect to activate.
   These are checked after an effect is triggered, but before the effect
   is applied
 
------------------------------------------------------------------------------
 ** Usage
 
 All effects that are written for this script are added to objects using
 note tags.
 
 The basic format of the note tag is
 
    <eff: idstring arg1 arg2 ... >
    
 Where
   `idstring`        is the name of effect that you want to add,
   `arg1, arg2, ...` are a list of arguments that the effect requires
   
 You can specify effects with conditions by using the format:
 
    <cond_eff: idstring cond arg1 arg2 ... >
    
 Where
   `cond`  is a ruby expression that evaluates to true or false that contains
           no spaces
   
 The only difference between the two note-tags is that one allows you to
 specify conditions while the other does not.
   
 Instructions should be provided with the effect plugin describing what each
 argument represents.
 
 By default, if you simply write the idstring of the effect, then it is assumed
 to activate under any effect trigger. If you wish to specify the triggers that
 it will activate under, you should write it as
 
    <eff: idstring-TRIGGER arg1 arg2 ... >
    
 Where `TRIGGER` is an effect trigger. You can look at the list of triggers
 available in the reference list below, although a plugin may choose not to
 implement every trigger available. Check with the plugin author to see what
 kinds of triggers are available.
 
------------------------------------------------------------------------------
 ** Reference
 
 This is a list of effect types that are currently supported:
 
 * actor       - applies to actors
 * class       - applies to classes
 * item        - applies to items/skills
 * skill       - applies to skills
 * weapon      - applies to weapons
 * armor       - applies to armors
 * enemy       - applies to enemies
 * state       - applies to states
 
 Note that actors and enemies currently only support passive triggers.
 
 This is a list of effect triggers that are currently supported:
 
 * attack        - triggered when an action hits a battler
 * guard         - triggered when a battler is hit by an action
 * crit_attack   - triggered when a critical hit is inflicted
 * crit_guard    - triggered when a battler received a critical hit
 * pre_attack    - triggered before damage from action is applied, attack side
 * pre_guard     - triggered before damage from action is applied, guard side
 * miss_attack   - triggered when an action misses, attack side
 * miss_guard    - triggered when an action misses, guard side
 * level_up      - when you increase a level
 * level_down    - when you decrease a level
 * battle_start  - triggered at the beginning of the battle
 * battle_end    - triggered at the end of the battle
 * turn_start    - triggered at the start of each turn
 * turn_end      - triggered at the end of each turn
 * equip         - equip trigger. When you equip a weapon/armor
 * unequip       - equip trigger. When you unequip a weapon/armor
 * add           - state trigger. When a state is added
 * remove        - state trigger. When a state is removed.
 * global        - special trigger. When an item/skill is used
 * troop         - special trigger. When a battle event has executed
 
 There are two general types of methods signatures
 
 1. TYPE_effect_NAME_TRIGGER(user, obj, effect)
 
   This applies to any trigger where two battlers are involved, such as
   attack, guard, or critical.
   
 2. TYPE_effect_NAME_TRIGGER(obj, effect)
 
   This applies to any trigger that involve only one battler. Basically every
   other trigger since there is no other battler.
 
------------------------------------------------------------------------------
 ** Plugin Developers
 
 This section is for users that wish to develop their own plugins for the
 Effect Manager. It will walk through various features that are available
 for you.
   
   == Making your plugin ==

 So we start by understanding how to write an effect plugin.
 Defining new effects is a simple 3-step process
 
 1: at the top of your script, add a single call to register your effect.
 
    Effect_Manager.register_effect(idstring, api_version)
    
    where
      `idstring`    is a string that you will use to refer to your effect.
      `api_version` is the version of the Effect Manager that your script
                    runs under. If the user's version is outdated, a popup
                    will appear alerting that the plugin is incompatible. The
                    default version required is 2.0
                    
    As an example, we'll register a new effect called "test_effect"
    
       Effect_Manager.register_effect(:test_effect, 2.0)
      
 2: Define the method for your effect in Game_Battler or its child classes.
    Depending on where it should be triggered, the name will be different.
    
    The format of the method name is defined above in the reference, so for
    example you might have something like
    
       def item_effect_test_effect(user, item, effect)
         args = effect.value1
       end
    
 3: Instruct your users to tag their objects with the following note tag:
 
       <eff: test_effect arg1 arg2 arg3 ...>

   == Storing and retrieving arguments ==
       
 By default, any arguments that are passed to your effect will be stored in
 an effect object as an array of strings. In step 2 above, you see that you are
 given a reference to your effect. You can access the arguments using
 
    effect.value1
    
 If you would like to type cast your arguments beforehand, you can define this
 method in any RPG::BaseItem classes:
 
    def add_effect_IDSTRING(code, data_id, args)
      # type cast your args here
      
      # now add the effect to the object
      add_effect(code, data_id, args)
    end
    
 Simply replace IDSTRING with the name that you registered in step 1.
 
   == Working with custom messages ==
   
 A simple way to inform users that something has happened is to simply add
 messages to $game_message:
 
   $game_message.add_message("your results")
   
 In addition, I have provided you a special way to store messages from your
 effects so that they will appear in the battle log during battle.
 
 The Game_ActionResult class holds an `effect_results` array that will store
 an array of strings. So the usual way of adding an effect message is

    @result.effect_results.append(YOUR_MESSAGE)
    
    == Using effect callbacks ==
    
 Sometimes, your effects require user input, which may occur on a different
 scene. Because the effect evaluation will end when you switch to another
 scene, you will need a way to remember which effect is currently activated.
 
 This can be accomplished using the following sequence of calls
 
   SceneManager.call(YOUR_NEW_SCENE)
   SceneManager.set_effect_callback(:method_name, effect)
   
 By setting the effect callback, you are able to trigger a custom method
 for your effect processing. 
    
    == Other stuff that may be of interest ==
    
 I have added some extra attributes for convenience in the following classes.
 
 Game_ActionResult
   old_hp : stores the battler's HP before damage is applied
   old_mp : stores the battler's MP before damage is applied
   old_tp : stores the battler's TP before damage is applied
   
 If you need to access the current action to get any information about what
 was executed, you can use the following
 
   user.current_action
   user.current_action.item
    
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Effect_Manager"] = 2.6
#==============================================================================
# ** Rest of the script
#==============================================================================

module Effect_Manager
  
  # The format of all note tags
  triggers = "(-attack|-guard|-crit_attack|-crit_guard|"         \
             "-attack_damage|-guard_damage|-level_up|-level_down|" \
             "-miss_attack|-miss_guard" \
             "-battle_start|-battle_end|-turn_start|-turn_end|" \
             "-global|-equip|-unequip|-add|-remove)?"           
  Effect_Regex = /<eff: (\w+)#{triggers}(.*)>/i
  Ext_Regex = /<eff:\s*(\w+)#{triggers}>(.*?)<\/eff>/im
  CondEff_Regex = /<cond_eff: (\w+)#{triggers} ['"](.*)['"](.*)>/i
  
  # Default effect code constants
  
  EFFECT_RECOVER_HP     = 11              # HP Recovery
  EFFECT_RECOVER_MP     = 12              # MP Recovery
  EFFECT_GAIN_TP        = 13              # TP Gain
  EFFECT_ADD_STATE      = 21              # Add State
  EFFECT_REMOVE_STATE   = 22              # Remove State
  EFFECT_ADD_BUFF       = 31              # Add Buff
  EFFECT_ADD_DEBUFF     = 32              # Add Debuff
  EFFECT_REMOVE_BUFF    = 33              # Remove Buff
  EFFECT_REMOVE_DEBUFF  = 34              # Remove Debuff
  EFFECT_SPECIAL        = 41              # Special Effect
  EFFECT_GROW           = 42              # Raise Parameter
  EFFECT_LEARN_SKILL    = 43              # Learn Skill
  EFFECT_COMMON_EVENT   = 44              # Common Events
  
  # Mapping object types to effect types
  Effect_Types = {
    RPG::Actor   => "actor",
    RPG::Class   => "class",
    RPG::Item    => "item",
    RPG::Skill   => "item",    # default engine treats them the same
    RPG::Weapon  => "weapon",
    RPG::Armor   => "armor",
    RPG::Enemy   => "enemy",
    RPG::State   => "state"
  }
  
  # Mapping params to ID's
  Param_Table = {
    "mhp" => 0,
    "mmp" => 1,
    "atk" => 2,
    "def" => 3,
    "mat" => 4,
    "mdf" => 5,
    "agi" => 6,
    "luk" => 7
  }
  
  # registers a new effect.
  #   code -> a number that has not been reserved by another effect
  #   data_id -> a special ID for the effect. Currently not used.
  #   method_name -> a symbol. Name of the method to call for this effect
  #   idstring -> a string. Used for note-tagging and other user-related things  
  def self.register_effect(idstring, api_version=2.0)
    idstring = idstring.to_s
    key = idstring.to_sym
    if $imported["Effect_Manager"] < api_version
      outdated_api_warn(idstring, api_version)
    elsif @method_table.include?(key)
      dupe_entry_warn(key, @method_table[key]) 
    else
      @method_table[key] = idstring
      @regex_table[key] = idstring
    end
  end
  
  # The initial table is the same as the one in the default scripts
  def self.initialize_tables
    @regex_table = {}
    @method_table = {
      EFFECT_RECOVER_HP    => :item_effect_recover_hp,
      EFFECT_RECOVER_MP    => :item_effect_recover_mp,
      EFFECT_GAIN_TP       => :item_effect_gain_tp,
      EFFECT_ADD_STATE     => :item_effect_add_state,
      EFFECT_REMOVE_STATE  => :item_effect_remove_state,
      EFFECT_ADD_BUFF      => :item_effect_add_buff,
      EFFECT_ADD_DEBUFF    => :item_effect_add_debuff,
      EFFECT_REMOVE_BUFF   => :item_effect_remove_buff,
      EFFECT_REMOVE_DEBUFF => :item_effect_remove_debuff,
      EFFECT_SPECIAL       => :item_effect_special,
      EFFECT_GROW          => :item_effect_grow,
      EFFECT_LEARN_SKILL   => :item_effect_learn_skill,
      EFFECT_COMMON_EVENT  => :item_effect_common_event,
    }
  end
  
  # Returns the effect code for the particular string.
  def self.get_effect_code(sym)
    @regex_table[sym]
  end
  
  def self.outdated_api_warn(idstring, version)
    msgbox("Warning: `%s` effect requires version %.2f of the script" %[idstring, version])
  end
  
  def self.dupe_entry_warn(your_id, existing_name)
    msgbox("Warning: idstring %s has already been reserved" %[existing_name.to_s])
  end
  
  def self.method_table
    @method_table
  end
  
  # Setup the tables
  initialize_tables
end

module RPG
  
  class UsableItem::Effect
    attr_accessor :trigger
    attr_accessor :condition
  end
  
  class BaseItem
    def effects
      load_notetag_effect_manager unless @effect_checked 
      return @effects
    end
    
    # Go through each line looking for effects. Note that the data id
    # is currently hardcoded to 0 since we don't really need it.
    def load_notetag_effect_manager
      @effects ||= [] 
      @effect_checked = true
      
      # check for effects
      results = self.note.scan(Effect_Manager::Effect_Regex)
      results.each {|code, trigger, args|
        code = Effect_Manager.get_effect_code(code.to_sym)
        if code
          check_effect(code, trigger, args)
          @effects[-1].trigger = trigger ? trigger.gsub!("-", "") : nil
        end
      }
      
      # check for conditional effects
      results = self.note.scan(Effect_Manager::CondEff_Regex)
      results.each {|code, trigger, cond, args|
        code = Effect_Manager.get_effect_code(code.to_sym)
        if code
          check_effect(code, trigger, args)
          @effects[-1].trigger = trigger ? trigger.gsub!("-", "") : nil
          @effects[-1].condition = cond
        end
      }
    end
    
    def check_effect(code, trigger, args)
      if self.class.method_defined?("add_effect_#{code}")
        send("add_effect_#{code}", code.to_sym, 0, args.split)
      else
        add_effect(code.to_sym, 0, args.split) 
      end
    end
    
    def add_effect(code, data_id, args)
      @effects.push(RPG::UsableItem::Effect.new(code, data_id, args))
    end
  end
  
  # Can't rely on inheritance because effects is declared as an
  # attr_accessor
  class UsableItem
    def effects
      load_notetag_effect_manager unless @effect_checked 
      return @effects
    end
  end
end

# Set the effect callback for the current scene
module SceneManager
  
  def self.set_effect_callback(method, effect)
    SceneManager.scene.set_effect_callback(method, effect)
  end
end

# Want to store effect messages to be displayed by the battle log
# Also want to store information like the battler's initial values because
# effects are applied AFTER damage has been evaluated.
class Game_ActionResult
  
  attr_accessor :effect_results
  attr_reader :old_hp
  attr_reader :old_mp
  attr_reader :old_tp
  
  alias :th_effect_manager_clear :clear
  def clear
    th_effect_manager_clear
    clear_effect_results
    clear_old_values
  end
  
  def clear_old_values
    @old_hp = 0
    @old_mp = 0
    @old_tp = 0
  end
  
  def clear_effect_results
    @effect_results = []
  end
  
  alias :th_effect_manager_make_damage :make_damage
  def make_damage(value, item)
    @old_hp = @battler.hp
    @old_mp = @battler.mp
    @old_tp = @battler.tp
    th_effect_manager_make_damage(value, item)
  end
  
  # Adds a message to the list of effect messages that should be
  # displayed
  def add_effect_message(msg)
    @effect_results.push(msg)
  end
end

class Game_Battler < Game_BattlerBase
  
  def effect_objects
    states
  end

  #---------------------------------------------------------------------------
  # * adding some additional effect checks
  #---------------------------------------------------------------------------
  
  # Trigger any attack/guard related effects
  alias :th_effect_manager_item_apply :item_apply
  def item_apply(user, item)
    th_effect_manager_item_apply(user, item)
    if @result.hit?
      if @result.critical
        check_critical_effects(user, item)
        check_crit_guard_effects(user, item)
      else
        check_attack_effects(user, item)
        check_guard_effects(user, item)
      end
    else
      check_miss_attack_effects(user, item)
      check_miss_guard_effects(user, item)
    end
  end
  
  alias :th_effect_manager_make_dmg_value :make_damage_value
  def make_damage_value(user, item)
    th_effect_manager_make_dmg_value(user, item)
    check_pre_attack_effects(user, item)    
    check_pre_guard_effects(user, item)
  end
  
  # trigger any global effects
  alias :th_effect_manager_use_item :use_item
  def use_item(item)
    th_effect_manager_use_item(item)
    check_effects([item], "global")
  end
  
  # new. Trigger turn start effects
  def on_turn_start
    check_turn_start_effects
  end
  
  # Trigger turn end effects
  alias :th_effect_manager_turn_end :on_turn_end
  def on_turn_end
    th_effect_manager_turn_end
    check_turn_end_effects
  end
  
  # Trigger battle start effects
  alias :th_effect_manager_battle_start :on_battle_start
  def on_battle_start
    th_effect_manager_battle_start
    check_battle_start_effects
  end
  
  # Trigger battle end effects
  alias :th_effect_manager_battle_end :on_battle_end
  def on_battle_end
    check_battle_end_effects
    th_effect_manager_battle_end
  end
  
  # Trigger state addition effects
  alias :th_effect_manager_add_new_state :add_new_state
  def add_new_state(state_id)
    check_state_add_effects(state_id)
    th_effect_manager_add_new_state(state_id)
  end
  
  # Trigger state removal effects
  def erase_state(state_id)
    super
    check_state_remove_effects(state_id)
  end
  
  #=============================================================================
  # * Apply the effect
  #=============================================================================
  
  def get_effect_method_name(effect, type="", trigger="")
    method_name = Effect_Manager.method_table[effect.code].to_s
    return "" unless method_name
    # no specific effect trigger specified, then assume any trigger valid
    # or maybe it is just a default effect
    if effect.trigger.nil?      
      if trigger.empty?
        method_name = sprintf("%s_effect_%s", type, method_name)
      else
        method_name = sprintf("%s_effect_%s_%s", type, method_name, trigger)
      end
    # otherwise, check if it's the specified trigger
    
    elsif effect.trigger == trigger
      method_name = sprintf("%s_effect_%s_%s", type, method_name, trigger)
    else
      method_name = ""
    end
    return method_name.to_sym
  end
  
  def eval_effect_cond(condition, a, b, v=$game_variables, s=$game_switches)
    return true unless condition
    eval(condition) rescue false
  end
  
  def check_effect_condition(user, effect)
    user ? eval_effect_cond(effect.condition, user, self) : eval_effect_cond(effect.condition, self, self)
  end
        
  # Apply custom effects. This should ignore all default effects since
  # they don't have anything special and shouldn't be called here anyways
  def effect_apply(user, obj, effect, type, trigger)
    return if effect.code.is_a?(Fixnum)
    return unless check_effect_condition(user, effect)
    method_name = get_effect_method_name(effect, type, trigger)
    if respond_to?(method_name)
      # someone used this against this battler
      if user
        send(method_name, user, obj, effect) 
        
      # effect was triggered by the system
      else
        send(method_name, obj, effect)
      end
    end
  end
  
  # overwritten. Table is now grabbed from a dynamically-created table
  def item_effect_apply(user, item, effect)
    return unless check_effect_condition(user, effect)
    method_name = Effect_Manager.method_table[effect.code]
    unless method_name.to_s.start_with?("item_effect")
      method_name = get_effect_method_name(effect, "item", "")
    end
    send(method_name, user, item, effect) if respond_to?(method_name)
  end
  
  #---------------------------------------------------------------------------
  # Check if there are effects to apply other than the item used
  #---------------------------------------------------------------------------
  
  # This method basically checks the effects for all effect objects
  def check_effects(objects, trigger, user=nil, item=nil)
    objects.each {|obj|
      type = type || Effect_Manager::Effect_Types[obj.class]
      obj.effects.each {|effect|
        effect_apply(user, obj, effect, type, trigger)
      }
    }
  end
  
  # Triggers for all effect objects
  
  # Triggered after basic damage calculation is done, but before damage
  # is executed
  def check_pre_attack_effects(user, item)
    check_effects(user.effect_objects, "pre_attack", user, item)
  end
  
  # Same as attack_damage, except on the guard side
  def check_pre_guard_effects(user, item)
    check_effects(effect_objects, "pre_guard", user, item)
  end
  
  # Attack effects are applied whenever the battler successfully hits
  def check_attack_effects(user, item)
    check_effects(user.effect_objects, "attack", user, item)
  end
  
  # Guard effects are applied whenever you are hit
  def check_guard_effects(user, item)
    check_effects(effect_objects, "guard", user, item)
  end
  
  # Critical effects applied when critical hit is dealt
  def check_critical_effects(user, item)
    check_effects(user.effect_objects, "crit_attack", user, item)
  end
  
  def check_crit_guard_effects(user, item)
    check_effects(effect_objects, "crit_guard", user, item)
  end
  
  def check_miss_attack_effects(user, item)
    check_effects(user.effect_objects, "miss_attack", user, item)
  end
  
  def check_miss_guard_effects(user, item)
    check_effects(effect_objects, "miss_guard", user, item)
  end
  
  def check_global_effects(user, item)
    check_effects(user.effect_objects, "global")
  end
  
  def check_troop_effects
    check_effects(effect_objects, "troop")
  end
  
  def check_level_up_effects
    check_effects(effect_objects, "level_up")
  end
  
  def check_level_down_effects
    check_effects(effect_objects, "level_down")
  end
  
  # Effects are applied at the start of the battle
  def check_battle_start_effects
    check_effects(effect_objects, "battle_start")
  end
  
  # Effects triggered at the end of the battle
  def check_battle_end_effects
    check_effects(effect_objects, "battle_end")
  end
  
  # Effects triggered at the start of each turn
  def check_turn_start_effects
    check_effects(effect_objects, "turn_start")
  end
  
  # Effects triggered at the end of each turn
  def check_turn_end_effects
    check_effects(effect_objects, "turn_end")
  end
  
  def check_die_effects
    check_effects(effect_objects, "die")
  end
  
  # Triggers for specific objects
  
  def check_equip_effects(equip)
  end
  
  def check_unequip_effects(equip)
  end
  
  def check_state_add_effects(state_id)
    state = $data_states[state_id]
    state.effects.each {|effect| effect_apply(nil, state, effect, "state", "add")}
  end
  
  def check_state_remove_effects(state_id)
    state = $data_states[state_id]
    state.effects.each {|effect| effect_apply(nil, state, effect, "state", "remove")}
  end
end

# Attack effects process the user's effects
class Game_Enemy < Game_Battler
  
  def effect_objects
    super + [enemy]
  end
end

class Game_Actor < Game_Battler
  
  def effect_objects
    super + [actor] + [self.class] + weapons + armors + skills
  end
  
  alias :th_effect_manager_level_up :level_up
  def level_up
    th_effect_manager_level_up
    check_level_up_effects
  end
  
  alias :th_effect_manager_level_down :level_down
  def level_down
    th_effect_manager_level_down
    check_level_down_effects
  end
  
  # Trigger equip/unequip effects
  alias :th_effect_manager_change_equip :change_equip
  def change_equip(slot_id, item)
    
    # keep track of the old one...just in case we actually need it
    old_item = @equips[slot_id].object
    th_effect_manager_change_equip(slot_id, item)
    
    # Now to check effect triggers
    if item
      # We are equipping something different
      if item != old_item
        # There was something in the slot
        if old_item
          check_equip_effects(item)
          check_unequip_effects(old_item)
        else          
          check_equip_effects(item)
        end
      end
    else
      # We are unequipping something
      if old_item
        check_unequip_effects(old_item)
      end
    end
  end
  
  def check_equip_effects(equip)
    super
    check_effects([equip], "equip")
  end
  
  def check_unequip_effects(equip)
    super
    check_effects([equip], "unequip")
  end
end


class Game_Troop < Game_Unit

  #-----------------------------------------------------------------------------
  # Add "Troop" trigger, which is activated after a troop event is executed.
  #-----------------------------------------------------------------------------
  alias :th_effect_manager_setup_battle_event :setup_battle_event
  def setup_battle_event
    return if @interpreter.running? || @interpreter.setup_reserved_common_event
    th_effect_manager_setup_battle_event
    
    # This assumes that the interpreter does not finish executing before
    # we get here
    if $game_troop.interpreter.running?
      @interpreter.call_troop_effect
    end
  end
end

class Game_Interpreter
  
  # Trigger troop effects after execution completes
  def call_troop_effect
    @troop_effect = true
  end
  
  alias :th_effect_manager_run :run
  def run
    th_effect_manager_run
    if @troop_effect
      ($game_party.members | $game_troop.members).each {|member| member.check_troop_effects}
      @troop_effect = false
    end
  end
end

# Allow scenes to store an effect callback, which can be set when the scene
# is called
class Scene_Base
  
  def set_effect_callback(method, effect)
    @effect_callback = method
    @effect = effect
  end
end

class Scene_Battle < Scene_Base
  
  alias :th_effect_manager_turn_start :turn_start
  def turn_start
    th_effect_manager_turn_start
    all_battle_members.each do |battler|
      battler.on_turn_start
      refresh_status
    end
  end
end
    
# Display all of the effect messages. Since I couldn't find a nice place to
# put it I simply put it before the affected status, which is ok to come near
# the end...
class Window_BattleLog
  
  alias :th_effect_manager_display_status :display_affected_status
  def display_affected_status(target, item)
    target.result.effect_results.each {|msg|
      add_text(msg)
      wait
    }
    th_effect_manager_display_status(target, item)
  end
end
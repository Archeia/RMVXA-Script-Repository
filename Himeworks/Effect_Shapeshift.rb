=begin
#===============================================================================
 ** Effect: Shape shift
 Author: Hime
 Date: Sep 8, 2015
--------------------------------------------------------------------------------
 ** Change log
 Sep 8, 2015
   - fixed bug where game crashes when enemy shapeshift state is removed
 Jun 3, 2015
   - fixed item dupe bug
   - fixed equip revert crash issue
 Jun 1, 2015
   - pull actor data from game actor, not database actor
 Sep 12, 2013
   - equips are changed to the new battler's equips
   - changing equips and skills are now optional
 Mar 10, 2013
   - old equips are re-equipped after transformation process
 Mar 9, 2013
   - updates character name and index, class, and initializes skills
 Oct 25, 2012
   - added support for actor transform
 Oct 10, 2012
   - initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
-------------------------------------------------------------------------------- 
 ** Description
 
 Adds a "Shape shift" effect to your state.
 When this state is active, the battler will be transformed to a different
 battler specified by the state.

--------------------------------------------------------------------------------
 ** Required
 
 Effects Manager
 (http://himeworks.com/2012/10/05/effects-manager/)
--------------------------------------------------------------------------------
 ** Usage
 
 Tag your state with
    <eff: shape_shift battler_ID change_equips change_skills>
    
 Where
   `battler_id` - either the ID of the actor or an enemy, depending on the
                  battler type
   `change_equips` - true or false, if you want to transform equips
   `change_skills` - true or false, if you want to transform skills
   
 If you don't want to change equips or skills, then your old equips or skills
 will only be preserved if the transformed battler can equip or use those
 equips or skills. 
 
--------------------------------------------------------------------------------
 ** Example
 
 If you want to change to actor 5, change the equips to the new actor's 
 equips, but use the original actor's skills, tag a state with
 
   <eff: shape_shift 5 true false>
   
 Actor 5 will need to have the appropriate "equip" and "skill type" features.
   
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Effect_Shapeshift"] = true
#===============================================================================
# ** Rest of the script
#===============================================================================
module Effects
  module Shape_Shift
    Effect_Manager.register_effect(:shape_shift)
  end
end

module RPG
  class State < BaseItem
    def add_effect_shape_shift(code, data_id, args)
      # type cast your args here
      args[1] = args[1] ? args[1].downcase == "true" : false
      args[2] = args[2] ? args[2].downcase == "true" : false
      # now add the effect to the object
      add_effect(code, data_id, args)
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  def state_effect_shape_shift_add(state, effect)
    new_form_id = effect.value1[0].to_i
    effect_transform(new_form_id, effect)
  end
  
  def state_effect_shape_shift_remove(state, effect)
    revert_transform(effect)
  end
  
  def effect_transform(new_id, effect)
  end
  
  def revert_transform(effect)
  end
end

class Game_Enemy < Game_Battler
  
  def state_effect_shape_shift_add(state, effect)
    @old_form_id = enemy.id
    @old_hp = self.hp
    @old_mp = self.mp
    @old_name = @name
    super
  end
  
  def effect_transform(new_id, effect)
    transform(new_id)
    super
  end
  
  def revert_transform(effect)
    transform(@old_form_id)
    @name = @old_name
    self.hp = @old_hp
    self.mp = @old_mp
    super
  end
end

class Game_Actor < Game_Battler
  
  def effect_transform(actor_id, effect)
    new_actor = Marshal.load(Marshal.dump($game_actors[actor_id]))
    @actor_id = actor_id
    @name = new_actor.name
    change_class(new_actor.class_id, true)
    init_skills if effect.value1[1]
    if effect.value1[2]
      curr_equips = equips
      new_equips = new_actor.equips
      new_equips.each_with_index {|equip, slot_id|
        change_equip(slot_id, equip) if equip != curr_equips[slot_id]
      }
    end
    @face_name = new_actor.face_name
    @face_index = new_actor.face_index
    @character_index = new_actor.character_index
    @character_name = new_actor.character_name
    refresh
    super
  end
  
  def revert_transform(effect)
    @actor_id = @old_form_id
    @name = @old_name
    change_class(@old_class_id, true)
    init_skills if effect.value1[1]
    if effect.value1[2]
      curr_equips = equips
      @old_equips.each_with_index {|equip, slot_id|
        change_equip(slot_id, equip) if equip != curr_equips[slot_id]
      }
    end
    @face_name = @old_face_name
    @face_index = @old_face_index
    @character_index = @old_character_index
    @character_name = @old_character_name
    self.hp = @old_hp
    self.mp = @old_mp
    super
  end
  
  #-----------------------------------------------------------------------------
  # Save the equips since we might remove them
  #-----------------------------------------------------------------------------
  def state_effect_shape_shift_add(state, effect)
    @old_form_id = @actor_id
    @old_equips = equips
    @old_hp = self.hp
    @old_mp = self.mp
    @old_name = @name
    @old_class_id = @class_id
    @old_face_name = face_name
    @old_face_index = face_index
    @old_character_index = character_index
    @old_character_name = character_name
    super
  end
end

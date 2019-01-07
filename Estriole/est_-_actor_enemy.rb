=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - ACTOR ENEMY v1.2
 by Estriole
 
 ■ License          ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE). 
 
 ■ Extra Credit   ╒═════════════════════════════════════════════════════════╛ 
 None yet
 
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
 RPG Maker VX ACE
 
 optional:
 - yanfly weapon attack replace script
 
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
 Want to have actor which will become enemy later? after you raise his/her level
 and give him/her good equipment. suddenly s/he goes back against you...
 
 or you just want to create something like suikoden IV where you can battle your
 friends for exp.
 
 ■ Features         ╒═════════════════════════════════════════════════════════╛
 - Enemy copy actor stats
 - Enemy copy actor trait
 - Enemy use both actor and enemy traits.
 - Enemy copy some of actor stats (only hp, only atk and def, etc)
 - Enemy copy actor stats and some modded by percentage
 - Enemy use actor attack skill id (need yanfly weapon attack replace script)
 - Can change enemy equipment (affect stat and attack skill id)
 - Compatibility with custom enemy AI
 - Built in Compatibility with yanfly weapon attack replace.
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.11.06           Initial Release
 v1.1 2013.12.10           compatibility with tsukihime enemy level and class script
                           add notetags to give equips to enemy even when no actor assigned
 v1.2 2014.08.15           simple fix for emerges messages
 
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 - Compatibility with custom enemy AI
 - Built in Compatibility with yanfly weapon attack replace.
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 1) to link actor to enemy. give notetags to ENEMY.
 <actor_enemy: x>
 x=> change to actor id you want enemy to copy it's parameter, traits, and equip
 
 ex:
 <actor_enemy: 1>
 will make that enemy have [actor 1] stat, trait, equipment, attack skill id
 (if using yanfly weapon attack replace script)
 
 [optional feature]
 -) the enemy use skill based on what you set in enemy AI in database. but if
 you want case like this:
 if actor 1 equipping muramasa. then the normal attack is muramasa slash.
 if actor 1 equipping gun and roses. then the normal attack is thorn shot.
 
 you can create a SKILL with these notetags:
  <use_actor_attack> 
 it will transform the skill to Actor Enemy attack skill id.
 
 -) if you use enemy ai script. you can use $game_actors[x].have_skill(id)
 for checking does the actor have that skill at current time. if actor have that
 skill it will return true.
 
 -) if you want to make the enemy based on actor. but want to customize it like
 giving it 10x hp, etc. here's list of notetags you can use with explanation.
 use it in ENEMY notetags !

 === trait and effect ===
 <merge_both_trait>     will merge both actor and enemy traits
 <merge_both_effect>    will merge both actor and enemy effects (if using tsukihime effect manager)
 <use_enemy_trait>      will ONLY use enemy traits and don't use actor traits
 <use_enemy_effect>     will ONLY use enemy effects and don't use actor effects

 === name, level, equip, class, subclass ===
 <use_enemy_name>       will use enemy name instead of actor name
 <use_enemy_level>      will use enemy level instead of actor level (if using level script)
 <use_enemy_equip>      will use enemy equip instead of actor equip (if using enemy equip script)
 <use_enemy_class>      will use enemy class instead of actor class (if using enemy class script)
 <use_enemy_subclass>   will use enemy subclass instead of actor subclass (if using enemy class script)

 give enemy equip even no actor assigned
 <enemy_equips>
 $data_weapons[x]
 $data_armors[y]
 $data_armors[z]
 </enemy_equips>
 
 === use enemy stats ===
 <use_enemy_hp>         will use hp set in database instead of actor hp
 <use_enemy_mp>         will use mp set in database instead of actor mp
 <use_enemy_atk>        will use atk set in database instead of actor atk
 <use_enemy_def>        will use def set in database instead of actor def
 <use_enemy_matk>       will use matk set in database instead of actor matk
 <use_enemy_mdef>       will use mdef set in database instead of actor mdef
 <use_enemy_agi>        will use agi set in database instead of actor agi
 <use_enemy_luk>        will use luk set in database instead of actor luk

 === stats ignoring equip === 
 <hp_ignore_equip>      hp will ignore bonus from equipment
 <mp_ignore_equip>      mp will ignore bonus from equipment
 <atk_ignore_equip>     atk will ignore bonus from equipment
 <def_ignore_equip>     def will ignore bonus from equipment
 <matk_ignore_equip>    matk will ignore bonus from equipment
 <mdef_ignore_equip>    mdef will ignore bonus from equipment
 <agi_ignore_equip>     agi will ignore bonus from equipment
 <luk_ignore_equip>     luk will ignore bonus from equipment
 
 === use actor stat but modded === 
 <actor_hp_mod: x>      will use actor hp but multiplied by x percent
 <actor_mp_mod: x>      will use actor mp but multiplied by x percent
 <actor_atk_mod: x>     will use actor atk but multiplied by x percent
 <actor_def_mod: x>     will use actor def but multiplied by x percent
 <actor_matk_mod: x>    will use actor matk but multiplied by x percent
 <actor_mdef_mod: x>    will use actor mdef but multiplied by x percent
 <actor_agi_mod: x>     will use actor agi but multiplied by x percent
 <actor_luk_mod: x>     will use actor luk but multiplied by x percent
 
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 None
 
=end


module ESTRIOLE
  module ACTOR_ENEMY
    #set below to true if you're using enemy level script
    USE_ENEMY_LEVEL_SCRIPT = true
    
    #set below to true if you're using enemy equip script
    USE_ENEMY_EQUIP_SCRIPT = false
    
    #set below to true if you're using enemy class script
    USE_ENEMY_CLASS_SCRIPT = true
    
    #set below to true if you're using enemy subclass script
    USE_ENEMY_SUBCLASS_SCRIPT = false
        
    # if we change enemy equip in the middle of battle
    # it can choose the action that should only able to used in next turn instead.
    # set this to true to prevent that.
    USE_TURN_CORRECTION = true
    
  end
end

class Game_Enemy < Game_Battler
  alias :est_actor_enemy_feature_objects :feature_objects
  def feature_objects
    return est_actor_enemy_feature_objects if !actor || enemy.use_enemy_trait
    return actor.feature_objects + est_actor_enemy_feature_objects if enemy.merge_both_trait
    return actor.feature_objects
  end  
  if $imported["Effect_Manager"]
    alias :est_actor_enemy_hime_effect_objects :effect_objects
    def effect_objects
      return est_actor_enemy_hime_effect_objects if !actor || enemy.use_enemy_effect
      return actor.effect_objects + est_actor_enemy_hime_effect_objects if enemy.merge_both_effect
      return actor.effect_objects
    end
  end
  def actor
    return nil if !enemy.actor_enemy
    @actor = Marshal.load(Marshal.dump($game_actors[enemy.actor_enemy])) if !@actor
    @actor
  end
  alias :est_actor_enemy_attack_skill_id :attack_skill_id
  def attack_skill_id
    return est_actor_enemy_attack_skill_id if !actor
    return weapon_attack_skill_id if weapon_attack_skill_id
    return actor.attack_skill_id
  end
  def weapon_attack_skill_id
    for equip in equips
      next if equip.nil?
      next if !equip.is_a?(RPG::Weapon)
      next if chk = !equip.attack_skill rescue true
      return equip.attack_skill
    end
    return nil
  end
  
  def change_equip(slot_id,item)
    @equips[slot_id] = item
    actor.force_change_equip(slot_id,item) if actor
    a = $game_troop.minus_turn rescue nil if ESTRIOLE::ACTOR_ENEMY::USE_TURN_CORRECTION  
    make_actions unless @actions.empty? 
    a = $game_troop.plus_turn rescue nil if ESTRIOLE::ACTOR_ENEMY::USE_TURN_CORRECTION
  end

  alias :est_actor_enemy_class :class if method_defined?(:class) && ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_CLASS_SCRIPT
  def class
    return main = actor.class rescue nil if actor && !enemy.use_enemy_class
    return main = est_actor_enemy_class rescue nil if ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_CLASS_SCRIPT
    return main = nil
  end
  
  alias :est_actor_enemy_subclass :subclass if method_defined?(:subclass) && ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_SUBCLASS_SCRIPT
  def subclass
    return sub = actor.subclass rescue nil if actor && !enemy.use_enemy_subclass
    return sub = est_actor_enemy_subclass rescue nil if ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_SUBCLASS_SCRIPT
    return sub = nil
  end
  
  alias :est_actor_enemy_name :name
  def name
    return est_actor_enemy_name if enemy.use_enemy_name
    actor ? actor.name : est_actor_enemy_name
  end
  
  def original_name
    name
  end
  
  alias :est_actor_enemy_param_base :param_base
  def param_base(param_id)
    return est_actor_enemy_param_base(param_id) if !actor
    (0..7).each do |pid|
      return est_actor_enemy_param_base(param_id) if param_id == pid && enemy.use_enemy_stat(pid)
    end
    #some precaution if someone add something in actor param plus
    plus_except_equip = actor.param_plus(param_id) - actor.param_from_equip(param_id)
    a = actor.param_base(param_id) + plus_except_equip
    (0..7).each do |pid|
      a = (a * enemy.actor_stat_mod(pid) / 100.0).to_i if param_id == pid && enemy.actor_stat_mod(pid)
    end
    return a
  end
  def param_plus(param_id)
    return 0 if enemy.stat_ignore_equip(param_id)
    equips.compact.inject(super) {|r, item| r += item.params[param_id] }    
  end
  alias :est_actor_enemy_equips :equips if ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_EQUIP_SCRIPT  
  def equips
    return @equips if @equips
    return @equips = actor.equips if actor && !enemy.use_enemy_equip
    return @equips = est_actor_enemy_equips rescue [] if ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_EQUIP_SCRIPT
    return @equips = enemy.enemy_equips
    @equips
  end
  alias :est_actor_enemy_level :level if ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_LEVEL_SCRIPT
  def level
    return actor.level if actor && !enemy.use_enemy_level
    return level = est_actor_enemy_level rescue 0  if ESTRIOLE::ACTOR_ENEMY::USE_ENEMY_LEVEL_SCRIPT
    return enemy.enemy_level
  end
  alias :est_actor_enemy_transform :transform
  def transform(enemy_id)
    est_actor_enemy_transform(enemy_id)
    @actor = nil
    @equips = nil
    make_actions unless @actions.empty?    
  end
end

class RPG::Enemy < RPG::BaseItem
  #notetags to flag enemy actor
  def actor_enemy
    return nil if !note[/<actor_enemy:(.*)>/im]
    a = note[/<actor_enemy:(.*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i rescue nil
  end
  def enemy_equips
    return [] if !note[/<enemy_equips?>(?:[^<]|<[^\/])*<\/enemy_equips?>/i]
    a = note[/<enemy_equips?>(?:[^<]|<[^\/])*<\/enemy_equips?>/i].scan(/(?:!<enemy_equips?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("[#{a}]") rescue []    
  end
  #merge both actor and enemy trait so you can add trait hp 200% to double the actor hp
  def merge_both_trait
    return false if !note[/<merge_both_trait>/im]
    return true if note[/<merge_both_trait>/im]    
  end
  #merge both actor and enemy effect
  def merge_both_effect
    return false if !note[/<merge_both_effect>/im]
    return true if note[/<merge_both_effect>/im]    
  end
  #use enemy trait instead of actor
  def use_enemy_trait
    return false if !note[/<use_enemy_trait>/im]
    return true if note[/<use_enemy_trait>/im]
  end
  #use enemy effect instead of actor
  def use_enemy_effect
    return false if !note[/<use_enemy_effect>/im]
    return true if note[/<use_enemy_effect>/im]
  end
  #notetags for use enemy data in database
  def use_enemy_class
    return false if !note[/<use_enemy_class>/im]
    return true if note[/<use_enemy_class>/im]
  end
  #notetags for use enemy data in database
  def use_enemy_subclass
    return false if !note[/<use_enemy_subclass>/im]
    return true if note[/<use_enemy_subclass>/im]
  end
  #notetags for use enemy data in database
  def use_enemy_name
    return false if !note[/<use_enemy_name>/im]
    return true if note[/<use_enemy_name>/im]
  end
  def use_enemy_level
    return false if !note[/<use_enemy_level>/im]
    return true if note[/<use_enemy_level>/im]
  end
  def use_enemy_equip
    return false if !note[/<use_enemy_equip>/im]
    return true if note[/<use_enemy_equip>/im]
  end
  #notetags for using some of enemy stat from database instead of actor.
  def use_enemy_stat(pid)
    case pid
    when 0; statname = "hp"
    when 1; statname = "mp"
    when 2; statname = "atk"
    when 3; statname = "def"
    when 4; statname = "matk"
    when 5; statname = "mdef"
    when 6; statname = "agi"
    when 7; statname = "luk"
    else; statname = "#{pid}"
    end
    return false if !note[/<use_enemy_#{statname}>/im]
    return true if note[/<use_enemy_#{statname}>/im]
  end
  #notetags for percentage of actor status the enemy have
  def actor_stat_mod(pid)
    case pid
    when 0; statname = "hp"
    when 1; statname = "mp"
    when 2; statname = "atk"
    when 3; statname = "def"
    when 4; statname = "matk"
    when 5; statname = "mdef"
    when 6; statname = "agi"
    when 7; statname = "luk"
    else; statname = "#{pid}"
    end
    return nil if !note[/<actor_#{statname}_mod:(.*)>/im]
    a = note[/<actor_#{statname}_mod:(.*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i rescue nil
  end
  def stat_ignore_equip(pid)
    case pid
    when 0; statname = "hp"
    when 1; statname = "mp"
    when 2; statname = "atk"
    when 3; statname = "def"
    when 4; statname = "matk"
    when 5; statname = "mdef"
    when 6; statname = "agi"
    when 7; statname = "luk"
    else; statname = "#{pid}"
    end
    return false if !note[/<#{statname}_ignore_equip>/im]
    return true if note[/<#{statname}_ignore_equip>/im]    
  end  
end

class Game_Actor < Game_Battler
  attr_reader :battler_name
  def param_from_equip(param_id)
    temp = 0
    equips.compact.inject(temp) {|r, item| r += item.params[param_id] }    
  end
  def have_skill(sid)
    return true if skills.include?($data_skills[sid])
    return false
  end
  def params
    self.class.params
  end
end

class Game_Action
  alias :est_actor_enemy_set_enemy_action :set_enemy_action 
  def set_enemy_action(action)
    chk = action && $data_skills[action.skill_id].use_actor_attack && subject.is_a?(Game_Enemy) && subject.actor
    return set_skill(subject.attack_skill_id) if chk
    est_actor_enemy_set_enemy_action(action)
  end
end

class RPG::Skill < RPG::UsableItem
  def use_actor_attack
    return false if !note[/<use_actor_attack>/im]
    return true if note[/<use_actor_attack>/im]    
  end
end

class Game_Troop < Game_Unit
  def plus_turn
    troop.pages.each {|page| @event_flags[page] = false if page.span == 1 }
    @turn_count += 1
  end
  def minus_turn
    troop.pages.each {|page| @event_flags[page] = false if page.span == 1 }
    @turn_count -= 1
  end
end
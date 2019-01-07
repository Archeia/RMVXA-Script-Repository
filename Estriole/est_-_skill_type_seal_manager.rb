=begin
EST - SKILL TYPE SEAL MANAGER
v.1.0

version history
v.1.0 - 2013.02.08 - finish the script

Feature:
1) seal the skill type COMMAND in battle.
2) can seal ALL skill type using notetags (instead of adding it one by one)
3) can seal skill type which belong to certain category (you define it)
   instead of adding it one by one.

Introduction:
when we add skill type to actor and then add trait to seal that skill type...
in battle the command of that skill type still enabled. then when we enter the command
inside the skill list then the skills are all greyed. this script change this behavior.
so now the skill type COMMAND is greyed instead. it will inform player faster
that those skill types is Sealed (because of enemy making you silenced, etc).
without need to enter the skill window to know that that skill type sealed.

this script also provide way to add notetags to seal ALL skill type instead of adding
each skill type you want to seal one by one to traits box.

this script also provide way to add notetags to seal CERTAIN group of skill type
instead of adding each skill type you want to seal one by one to trait box.

Compatibility
if using any script that change 'attack'/'guard' skill id such as yanfly weapon attack replace,
victor's attack and guard skill, and other...

you MUST made the attack and guard skill SKILL TYPE to None. or it will be disabled too
when you give tag <all_stype_seal>. since basically the attack, and guard is also skill.
and if have skill type it will check if the skill type sealed then the command is sealed.

if you still NEED to use stype_id for your attack / guard skill. for whatever the purpose is...
add the configuration what skill type id that don't get sealed using all skill seal  
then you need to seal the stype manually using trait box.

How to use:
basically just seal the skill via trait box and you'll see the difference.

advanced usage:
1) seal all skill type:
give notetags to actor/class/subclass/weapon/armor/state
<all_stype_seal>

2) seal skill type by category:
first define the category inside the hash in module ESTRIOLE.
format is like this:
:category => [stypeid,stypeid,stypeid,stypeid],
then just give notetags to the actor/class/subclass/weapon/armor/state
<x_stype_seal>
where x replaced by the category name you define above (minus :)

=end

module ESTRIOLE
  EXCLUDED_STYPE_SEAL_ALL = []  # array of stype id that NOT sealed when using <all_stype_seal> notetags
                                   # Skill type: "None" will ALWAYS excluded  
  STYPE_CATEGORY = { #do not touch
  :physical => [1,8],         #add your category here (:category). then add the stype id in that category
  :magical => [2,3,4,5,6,7],  #don't forget give ,(coma) at end of category.
  :supernatural => [8,2,3],   #remember don't use :all as category. since it won't be read.
  
  }#do not touch
  #----------------------------------------------------------------------------#
  # from above setting you can use notetags like this:
  #  <x_stype_seal>
  #  x=> your category name
  #
  # from above example:
  #  <physical_stype_seal> -> will seal stype 1 and 8
  #
  #----------------------------------------------------------------------------#
end

class RPG::BaseItem
  def all_stype_seal?
    return false if !@note[/<all_stype_seal>/i]
    return true if @note[/<all_stype_seal>/i]
  end
  def stype_category_seal?(cat)
    return false if !@note[/<#{cat}_stype_seal>/i]
    return true if @note[/<#{cat}_stype_seal>/i]
  end
end

class Game_Actor < Game_Battler
  def all_stype_seal?
    return true if actor.all_stype_seal?
    return true if $data_classes[@class_id].all_stype_seal?
    return true if $imported["YEA-ClassSystem"] &&
                   $data_classes[@subclass_id] &&
                   $data_classes[@subclass_id].all_stype_seal?
    equips.each do |equip|
     next if !equip
     return true if equip.all_stype_seal?
    end    
    states.each do |state|
     return true if state.all_stype_seal?
    end
    return false
  end
  def stype_category_seal?(cat)
    return true if actor.stype_category_seal?(cat)
    return true if $data_classes[@class_id].stype_category_seal?(cat)
    return true if $imported["YEA-ClassSystem"] &&
                   $data_classes[@subclass_id] &&
                   $data_classes[@subclass_id].stype_category_seal?(cat)
    equips.each do |equip|
     next if !equip
     return true if equip.stype_category_seal?(cat)
    end    
    states.each do |state|
     return true if state.stype_category_seal?(cat)
    end
    return false    
  end
  alias est_stype_seal_modify_skill_type_sealed? skill_type_sealed?  
  def skill_type_sealed?(stype_id)
    excluded = [0] + ESTRIOLE::EXCLUDED_STYPE_SEAL_ALL
    return true if all_stype_seal? && !excluded.include?(stype_id)
    ESTRIOLE::STYPE_CATEGORY.each do |cat|
     return true if stype_category_seal?(cat[0].to_s) if cat[1].include?(stype_id) && stype_id != 0
    end
    est_stype_seal_modify_skill_type_sealed?(stype_id)
  end
end

class Window_ActorCommand < Window_Command
  alias est_stype_seal_modify_command_list make_command_list
  def make_command_list
    est_stype_seal_modify_command_list
    modify_stype_seal
  end
  def modify_stype_seal
    @list.each do |command|
      next if command[:symbol] != :skill
      command[:enabled] = command[:enabled] && !@actor.skill_type_sealed?(command[:ext]) if command[:ext] != nil
    end
  end
end
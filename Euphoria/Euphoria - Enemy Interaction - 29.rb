#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                           *Enemy Interaction*
#│                              Version: 1.0
#│                            Author: Euphoria
#│                             Date: 9/1/2014
#│                        Euphoria337.wordpress.com
#│                        
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: None                          
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: To set up the interaction skills, first go to the database
#│                under the skills tab. You need to create two new skills:
#│                
#│                Skill One (Talk):
#│                Name the skill "Talk", set it's scope to "one enemy", and in
#│                the notebox, put the tag <talk skill>. Make sure the hit type
#│                is set to "certain hit". You should leave the damage formula,
#│                weapon requirements, skill costs, and anything else not
#│                mentioned, blank. You can however, change the skill's message
#│                if you would like to.
#│                                           
#│                Skill Two (Give):
#│                Name the skill "Give", set it's scope to "one enemy", and in
#│                the notebox, put the tag <give skill>. Make sure the hit type
#│                is set to "certain hit". You should leave the damage formula,
#│                weapon requirements, skill costs, and anything else not
#│                mentioned, blank. You can however, change the skill's message
#│                if you would like to.
#│                
#│                You WILL NOT be assigning these skills to any class, all you
#│                have to do is set the skill ID numbers of the talk and give   
#│                skills to match the options in the configuration settings. Now
#│                the skills will appear on their own, when available.
#│                                            
#│                The rest of the instructions take place in the database, under
#│                the enemy tab.
#│                 
#│                To allow these skills to be used, the enemies must be tagged
#│                appropriately. For any enemy you want to be able to use the
#│                talk skill on, put the following tag in the enemy's notebox:
#│
#│                <interact: talk>
#│
#│                For enemies you only wish to use the give skill on, use the
#│                tag:
#│
#│                <interact: give>
#│
#│                If you want to be able to talk and give to the enemy, there's 
#│                no need to make separate tags for each, just use this tag:
#│
#│                <interact: talk give>
#│
#│                Do note that when using both, talk MUST come before give. Next
#│                we will set up the enemy's response to the talk skill with
#│                this tag:
#│
#│                <reply: Your text here!>
#│
#│                Notice that quotes are not needed for your enemy's response.
#│                So, how about the give skill? Well the give skill will let you
#│                give any item to an enemy that you want, but in order to set
#│                up conditions for giving the right or wrong items later on, 
#│                for now we will use this tag to tell what item the enemy 
#│                actually wants:
#│
#│                <wants: x: y>
#│
#│                When using this tag, you will replace the "x" with either i, 
#│                w, or a. "y" will be replaced with an item ID. If you replaced
#│                "x" with i, "y" should be replaced with the item ID number you
#│                want the enemy to accept. So in the default database, a potion
#│                is ID number 1, so setting "x" to i, and "y" to 1, would make
#│                this enemy accept a potion! w stands for weapon, so the "y" 
#│                would then be a weapon ID number. a is for armor, and the same
#│                rules apply.
#│
#│                Now, we can talk to an enemy, it can tell us what it wants (or
#│                anything else you want it to say), and we can then give it an 
#│                an item. You probably want something to happen depending on if
#│                you gave the enemy the right item or not, right? So there are
#│                three "result" tags that you can use, these will be explained,
#│                but for now, here they are:
#│
#│                <talk result: x y z>
#│
#│                <correct give result: x y z>
#│
#│                <incorrect give result: x y z>
#│
#│                "x", "y", and "z" in all three of these tags are the same. "x"
#│                will be replaced with the resulting action TYPE. The different
#│                types of results are:
#│
#│                buff, debuff, state, skill, escape
#│
#│                You can probably guess what they will do, but what about the 
#│                other two spaces in the note tag?! Well, let's start with the
#│                easiest result and move to the hardest. When using escape as
#│                the result (in place of "x"), you do NOT need to worry about
#│                "y" and "z". So to make the enemy escape after giving it the
#│                correct item, the tag would look like this:
#│
#│                <correct give result: escape>
#│
#│                Now for states and skills. They still follow the same type of
#│                format, but for states and skills "y" will also be used. "y"
#│                represents the ID number of the state or skill you want the
#│                result to be. So if you want to make the enemy use skill 51
#│                after talking to it the tag would look like this:
#│
#│                <talk result: skill 51>
#│
#│                or let's say you want to add state 2 to the enemy when you 
#│                give it the wrong item, that tag would look like this:
#│
#│                <incorrect give result: state 2>
#│
#│                Finally, for buffs and debuffs, you will use all three spots,
#│                "x", "y", and "z". Hopefully by now you at least know what "x"
#│                should be replaced with. "y" is a bit tricky for buffs and
#│                debuffs. "y" represents the parameter to be buffed or debuffed
#│                but "y" must be a number! These are the numbers corresponding
#│                to their parameters:
#│
#│                0 = Max Health Points
#│                1 = Max Mana Points
#│                2 = Attack
#│                3 = Defense
#│                4 = Magic Attack
#│                5 = Magic Defense
#│                6 = Agility
#│                7 = Luck
#│
#│                And lastly, "z" will also be a number, it will be the number
#│                of turns the buff or debuff will last for. So let's say that
#│                upon being given the wrong item, the enemy gets a 5-turn buff
#│                to it's attack. The note tag for that would look like this:
#│
#│                <incorrect give result: buff 2 5>
#│
#│                Hopefully you understand all the tags by now, but I'll go 
#│                through a final example just in case.
#│
#│                This enemy can be talked to or have items given to it. When 
#│                talking to it, it will tell you that it wants a potion, but
#│                also use skill 47 as it's next attack. The enemy is in fact
#│                telling the truth, and really does want a potion, but if you
#│                give it something different, it will gain a buff to it's luck
#│                for 3 turns. If you do happen to give the enemy the potion it 
#│                wants, it will leave the battle! The enemy's note box would 
#│                look like this:
#│
#│                <interact: talk give>
#│                <reply: I want a potion!>
#│                <talk result: skill 47>
#│                <wants: i: 1>
#│                <correct give result: escape>
#│                <incorrect give result: buff 7 3>
#│
#│                And that's all there is to it!
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaEnemyInteraction"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module EnemyInteraction
    
    TALK_SKILL_ID   = 127 #The Skill ID of your Talk Skill
    
    GIVE_SKILL_ID   = 128 #The Skill ID of your Give Skill
    
    #ONLY set ONE of the following two options to true!
    
    GIVE_ITEMS_ONLY = true #If true, only items can be given to enemies
    
    GIVE_ANYTHING   = false #If true, weapons and armor can also be given
    
  end
  module RegexInteraction
    
    REGEX_STALK = /<(talk)[-_ ]?skill>/i
    
    REGEX_SGIVE = /<(give)[-_ ]?skill>/i
    
    REGEX_CMDS  = /<interact:[-_ ]?(talk)?[-_ ]?(give)?>/i
    
    REGEX_MSG   = /<reply:[-_ ]?(.+)>/i
    
    REGEX_TALKR = /<talk[-_ ]?result:[-_ ]?(debuff|buff|skill|state|escape)[-_ ]?(\S+)?[-_ ]?(\S+)?>/i
    
    REGEX_WANTS = /<wants:[-_ ]?([iwa]):[-_ ]?(\d+)>/i
    
    REGEX_GIVER = /<correct[-_ ]?give[-_ ]?result:[-_ ]?(debuff|buff|skill|state|escape)[-_ ]?(\S+)?[-_ ]?(\S+)?>/i
    
    REGEX_GIVEW = /<incorrect[-_ ]?give[-_ ]?result:[-_ ]?(debuff|buff|skill|state|escape)[-_ ]?(\S+)?[-_ ]?(\S+)?>/i
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ DataManager
#└──────────────────────────────────────────────────────────────────────────────
class << DataManager

  #ALIAS - LOAD_DATABASE
  alias euphoria_interact_datamanager_loaddatabase_29 load_database
  def load_database
    euphoria_interact_datamanager_loaddatabase_29
    load_interact_notetags
  end
 
  #NEW - LOAD_INTERACT_NOTETAGS
  def load_interact_notetags
    groups = [$data_enemies, $data_skills]
    for group in groups
      for obj in group
        next if obj.nil?
      obj.load_interact_notetags
      end
    end
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ RPG::Enemy
#└──────────────────────────────────────────────────────────────────────────────
class RPG::Enemy < RPG::BaseItem
  attr_accessor :talk_cmd
  attr_accessor :give_cmd
  attr_accessor :message
  attr_accessor :wanted_item
  attr_accessor :talk_result_type
  attr_accessor :talk_result_id
  attr_accessor :talk_result_duration_or_target
  attr_accessor :give_result_type
  attr_accessor :give_result_id
  attr_accessor :give_result_duration_or_target
  attr_accessor :wrong_give_result_type
  attr_accessor :wrong_give_result_id
  attr_accessor :wrong_give_result_duration_or_target
  
  #NEW - LOAD_INTERACT_NOTETAGS
  def load_interact_notetags
    @talk_cmd = false
    @give_cmd = false
    @message = nil
    @wanted_item = nil
    @talk_result_type = nil
    @talk_result_id = nil
    @talk_result_duration_or_target = nil
    @give_result_type = nil
    @give_result_id = nil
    @give_result_duration_or_target = nil
    @wrong_give_result_type = nil
    @wrong_give_result_id = nil
    @wrong_give_result_duration_or_target = nil
    self.note.scan(Euphoria::RegexInteraction::REGEX_CMDS)
    if $1 != nil
      @talk_cmd = true
    end
    if $2 != nil
      @give_cmd = true
    end
    self.note.scan(Euphoria::RegexInteraction::REGEX_MSG)
    @message = $1.to_s
    self.note.scan(Euphoria::RegexInteraction::REGEX_TALKR)
    @talk_result_type = $1.to_s.upcase
    @talk_result_id = $2.to_i
    if $1.to_s.upcase == "DEBUFF" || $1.to_s.upcase == "BUFF"
      @talk_result_duration_or_target = $3.to_i
    end
    self.note.scan(Euphoria::RegexInteraction::REGEX_WANTS)
    case $1.to_s.upcase
    when "I"
      @wanted_item = $data_items[$2.to_i]
    when "W"
      @wanted_item = $data_weapons[$2.to_i]
    when "A"
      @wanted_item = $data_armors[$2.to_i]
    end
    self.note.scan(Euphoria::RegexInteraction::REGEX_GIVER)
    @give_result_type = $1.to_s.upcase
    @give_result_id = $2.to_i
    if $1.to_s.upcase == "DEBUFF" || $1.to_s.upcase == "BUFF"
      @give_result_duration_or_target = $3.to_i
    end
    self.note.scan(Euphoria::RegexInteraction::REGEX_GIVEW)
    @wrong_give_result_type = $1.to_s.upcase
    @wrong_give_result_id = $2.to_i
    if $1.to_s.upcase == "DEBUFF" || $1.to_s.upcase == "BUFF"
      @wrong_give_result_duration_or_target = $3.to_i
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ RPG::UsableItem
#└──────────────────────────────────────────────────────────────────────────────
class RPG::UsableItem < RPG::BaseItem
  attr_accessor :talk_skill
  attr_accessor :give_skill
  
  #NEW - LOAD_INTERACT_NOTETAGS
  def load_interact_notetags
    @talk_skill = false
    @give_skill = false
    self.note.scan(Euphoria::RegexInteraction::REGEX_STALK)
    if $1.to_s.upcase == "TALK"
      @talk_skill = true
    end
    self.note.scan(Euphoria::RegexInteraction::REGEX_SGIVE)
    if $1.to_s.upcase == "GIVE"
      @give_skill = true
    end
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_Action
#└────────────────────────────────────────────────────────────────────────────── 
class Game_Action
  
  #NEW - SET_TALK
  def set_talk
    set_skill(subject.talk_skill_id)
    self
  end
  
  #NEW - SET_GIVE
  def set_give
    set_skill(subject.give_skill_id)
    self
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_BatlerBase
#└────────────────────────────────────────────────────────────────────────────── 
class Game_BattlerBase
  
  #NEW - TALK_SKILL_ID
  def talk_skill_id
    return Euphoria::EnemyInteraction::TALK_SKILL_ID
  end
  
  #NEW - GIVE_SKILL_ID
  def give_skill_id
    return Euphoria::EnemyInteraction::GIVE_SKILL_ID
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_Battler
#└────────────────────────────────────────────────────────────────────────────── 
class Game_Battler < Game_BattlerBase
  
  #ALIAS - ITEM_USER_EFFECT
  alias euphoria_interact_gamebattler_itemusereffect_29 item_user_effect
  def item_user_effect(user, item)
    euphoria_interact_gamebattler_itemusereffect_29(user, item)
    execute_interaction_skills(user, item)
  end
  
  #NEW - EXECUTE_INTERACTION_SKILLS
  def execute_interaction_skills(user, item)
    if item.talk_skill == true
      apply_talk_effect(user, item)
    end
    if item.give_skill == true
      apply_give_effect(user, item)
    end
  end
  
  #NEW - APPLY_TALK_EFFECT
  def apply_talk_effect(user, item)
    @result.success = true
  end
  
  #NEW - APPLY_GIVE_EFFECT
  def apply_give_effect(user, item)
    @result.success = true
  end
  
  #NEW - NEW_FORCE_ACTION
  def new_force_action(skill_id)
    clear_actions
    action = Game_Action.new(self, true)
    action.set_skill(skill_id)
    action.decide_random_target
    @actions.push(action)
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_Enemy
#└──────────────────────────────────────────────────────────────────────────────    
class Game_Enemy < Game_Battler
  attr_accessor :enemy_message
  attr_accessor :wanted_item
  attr_accessor :talk_effect
  attr_accessor :give_effect
  attr_accessor :wrong_give_effect
  
  #ALIAS - INITIALIZE
  alias euphoria_interact_gameenemy_initialize_29 initialize
  def initialize(index, enemy_id)
    euphoria_interact_gameenemy_initialize_29(index, enemy_id)
    @enemy_message = ""
    @wanted_item = nil
    @talk_effect = nil
    @give_effect = nil
    @wrong_give_effect = nil
  end    
    
  #NEW - CAN_TALK_TO?
  def can_talk_to?
    if enemy.talk_cmd == true
      return true
    end
  end
  
  #NEW - TALK_RESULT_TYPE
  def talk_result_type
    if enemy.talk_result_type != nil
      return enemy.talk_result_type
    end
  end
  
  #NEW - TALK_RESULT_ID
  def talk_result_id
    if enemy.talk_result_id != nil
      return enemy.talk_result_id
    end
  end
  
  #NEW - TALK_RESULT_DURATION_OR_TARGET
  def talk_result_duration_or_target
    if enemy.talk_result_duration_or_target != nil
      return enemy.talk_result_duration_or_target
    end
  end
  
  #NEW - ENEMY_MESSAGE
  def enemy_message
    if enemy.message != nil
      @enemy_message = enemy.message
    end
  end
  
  #NEW - CAN_GIVE?
  def can_give?
    if enemy.give_cmd == true
      return true
    end
  end
  
  #NEW - WANTED_ITEM
  def wanted_item
    if enemy.wanted_item != nil
      @wanted_item = enemy.wanted_item.id
    end
  end
  
  #NEW - GIVE_RESULT_TYPE
  def give_result_type
    if enemy.give_result_type != nil
      return enemy.give_result_type
    end
  end
  
  #NEW - GIVE_RESULT_ID
  def give_result_id
    if enemy.give_result_id != nil
      return enemy.give_result_id
    end
  end
  
  #NEW - GIVE_RESULT_DURATION_OR_TARGET
  def give_result_duration_or_target
    if enemy.give_result_duration_or_target != nil
      return enemy.give_result_duration_or_target
    end
  end
  
  #NEW - WRONG_GIVE_RESULT_TYPE
  def wrong_give_result_type
    if enemy.wrong_give_result_type != nil
      return enemy.wrong_give_result_type
    end
  end
  
  #NEW - WRONG_GIVE_RESULT_ID
  def wrong_give_result_id
    if enemy.wrong_give_result_id != nil
      return enemy.wrong_give_result_id
    end
  end
  
  #NEW - WRONG_GIVE_RESULT_DURATION_OR_TARGET
  def wrong_give_result_duration_or_target
    if enemy.wrong_give_result_duration_or_target != nil
      return enemy.wrong_give_result_duration_or_target
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_Troop
#└────────────────────────────────────────────────────────────────────────────── 
class Game_Troop < Game_Unit  
    
  #NEW - ANY_TALK_MEMBERS?
  def any_talk_members?
    members.any? {|member|
      member.can_talk_to? && member.alive?
    }
  end
  
  #NEW - TALK_MEMBERS
  def talk_members
    members.select {|member| member.can_talk_to? && member.alive? }
  end
  
  #NEW - ANY_GIVE_MEMBERS?
  def any_give_members?
    members.any? {|member|
      member.can_give? && member.alive?
    }
  end
  
  #NEW - GIVE_MEMBERS
  def give_members
    members.select {|member| member.can_give? && member.alive? }
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_BattleEnemyTalk
#└──────────────────────────────────────────────────────────────────────────────
class Window_BattleEnemyTalk < Window_BattleEnemy
  
  #NEW - WINDOW_WIDTH
  def window_width
    Graphics.width - 128
  end
  
  #NEW - COL_MAX
  def col_max
    return 2
  end
  
  #NEW - ITEM_MAX
  def item_max
    $game_troop.talk_members.size
  end
  
  #NEW - ENEMY
  def enemy
    $game_troop.talk_members[@index]
  end
  
  #NEW - DRAW_ITEM
  def draw_item(index)
    change_color(normal_color)
    name = $game_troop.talk_members[index].name
    draw_text(item_rect_for_text(index), name)
  end
  
  #NEW - SHOW
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.x = width_remain
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  
  #NEW - HIDE
  def hide
    @info_viewport.rect.width = Graphics.width if @info_viewport
    super
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_BattleEnemyGive
#└──────────────────────────────────────────────────────────────────────────────
class Window_BattleEnemyGive < Window_BattleEnemy
  
  #NEW - WINDOW_WIDTH
  def window_width
    Graphics.width - 128
  end
  
  #NEW - COL_MAX
  def col_max
    return 2
  end
  
  #NEW - ITEM_MAX
  def item_max
    $game_troop.give_members.size
  end
  
  #NEW - ENEMY
  def enemy
    $game_troop.give_members[@index]
  end
  
  #NEW - DRAW_ITEM
  def draw_item(index)
    change_color(normal_color)
    name = $game_troop.give_members[index].name
    draw_text(item_rect_for_text(index), name)
  end
  
  #NEW - SHOW
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.x = width_remain
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  
  #NEW - HIDE
  def hide
    @info_viewport.rect.width = Graphics.width if @info_viewport
    super
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_BattleItemGive
#└──────────────────────────────────────────────────────────────────────────────
class Window_BattleItemGive < Window_ItemList
  
  #NEW - INITIALIZE
  def initialize(help_window, info_viewport)
    y = help_window.height
    super(0, y, Graphics.width, info_viewport.rect.y - y)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
  end
  
  #NEW - MAKE_ITEM_LIST
  def make_item_list
    @data = $game_party.all_items.select {|item| include?(item) }
  end
  
  #NEW - INCLUDE?
  def include?(item)
    if Euphoria::EnemyInteraction::GIVE_ITEMS_ONLY == true
      $game_party.items
    elsif Euphoria::EnemyInteraction::GIVE_ANYTHING == true
      $game_party.all_items
    end
  end
  
  #NEW - SHOW
  def show
    select_last
    @help_window.show
    super
  end
  
  #NEW - HIDE
  def hide
    @help_window.hide
    super
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_BattleHelp
#└──────────────────────────────────────────────────────────────────────────────
if $imported["YEA-BattleEngine"]
class Window_BattleHelp < Window_Help
  attr_accessor :talk_window
  attr_accessor :give_window
  
  #ALIAS - UPDATE_BATTLER_NAME
  alias euphoria_interact_windowbattlehelp_updatebattlername_29 update_battler_name
  def update_battler_name
    euphoria_interact_windowbattlehelp_updatebattlername_29
    return unless @talk_window.active || @give_window.active
    if @talk_window.active
      battler = @talk_window.enemy
    elsif @give_window.active
      battler = @give_window.enemy
    end
    if special_display?
      refresh_special_case(battler)
    else
      refresh_battler_name(battler) if battler_name(battler) != @text
    end
  end
  
end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_ActorCommand
#└──────────────────────────────────────────────────────────────────────────────     
class Window_ActorCommand < Window_Command
  
  #ALIAS - MAKE_COMMAND_LIST
  alias euphoria_interact_windowactorcommand_makecommandlist_29 make_command_list
  def make_command_list
    return unless @actor
    add_interact_commands
    euphoria_interact_windowactorcommand_makecommandlist_29
  end   
    
  #NEW - ADD_INTERACT_COMMANDS
  def add_interact_commands
    if $game_troop.any_talk_members?
      add_command("Talk", :talkcommand, $game_troop.any_talk_members?)
    end
    if $game_troop.any_give_members?
      add_command("Give", :givecommand, $game_troop.any_give_members?)
    end
  end
    
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Scene_Battle
#└──────────────────────────────────────────────────────────────────────────────    
class Scene_Battle < Scene_Base  
  
  #ALIAS - CREATE_ALL_WINDOW
  alias euphoria_interact_scenebattle_createallwindows_29 create_all_windows
  def create_all_windows
    euphoria_interact_scenebattle_createallwindows_29
    create_talk_window
    create_give_window
    create_give_item_window
    if $imported["YEA-BattleEngine"]
      set_help_window
    end
  end
  
  #NEW - CREATE_TALK_WINDOW
  def create_talk_window
    @talk_window = Window_BattleEnemyTalk.new(@info_viewport)
    @talk_window.set_handler(:ok,     method(:on_enemy_talk_ok))
    @talk_window.set_handler(:cancel, method(:on_enemy_talk_cancel))
  end
  
  #NEW - CREATE_GIVE_WINDOW
  def create_give_window
    @give_window = Window_BattleEnemyGive.new(@info_viewport)
    @give_window.set_handler(:ok,     method(:on_enemy_give_ok))
    @give_window.set_handler(:cancel, method(:on_enemy_give_cancel))
  end
  
  #NEW - CREATE_GIVE_ITEM_WINDOW
  def create_give_item_window
    @give_item_window = Window_BattleItemGive.new(@help_window, @info_viewport)
    @give_item_window.set_handler(:ok,     method(:on_item_give_ok))
    @give_item_window.set_handler(:cancel, method(:on_item_give_cancel))
    if $imported["YEA-BattleEngine"]
      @give_item_window.height = @skill_window.height
      @give_item_window.width = @skill_window.width
      @give_item_window.y = Graphics.height - @item_window.height
    end
  end
    
  #ALIAS - CREATE_ACTOR_COMMAND_WINDOW
  alias euphoria_interact_scenebattle_createactorcommandwindow_29 create_actor_command_window
  def create_actor_command_window
    euphoria_interact_scenebattle_createactorcommandwindow_29
    @actor_command_window.set_handler(:talkcommand, method(:command_talk))
    @actor_command_window.set_handler(:givecommand, method(:command_give))
  end
  
  #ALIAS - SET_HELP_WINDOW
  if $imported["YEA-BattleEngine"]
  alias euphoria_interact_scenebattle_sethelpwindow_29 set_help_window
  def set_help_window
    euphoria_interact_scenebattle_sethelpwindow_29
    @help_window.talk_window = @talk_window
    @help_window.give_window = @give_window
  end
  end
  
  #NEW - COMMAND_TALK
  def command_talk
    BattleManager.actor.input.set_talk
    select_talk_selection
  end
  
  #NEW - ON_ENEMY_TALK_OK
  def on_enemy_talk_ok
    BattleManager.actor.input.target_index = @talk_window.enemy.index
    @talk_window.hide
    @skill_window.hide
    @item_window.hide
    next_command
  end
  
  #NEW - ON_ENEMY_TALK_CANCEL
  def on_enemy_talk_cancel
    @talk_window.hide
    @actor_command_window.activate
    if $imported["YEA-BattleEngine"]
      @help_window.hide
    end
  end
  
  #NEW - SELECT_TALK_SELECTION
  def select_talk_selection
    @talk_window.refresh
    @talk_window.show.activate
    if $imported["YEA-BattleEngine"]
      @status_aid_window.refresh
      @talk_window.hide
      @item_window.hide
      @status_aid_window.hide
      @help_window.show
    end
  end
  
  #NEW - COMMAND_GIVE
  def command_give
    BattleManager.actor.input.set_give
    @give_item_window.refresh
    @give_item_window.show.activate
    if $imported["YEA-BattleEngine"]
      @status_window.hide
      @actor_command_window.hide
      @status_aid_window.show
    end
  end
  
  #NEW - ON_ITEM_GIVE_OK
  def on_item_give_ok
    @item = @give_item_window.item
    select_give_selection
  end
  
  #NEW - ON_ITEM_GIVE_CANCEL
  def on_item_give_cancel
    @give_item_window.hide
    @actor_command_window.activate
    if $imported["YEA-BattleEngine"]
      @status_window.show
      @actor_command_window.show
      @status_aid_window.hide
    end
  end
  
  #NEW - ON_ENEMY_GIVE_OK
  def on_enemy_give_ok
    BattleManager.actor.input.target_index = @give_window.enemy.index
    @give_item_window.hide
    @give_window.hide
    next_command
  end
  
  #NEW - ON_ENEMY_GIVE_CANCEL
  def on_enemy_give_cancel
    @give_window.hide
    @give_item_window.show.activate
    if $imported["YEA-BattleEngine"]
      @status_window.hide
      @actor_command_window.hide
      @status_aid_window.show
      if @skill_window.visible || @item_window.visible
        @help_window.show
      else
        @help_window.hide
      end
    end
  end
  
  #NEW - SELECT_GIVE_SELECTION
  def select_give_selection
    @give_window.refresh
    @give_window.show.activate
    if $imported["YEA-BattleEngine"]
      @status_aid_window.refresh
      @give_window.hide
      @status_aid_window.show
      @help_window.show
    end
  end
  
  #ALIAS - APPLY_ITEM_EFFECTS
  alias euphoria_interact_scenebattle_applyitemeffects_29 apply_item_effects
  def apply_item_effects(target, item)
    euphoria_interact_scenebattle_applyitemeffects_29(target, item)
    apply_interact_effects(target, item)
  end
  
  #NEW - APPLY_INTERACT_EFFECT
  def apply_interact_effects(target, item)
    return if target.actor?
    return if item.talk_skill == false && item.give_skill == false
    if item.talk_skill == true && item.give_skill == false
      format = "%s says: %s"
      name = target.name
      message = target.enemy_message
      text = sprintf(format, name, message)
      @log_window.add_text(text)
      3.times do @log_window.wait end
      @log_window.back_one
      @log_window.wait
      @log_window.clear
      if target.talk_result_type == "BUFF"
        if target.talk_result_duration_or_target == nil
          turns = 5
        else
          turns = target.talk_result_duration_or_target
        end
        paramid = target.talk_result_id
        target.add_buff(paramid, turns)
        @log_window.display_changed_buffs(target)
      elsif target.talk_result_type == "DEBUFF"
        if target.talk_result_duration_or_target == nil
          turns = 5
        else
          turns = target.talk_result_duration_or_target
        end
        paramid = target.talk_result_id
        target.add_debuff(paramid, turns)
        @log_window.display_changed_buffs(target)
      elsif target.talk_result_type == "STATE"
        stateid = target.talk_result_id
        target.add_state(stateid)
        @log_window.display_changed_states(target)
      elsif target.talk_result_type == "SKILL"
        skillid = target.talk_result_id
        target.new_force_action(skillid)
      elsif target.talk_result_type == "ESCAPE"
        format = "%s has left the battle."
        @log_window.add_text(sprintf(format, target.name))
        target.escape
      end
      @actor_command_window.refresh
    elsif item.give_skill == true && item.talk_skill == false
      $game_party.lose_item(@item, 1)
      if @item.id == target.wanted_item
        format = "%s accepted the %s from %s."
        enemy = target.name
        item = @item.name
        actor = @subject.name
        text = sprintf(format, enemy, item, actor)
        @log_window.add_text(text)
        3.times do @log_window.wait end
        @log_window.back_one
        @log_window.wait
        @log_window.clear
        if target.give_result_type == "BUFF"
          if target.give_result_duration_or_target == nil
            turns = 5
          else
            turns = target.give_result_duration_or_target
          end
          paramid = target.give_result_id
          target.add_buff(paramid, turns)
          @log_window.display_changed_buffs(target)
        elsif target.give_result_type == "DEBUFF"
          if target.give_result_duration_or_target == nil
            turns = 5
          else
            turns = target.give_result_duration_or_target
          end
          paramid = target.give_result_id
          target.add_debuff(paramid, turns)
          @log_window.display_changed_buffs(target)
        elsif target.give_result_type == "STATE"
          stateid = target.give_result_id
          target.add_state(stateid)
          @log_window.display_changed_states(target)
        elsif target.give_result_type == "SKILL"
          skillid = target.give_result_id
          target.new_force_action(skillid)
        elsif target.give_result_type == "ESCAPE"
          format = "%s has left the battle."
          @log_window.add_text(sprintf(format, target.name))
          target.escape
        end
        @actor_command_window.refresh
      elsif @item.id != target.wanted_item
        format = "%s was not happy with the %s"
        enemy = target.name
        item = @item.name
        text = sprintf(format, enemy, item)
        @log_window.add_text(text)
        3.times do @log_window.wait end
        @log_window.back_one
        @log_window.wait
        @log_window.clear
        if target.wrong_give_result_type == "BUFF"
          if target.wrong_give_result_duration_or_target == nil
            turns = 5
          else
            turns = target.wrong_give_result_duration_or_target
          end
          paramid = target.wrong_give_result_id
          target.add_buff(paramid, turns)
          @log_window.display_changed_buffs(target)
        elsif target.wrong_give_result_type == "DEBUFF"
          if target.wrong_give_result_duration_or_target == nil
            turns = 5
          else
            turns = target.wrong_give_result_duration_or_target
          end
          paramid = target.wrong_give_result_id
          target.add_debuff(paramid, turns)
          @log_window.display_changed_buffs(target)
        elsif target.wrong_give_result_type == "STATE"
          stateid = target.wrong_give_result_id
          target.add_state(stateid)
          @log_window.display_changed_states(target)
        elsif target.wrong_give_result_type == "SKILL"
          skillid = target.wrong_give_result_id
          target.new_force_action(skillid)
        elsif target.wrong_give_result_type == "ESCAPE"
          format = "%s has left the battle."
          @log_window.add_text(sprintf(format, target.name))
          target.escape
        end
        @actor_command_window.refresh
      end
    elsif item.talk_skill == true && item.give_skill == true
      text = "You CAN NOT have a skill tagged with talk AND give!"
      @log_window.add_text(text)
      3.times do @log_window.wait end
      @log_window.back_one
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────
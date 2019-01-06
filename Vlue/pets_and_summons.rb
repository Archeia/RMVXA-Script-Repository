#Pets and Summons (Stand Alone) v1.4g
#----------#
#Features: Allows you to set skills that summons pets (actors) into battle, which
#           can last for the duration of the battle, until dead, or by timer.
#
#Usage:    Plug and play, Customize as needed
#           Skill/Item Notetag:
#            <SUMMON actor_id, timer, level_bonus (optional)>
#           Set timer to 0 to not use it.
#           level_bonus is change in pet level from the actor
#
#            <BIG_SUMMON actor_id, timer, level_bonus>
#           Same as above, but replaces party for duration
#            <MED_SUMMON actor_id, timer, level_bonus>
#           Same as above, but replaces actor for duration
#
#----------#
#-- Script by: V.M of D.T
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#Maximum number of pets one actor can have:
MAX_PETS = 3
 
#Message played when certain pet is summoned:
# actor_id => "message"
SUMMON_MESSAGES = {
  2 => "A large wolf joins the fray!",
  3 => "Transformed into a dragon!!!"
}
#Message played when pets timer runs out:
RETREAT_MESSAGES = {
  2 => "A large wolf retreats into the shadows.",
  3 => "A large wolf retreats into the shadows."
}
#Message played when pet dies:
DEATH_MESSAGES = {
  2 => "A large wolf has died!",
  3 => "A large wolf has died!"
}
 
class Game_Battler < Game_BattlerBase
  attr_accessor  :pets
  alias pet_init initialize
  alias pet_iue item_user_effect
  alias pet_obe on_battle_end
  def initialize(*args)
    pet_init(*args)
    @hp = 1
    @pets = []
  end
  def add_pet(actor_id, timer = -1, level = 0)
  end
  def remove_pet(index)
    @pets[index] = nil
    @pets.compact!
  end
  def remove_pets_by_state
    iter = 0
    @pets.each do |pet|
      pet.timer -= 1
      if pet.hp <= 0
        remove = true
        if DEATH_MESSAGES[pet.actor_id]
          SceneManager.scene.log_window.add_text(DEATH_MESSAGES[pet.actor_id])
          SceneManager.scene.log_window.wait
          SceneManager.scene.status_window.refresh
        end
      elsif pet.timer == 0 || self.hp <= 0
        remove = true
        if RETREAT_MESSAGES[pet.actor_id]
          SceneManager.scene.log_window.add_text(RETREAT_MESSAGES[pet.actor_id])
          SceneManager.scene.log_window.wait
          SceneManager.scene.status_window.refresh
        end
      end
      @pets[iter] = nil if remove
      iter += 1
    end
    SceneManager.scene.reset_actor_sprites
    SceneManager.scene.log_window.wait_and_clear
    @pets.compact!
  end
  def item_user_effect(user, item)
    pet_iue(user, item)
    if item.big_summons
      temp_replace_party(item.big_summons)
      @result.success = true
      SceneManager.scene.log_window.wait
      SceneManager.scene.log_window.wait_and_clear
    elsif item.med_summons
      temp_replace_actor(item.med_summons[0])
      @result.success = true
      SceneManager.scene.log_window.wait
      SceneManager.scene.log_window.wait_and_clear
    elsif item.summons
      return if self.pets.size >= MAX_PETS
      item.summons.each do |array|
        next if self.pets.size >= MAX_PETS
        add_pet(array[0],array[1],array[2])
        @result.success = true
      end
      SceneManager.scene.log_window.wait
      SceneManager.scene.log_window.wait_and_clear
    end
  end
  def on_battle_end
    @pets = []
    pet_obe
  end
  def temp_replace_actor(array)
  end
  def temp_replace_party(array)
  end
  def summon_pet(array)
  end
end
 
class Game_Actor < Game_Battler
  attr_accessor  :actor_id
  def add_pet(actor_id, timer = -1, level = 0)
    if level
      @pets.push(Game_Pet.new(actor_id,timer,@level + level))
    else
      @pets.push(Game_Pet.new(actor_id,timer,false))
    end
    @pets[-1].set_ori(@actor_id)
    return unless SceneManager.scene.is_a?(Scene_Battle)
    if SUMMON_MESSAGES[actor_id]
      SceneManager.scene.log_window.add_text(SUMMON_MESSAGES[actor_id])
      SceneManager.scene.log_window.wait
      SceneManager.scene.status_window.refresh
    end
    SceneManager.scene.reset_actor_sprites
  end
  def temp_replace_actor(array)
    $game_party.temp_replace_actor(self, array)
  end
  def temp_replace_party(array)
    $game_party.temp_replace_party(self, array)
  end
  def summon_pet(array)
    $game_party.summon_pet(self, array)
  end
  def restore_actor
    return false
  end
  def screen_x
    0
  end 
  def screen_y
    0
  end 
  def screen_z
    0
  end 
end
 
class Game_Pet < Game_Actor
  attr_accessor  :timer
  attr_accessor  :actor_id
  attr_accessor  :former_actor
  def initialize(actor_id, timer, level_bonus, former_actor = nil)
    super(actor_id)
    @timer = timer
    @timer -= 1 if @timer == 0
    if level_bonus
      @level = [[@level + level_bonus,1].max,99].min
    end
    @former_actor = former_actor
    @ori_actor = nil
    init_skills
    recover_all
  end
  def set_ori(id)
    @ori_actor = id
  end
  def sprite
    @sprite = Sprite_Battler.new(nil) if @sprite.nil?
    @sprite
  end
  def on_turn_end
    super
    if @former_actor
      @timer -= 1
      if @hp <= 0 ||  @timer == 0
        return if $game_party.restore_party
        $game_party.restore_actor(self, former_actor)
      end
    end
  end
  def restore_actor
    return false unless @former_actor
    $game_party.restore_actor(self, former_actor)
    return true
  end
  def on_battle_end
    super
    restore_actor
  end
  def screen_x
    return super unless @ori_actor
    $game_actors[@ori_actor].screen_x + 12
  end
  def screen_y
    return super unless @ori_actor
    $game_actors[@ori_actor].screen_y + 12
  end
  def use_sprite?
    true
  end
end
 
class RPG::UsableItem
  def summons
    return false unless self.note.index("<SUMMON")
    notes = self.note.clone
    summon_array = []
    while notes =~ /<SUMMON (\d+), ((\d+)|(\d+), ((\d+)|(-\d+)))>/
      if $2.include?(",")
        array = [$1.to_i] + $2.split(",").map {|s| s.to_i}
      else
        array = [$1.to_i,$2.to_i,false]
      end
      summon_array.push(array)
      notes[notes.index("SUMMON")] = "N"
    end
    summon_array
  end
  def med_summons
    return false unless self.note.index("<MED_SUMMON")
    notes = self.note.clone
    summon_array = []
    while notes =~ /<MED_SUMMON (\d+), (\d+), (\d+)>/
      summon_array.push([$1.to_i,$2.to_i,$3.to_i])
      notes[notes.index("MED_SUMMON")] = "N"
    end
    summon_array
  end
  def big_summons
    return false unless self.note.index("<BIG_SUMMON")
    notes = self.note.clone
    summon_array = []
    while notes =~ /<BIG_SUMMON (\d+), (\d+), (\d+)>/
      summon_array.push([$1.to_i,$2.to_i,$3.to_i])
      notes[notes.index("BIG_SUMMON")] = "N"
    end
    summon_array
  end
end
 
class Scene_Battle
  attr_accessor  :log_window
  attr_accessor  :status_window
  def turn_start
    @party_command_window.close
    @actor_command_window.close
    @status_window.unselect
    @subject =  nil
    BattleManager.turn_start
    @log_window.wait
    @log_window.clear
  end
  def turn_end
    all_battle_members.each do |battler|
      battler.on_turn_end
      refresh_status
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
      battler.remove_pets_by_state
    end
    BattleManager.turn_end
    process_event
    start_party_command_selection
  end
  def reset_actor_sprites
    @spriteset.create_actors
  end
end

class Scene_Map
  def reset_actor_sprites
  end
end
 
class Game_Party
  def pets
    pet = []
    self.pets_battle_members.each do |actor|
      pet += actor.pets
    end
    pet.compact
  end
  alias pets_battle_members battle_members
  def battle_members
    pets_battle_members + pets
  end
  def temp_replace_actor(actor, array)
    if SUMMON_MESSAGES[array[0]]
      SceneManager.scene.log_window.add_text(SUMMON_MESSAGES[array[0]])
      SceneManager.scene.log_window.wait
      SceneManager.scene.status_window.refresh
    end
    $game_actors.set_pet(array[0],Game_Pet.new(array[0],array[1],actor.level + array[2],actor.actor_id))
    @actors[actor.index] = array[0]
    SceneManager.scene.reset_actor_sprites
  end
  def restore_actor(pet, actor_id)
    @actors[pet.index] = actor_id
    SceneManager.scene.reset_actor_sprites
  end
  def temp_replace_party(actor, arrays)
    @actors_sideline = @actors.clone
    @actors = []
    arrays.each do |array|
      $game_actors.set_pet(array[0],Game_Pet.new(array[0],array[1],actor.level + array[2],actor.actor_id))
      add_actor(array[0])
    end
    SceneManager.scene.reset_actor_sprites
  end
  def restore_party
    return false unless @actors_sideline
    @actors = @actors_sideline.clone
    @actors_sideline = nil
    SceneManager.scene.reset_actor_sprites
    return true
  end
  def on_battle_end
    restore_party
    super
  end
end
 
class Game_Actors
  def set_pet(id, pet)
    @data[id] = pet
  end
end
 
$imported = {} if $imported.nil?
class Window_BattleStatus < Window_Selectable
  alias pets_yan_refresh refresh
  alias pets_yan_draw_item draw_item
  def refresh
    return pets_yan_refresh if !$imported["YEA-BattleEngine"].nil?
    contents.dispose
    self.contents = Bitmap.new(self.width-24,line_height*item_max)
    contents.clear
    draw_all_items
  end
  def item_max
    $game_party.members.size
  end
  def battle_members; return $game_party.members; end
  def draw_item(index)
    return pets_yan_draw_item(index) if !$imported["YEA-BattleEngine"].nil?
    actor = $game_party.members[index]
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
end
 
module BattleManager
  class << self
    alias pets_process_victory process_victory
  end
  def self.process_defeat
    return false if $game_party.restore_party
    $game_party.members.each do |actor|
      return false if actor.restore_actor
    end
    $game_message.add(sprintf(Vocab::Defeat, $game_party.name))
    wait_for_message
    if @can_lose
      revive_battle_members
      replay_bgm_and_bgs
      SceneManager.return
    else
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
  def self.process_victory
    $game_party.restore_party
    pets_process_victory
  end
end
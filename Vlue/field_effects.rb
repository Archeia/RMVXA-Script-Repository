#Field Effects v1.1
#----------#
#Features: Allows you to set skills and items that change the background of the
#           battle, as well as apply states to both enemies and allies.
#
#Usage:    Plug and play, Customize as needed
#            Skill/Item Notetag:
#             <FIELD id>   - where id is the field ID to apply
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#FIELD SETUP:
# ID => {
#   :name => "field name",              - Arbitrary, isn't even used.
#   :background1 => "background1",      - Background 1 to use
#   :background1 => "background1",      - Background 2 to use
#   :fade => :fadestyle,                - Fade effect- :none, :white, :black
#   :duration => int,                   - Where int is number of turns to last
#   :enemy_state => id,                 - State id to be applied to all enemies
#   :actor_state => id, },              - State id to be applied to all actors
#
# Setting duration, enemy_state, or actor_state to 0 will ignore that portion.

$imported = {} if $imported.nil?
$imported[:VlueFieldEffects] = true
 
FIELD_EFFECTS = {
  0 => { },
  1 => {
    :name => "Swamp",
    :background1 => "PoisonSwamp",
    :background2 => "PoisonSwamp",
    :fade => :black,
    :duration => 3,
    :enemy_state => 2,
    :actor_state => 0, },
  2 => {
    :name => "Sanctuary",
    :background1 => "GrassMaze",
    :background2 => "Forest1",
    :fade => :white,
    :duration => 3,
    :enemy_state => 0,
    :actor_state => 14, },
}
 
#Fade effect when field effect is over
RESET_FIELD_FADE = :black
   
class Scene_Battle
  alias field_effects_start start
  alias field_effects_apply_item_effects apply_item_effects
  alias field_effects_turn_end turn_end
  alias field_effects_turn_start turn_start
  def start(*args)
    field_effects_start(*args)
    @field_effect = 0
    @field_duration = 0
  end
  def turn_end(*args)
    field_effects_turn_end
    if @field_duration > 0
      @field_duration -= 1
      if @field_duration == 0
        @spriteset.change_field(0)
        remove_field_effects
        @field_effect = 0
      end
    end
  end
  def turn_start(*args)
    field_effects_turn_start(*args)
    apply_field_effects
  end
  def apply_field(id)
    return unless id
    return if @field_effect == id
    remove_field_effects
    @field_effect = id
    @spriteset.change_field(id)
    @field_duration = field[:duration]
    apply_field_effects
  end
  def field
    FIELD_EFFECTS[@field_effect]
  end
  def apply_item_effects(target, item)
    field_effects_apply_item_effects(target, item)
    apply_field(item.field_effect?)
  end
  def apply_field_effects
    return unless @field_effect > 0
    if field[:actor_state] > 0
      $game_party.battle_members.each do |actor|
        actor.add_state(field[:actor_state])
      end
    end
    if field[:enemy_state] > 0
      $game_troop.members.each do |enemy|
        enemy.add_state(field[:enemy_state])
      end
    end
  end
  def remove_field_effects
    return unless @field_effect > 0
    if field[:actor_state] > 0
      $game_party.battle_members.each do |actor|
        actor.remove_state(field[:actor_state])
      end
    end
    if field[:enemy_state] > 0
      $game_troop.members.each do |enemy|
        enemy.remove_state(field[:enemy_state])
      end
    end
  end
end
 
class Spriteset_Battle
  #@back2_sprite
  def change_field(id)
    field = FIELD_EFFECTS[id]
    field = {:fade => RESET_FIELD_FADE } if id == 0
    case field[:fade]
    when :none
      create_battleback_custom(field)
    when :white
      fade_white_battleback
      create_battleback_custom(field)
      unfade_battleback
    when :black
      fade_black_battleback
      create_battleback_custom(field)
      unfade_battleback
    end
  end
  def fade_white_battleback
    duration = 0
    while @back1_sprite.color.red != 255
      @back1_sprite.color = Color.new(duration,duration,duration,duration)
      @back2_sprite.color = Color.new(duration,duration,duration,duration)
      duration += 5
      SceneManager.scene.update_basic
    end
  end
  def fade_black_battleback
    duration = 0
    while @back1_sprite.color.alpha != 255
      @back1_sprite.color = Color.new(0,0,0,duration)
      @back2_sprite.color = Color.new(0,0,0,duration)
      duration += 5
      SceneManager.scene.update_basic
    end
  end
  def unfade_battleback
    duration = 255
    while @back1_sprite.color.alpha != 0
      @back1_sprite.color.red == 0 ? color_value = 0 : color_value = duration
      @back1_sprite.color = Color.new(color_value,color_value,color_value,duration)
      @back2_sprite.color = Color.new(color_value,color_value,color_value,duration)
      duration -= 5
      SceneManager.scene.update_basic
    end
  end
  def create_battleback_custom(field)
    if field[:background1]
      @back1_sprite.bitmap = Cache.battleback1(field[:background1])
      @back2_sprite.bitmap = Cache.battleback2(field[:background2])
    else
      @back1_sprite.bitmap = battleback1_bitmap
      @back2_sprite.bitmap = battleback2_bitmap
    end
  end
end
 
class RPG::UsableItem
  def field_effect?
    self.note =~ /<FIELD (\d+)>/ ? $1.to_i : nil
  end
end
#==============================================================================
# Absolute_Defense v1.10
#------------------------------------------------------------------------------
# Author: Kread-EX
#==============================================================================

# UPDATES
# 02/01/2012. Added compat. with Tankentai.

# INTRODUCTION
# Absolute Defense is a technique used in the game Breath of Fire V (Ps2).
# It allows to nullify damage inflicted by the user under a set value.
# Technically, you must spam your best attacks in order to wound the big tank who use this.

# IMPORTANT NOTE
# Absolute Defense protect only from HP damage. Not from eventual SP damage or status ailments.

# HOW TO USE
# Just copy this and paste above Main.
# Then follow the configuration steps.

# COMPATIBILITY
# Very low compatibility with any script which modify Game_Battler, Sprite_Battler or Scene_Battle (this was one of my very first script, be indulgent).
# I suggest to NOT make 2 enemies in the same group using Absolute Degense
# Actors can't use this because this would unbalance the game.
# Work with the DBS and turn-based CBS. You shouldn't use this with ATB or RTAB. Maybe CTB, but I'm not sure.
# Will clash with custom damage displays.

#==============================================================================
# Configuration part
#==============================================================================
module KreadCFG

# Ids of enemies using Absolute Defense
ENEMIES_IDS = [1,5]

# Value of the Absolute Defense. The order MUST match the order inside the ENEMIES_ID
ABSOLUTE_VALUES = [80,650]

# Number of turns before the Absolute Defense is recharged. Then again, the order must match ENEMIES_ID
REFRESH_RATE = [1,3]

# ID of the animation used when the defense is active (leave to 0 for no animation)
FULL_ANIM_ID = 0

# ID of the animation used when the defense breaks (leave to 0 for no animation)
BREAK_ANIM_ID = 0

end

#==============================================================================
# Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :absolute_defense_break
  attr_accessor :absolute_defense_value
  attr_accessor :absolute_defense_refresh_rate
  #--------------------------------------------------------------------------
  # Object initialization
  #--------------------------------------------------------------------------
  alias orig_enemy_init initialize
  def initialize(troop_id, member_index)
    orig_enemy_init(troop_id, member_index)
    unless KreadCFG::ENEMIES_IDS.include?(self.id)
      @absolute_defense_break = false
      @absolute_defense_value = 0
      @absolute_defense_refresh_rate = 0
      return
    end
   #Les variables d'instances prennent les valeurs des constantes.
   index = KreadCFG::ENEMIES_IDS.index(self.id)
   @absolute_defense_break = false
   @absolute_defense_value = KreadCFG::ABSOLUTE_VALUES[index]
   @absolute_defense_refresh_rate = KreadCFG::REFRESH_RATE[index]
  end
end

#==============================================================================
# Game_Battler
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # Apply normal attack effect
  #--------------------------------------------------------------------------
  alias krx_absdef_attack_effect attack_effect
  def attack_effect(attacker)
    if self.class == Game_Actor or self.absolute_defense_value == 0
      return krx_absdef_attack_effect(attacker)
    end
    last_hp = self.hp
    result = krx_absdef_attack_effect(attacker)
    if self.damage.is_a?(Numeric) and self.damage >= self.absolute_defense_value and self.damage > 0
      last_damage = self.damage
      self.damage = [self.damage - self.absolute_defense_value, 0].max
      self.absolute_defense_break = true
      self.absolute_defense_value = [self.absolute_defense_value - last_damage, 0].max
      self.hp = last_hp - self.damage
    elsif self.damage.is_a?(Numeric) and self.damage > 0
      self.absolute_defense_value -= self.damage
      self.hp = last_hp
      self.damage = '-' + self.absolute_defense_value.to_s
    end
    return result
  end
  #--------------------------------------------------------------------------
  # Apply skill effect
  #--------------------------------------------------------------------------
  alias krx_absdef_skill_effect skill_effect
  def skill_effect(user,skill)
    if self.class == Game_Actor or self.absolute_defense_value == 0
      return krx_absdef_skill_effect(user,skill)
    end
    last_hp = self.hp
    result = krx_absdef_skill_effect(user,skill)
    if self.damage.class == Numeric and self.damage >= self.absolute_defense_value and
      self.damage > 0
      last_damage = self.damage
      self.damage = [self.damage - self.absolute_defense_value, 0].max
      self.absolute_defense_break = true
      self.absolute_defense_value = [self.absolute_defense_value - last_damage, 0].max
      self.hp = last_hp - self.damage
    elsif self.damage.class == Numeric and self.damage > 0
      self.absolute_defense_value -= self.damage
      self.damage = '-' + self.absolute_defense_value.to_s
    end
    return result
  end
  #--------------------------------------------------------------------------
  # Apply item effect
  #--------------------------------------------------------------------------
  alias krx_absdef_item_effect item_effect
  def item_effect(item)
    if self.class == Game_Actor or self.absolute_defense_value == 0
      return krx_absdef_item_effect(item)
    end
    last_hp = self.hp
    result = krx_absdef_item_effect(item)
    if self.damage.class == Numeric and self.damage >= self.absolute_defense_value and
      self.damage > 0
      last_damage = self.damage
      self.damage = [self.damage - self.absolute_defense_value, 0].max
      self.absolute_defense_break = true
      self.absolute_defense_value = [self.absolute_defense_value - last_damage, 0].max
      self.hp = last_hp - self.damage
    elsif self.damage.class == Numeric and self.damage > 0
      self.absolute_defense_value -= self.damage
      self.damage = '-' + self.absolute_defense_value.to_s
    end
    return result
  end
end

#==============================================================================
# Game_Battler
#==============================================================================
class Sprite_Battler
  #--------------------------------------------------------------------------
  # Display damage
  #--------------------------------------------------------------------------
  def damage(value, critical)
   dispose_damage
   if value.is_a?(Numeric)
     damage_string = value.abs.to_s
   else
     damage_string = value.to_s
   end
   bitmap = Bitmap.new(160, 48)
   bitmap.font.name = 'Arial Black'
   bitmap.font.size = 32
   bitmap.font.color.set(0, 0, 0)
   bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)
   bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)
   bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)
   bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)
   if value.is_a?(Numeric) and value < 0
     bitmap.font.color.set(176, 255, 144)
   elsif value.is_a?(String) and value.include?('-') and @battler.absolute_defense_value > 0 and not @battler.absolute_defense_break
     @battler.animation_id = KreadCFG::FULL_ANIM_ID
     bitmap.font.color.set(230, 230, 75)
   elsif @battler.class == Game_Enemy and @battler.absolute_defense_break
     @battler.animation_id = KreadCFG::BREAK_ANIM_ID
     @battler.absolute_defense_break = false
     bitmap.font.color.set(255, 255, 255)
   else
     @battler_animation_id = 0
     bitmap.font.color.set(255, 255, 255)
   end
   bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
   if critical
     bitmap.font.size = 20
     bitmap.font.color.set(0, 0, 0)
     bitmap.draw_text(-1, -1, 160, 20, "CRITICAL", 1)
     bitmap.draw_text(+1, -1, 160, 20, "CRITICAL", 1)
     bitmap.draw_text(-1, +1, 160, 20, "CRITICAL", 1)
     bitmap.draw_text(+1, +1, 160, 20, "CRITICAL", 1)
     bitmap.font.color.set(255, 255, 255)
     bitmap.draw_text(0, 0, 160, 20, "CRITICAL", 1)
   end
   @_damage_sprite = ::Sprite.new(self.viewport)
   @_damage_sprite.bitmap = bitmap
   @_damage_sprite.ox = 80
   @_damage_sprite.oy = 20
   @_damage_sprite.x = self.x
   @_damage_sprite.y = self.y - self.oy / 2
   @_damage_sprite.z = 3000
   @_damage_duration = 40
 end
end

#==============================================================================
# Scene_Battle
#==============================================================================
class Scene_Battle
  #--------------------------------------------------------------------------
  # Alias the phase 1
  #--------------------------------------------------------------------------
  alias krx_absdef_start_phase1 start_phase1
  def start_phase1
    @ad_count = {}
    $game_troop.enemies.each do |enemy|
      @ad_count[enemy.index] = enemy.absolute_defense_refresh_rate
    end
    krx_absdef_start_phase1
  end
  #--------------------------------------------------------------------------
  # Alias the step 6 of phase 4
  #--------------------------------------------------------------------------
  alias krx_absdef_update_step6 update_phase4_step6
  def update_phase4_step6
    if @active_battler.is_a?(Game_Enemy) and @active_battler.movable?
      @ad_count[@active_battler.index] -= 1
      if @ad_count[@active_battler.index] == 0
        @ad_count[@active_battler.index] = @active_battler.absolute_defense_refresh_rate
        r_index = KreadCFG::ENEMIES_IDS.index(@active_battler.id)
        @active_battler.absolute_defense_value = KreadCFG::ABSOLUTE_VALUES[r_index]
      end
    end
    krx_absdef_update_step6
  end
end

## Tankentai compatibility
if defined?(N01)
#==============================================================================
# Game_Battler
#==============================================================================
class Sprite_Battler
  #--------------------------------------------------------------------------
  # Display damage
  #--------------------------------------------------------------------------
  def damage(value, critical, sp_damage = nil)
    dispose_damage(0...@_damage_durations.size)
    @_damage_sprites = []
    if value.is_a?(Numeric)
      damage_string = value.abs.to_s
    else
      damage_string = value.to_s
    end
    @damage_size = 1 if !MULTI_POP
    @damage_size = damage_string.size if MULTI_POP
    for i in 0...@damage_size
      letter = damage_string[i..i] if MULTI_POP
      letter = damage_string if !MULTI_POP
      bitmap = Bitmap.new(160, 48)
      bitmap.font.name = DAMAGE_FONT
      bitmap.font.size = DMG_F_SIZE
      bitmap.font.color.set(0, 0, 0)
      bitmap.draw_text(-1, 12-1,160, 36, letter, 1)
      bitmap.draw_text(+1, 12-1,160, 36, letter, 1)
      bitmap.draw_text(-1, 12+1,160, 36, letter, 1)
      bitmap.draw_text(+1, 12+1,160, 36, letter, 1)
      if value.is_a?(Numeric) and value < 0
        bitmap.font.color.set(HP_REC_COLOR[0],HP_REC_COLOR[1],HP_REC_COLOR[2]) if !sp_damage
        bitmap.font.color.set(SP_REC_COLOR[0],SP_REC_COLOR[1],SP_REC_COLOR[2]) if sp_damage
      elsif value.is_a?(String) && value.include?('-') && @battler.absolute_defense_value > 0 &&
      !@battler.absolute_defense_break
        @battler.animation_id = KreadCFG::FULL_ANIM_ID
        bitmap.font.color.set(230, 230, 75)
      elsif @battler.class == Game_Enemy && @battler.absolute_defense_break
        @battler.animation_id = KreadCFG::BREAK_ANIM_ID
        @battler.absolute_defense_break = false
        bitmap.font.color.set(255, 255, 255)
      else
        bitmap.font.color.set(HP_DMG_COLOR[0],HP_DMG_COLOR[1],HP_DMG_COLOR[2]) if !sp_damage
        bitmap.font.color.set(SP_DMG_COLOR[0],SP_DMG_COLOR[1],SP_DMG_COLOR[2]) if sp_damage
        bitmap.font.color.set(CRT_DMG_COLOR[0],CRT_DMG_COLOR[1],CRT_DMG_COLOR[2]) if critical 
      end
      bitmap.draw_text(0, 12,160, 36, letter, 1)
      if critical and CRITIC_TEXT and i == 0
        x_pop = (MULTI_POP ? (damage_string.size - 1) * (DMG_SPACE / 2) : 0)
        bitmap.font.size = ((DMG_F_SIZE * 2) / 3).to_i
        bitmap.font.color.set(0, 0, 0)
        bitmap.draw_text(-1 + x_pop, -1, 160, 20, POP_CRI, 1)
        bitmap.draw_text(+1 + x_pop, -1, 160, 20, POP_CRI, 1)
        bitmap.draw_text(-1 + x_pop, +1, 160, 20, POP_CRI, 1)
        bitmap.draw_text(+1 + x_pop, +1, 160, 20, POP_CRI, 1)
        bitmap.font.color.set(CRT_TXT_COLOR[0],CRT_TXT_COLOR[1],CRT_TXT_COLOR[2]) if critical 
        bitmap.draw_text(0 + x_pop, 0, 160, 20, POP_CRI, 1)
      end
      if critical and CRITIC_FLASH
        $game_screen.start_flash(Color.new(255, 255, 255, 255),10)
      end
      @_damage_sprites[i] = ::Sprite.new(self.viewport)
      @_damage_sprites[i].bitmap = bitmap
      @_damage_sprites[i].ox = 80
      @_damage_sprites[i].oy = 20
      @_damage_sprites[i].x = self.x + i * DMG_SPACE
      @_damage_sprites[i].y = self.y - self.oy / 2
      @_damage_sprites[i].z = DMG_DURATION + 3000 + i * 2
    end
  end
end

end ## End of Tankentai compatibility
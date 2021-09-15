#encoding:UTF-8
# Sound
#==============================================================================
# ** Sound
#------------------------------------------------------------------------------
#  This module plays sound effects. It obtains sound effects specified in the
# database from $data_system, and plays them.
#==============================================================================

module Sound

  # Cursor
  def self.play_cursor
    $data_system.sounds[0].play
  end

  # Decision
  def self.play_decision
    $data_system.sounds[1].play
  end

  # Cancel
  def self.play_cancel
    $data_system.sounds[2].play
  end

  # Buzzer
  def self.play_buzzer
    $data_system.sounds[3].play
  end

  # Equip
  def self.play_equip
    $data_system.sounds[4].play
  end

  # Save
  def self.play_save
    $data_system.sounds[5].play
  end

  # Load
  def self.play_load
    $data_system.sounds[6].play
  end

  # Battle Start
  def self.play_battle_start
    $data_system.sounds[7].play
  end

  # Escape
  def self.play_escape
    $data_system.sounds[8].play
  end

  # Enemy Attack
  def self.play_enemy_attack
    $data_system.sounds[9].play
  end

  # Enemy Damage
  def self.play_enemy_damage
    $data_system.sounds[10].play
  end

  # Enemy Collapse
  def self.play_enemy_collapse
    $data_system.sounds[11].play
  end

  # Actor Damage
  def self.play_actor_damage
    $data_system.sounds[12].play
  end

  # Actor Collapse
  def self.play_actor_collapse
    $data_system.sounds[13].play
  end

  # Recovery
  def self.play_recovery
    $data_system.sounds[14].play
  end

  # Miss
  def self.play_miss
    $data_system.sounds[15].play
  end

  # Evasion
  def self.play_evasion
    $data_system.sounds[16].play
  end

  # Shop
  def self.play_shop
    $data_system.sounds[17].play
  end

  # Use Item
  def self.play_use_item
    $data_system.sounds[18].play
  end

  # Use Skill
  def self.play_use_skill
    $data_system.sounds[19].play
  end

end

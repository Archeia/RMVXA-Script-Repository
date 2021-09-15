#encoding:UTF-8
# Vocab
#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  # Shop Screen
  ShopBuy         = "Buy"
  ShopSell        = "Sell"
  ShopCancel      = "Cancel"
  Possession      = "Possession"

  # Status Screen
  ExpTotal        = "Current Exp"
  ExpNext         = "To Next %s"

  # Save/Load Screen
  SaveMessage     = "Save to which file?"
  LoadMessage     = "Load which file?"
  File            = "File"

  # Display when there are multiple members
  PartyName       = "%s's Party"

  # Basic Battle Messages
  Emerge          = "%s emerged!"
  Preemptive      = "%s got the upper hand!"
  Surprise        = "%s was surprised!"
  EscapeStart     = "%s has started to escape!"
  EscapeFailure   = "However, it was unable to escape!"

  # Battle Ending Messages
  Victory         = "%s was victorious!"
  Defeat          = "%s was defeated."
  ObtainExp       = "%s EXP were received!"
  ObtainGold      = "%s%s were obtained!"
  ObtainItem      = "%s was found!"
  LevelUp         = "%s is now %s %s!"
  ObtainSkill     = "%s was learned!"

  # Battle Actions
  DoAttack        = "%s attacks!"
  DoGuard         = "%s is guarding."
  DoEscape        = "%s ran away."
  DoWait          = "%s is waiting."
  UseItem         = "%s uses %s!"

  # Critical Hit
  CriticalToEnemy = "An excellent hit!!"
  CriticalToActor = "A painful blow!!"

  # Results for Actions on Actors
  ActorDamage     = "%s took %s damage!"
  ActorLoss       = "%1$s lost %3$s %2$s!"
  ActorDrain      = "%1$s drained %3$s %2$s!"
  ActorNoDamage   = "%s took no damage!"
  ActorNoHit      = "Miss! %s took no damage!"
  ActorEvasion    = "%s evaded the attack!"
  ActorRecovery   = "%1$s recovered %3$s %2$s!"

  # Results for Actions on Enemies
  EnemyDamage     = "%s took %s damage!"
  EnemyLoss       = "%1$s lost %3$s %2$s!"
  EnemyDrain      = "%1$s drained %3$s %2$s!"
  EnemyNoDamage   = "%s took no damage!"
  EnemyNoHit      = "Miss! %s took no damage!"
  EnemyEvasion    = "%s evaded the attack!"
  EnemyRecovery   = "%1$s recovered %3$s %2$s!"

  # Non-physical skills or items failed
  ActionFailure   = "There was no effect on %s!"

  # Level
  def self.level
    return $data_system.terms.level
  end

  # Level (Abbreviation)
  def self.level_a
    return $data_system.terms.level_a
  end

  # HP
  def self.hp
    return $data_system.terms.hp
  end

  # HP (Abbreviation)
  def self.hp_a
    return $data_system.terms.hp_a
  end

  # MP
  def self.mp
    return $data_system.terms.mp
  end

  # MP (Abbreviation)
  def self.mp_a
    return $data_system.terms.mp_a
  end

  # Attack
  def self.atk
    return $data_system.terms.atk
  end

  # Defense
  def self.def
    return $data_system.terms.def
  end

  # Spirit
  def self.spi
    return $data_system.terms.spi
  end

  # Agility
  def self.agi
    return $data_system.terms.agi
  end

  # Weapon
  def self.weapon
    return $data_system.terms.weapon
  end

  # Shield
  def self.armor1
    return $data_system.terms.armor1
  end

  # Helmet
  def self.armor2
    return $data_system.terms.armor2
  end

  # Body Armor
  def self.armor3
    return $data_system.terms.armor3
  end

  # Accessory
  def self.armor4
    return $data_system.terms.armor4
  end

  # Weapon 1
  def self.weapon1
    return $data_system.terms.weapon1
  end

  # Weapon 2
  def self.weapon2
    return $data_system.terms.weapon2
  end

  # Attack
  def self.attack
    return $data_system.terms.attack
  end

  # Skill
  def self.skill
    return $data_system.terms.skill
  end

  # Guard
  def self.guard
    return $data_system.terms.guard
  end

  # Item
  def self.item
    return $data_system.terms.item
  end

  # Equip
  def self.equip
    return $data_system.terms.equip
  end

  # Status
  def self.status
    return $data_system.terms.status
  end

  # Save
  def self.save
    return $data_system.terms.save
  end

  # Game End
  def self.game_end
    return $data_system.terms.game_end
  end

  # Fight
  def self.fight
    return $data_system.terms.fight
  end

  # Escape
  def self.escape
    return $data_system.terms.escape
  end

  # New Game
  def self.new_game
    return $data_system.terms.new_game
  end

  # Continue
  def self.continue
    return $data_system.terms.continue
  end

  # Shutdown
  def self.shutdown
    return $data_system.terms.shutdown
  end

  # To Title
  def self.to_title
    return $data_system.terms.to_title
  end

  # Cancel
  def self.cancel
    return $data_system.terms.cancel
  end

  # G (Currency Unit)
  def self.gold
    return $data_system.terms.gold
  end

end

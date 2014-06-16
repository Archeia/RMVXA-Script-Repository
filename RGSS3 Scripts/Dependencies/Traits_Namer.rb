#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Traits Namer
#  Author: Kread-EX
#  Version: 1.02
#  Release date: 11/03/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 03/02/2012. Bug fixes.
# # 24/03/2012. Added methods used by Alchemic Synthesis.
# # 23/03/2012. Version 1.0, now help window generation is included.
#------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#------------------------------------------------------------------------------
# # This is a core script. By itself, it doesn't do anything but it used by
# # Runic Enchantment and Alchemic Synthesis. The purpose of this script
# # is to provide an automated way to name traits: the script retrieve the traits
# # data and generates a name based on a customizable template.
#------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-TraitsNamer'] = true

puts 'Load: Traits Namer v1.02 by Kread-EX'

module KRX
  module TraitsNamer
#===========================================================================
# ■ CONFIGURATION
#===========================================================================

    X_PARAMETERS = [
    
    'Accuracy',
    'Evasion',
    'Critical rate',
    'Critical eva. rate',
    'M. Evasion',
    'Magic reflection',
    'Counter rate',
    'HP Regen',
    'MP Regen',
    'TP Regen'
    
    ]
    
    S_PARAMETERS = [
    
    'Aggro effect',
    'Guard effect',
    'Recovery rate',
    'Pharmacology',
    'MP cost',
    'TP charge rate',
    'Physical damage',
    'Magical damage',
    'Floor damage',
    'EXP rate'
    
    ]

    SPECIAL_FLAGS = [
    
    'Autobattle',
    'Guard',
    'Cover',
    'TP Saver'
    
    ]
    
    PARTY_ABILITY = [
    
    'Half Encounter',
    'No Encounter',
    'No surprise attacks',
    'No preemptive attacks',
    'Gold x2',
    'Item Drops x2'
    
    ]
    
    CODENAMES = {
    
    11 => '%s resist: %d%%'       , # Element rate
    12 => '%s debuff rate: %d%%'  , # Debuff rate
    13 => '%s resist: %d%%'       , # State rate
    14 => 'Immunity: %s'          , # State immunity
    21 => '%s: %d%%'              , # Parameter rate
    22 => '%s: %d%%'              , # Additional parameter rate
    23 => '%s: %d%%'              , # Special parameter rate
    31 => 'Attack %s'             , # Physical attack attribute
    32 => 'Attack %s %d%%'        , # Physical attack state
    33 => 'Attack speed %d'       , # Attack speed correction
    34 => 'Attack x%d'            , # Additional attacks
    41 => 'Command: %s'           , # Add skill type
    42 => 'Seal: %s'              , # Seal skill type
    43 => 'Skill: %s'             , # Add skill
    44 => 'Skill Seal: %s'        , # Seal skill
    51 => 'Can equip: %s'         , # Add equip type (weapon)
    52 => 'Can equip: %s'         , # Add equip type (armor)
    53 => 'Fix equip: %s'         , # Fix equip slot
    54 => 'Seal equip: %s'        , # Seal equip slot
    55 => 'Dual Wielding'         , # Dual Wield
    61 => 'Bonus Actions: +%d%%'  , # Bonus actions
    62 => '%s'                    , # Special flag
    63 => 'Collapse type'         , # Collapse type (will never be used, I think)
    64 => '%s'                    , # Party ability
    
    }
    
    CODEHELP = {
    
    # Element rate
    11 => 'Raises %s resistance by %d%%.',
    # Debuff rate
    12 => 'Raises %s resistance by %d%%.',
    # State rate
    13 => 'Raises %s resistance by %d%%.',
    # State immunity
    14 => 'Grants immunity to %s.',
    # Parameter rate
    21 => 'Raises %s by %d%%.',
    # Additional parameter rate
    22 => 'Raises %s by %d%%.',
    # Special parameter rate
    23 => 'Grants a %d% modifier to %s.',
    # Physical attack attribute 
    31 => 'Adds %s element to normal attacks.',
    # Physical attack state
    32 => 'Adds %s to normal attacks (%d%% accuracy).',
    # Attack speed correction (bonus)
    33 => ['Raises attack speed by %d.',
    # Attack speed correction (malus)
    'Reduces attack speed by %d.'],
    # Additional attacks
    34 => 'Grants %d additional attacks.',
    # Add skill type
    41 => 'Enables the %s battle command.',
    # Seal skill type
    42 => 'Seals the %s battle command.',
    # Add skill
    43 => 'Allows the use of the %s skill',
    # Seal skill
    44 => 'Seals the %s skill.',
    # Add equip type (weapon)
    51 => 'Allows %s to be equipped.',
    # Add equip type (armor)
    52 => 'Allows %s to be equipped.',
    # Fix equip slot
    53 => 'Fixes the %s equipment slot.',
    # Seal equip slot
    54 => 'Seals the %s equipment slot.',
    # Dual Wield
    55 => 'Allows to use two weapons as the same time.',
    # Bonus actions
    61 => 'Raises the action rate by %d%%.',
    # Autobattle
    62 => ['The character will act on his/her own in battle.',
    # Guard
    'The character will permanently defend.',
    # Cover
    'The character will take hits for his/her wounded comrades.',
    # TP Saver
    'TP are kept after battles.'],
    # Collapse type (no need to use it but meh)
    63 => 'Alters the collapse animation.',
    # Half encounter
    64 => ['Halves the random encounter rate.',
    # No encounter
    'Disables random encounters.',
    # No surprise attacks
    'Disables surprise attacks.',
    # No preemptive attacks
    'Disables preemptive attacks.',
    # Gold x2
    'Doubles the money obtained after a battle.',
    # Item Drops x2
    'Doubles the drop rate of items.']
    
    }

    EFFECTS_CODENAMES = {
    
    11 => 'HP Recovery'                   , # HP Recovery
    12 => 'MP Recovery'                   , # MP Recovery
    13 => 'TP Recovery'                   , # TP Gain
    21 => 'Add %s'                        , # Add State
    22 => 'Cleanse %s'                    , # Remove State
    31 => '%s+'                           , # Add buff
    32 => '%s-'                           , # Add debuff
    33 => 'Dispel %s+'                    , # Remove buff
    34 => 'Cancel %s-'                    , # Remove debuff
    41 => 'Escape'                        , # Escape
    42 => '%s Bonus'                      , # Permanent stat growth
    43 => 'Learn %s'                      , # Permanent skill learning
    44 => 'Common Event'                  , # Common event
    
    }
    
    EFFECTS_CODEHELP = {
    
    # HP Recovery (static)
    11 => ['Restores %d HP.',
    # HP Recovery (dynamic)
    'Restores %d%% of maximum HP.'],
    # MP Recovery (static)
    12 => ['Restores %d MP.',
    # MP Recovery (dynamic)
    'Restores %d%% of maximum MP.'],
    # TP Gain
    13 => 'Restores %d%% TP.',
    # Add State
    21 => 'Inflicts %s (%d%% chance).',
    # Remove State
    22 => 'Cancels %s.',
    # Add buff
    31 => 'Increases %s for %d turns.',
    # Add debuff
    32 => 'Decreases %s for %d turns.',
    # Remove buff
    33 => 'Cancels a previously applied %s buff.',
    # Remove debuff
    34 => 'Dispels an active %s debuff.',
    # Escape
    41 => 'Automatically escape from battle.',
    # Permanent stat growth
    42 => 'Boosts %d by %d permanently.',
    # Permanent skill learning
    43 => 'Teaches the %s skill permanently.',
    # Common Event
    44 => 'Calls a common event.'
    
    }
    
#===========================================================================
# ■ CUSTOM TRAITS/EFFECTS CONFIGURATION
#===========================================================================

    # INSTRUCTIONS
    # Here you can define custom traits names and descriptions.
    #
    # Syntax:
    # [type, code, data_id, value 1, value2] => [name, description]
    #
    # type: 0 (for equipment), 1 (for usables)
    #
    # code: the code number. Refer to default naming to know what is what.
    #
    # data_id: the number of the option you've choosen in the trait droplist.
    #
    # value1: what you typed in the first field where you can write numbers.
    # For equipment this is the only one.
    #
    # value2: usable items only. What you typed in the second field.
    #
    # description: If you want to also use a custom description. If you only
    # want the custom name, set this to nil.

    CUSTOM_TRAITS = {
    
    [0, 32, 2, 50] => ['Poisonous', nil],
    [0, 32, 2, 100] => ['Venomous', nil],
    
    [1, 11, 0, 0, 10] => ['HP Recovery XS', nil],
    [1, 11, 0, 0, 25] => ['HP Recovery S', nil],
    [1, 11, 0, 0, 50] => ['HP Recovery M', nil],
    [1, 11, 0, 0, 75] => ['HP Recovery L', nil],
    [1, 11, 0, 0, 100] => ['HP Recovery XL', 'Restores all HP!'],
    [1, 12, 0, 0, 10] => ['MP Recovery XS', nil],
    [1, 12, 0, 0, 25] => ['MP Recovery S', nil],
    [1, 12, 0, 0, 50] => ['MP Recovery M', nil],
    [1, 12, 0, 0, 75] => ['MP Recovery L', nil],
    [1, 12, 0, 0, 100] => ['MP Recovery XL', 'Restores all MP!'],
    [1, 13, 0, 2, 0] => ['TP Recovery XS', nil],
    [1, 13, 0, 5, 0] => ['TP Recovery S', nil],
    [1, 13, 0, 10, 0] => ['TP Recovery M', nil],
    [1, 13, 0, 16, 0] => ['TP Recovery L', nil],
    [1, 13, 0, 20, 0] => ['TP Recovery XL', nil],
    
    }
    
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
    #--------------------------------------------------------------------------
    # ● Generates traits name
    #--------------------------------------------------------------------------
    def self.feature_name(code, data_id, value)
      custom = CUSTOM_TRAITS[[0, code, data_id, self.convert_value(code, value)]]
      return custom[0] unless custom.nil? || custom[0].nil?
      base_name = CODENAMES[code]
      data_name = case code
        when 11, 31
          $data_system.elements[data_id]
        when 12, 21
          Vocab.param(data_id)
        when 13, 14, 32
          $data_states[data_id].name
        when 22
          X_PARAMETERS[data_id]
        when 23
          S_PARAMETERS[data_id]
        when 41, 42
          $data_system.skill_types[data_id]
        when 43, 44
          $data_skills[data_id].name
        when 51
          $data_system.weapon_types[data_id]
        when 52
          $data_system.armor_types[data_id]
        when 53, 54
          Vocab.etype(data_id)
        when 62
          SPECIAL_FLAGS[data_id]
        when 64
          PARTY_ABILITY[data_id]
        end
      final_value = case code
        when 11, 13
          100 - (value * 100)
        when 33, 34
          value
        else
          value * 100
        end
      if data_name.nil?
        name = sprintf(base_name, final_value)
      else
        name = sprintf(base_name, data_name, final_value)
      end
      name
    end
    #--------------------------------------------------------------------------
    # ● Generates traits description
    #--------------------------------------------------------------------------
    def self.feature_description(code, data_id, value)
      custom = CUSTOM_TRAITS[[0, code, data_id, self.convert_value(code, value)]]
      return custom[1] unless custom.nil? || custom[1].nil?
      if CODEHELP[code].is_a?(Array)
        base_help = CODEHELP[code][data_id]
      else
        base_help = CODEHELP[code]
      end
      data_name = case code
        when 11, 31
          $data_system.elements[data_id]
        when 12, 21
          Vocab.param(data_id)
        when 13, 14, 32
          $data_states[data_id].name
        when 22
          X_PARAMETERS[data_id]
        when 23
          S_PARAMETERS[data_id]
        when 41, 42
          $data_system.skill_types[data_id]
        when 43, 44
          $data_skills[data_id].name
        when 51
          $data_system.weapon_types[data_id]
        when 52
          $data_system.armor_types[data_id]
        when 53, 54
          Vocab.etype(data_id)
        when 62
          SPECIAL_FLAGS[data_id]
        when 64
          PARTY_ABILITY[data_id]
        end
      final_value = case code
        when 11, 13
          100 - (value * 100)
        when 33, 34
          value
        else
          value * 100
        end
      if data_name.nil?
        name = sprintf(base_help, final_value)
      else
        name = sprintf(base_help, data_name, final_value)
      end
      name
    end
    #--------------------------------------------------------------------------
    # ● Generates effects name
    #--------------------------------------------------------------------------
    def self.effect_name(code, data_id, value1, value2)
      custom = CUSTOM_TRAITS[[1, code, data_id,
      self.convert_value(code, value1, false),
      self.convert_value(code, value2, false)]]
      return custom[0] unless custom.nil? || custom[0].nil?
      base_name = EFFECTS_CODENAMES[code]
      data_name = case code
        when 21, 22
          $data_states[data_id].name
        when 31, 32, 33, 34, 42
          Vocab.param(data_id)
        when 43
          $data_skills[data_id]
        end
      if data_name.nil?
        name = sprintf(base_name, value1, value2)
      else
        name = sprintf(base_name, data_name, value1, value2)
      end
      name
    end
    #--------------------------------------------------------------------------
    # ● Generates effects description
    #--------------------------------------------------------------------------
    def self.effect_description(code, data_id, value1, value2)
      custom = CUSTOM_TRAITS[[1, code, data_id,
      self.convert_value(code, value1, false),
      self.convert_value(code, value2, false)]]
      return custom[1] unless custom.nil? || custom[1].nil?
      if EFFECTS_CODEHELP[code].is_a?(Array)
        base_help = value2 > 0 ? EFFECTS_CODEHELP[code][0] :
        EFFECTS_CODEHELP[code][1]
      else
        base_help = EFFECTS_CODEHELP[code]
      end
      data_name = case code
        when 21, 22
          $data_states[data_id].name
        when 31, 32, 33, 34, 42
          Vocab.param(data_id)
        when 43
          $data_skills[data_id]
        end
      value1 = self.convert_value(code, value1, false)
      value2 = self.convert_value(code, value2, false)
      value1 = value2 if value1 == 0
      if data_name.nil?
        name = sprintf(base_help, value1, value2)
      else
        name = sprintf(base_help, data_name, value1, value2)
      end
      name
    end
    #--------------------------------------------------------------------------
    # ● Converts the real value to the one entered in the editor
    #--------------------------------------------------------------------------
    def self.convert_value(code, value, feature = true)
      if feature && [33, 34].include?(code)
        return value.to_i
      elsif feature && [21].include?(code)
        return (value.to_f / 100)
      elsif [11, 12].include?(code) && value <= 1
        return (value.to_i * 100).to_i
      else
        value.to_i
      end
    end
    #--------------------------------------------------------------------------
    # ● Points towards either feature name or effect name
    #--------------------------------------------------------------------------
    def self.trait_name(trait)
      if trait.is_a?(RPG::BaseItem::Feature)
        return self.feature_name(trait.code, trait.data_id, trait.value)
      end
      self.effect_name(trait.code, trait.data_id, trait.value1, trait.value2)
    end
    #--------------------------------------------------------------------------
    # ● Points towards either feature description or effect description
    #--------------------------------------------------------------------------
    def self.trait_description(trait)
      if trait.is_a?(RPG::BaseItem::Feature)
        return self.feature_description(trait.code, trait.data_id, trait.value)
      end
      self.effect_description(trait.code, trait.data_id, trait.value1,
      trait.value2)
    end
  end
end
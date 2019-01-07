=begin
#===============================================================================
 ** Feature Manager
 Author: Hime
 Date: Oct 3, 2013
--------------------------------------------------------------------------------
 ** Change log
 2.0 Oct 3, 2013
   - implemented the extended regex for feature note-tags
 1.32 Nov 18, 2012
   - added convenience wrapper for data elements
 1.31 Nov 9, 2012
   - fixed bug where item features didn't have conditions
 1.3 Nov 8, 2012
   - Added conditional features.
   - Aliased default features for use with conditional features
 Oct 22, 2012
   - No longer overwrites any methods
 Oct 21, 2012
   - features_value_set should return set of values, not data_id's
 Oct 18, 2012
   - added item_feature_set to collect all features for a given item
 Oct 14, 2012
   - added max/min feature value collection
 Oct 13, 2012
   - added some feature collection to check features of specific item
   - re-wrote `equippable?` to do negative-checking
 Oct 12, 2012
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
 ** Compatibility
 
 This script does not overwrite any methods and aliases one method.
 Most features should not have conflicts with the following systems
 
 -Tankentai SBS
 -Yanfly Ace Battle Engine
--------------------------------------------------------------------------------
 ** Description
 
 This is a plugin-based feature system that allows you to define your own
 features easily and add them to database objects.
 
 Register a feature using an idstring to identify your feature. Recommended
 strings or symbols, but anything hashable is valid.
 
 You will use the idstring throughout your script, such as in notetags
 and also initializing the feature (optional).
 
 If your script will be using params, xparams, or sparams, you should use
 standard data ID's that the rest of the script uses. These are defined in
 the tables below.
 
 You should use data ID 0 for weapons, 1 for armors, and 2 for items.
--------------------------------------------------------------------------------
 ** Usage
 
 To add a feature to a feature object, simply note-tag with a feature tag.
 The general syntax for a feature tag is
 
    <ft: name arg1 arg2 ... >
    
 Where 
   `name` is the name of the feature you wish to add
   `arg1 arg2 ...` are a list of arguments that the plugin requires
   
 You may specify conditional features as well, using the following note-tag
 
    <cond_ft: name "cond" arg1 arg2 ... >
    
 Where
   `cond` is a ruby expression that evaluates to true or false. The condition
          must be surrounded by quotation marks.
          
 Conditional features can be applied to any feature that is supported by this
 system.
 
 If you need more control over the note-tag, you can use the extended note-tag
 
   <ft: FEATURE_NAME>
     option1: value1
     option2: value2
     ...
   </ft>
   
 You can define any option name that you want. All options will be passed to
 your `add_feature` method as a hash, where the keys are the option names and
 the values are the corresponding values. For example, the above example
 would create a hash that looks like
 
   {
     :option1 => value1,
     :option2 => value2
   }
   
 Which you can then use to grab values.
 To work with your extended note-tag, you need to define the following method
 in BaseItem or its child classes:
 
   def add_feature_FEATURE_NAME_ext(code, data_id, args)
     
     # do something with your args
     value = ...
     add_feature(code, data_id, value)
   end
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Feature_Manager"] = 2.0
#===============================================================================
# ** Rest of the script
#===============================================================================
module FeatureManager

  # Format for all note tags
  Feature_Regex = /<ft: (\w+)(.*)>/i
  Cond_Feature_Regex = /<cond_ft: (\w+) ['"](.*)['"](.*)>/i
  
  Ext_Regex = /<feature: (\w+)>(.*?)<\/feature>/im
  
  # Default features.
  FEATURE_ELEMENT_RATE  = 11              # Element Rate
  FEATURE_DEBUFF_RATE   = 12              # Debuff Rate
  FEATURE_STATE_RATE    = 13              # State Rate
  FEATURE_STATE_RESIST  = 14              # State Resist
  FEATURE_PARAM         = 21              # Parameter
  FEATURE_XPARAM        = 22              # Ex-Parameter
  FEATURE_SPARAM        = 23              # Sp-Parameter
  FEATURE_ATK_ELEMENT   = 31              # Atk Element
  FEATURE_ATK_STATE     = 32              # Atk State
  FEATURE_ATK_SPEED     = 33              # Atk Speed
  FEATURE_ATK_TIMES     = 34              # Atk Times+
  FEATURE_STYPE_ADD     = 41              # Add Skill Type
  FEATURE_STYPE_SEAL    = 42              # Disable Skill Type
  FEATURE_SKILL_ADD     = 43              # Add Skill
  FEATURE_SKILL_SEAL    = 44              # Disable Skill
  FEATURE_EQUIP_WTYPE   = 51              # Equip Weapon
  FEATURE_EQUIP_ATYPE   = 52              # Equip Armor
  FEATURE_EQUIP_FIX     = 53              # Lock Equip
  FEATURE_EQUIP_SEAL    = 54              # Seal Equip
  FEATURE_SLOT_TYPE     = 55              # Slot Type
  FEATURE_ACTION_PLUS   = 61              # Action Times+
  FEATURE_SPECIAL_FLAG  = 62              # Special Flag
  FEATURE_COLLAPSE_TYPE = 63              # Collapse Effect
  FEATURE_PARTY_ABILITY = 64              # Party Ability
  
  # Data ID's for consistency with the rest of the scripts
  Weapon_ID = 0
  Armor_ID = 1
  Item_ID = 2
  
  # Data ID's for basic parameters. Use this if you are going to
  # use params in note tags
  Param_Table = {
    "mhp" => 0,
    "mmp" => 1,
    "atk" => 2,
    "def" => 3,
    "mat" => 4,
    "mdf" => 5,
    "agi" => 6,
    "luk" => 7
  }
   
  # Data ID's for extra parameters.
  XParam_Table = {
    "hit" => 0,
    "eva" => 1,
    "cri" => 2,
    "cev" => 3,
    "mev" => 4,
    "mrf" => 5,
    "cnt" => 6,
    "hrg" => 7,
    "mrg" => 8,
    "trg" => 9
  }
  
  # Data ID's for special parameters
  SParam_Table = {
    "tgr" => 0,
    "grd" => 1,
    "rec" => 2,
    "pha" => 3,
    "mcr" => 4,
    "tcr" => 5,
    "pdr" => 6,
    "mdr" => 7,
    "fdr" => 8,
    "exr" => 9,
  }
  
  def self.register(idstring, api_version=1.0)
    idstring = idstring.to_s
    key = idstring.to_sym
    if $imported["Feature_Manager"] < api_version
      outdated_api_warn(idstring, api_version)
    elsif @feature_table.include?(key)
      dupe_entry_warn(key, @feature_table[key]) 
    else
      @feature_table[key] = idstring
    end
  end
  
  def self.api_version(version)
    
  end
  
  # Each feature maps to a code, which is stored in the feature.
  # It should be a symbol. Notice that this table is only used for
  # mapping and is never referenced after an object has been setup.
  def self.initialize_tables
    @feature_table = {
      FEATURE_ELEMENT_RATE  => 11,              # Element Rate
      FEATURE_DEBUFF_RATE   => 12,              # Debuff Rate
      FEATURE_STATE_RATE    => 13,              # State Rate
      FEATURE_STATE_RESIST  => 14,              # State Resist
      FEATURE_PARAM         => 21,              # Parameter
      FEATURE_XPARAM        => 22,              # Ex-Parameter
      FEATURE_SPARAM        => 23,              # Sp-Parameter
      FEATURE_ATK_ELEMENT   => 31,              # Atk Element
      FEATURE_ATK_STATE     => 32,              # Atk State
      FEATURE_ATK_SPEED     => 33,              # Atk Speed
      FEATURE_ATK_TIMES     => 34,              # Atk Times+
      FEATURE_STYPE_ADD     => 41,              # Add Skill Type
      FEATURE_STYPE_SEAL    => 42,              # Disable Skill Type
      FEATURE_SKILL_ADD     => 43,              # Add Skill
      FEATURE_SKILL_SEAL    => 44,              # Disable Skill
      FEATURE_EQUIP_WTYPE   => 51,              # Equip Weapon
      FEATURE_EQUIP_ATYPE   => 52,              # Equip Armor
      FEATURE_EQUIP_FIX     => 53,              # Lock Equip
      FEATURE_EQUIP_SEAL    => 54,              # Seal Equip
      FEATURE_SLOT_TYPE     => 55,              # Slot Type
      FEATURE_ACTION_PLUS   => 61,              # Action Times+
      FEATURE_SPECIAL_FLAG  => 62,              # Special Flag
      FEATURE_COLLAPSE_TYPE => 63,              # Collapse Effect
      FEATURE_PARTY_ABILITY => 64,              # Party Ability
      
      # Aliasing the above features with custom names to support conditionals
      :element_rate         => "element_rate",
      :debuff_rate          => "debuff_rate",
      :state_rate           => "state_rate",
      :state_resist         => "state_resist",
      :param                => "param",
      :xparam               => "xparam",
      :sparam               => "sparam",
      :atk_element          => "atk_element",
      :atk_state            => "atk_state",
      :atk_speed            => "atk_speed",
      :atk_times            => "atk_times",
      :stype_add            => "stype_add",
      :stype_seal           => "stype_seal",
      :skill_add            => "skill_add",
      :skill_seal           => "skill_seal",
      :equip_wtype          => "equip_wtype",
      :equip_atype          => "equip_atype",
      :equip_fix            => "equip_fix",
      :equip_seal           => "equip_seal",
      :slot_type            => "slot_type",
      :action_plus          => "action_plus",
      :special_flag         => "special_flag",
      :collapse_type        => "collapse_type",
      :party_ability        => "party_ability"
    }
    
    @element_tables = {}
    
  end
  
  # Returns the feature code for the particular string.
  def self.get_feature_code(sym)
    @feature_table[sym]
  end
  
  def self.dupe_entry_warn(your_id, existing_name)
    msgbox("Warning: %s has already been reserved" %[existing_name.to_s])
  end
  
  def self.outdated_api_warn(idstring, version)
    msgbox("Warning: `%s` feature requires version %.2f of the script" %[idstring, version])
  end
  
  def self.feature_table
    @feature_table
  end
  
  # Table of elements, mapped to their ID's.
  def self.element_table
    return @element_table unless @element_table.nil?
    @element_table = {}
    $data_system.elements.each_with_index {|element, i|
      next if element.empty?
      @element_table[element.downcase] = i
    }
    return @element_table
  end
  
  # start things up
  initialize_tables
end

module RPG
  
  class BaseItem::Feature
    attr_accessor :condition
  end

  class BaseItem
    def features
      load_notetag_feature_manager unless @feature_checked
      return @features
    end
    
    # Go through each line looking for custom features. Note that the data id
    # is currently hardcoded to 0 since we don't really need it.
    def load_notetag_feature_manager
      @feature_checked = true
      
      #check for features
      results = self.note.scan(FeatureManager::Feature_Regex)
      results.each { |code, args|
        code = FeatureManager.get_feature_code(code.to_sym)
        if code
          check_feature(code, args)
        end
      }
      
      # check for conditional features
      results = self.note.scan(FeatureManager::Cond_Feature_Regex)
      results.each {|code, cond, args|
        code = FeatureManager.get_feature_code(code.to_sym)
        if code
          check_feature(code, args)
          @features[-1].condition = cond
        end
      }
      
      # check for features using extended regex.
      results = self.note.scan(FeatureManager::Ext_Regex)
      results.each do |res|
        args = {}
        code = FeatureManager.get_feature_code(res[0].to_sym)
        if code
          data = res[1].strip.split("\r\n")
          data.each do |option|
            name, value = option.split(":")
            args[name.strip.to_sym] = value.strip
          end
          check_feature_ext(code, args)
        end
      end
    end
    
    def check_feature(code, args)
      ft_code = code.is_a?(Fixnum) ? code : code.to_sym
      if respond_to?("add_feature_#{code}")
        send("add_feature_#{code}", ft_code, 0, args.split)
      else
        add_feature(ft_code, 0, args.split) 
      end
    end
    
    def check_feature_ext(code, args)
      ft_code = code.is_a?(Fixnum) ? code : code.to_sym
      if respond_to?("add_feature_#{code}_ext")
        send("add_feature_#{code}_ext", ft_code, 0, args)
      else
        add_feature(ft_code, 0, args) 
      end
    end
    
    def add_feature(code, data_id, args)
      @features.push(RPG::BaseItem::Feature.new(code, data_id, args))
    end
    
    # Register default features. Redundant, but the editor hardcodes values
    # so we must do the same
    
    # Args: element name (case-sensitive) or ID, float percentage
    def add_feature_element_rate(code, data_id, args)
      data_id = Integer(args[0]) rescue $data_system.elements.index(args[0])
      add_feature(11, data_id, args[1].to_f)
    end
    
    # Args: param name, float percentage
    def add_feature_debuff_rate(code, data_id, args)
      data_id = FeatureManager::Param_Table[args[0].downcase]
      add_feature(12, data_id, args[1].to_f)
    end
    
    # Args: state ID, float percentage
    def add_feature_state_rate(code, data_id, args)
      data_id = Integer(args[0])
      add_feature(13, data_id, args[1].to_f)
    end
    
    # Args: state ID, float percentage
    def add_feature_state_resist(code, data_id, args)
      data_id = Integer(args[0])
      add_feature(14, data_id, args[1].to_f)
    end
    
    # Args: param name, float percentage
    def add_feature_param(code, data_id, args)
      data_id = FeatureManager::Param_Table[args[0].downcase]
      add_feature(21, data_id, args[1].to_f)
    end
    
    # Args: sparam name, float percentage
    def add_feature_xparam(code, data_id, args)
      data_id = FeatureManager::XParam_Table[args[0].downcase]
      add_feature(22, data_id, args[1].to_f)
    end
    
    # Args: xparam name, float percentage
    def add_feature_sparam(code, data_id, args)
      data_id = FeatureManager::SParam_Table[args[0].downcase]
      add_feature(23, data_id, args[1].to_f)
    end
    
    # Args: param name, float percentage
    def add_feature_atk_element(code, data_id, args)
      data_id = Integer(args[0]) rescue $data_system.elements.index(args[0])
      add_feature(31, data_id, args[1].to_f)
    end
    
    # Args: state ID, float percentage
    def add_feature_atk_state(code, data_id, args)
      data_id = Integer(args[0])
      add_feature(32, data_id, args[1].to_f)
    end
    
    # Args: float attack speed
    def add_feature_atk_speed(code, data_id, args)
      add_feature(33, 0, args[1].to_f)
    end

    # Args: float attack times
    def add_feature_atk_times(code, data_id, args)
      add_feature(34, 0, args[1].to_f)
    end
    
    # Args: stype ID or name
    def add_feature_stype_add(code, data_id, args)
      data_id = Integer(args[0]) rescue $data_system.skill_types.index(args[0])
      add_feature(41, data_id, 0)
    end
    
    def add_feature_stype_seal(code, data_id, args)
      data_id = Integer(args[0]) rescue $data_system.skill_types.index(args[0])
      add_feature(42, data_id, 0.0)
    end
      
    def add_feature_skill_add(code, data_id, args)
      add_feature(43, args[0].to_i, 0.0)
    end
    
    def add_feature_skill_seal(code, data_id, args)
      add_feature(44, args[0].to_i, 0.0)
    end
    
    def add_feature_equip_wtype(code, data_id, args)
      data_id = Integer(args[0]) rescue $data_system.weapon_types.index(args[0])
      add_feature(51, data_id, 0)
    end
    
    def add_feature_equip_atype(code, data_id, args)
      data_id = Integer(args[0]) rescue $data_system.armor_types.index(args[0])
      add_feature(52, data_id, 0)
    end
    
    # args: etype_id
    def add_feature_equip_fix(code, data_id, args)
      add_feature(53, args[0].to_i, 0)
    end
    
    # args: etype_id
    def add_feature_equip_seal(code, data_id, args)
      add_feature(54, args[0].to_i, 0)
    end
    
    # args: slot type (1 for dual wield)
    def add_feature_slot_type(code, data_id, args)
      add_feature(55, args[0].to_i, 0)
    end
    
    def add_feature_action_plus(code, data_id, args)
      add_feature(61, 0, args[0].to_f)
    end
    
    # args: flag_ID
    def add_feature_special_flag(code, data_id, args)
      add_feature(62, args[0].to_i, 0)
    end
    
    # args: collapse type ID
    def add_feature_collapse_type(code, data_id, args)
      add_feature(63, args[0].to_i, 0)
    end
    
    # args: party ability ID
    def add_feature_party_ability(code, data_id, args)
      add_feature(64, args[0].to_i, 0)
    end
  end
end

class Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # * Feature collection methods
  #-----------------------------------------------------------------------------
  
  def eval_feature_condition(condition, a, v=$game_variables, s=$game_switches)
    eval(condition) rescue false
  end
  
  def feature_condition_met?(ft)
    return true unless ft.condition
    eval_feature_condition(ft.condition, self)
  end
  
  # May be inefficient since this method is called all the time
  alias :th_feature_manager_all_features :all_features
  def all_features
    th_feature_manager_all_features.select {|ft| feature_condition_met?(ft)}
  end
  
  # Returns features for item filtered by code
  def item_features(item, code)
    item.features.select {|ft| ft.code == code && feature_condition_met?(ft)}
  end
  
  # Returns a set of all values for the given feature code
  def features_value_set(code)
    features(code).inject([]) {|r, ft| r |= [ft.value] }
  end
  
  # Returns a set of all values for the given feature code, filtered by data ID
  def features_value_set_with_id(code, data_id)
    features_with_id(code, data_id).inject([]) {|r, ft| r |= [ft.value]}
  end
  
  # Returns features for item filtered by code and data ID
  def item_features_with_id(item, code, data_id)
    item.features.select {|ft| ft.code == code && ft.data_id == data_id}
  end
  
  def item_features_set(item, code, data_id)
    item_features_with_id(item, code, data_id).inject([]) {|r, ft| r |= [ft.value]}
  end
  
  # Returns sum of all features for item, by code and data ID
  def item_features_sum(item, code, data_id)
    item_features_with_id(item, code, data_id).inject(0.0) {|r, ft| r += ft.value }
  end
  
  # Returns the max value for the code
  def features_max(code)
    features(code).collect {|ft| ft.value}.max
  end
  
  # Returns the max value for the code, filtered by ID
  def features_max_with_id(code, data_id)
    features_with_id(code, data_id).collect {|ft| ft.value}.max
  end
  
  # Returns the min value for the given code
  def features_min(code)
    features(code).collect {|ft| ft.value}.min
  end
  
  # Returns the min value for the given code, filtered by ID
  def features_min_with_id(code, data_id)
    features_with_id(code, data_id).collect {|ft| ft.value}.min
  end
  
  # Returns the max value of features for item, filtered by code and ID
  def item_features_max(item, code, data_id)
    item_features_with_id(item, code, data_id).collect {|ft| ft.value}.max
  end
  
  # Returns the min value of features for item, filtered by code and ID
  def item_features_min(item, code, data_id)
    item_features_with_id(item, code, data_id).collect {|ft| ft.value}.min
  end
  #-----------------------------------------------------------------------------
  # * Equip conditions
  #-----------------------------------------------------------------------------
  
  alias :feature_manager_equippable? :equippable?
  def equippable?(item)
    return false unless feature_manager_equippable?(item)
    return false if item.is_a?(RPG::Weapon) && !feature_equip_weapon_ok?(item) 
    return false if item.is_a?(RPG::Armor) && !feature_equip_armor_ok?(item)
    return true
  end
    
  def feature_equip_weapon_ok?(item)
    return true
  end
  
  def feature_equip_armor_ok?(item)
    return true
  end
end

class Game_Party
  attr_accessor :actors
end
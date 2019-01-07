=begin
#===============================================================================
 Title: Item Affixes
 Author: Hime
 Date: Jan 27, 2015
 URL: http://himeworks.com/2014/01/13/item-affixes/
--------------------------------------------------------------------------------
 ** Change log 
 Jam 27, 2015
   - updated to support placeholder affix descriptions
 Jan 23, 2014
   - applies note modifiers
 Jan 14, 2014
   - applied compatible name modifiers
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script introduces the concept of "item affixes". Prefixes and suffixes
 may be assigned to your equips to provide additional parameter bonuses or
 features.
 
 For example, you might have a prefix called "Fiery " that gives a +20 bonus
 to ATK and adds a fire elemental damage. When your Short Sword has this prefix,
 its atk power will be higher than regular Short Swords and will deal more
 damage to targets that are weak against fire.
 
 An item may have at most one prefix and one suffix.
 
--------------------------------------------------------------------------------
 ** Required
 
 Instance Items
 (http://himeworks.com/2014/01/07/instance-items/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Instance Items and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 -- Creating affixes --
 
 Prefixes and Suffixes are created as Armors into your database.
 
 1. Choose a name. You must manually add in the appropriate spaces before or
    after the name so it will be displayed properly in the game
    
 2. Choose parameter bonuses for your affix.
 
 3. Choose feature bonuses for your affix
 
 -- Applying Placeholder Descriptions
 
 Placeholder descriptions are special descriptions for your affixes.
 They allow you to add new text to an equip's description without overwriting
 the original description.
 
 For example, if you add a prefix to an equip, you might want to show both
 the original equip's description as well as the prefix's description.
 
 To do this, use a special symbol: %s
 
 The %s is the placeholder that will be replaced with the original equip's
 description.
 
 If you had a short sword with a description
 
   "Basic short sword."
   
 and you had a prefix with the description
 
   "%s Adds fire elemental damage."
    
 When the prefix is added to the short sword, the short sword will now have the
 resulting description
 
   "Basic short sword. Adds fire elemental damage."
 
 -- Setting affixes to your equips --
 
 To set prefixes or suffixes, use the script calls
 
   set_prefix(equip, prefix_id)
   set_suffix(equip, suffix_id)
   
 Where the equip is an RPG::Weapon or RPG::Armor object.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_ItemAffixes] = true
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class EquipItem < BaseItem
    
    #---------------------------------------------------------------------------
    # Returns the equip's prefix. Returns nil if there is no prefix
    #---------------------------------------------------------------------------
    def prefix
      $data_armors[self.prefix_id]
    end

    #---------------------------------------------------------------------------
    # Returns the equip's suffix. Returns nil if there is no suffix
    #---------------------------------------------------------------------------
    def suffix
      $data_armors[self.suffix_id]
    end
    
    #---------------------------------------------------------------------------
    # Returns the equip's prefix ID. 0 if there is no prefix
    #---------------------------------------------------------------------------
    def prefix_id
      @prefix_id ||= 0
    end
    
    #---------------------------------------------------------------------------
    # Sets the equip's prefix. Takes the ID of the prefix to set
    #---------------------------------------------------------------------------
    def prefix_id=(id)
      @prefix_id = id
      refresh
    end
    
    #---------------------------------------------------------------------------
    # Returns the equip's suffix ID. 0 if there is no suffix
    #---------------------------------------------------------------------------
    def suffix_id
      @suffix_id ||= 0
    end
    
    #---------------------------------------------------------------------------
    # Sets the equip's suffix. Takes the ID of the suffix to set
    #---------------------------------------------------------------------------
    def suffix_id=(id)
      @suffix_id = id
      refresh
    end
    
    alias :th_item_affixes_make_name :make_name
    def make_name(name)
      name = th_item_affixes_make_name(name)
      name = apply_name_prefix(name) if self.prefix
      name = apply_name_suffix(name) if self.suffix
      name
    end
    
    alias :th_item_affixes_make_params :make_params
    def make_params(params)
      params = th_item_affixes_make_params(params)
      params = apply_prefix_params(params) if self.prefix
      params = apply_suffix_params(params) if self.suffix
      params
    end
    
    alias :th_item_affixes_make_description :make_description
    def make_description(desc)
      desc = th_item_affixes_make_description(desc)
      desc = apply_prefix_description(desc) if self.prefix
      desc = apply_suffix_description(desc) if self.suffix
      desc
    end
    
    def apply_name_prefix(name)
      name = prefix.name + name 
      return name
    end
    
    def apply_name_suffix(name)
      name = name + suffix.name 
      return name
    end
    
    def apply_prefix_description(desc)
      sprintf(self.prefix.description, desc)
    end
    
    def apply_suffix_description(desc)
      sprintf(self.suffix.description, desc)
    end
    
    def apply_prefix_params(params)
      prefix.params.size.times do |i|
        params[i] += prefix.params[i] 
      end
      return params
    end
    
    def apply_suffix_params(params)
      suffix.params.size.times do |i|
        params[i] += suffix.params[i]
      end
      return params
    end
    
    alias :th_item_affixes_make_price :make_price
    def make_price(price)
      price = th_item_affixes_make_price(price)
      price = apply_affix_price(price)
      price
    end
    
    def apply_affix_price(price)
      price += self.prefix.price if self.prefix
      price += self.suffix.price if self.suffix
      price
    end
    
    alias :th_item_affixes_make_features :make_features
    def make_features(feats)
      feats = th_item_affixes_make_features(feats)
      apply_affix_features(feats)
      feats
    end
    
    def apply_affix_features(feats)
      feats.concat(prefix.features) if self.prefix
      feats.concat(suffix.features) if self.suffix
    end
    
    alias :th_item_affixes_make_note :make_note
    def make_note(note)
      note = th_item_affixes_make_note(note)
      apply_affix_notes(note)
    end
    
    def apply_affix_notes(note)
      note << self.prefix.note if self.prefix
      note << self.suffix.note if self.suffix
      note
    end
  end
end

class Game_Interpreter
  
  def set_prefix(equip, id)
    equip.prefix_id = id
  end
  
  def set_suffix(equip, id)
    equip.suffix_id = id
  end
end
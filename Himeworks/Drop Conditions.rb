=begin
#==============================================================================
 ** Core: Drop Conditions
 Author: Hime
 Date: Oct 14, 2012
------------------------------------------------------------------------------
 ** Change log
 Oct 14
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free
-------------------------------------------------------------------------------
 This script makes item drop conditions much more flexible.
 You can alias `can_drop_item?` to add more conditions if needed.
 
 Place this script below Materials and above all custom scripts
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_Core_DropConditions"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module TH::Core
  module Drop_Conditions
  end
end
#==============================================================================
# ** Rest of the script
#==============================================================================
class Game_Enemy < Game_Battler
  
  # Replaced to make condition checks elsewhere
  def make_drop_items
    enemy.drop_items.inject([]) do |r, di|
      if can_drop_item?(di)
        r.push(item_object(di.kind, di.data_id)) 
      else
        r
      end
    end
  end

  # Specify conditions here
  def can_drop_item?(di)
    return false if di.kind == 0
    return false unless rand * di.denominator < drop_item_rate
    return true
  end
end
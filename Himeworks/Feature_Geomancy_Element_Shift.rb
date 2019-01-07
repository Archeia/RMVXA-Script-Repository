=begin
#===============================================================================
 Title: Geomancy Element Shift
 Author: Hime
 Date: Apr 9, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 9, 2013
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
 
 This feature allows you shift a target's element rate. It uses the following
 rules for element shifting on the elemental damage:
 
 If target absorbs element, then it nulls it
 If target nulls element, then it halves it
 If target halves element, then it takes full damage
 If target takes full damage, then it doubles it
 If target is weak against element, then it absorbs the extra damage
--------------------------------------------------------------------------------
 ** Required
 
 Feature Manager
   http://himeworks.com/2012/10/13/feature-manager/
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Feature Manager and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Tag feature objects with

   <ft: geomancy_element_shift>
   
 All elemental damage will automatically be adjusted based on the following
 shift rules: for some rate r,
 
 if r < 0, then r = 0
 if r in [0, 0.5), then r = 0.5
 if r in [0.5, 1), then r = 1
 if r == 1, then r = 2
 if r > 1, then r = -(r - 1)
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_VehicleRoutes"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Geomancy_Shift
    FeatureManager.register(:geomancy_element_shift, 1.3)
  end
end

module RPG
  class BaseItem
    def add_feature_geomancy_shift(code, data_id, args)
      add_feature(code, data_id, args)
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_geomancy_shift_item_element_rate :item_element_rate
  def item_element_rate(user, item)
    rate = th_geomancy_shift_item_element_rate(user, item)
    user.has_geomancy_feature? ? geomancy_element_shift(rate) : rate
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if the fft_geomancy feature exists
  #-----------------------------------------------------------------------------
  def has_geomancy_feature?
    !features(:geomancy_element_shift).empty?
  end
  
  #-----------------------------------------------------------------------------
  # Apply "element rate rotation" for geomancy feature. Takes the base
  # element rate. You can change these rules as you see fit.
  #-----------------------------------------------------------------------------
  def geomancy_element_shift(rate)
    # absorb -> null
    if rate < 0
      return 0
    # null -> resist (half)
    elsif rate < 0.5
      return 0.5
    # resist (half) -> normal
    elsif rate < 1
      return 1
    # normal -> weak (double)
    elsif rate == 1
      return 2
    # weak -> absorb
    elsif rate > 1
      return -(rate-1)
    end
  end
end
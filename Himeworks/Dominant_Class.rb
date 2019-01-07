=begin
#===============================================================================
 Title: Dominant Class
 Author: Hime
 Date: Apr 4, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 4, 2013
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
 
 This script adds a "dominant class" to your actors.
 The dominant class is the class with the highest level.
 
 For example, if your actor has a lv 20 Soldier and a lv 5 Mage, then your
 lv 5 mage has the stats of a lv 20 soldier.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug and play.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_DominantClass"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Dominant_Class
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Actor < Game_Battler
  
  attr_reader :dominant_class_id
  
  alias :th_dominant_class_setup :setup
  def setup(actor_id)
    @actor_id = actor_id
    @dominant_class_id = actor.class_id
    initialize_class_levels
    th_dominant_class_setup(actor_id)    
  end
  
  #-----------------------------------------------------------------------------
  # Initialize the actor's class levels
  #-----------------------------------------------------------------------------
  def initialize_class_levels
    @class_levels = {}
    @class_levels[actor.class_id] = actor.initial_level
  end
  
  #-----------------------------------------------------------------------------
  # Return the class with the highest level
  #-----------------------------------------------------------------------------
  def dominant_class
    $data_classes[@dominant_class_id]
  end
  
  #-----------------------------------------------------------------------------
  # return the level of the class with the highest level
  #-----------------------------------------------------------------------------
  def dominant_class_level
    @class_levels[@dominant_class_id]
  end
  
  #-----------------------------------------------------------------------------
  # Update the levels for the class
  #-----------------------------------------------------------------------------
  def update_class_level
    @class_levels[@class_id] = @level
  end
  
  #-----------------------------------------------------------------------------
  # Update the ID of the dominant class
  #-----------------------------------------------------------------------------
  def update_dominant_class
    @dominant_class_id = @class_levels.max_by{| k,v| v}[0]
  end
  
  #-----------------------------------------------------------------------------
  # Update class level whenever exp is changed
  #-----------------------------------------------------------------------------
  alias :th_dominant_class_change_exp :change_exp
  def change_exp(exp, show)
    th_dominant_class_change_exp(exp, show)
    update_class_level
    update_dominant_class
  end
  
  #-----------------------------------------------------------------------------
  # Get base parameters based on the dominant class
  #-----------------------------------------------------------------------------
  def param_base(param_id)
    self.dominant_class.params[param_id, self.dominant_class_level]
  end
end
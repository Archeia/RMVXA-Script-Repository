=begin
#===============================================================================
 Title: User Effects
 Author: Hime
 Date: Feb 28, 2014
 URL: 
--------------------------------------------------------------------------------
 ** Change log
 Feb 28, 2014
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
 
 This script allows you to convert item/skill effects into "user effects".
 By default, when your skill misses, none of the effects are executed.
 
 There are two types of user effects: "pre use effects" which occurs before
 the skill is executed, and "post use effects" which occurs after the skill
 is executed.
 
 Using this, you can specify that certain effects are supposed to be executed
 when the skill is used regardless whether it actually hit the target or not.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Note-tag skills and items with
 
   <pre user effect: ID>
   <post user effect: ID>
   
 Where ID is the effect ID that you want to convert into a user effect.
 The first effect on the list has ID 1, the second effect has ID 2, and so on.
 
 If you are using custom effect scripts, note the order that they are added to
 the list. This should be explained in the documentation for those script.
--------------------------------------------------------------------------------
 ** Example
 
 Suppose you have a skill with two effects: add state poison, recover HP.
 To convert the second effect into a post use effect, note-tag your skill with
 
   <post user effect: 2>
   
 Now your skill will always recover HP even if it misses.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_UserEffects] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module User_Effects
    Pre_Regex = /<pre[-_ ]user[-_ ]effect:\s*(\d+)\s*>/i
    Post_Regex = /<post[-_ ]user[-_ ]effect:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class UsableItem
    def pre_user_effects
      load_notetag_user_effects unless @pre_user_effects
      return @pre_user_effects
    end
    
    def post_user_effects
      load_notetag_user_effects unless @post_user_effects
      return @post_user_effects
    end
    
    def load_notetag_user_effects
      @pre_user_effects = []
      @post_user_effects = []
      res = self.note.scan(TH::User_Effects::Pre_Regex)
      convert_user_effects(res, @pre_user_effects)
      
      res = self.note.scan(TH::User_Effects::Post_Regex)
      convert_user_effects(res, @post_user_effects)
      
      # Delete flagged effects
      self.effects.compact!
    end
    
    def convert_user_effects(results, arr)
      results.each do |res|
        id = res[0].to_i - 1
        effect = self.effects[id]
        arr << effect
        
        # Reserve deletion
        self.effects[id] = nil
      end
    end
    
    alias :th_user_effects_effects :effects
    def effects
      load_notetag_user_effects unless @pre_user_effects
      th_user_effects_effects
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_user_effects_item_apply :item_apply
  def item_apply(user, item)
    item.pre_user_effects.each {|effect| item_effect_apply(user, item, effect) }
    th_user_effects_item_apply(user, item)
    item.post_user_effects.each {|effect| item_effect_apply(user, item, effect) }
  end
end
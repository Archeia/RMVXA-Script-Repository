=begin
#===============================================================================
 Title: Pearl ABS - Enemy Level Patch
 Author: Hime
 Date: Jul 13, 2014
 URL: http://himeworks.com/2013/11/16/enemy-levels/
--------------------------------------------------------------------------------
 ** Change log
 Jul 13, 2014
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
 
 This is a patch for Pearl ABS that allows you to change enemy levels. 

--------------------------------------------------------------------------------
 ** Required
 
 Enemy Levels
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Enemy Levels and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 See Enemy Levels
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PearlABS_EnemyLevels"] = true
#===============================================================================
# ** Configuration
#===============================================================================
class Game_Interpreter
  
  # This is really all we need
  def get_enemy(index)
    $game_map.enemies.find {|enemy| enemy.index == index}
  end
end


class Game_Event < Game_Character
  
  # Need to overwrite. Not sure what the consequences may be.
  # Ideally the original script should just apply this change.
  def register_enemy(event)
    
    if !$game_system.remain_killed[$game_map.map_id].nil? and
      $game_system.remain_killed[$game_map.map_id].include?(self.id)
      return
    end
    
    # Change this to pass in the event ID instead of just 0
    @enemy  = Game_Enemy.new(event.id, $1.to_i) if event.name =~ /<enemy: (.*)>/i
    
    if @enemy != nil
      passive = @enemy.enemy.tool_data("Enemy Passive = ", false)
      @epassive = true if passive == "true"
      touch = @enemy.enemy.tool_data("Enemy Touch Damage Range = ")
      @sensor = @enemy.esensor
      @touch_damage = touch if touch != nil
      $game_map.event_enemies.push(self) # new separate enemy list
      $game_map.enemies.push(@enemy)     # just enemies used in the cooldown
      @event.pages.each do |page|
        if page.condition.self_switch_valid and
          page.condition.self_switch_ch == PearlKernel::KnockdownSelfW
          @knockdown_enable = true
          break
        end
      end
      pose = @enemy.enemy.tool_data("Enemy Dead Pose = ", false) == "true"
      @deadposee = true if pose and @knockdown_enable
    end
  end
end


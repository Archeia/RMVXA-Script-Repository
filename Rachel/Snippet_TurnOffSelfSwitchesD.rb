#--------------------------------------------------------------------------
# Turn off Self Switches Snippet by Racheal
# This is the little scriptlet I use to reset all 'D' self switches on a particular map.
# You call it with a script call of reset_gather_points(id of map).
#--------------------------------------------------------------------------
# Original Topic: https://forums.rpgmakerweb.com/index.php?threads/turn-all-self-switches-off-on-a-map.43314/
#--------------------------------------------------------------------------
class Game_Interpreter  
	def reset_gather_points(map_id)    
		map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))    
		map.events.each do |i, event|      
			key = [map_id, i, 'D']      
			$game_self_switches[key] = false    
		end  
	end
end
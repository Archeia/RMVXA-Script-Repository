=begin
EST - VE BATTLE PATCH v1.1

content of this patch
 - use charset mode easily.
 just tag your ALL actor with: <battler name: default_actor>
 and it will automatically use charset as battler
 - synchro formation changer with battler position
 
=end


module Victor_Engine  
  VE_SPRITE_SETTINGS_ADD = {
    'default_actor'    => {frames: 3, rows: 4, mirror: false, invert: false,
                    mode: :charset, action: :charset},    
    'default_enemy'    => {frames: 3, rows: 4, mirror: false, invert: false,
                    mode: :charset, action: :charset},
  } # Don't remove  
  VE_SPRITE_SETTINGS.merge!(VE_SPRITE_SETTINGS_ADD)
  
  VE_CUSTOM_POSITION6 = {
  # Position
    1 => {x: 430, y: 270}, # Position for the first actor.
    2 => {x: 430, y: 235}, # Position for the second actor.
    3 => {x: 430, y: 200}, # Position for the thrid actor.
    4 => {x: 490, y: 270}, # Position for the fourth actor.
    5 => {x: 490, y: 235}, # Position for the fifth actor.
    6 => {x: 490, y: 200}, # Position for the sixth actor.
  } # Don't remove   
  VE_CUSTOM_POSITION = VE_CUSTOM_POSITION6.dup   
end
  
#PATCH to rearrange the position based on battle_member_array
module ESTRIOLE
def self.getpos(memberid)
 for i in 0..$game_party.battle_members_array.size-1
   if $game_party.battle_members_array[i] == memberid
    j = i+1
    return j
   end
 end
end

def self.update_ve_pos(look)
  case look    
  when 7;
    for i in 1..look
       id = $game_party.battle_members[i-1].id
       j = getpos(id)
      $game_custom_positions[i][:x] = Victor_Engine::VE_CUSTOM_POSITION8[j][:x]
      $game_custom_positions[i][:y] = Victor_Engine::VE_CUSTOM_POSITION8[j][:y]
    end         
  when 8;
    for i in 1..look
       id = $game_party.battle_members[i-1].id
       j = getpos(id)
      $game_custom_positions[i][:x] = Victor_Engine::VE_CUSTOM_POSITION8[j][:x]
      $game_custom_positions[i][:y] = Victor_Engine::VE_CUSTOM_POSITION8[j][:y]
    end     
  else
    for i in 1..look
       id = $game_party.battle_members[i-1].id
       j = getpos(id)
      $game_custom_positions[i][:x] = Victor_Engine::VE_CUSTOM_POSITION6[j][:x]      
      $game_custom_positions[i][:y] = Victor_Engine::VE_CUSTOM_POSITION6[j][:y]
    end              
  end
end #end self.update_ve_pos
end #end module estriole

#patch to use the estriole position updater
class Scene_Battle < Scene_Base
  alias est_victor_update_form_start start
  def start
    ESTRIOLE.update_ve_pos($game_party.battle_members.size) if $imported["YEA-PartySystem"] == true
    est_victor_update_form_start
  end    
end


# patch for basic module to make anim battle 1.09 can used with older basic module
class Object
  def get_all_values(value1, value2 = nil)
    value2 = value1 unless value2
    /<#{value1}>((?:[^<]|<[^\/])*)<\/#{value2}>/im
  end
end
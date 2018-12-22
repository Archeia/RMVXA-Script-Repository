#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Self-Switch Reset
#  Author: Kread-EX
#  Version 1.0
#  Release date: 03/02/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # OR
# # rpgmakervxace.net
# # OR
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Automatically reset self-switches upon transferring to another map.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # You'll have to put a flag in the event's name:
# # /SSR[letter]
# # The letter can be A, B, C or D. It will reset the self-switch from D to that
# # letter. Basically, if you put C, D and C will be reset. If you put D, only D.
# # If you put A, then all letters will be.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # List of aliases and overwrites:
# # Game_Event
# # ssr (new method)
# # name (new method)
# #
# # Scene_Map
# # perform_transfer (alias)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-SelfSwitchReset'] = true

puts 'Load: Self-Switch Reset v1.0 by Kread-EX'

module KRX
  
  module REGEXP
    SSR = /\/SSR\[(\w+)\]/i
  end
  
end

#===========================================================================
# ■ Game_Event
#===========================================================================

class Game_Event < Game_Character
	#--------------------------------------------------------------------------
	# ● Determine if the event's self-switches will be resetted
	#--------------------------------------------------------------------------
	def ssr
    result = KRX::REGEXP::SSR.match(name)
    result.nil? ? nil : $1
  end
  #--------------------------------------------------------------------------
  # ● Returns the event's name
  #--------------------------------------------------------------------------
  def name
    @event.name
  end
end

#===========================================================================
# ■ Scene_Map
#===========================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● Map transfer
  #--------------------------------------------------------------------------
  alias_method(:krx_ssr_sm_pt, :perform_transfer)
  def perform_transfer
    values = ['D', 'C', 'B', 'A']
    $game_map.events.values.each do |event|
      letter = event.ssr
      next if letter.nil?
      index = values.index(letter)
      (0..index).each do |i|
        $game_self_switches[[$game_map.map_id, event.id, values[i]]] = false
      end
    end
    krx_ssr_sm_pt
  end
end
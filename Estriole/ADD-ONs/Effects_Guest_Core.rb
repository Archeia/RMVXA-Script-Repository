
=begin
** Effect: Guest Core
Version: 1.1
Author: Estriole
Date: 26 Nov 2012

This is add on for
Tsukihime Effect Manager
and
Mr Bubble Guest Script

now we can tag effect to the guest. for those suikoden IV guest system.
just tag the guest actor notetags

[new in v 1.1]
now we can tag guest class notetags too.
now we can give skills/auto_skill to the guest and have the effect occur

guest effect will inherited by EVERY battle members
so if you tag the guest to have effect heal self 100 hp everytime attack.
then when battle member A attack it will gain 100 hp.
when battle member B attack it will gain 100 hp.

special note: (READ THIS CAREFULLY BEFORE COMPLAINING)
if you want effect that damage 100 hp for enemies at battle start.
remember guest effect will inherited by ALL battle member.
so if you have 5 battle members. it will executed 5 times. means 500 damage...

how to prevent this?
simple... just add at start of your effect method:

return if self != $game_party.battle_members[0]

this way the effect only will executed once. and the enemies will only get
damaged by 100 hp damage at battle start.

=end

$imported = {} if $imported.nil?
if $imported["BubsPartyGuests"] == true

class Game_Actor < Game_Battler
	alias est_effect_guest_effect_objects effect_objects
	def effect_objects
		est_effect_guest_effect_objects + $game_party.guests_effect_object
	end
end #end class game_actor

class Game_Party < Game_Unit
	def guests_actor
		@guest_ids.collect {|id| $data_actors[id] }
	end #i use guests_actor since mr bubble already use guests method

	def guests_class
		class_list = []
		for member in guests
		class_list.push(member.class)
		end
		class_list.compact!
		return class_list
	end

	def guests_skills
		skill_list = []
		for member in guests
		for skill in member.skills
		skill_list.push(skill)
		end
		end
		skill_list.compact!
		return skill_list
	end


	def guests_effect_object
		guests_actor + guests_class + guests_skills
	end

end #end game_party


end #end if imported

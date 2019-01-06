#Enhanced Encounter Conditions
#----------#
#Features: Grant's you complete control over how your encounters get encountered!
#
#Usage:  Set up your conditions below, then use the note tags in map properties
#
#        Several examples are below, the format runs like...
#           id => "script",
#          can use variable(id) for variables and switch(id) for switches
#           and if the script call returns true, then that encounter can be
#           encountered!
#
#        Example:
#          1 => "variable(1) > 50",
#         And any encounter with that condition will only occur if variable 1
#          is greater than 50! Oooh, ahhh.
#
#        Note tags: 
#         This is how you define which encounters get which condition
#         (Only one condition per encounter, the first will be used)
#         <TROOP id# condition#>
#          Where id is the number it is on the encounter list and condition
#           is the number of the condition to use
#
#        Example:
#         <TROOP 1 1>
#         Which would give the first encounter in the list condition 1.
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)


class Troop_Encounters
  
  #########
  #Set up you Conditions here! Here! Here!!
  #########
  
  CONDITIONS = { 1 => "variable(1) > 50", 
                 2 => "switch(5)",
                 3 => "$game_party.highest_level > 25",}
  
  ##### Not here
  def self.condition(id)
    return "false" if CONDITIONS[id].nil?
    return CONDITIONS[id]
  end
end

class Game_Player
  alias enc_cond_mati make_encounter_troop_id
  def make_encounter_troop_id
    @id = 0
    enc_cond_mati
  end
  def encounter_ok?(encounter)
    @id += 1
    return false unless encounter.region_set.include?(region_id) || encounter.region_set.empty?
    return false unless special_encounter_condition(encounter,id)
    return true
  end
  def special_encounter_condition(encounter,id)
    return true if $game_map.map_note.empty?
    return true unless /<TROOP #{id} (?<cond>\d{1,3})>/ =~ $game_map.map_note
    return eval(Troop_Encounters.condition($1.to_i))
  end
  def switch(id)
    $game_switches[id]
  end
  def variable(id)
    $game_variables[id]
  end
end

class Game_Map
  def map_note
    return @map.note unless @map.nil?
  end
end
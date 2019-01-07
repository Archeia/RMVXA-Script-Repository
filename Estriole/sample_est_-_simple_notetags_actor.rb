if $imported["EST - SIMPLE NOTETAGS"] == true
############################# EXAMPLE USAGE ####################################
=begin
example usage. i have notetags in ACTOR
<testnote: 100 200 300>

and i want to have SEPARATE method to call each 100 200 and 300.
lets set the method 
testnote1 return 100, testnote2 return 200, testnote3 return 300
and i want it to return as integer because i want to use it in calculation
i also want it to able to change in game and saved. so loading the file will not
revert it back to database value...
so i give you the example usage

to access testnote1

$game_actors[id].testnote1

for testnote2, etc just change to corresponding method
to change the value of testnote1 ingame

$game_actors[id].testnote1 = x
  
=end

class Game_Actor < Game_Battler
    attr_accessor :testnote1
    attr_accessor :testnote2
    attr_accessor :testnote3
    
    def testnote1
      if !@testnote1                                   
      a = actor.note_args("testnote")
      @testnote1 = a[0].to_i if a[0]
      end
      return @testnote1
    end

    def testnote2
      if !@testnote2                                   
      a = actor.note_args("testnote")
      @testnote2 = a[1].to_i if a[0]
      end
      return @testnote2
    end

    def testnote3
      if !@testnote3                                   
      a = actor.note_args("testnote")
      @testnote3 = a[2].to_i if a[0]
      end
      return @testnote3
    end
    
end
  
  
end #end if imported simple notetags script
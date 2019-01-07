=begin
Infinite Levels
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Default is 200
----------------------
Instructions
----------------------
In the class tab of the database you will need to set the stats up
differantly to what you're used to, the stat at level one is the base
stat for a level one character as you would expect.
But the stat for level two is now how much you would like the stat to 
go up by each level.

Also edit max level below to your liking.
----------------------
Known bugs
----------------------
None
=end
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Feel free to edit
  #--------------------------------------------------------------------------
  def max_level
    return 200
  end
  #--------------------------------------------------------------------------
  # ● Formula for stats
  #--------------------------------------------------------------------------
  def param_base(param_id)
    b = self.class.params[param_id, 1]
    i = self.class.params[param_id, 2]
    return b + i * (@level - 1)
  end
end
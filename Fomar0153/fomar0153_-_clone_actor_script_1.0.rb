=begin
Clone Actor Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Allows you to "clone" an actor. The clones will be an exact copy
of the chosen actor in the database.
----------------------
Instructions
----------------------
You create a clone by calling:
$game_actors[id,true]
and it will return the physical id of the clone.
I reccomend doing something like:
$game_variables[1]=$game_actors[1,true]
$game_party.add_actor($game_variables[1])

You will also need to set:
CLONE_ID_START
you'll find it at the top of the script.
Anyone whose id is less than this number will work like normal.
Anyone whose id is larger than or equal to this number can only exist
as clones. So I reccomend using them as templates for the clones.
----------------------
Known bugs
----------------------
None
=end
class Game_Actors
  #--------------------------------------------------------------------------
  # ● Basically this protects the first 8 party members and lets them 
  #   function as normal. All clones will start from this id.
  #--------------------------------------------------------------------------
  CLONE_ID_START = 9
  #--------------------------------------------------------------------------
  # ● Aliases initialize
  #--------------------------------------------------------------------------
  alias clone_initialize initialize
  def initialize
    clone_initialize
    @clone_index = CLONE_ID_START
  end
  #--------------------------------------------------------------------------
  # ● Rewrites []
  #--------------------------------------------------------------------------
  def [](actor_id, clone = false)
    if clone
      @data[@clone_index] = Game_Actor.new(actor_id)
      @data[@clone_index].clone_id = @clone_index
      @clone_index += 1
      return @clone_index - 1
    else
      if actor_id < CLONE_ID_START
        return nil unless $data_actors[actor_id]
        @data[actor_id] ||= Game_Actor.new(actor_id)
      else
        return @data[actor_id]
      end
    end
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● New accessor
  #--------------------------------------------------------------------------
  attr_accessor :clone_id
  #--------------------------------------------------------------------------
  # ● Aliases id
  #--------------------------------------------------------------------------
  alias clone_id id
  def id
    return @clone_id unless @clone_id.nil?
    return clone_id
  end
end
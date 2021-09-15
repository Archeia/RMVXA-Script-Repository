#encoding:UTF-8
# Window_ActorCommand
#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is used to select actor commands, such as "Attack" or "Skill".
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(128, [], 1, 4)
    self.active = false
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     actor : actor
  #--------------------------------------------------------------------------
  def setup(actor)
    s1 = Vocab::attack
    s2 = Vocab::skill
    s3 = Vocab::guard
    s4 = Vocab::item
    if actor.class.skill_name_valid     # Skill command name is valid?
      s2 = actor.class.skill_name       # Replace command name
    end
    @commands = [s1, s2, s3, s4]
    @item_max = 4
    refresh
    self.index = 0
  end
end

#encoding:UTF-8
# ISS005 - SRE 0.8
# // 05/01/2011
# // 05/08/2011
# // Sub-Routine Engine
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
#==============================================================================#
# ** SRE
#==============================================================================#
  module SRE ; end
#==============================================================================#
# ** SRE::Script # A dumpable proc like class XD
#==============================================================================#
  class SRE::Script
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :code

  #--------------------------------------------------------------------------#
  # * new-method :_load
  #--------------------------------------------------------------------------#
    def self._load(con_string ) ; new( con_string) ; end

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(parameters, con_string)

      @code = con_string ; create_block()
    end

  #--------------------------------------------------------------------------#
  # * new-method :create_block
  #--------------------------------------------------------------------------#
    def create_block
      if @parameters.empty?
        @__block = eval("::Proc.new { #{@code} }")
      else
        prm = @parameters.clone ; last = prm.pop
        @__block = eval("::Proc.new { |#{(prm.inject("") { |r, s| r + s + "," })+last}| #{@code} }")
      end
    end

  #--------------------------------------------------------------------------#
  # * new-method :call
  #--------------------------------------------------------------------------#
    def call(*args ) ; @__block.call( *args) ; end
  #--------------------------------------------------------------------------#
  # * new-method :_dump
  #--------------------------------------------------------------------------#
    def _dump(n) ; @code ; end

  #--------------------------------------------------------------------------#
  # * new-method :get_script
  #--------------------------------------------------------------------------#
    def get_script() ; return @code end

  end
#==============================================================================#
# ** SRE::ObjectHandler
#==============================================================================#
  class SRE::ObjectHandler

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :character
    attr_accessor :resource

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(character)
      @character    = character
      @resource     = ::ISS::SRE::ResourceHandler.new()
      @resource.max = 10
    end

  #--------------------------------------------------------------------------#
  # * new-method :gather
  #--------------------------------------------------------------------------#
    def gather(n)
      @resource.increase_value(n)
    end

  #--------------------------------------------------------------------------#
  # * new-method :ungather
  #--------------------------------------------------------------------------#
    def ungather(n)
      @resource.decrease_value(n)
    end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update()
    end

  end
#==============================================================================#
# ** SRE::ResourceHandler
#==============================================================================#
  class SRE::ResourceHandler

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :value
    attr_accessor :max
    attr_accessor :type

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( )
      @type  = :nil
      @minimum = 0
      @value = 0
      @max   = 0
    end
  #--------------------------------------------------------------------------#
  # * new-method :cap_value/!
  #--------------------------------------------------------------------------#
    def cap_value()  ; return [[@value, @max].min, @minimum].max end
    def cap_value!() ; @value = cap_value end

  #--------------------------------------------------------------------------#
  # * new-method :increase/decrease_value
  #--------------------------------------------------------------------------#
    def increase_value(n) ; @value += n ; cap_value!() end
    def decrease_value(n ) ; increase_value( -n) end

    def maxed?() ; return @value >= @max end
    def max?()   ; return maxed?() end
    def min?()   ; return @value <= @minimum end

  end
#==============================================================================#
# ** SRE::ActionCommand
#==============================================================================#
  class SRE::ActionCommand

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :parameters
    attr_accessor :type

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(type = "", paramters = [])
      @type       = type
      @parameters = paramters
    end

  end

#==============================================================================#
# ** SRE::ActionCommandSet
#==============================================================================#
  class SRE::ActionCommandSet

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :type
    attr_accessor :skip_procs  # // Used for loop sets
    attr_accessor :break_procs # // Used for loop sets
    attr_accessor :end_procs   # //
    attr_accessor :proc_order
    attr_accessor :list
    attr_accessor :name

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( )
      @name        = ""
      @type        = :one_shot
      @skip_procs  = []
      @break_procs = []
      @end_procs   = []
      @list        = []
      @proc_order  = [:break, :skip]
    end

  #--------------------------------------------------------------------------#
  # * new-method :break?
  #--------------------------------------------------------------------------#
    def break?(character)
      return @break_procs.any? { |p| p.call(character) }
    end

  #--------------------------------------------------------------------------#
  # * new-method :skip?
  #--------------------------------------------------------------------------#
    def skip?(character)
      return @skip_procs.any? { |p| p.call(character) }
    end

  end

#==============================================================================#
# ** SRE::ActionCommandRef
#==============================================================================#
  class SRE::ActionCommandRef

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :phase_actions
    attr_accessor :phase_size
    attr_accessor :type

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( )
      @type           = :one_shot
      @phase_actions  = []
      @phase_size     = 0
    end

  #--------------------------------------------------------------------------#
  # * new-method :get_actionlist
  #--------------------------------------------------------------------------#
    def get_actionlist(n) ;
      return nil if @phase_actions[n].nil?()
      return @phase_actions[n].clone()
    end

  end

#==============================================================================#
# ** SRE::ActionCommandEngine
#==============================================================================#
  class SRE::ActionCommandEngine

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :action_ref
    attr_accessor :action_list
    attr_accessor :action_phase
    attr_accessor :action_set
    attr_accessor :character

  #--------------------------------------------------------------------------#
  # * new-method :sre_debug?
  #--------------------------------------------------------------------------#
    def sre_debug? ; return false end

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(character = nil)
      @character      = character
      @action_ref     = ::ISS::SRE::ActionCommandRef.new()
      @action_list    = []  # Full action list, each set, is shifted off until its empty
      @action_set     = nil # Current action set
      @action_loop    = false
      @action_phase   = 0   # // 0 - Start, 1 - Loop, 2 - End
      @wait_count     = 0
    end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update()
      @wait_count -= 1 unless @wait_count == 0
      return unless @wait_count == 0
      update_actions()
    end

  #--------------------------------------------------------------------------#
  # * new-method :update_actions
  #--------------------------------------------------------------------------#
    def update_actions()
      unless @action_loop
        if @action_list.empty?()
          s = @action_ref.get_actionlist(@action_phase)
          @action_list << s unless s.nil?
        end
        return if @action_list.empty?()
        a = @action_list.shift()
        @action_set     = a
        @action_loop    = a.nil?() ? false : a.type == :loop
        p a.name if sre_debug?
      end
      return if @action_set.nil?()
      @action_set.proc_order.each { |t|
        case t
        when :break
          if @action_set.break?(@character)
            @action_phase += 1
            @action_phase %= @action_ref.phase_size
            return @action_loop = false
          else ; @action_loop = true ; end
        when :skip ; return if @action_set.skip?(@character)
        end
      }
      @action_set.list.each { |c|
        break if perform_command(c.type, c.parameters) == 2}
    end

  #--------------------------------------------------------------------------#
  # * new-method :perform_command
  #--------------------------------------------------------------------------#
    def perform_command(command, parameters)
      case command.upcase
      when "ANIMATION"
        action_animation(command, parameters)
      when "MOVE"
        action_move(command, parameters)
      when "GATHER"
        action_gather(command, parameters)
      when "DROPOFF", "UNGATHER"
        action_ungather(command, parameters)
      when "CHANGEPHASE"
        action_phase(command, parameters)
      when "SCRIPT"
        action_script(command, parameters)
      when "WAIT"
        action_wait(command, parameters)
        return 2
      end
      return 0
    end

  #--------------------------------------------------------------------------#
  # * new-method :action_animation
  #--------------------------------------------------------------------------#
    def action_animation(action, parameters)
      @character.animation_id = parameters[0].to_i
    end

  #--------------------------------------------------------------------------#
  # * new-method :action_move
  #--------------------------------------------------------------------------#
    def action_move(action, parameters)
      case parameters[0].upcase()
      when "TO"
        target_x, target_y =*parameters[1] # // [x, y] integer array
        diagonal           = parameters[2] # // boolean
        max_iterations     = parameters[3] # // integer
        #@character.move_toward_xy(target_x, target_y)
        @character.force_path (target_x, target_y, diagonal, max_iterations)
      when "SCRIPT_TO"
        data = []
        5.times { |i| data[i] = eval(parameters[1]) }
        data[1][1] += 1 # // y+
        data[2][1] -= 1 # // y-
        data[3][0] -= 1 # // x-
        data[4][0] += 1 # // x+
        #@character.find_path(*data)
        5.times { |i| return if @character.force_path (*data[i]) }
      end
    end

  #--------------------------------------------------------------------------#
  # * new-method :action_gather
  #--------------------------------------------------------------------------#
    def action_gather(action, parameters)
      @character.rts_object.gather(1)
    end

  #--------------------------------------------------------------------------#
  # * new-method :action_ungather
  #--------------------------------------------------------------------------#
    def action_ungather(action, parameters)
      @character.rts_object.ungather(1)
    end

  #--------------------------------------------------------------------------#
  # * new-method :action_phase
  #--------------------------------------------------------------------------#
    def action_phase(action, parameters)
      case parameters[0].to_s().upcase()
      when "FORWARD"  ; @action_phase += 1
      when "BACKWARD" ; @action_phase -= 1
      else            ; @action_phase  = parameters[0].to_i
      end
    end

  #--------------------------------------------------------------------------#
  # * new-method :action_script
  #--------------------------------------------------------------------------#
    def action_script(action, parameters)
      character = @character
      eval(parameters[0])
    end

  #--------------------------------------------------------------------------#
  # * new-method :action_wait
  #--------------------------------------------------------------------------#
    def action_wait(action, parameters)
      @wait_count = parameters[0]
    end

  end

#==============================================================================#
# ** SRE
#==============================================================================#
  module SRE

    # // Shortcut for ::ISS::SRE::Script
    SCR = ::ISS::SRE::Script
    # // Shortcut for ::ISS::SRE::ActionCommand
    SAC = ::ISS::SRE::ActionCommand
    # // Shortcut for ::ISS::SRE::ActionCommandSet
    SACS= ::ISS::SRE::ActionCommandSet
    # // Shortcut for ::ISS::SRE::ActionCommandRef
    SACR= ::ISS::SRE::ActionCommandRef

    # // Default SCR scrips
    DEFSCRIPTS = {
      "TRUE"    => SCR.new([], "true"),
      "FALSE"   => SCR.new([], "false"),
      "MOVING"  => SCR.new(["character"], "character.moving?()"),
      "NMOVING" => SCR.new(["character"], "!character.moving?()"),
    }

    module_function()

  #--------------------------------------------------------------------------#
  # * new-method :get_defScript
  #--------------------------------------------------------------------------#
    def get_defScript(name) return DEFSCRIPTS[name].clone end

  #--------------------------------------------------------------------------#
  # * new-method :create_Moveto_set
  # // ------------------------------------------------------------------ // #
  # Used to create static move points.
  # Uses Modern Algebra's path finding.
  # tx, ty   : Target X, Target Y
  # diagonol : allow diagnol movement?
  # mi       : Move Iterations, 0 use as many as needed
  #--------------------------------------------------------------------------#
    def create_Moveto_set(tx, ty, diagonol = true, mi = 0)
      comm = SAC.new("MOVE", ["TO", [tx, ty], diagonol, mi])
      set  = SACS.new()
      set.list        << comm
      set.skip_procs  << get_defScript("MOVING")
      set.break_procs << SCR.new(["character"], "character.pos?(#{tx}, #{ty})")
      set.type = :loop
      return set
    end

  #--------------------------------------------------------------------------#
  # * new-method :create_ScriptMoveto_set
  # // ------------------------------------------------------------------ // #
  # script is called every time the character wants to move via the command
  # This means it is also recalculated each time, say away from heavy methods.
  # the script must return an array [x, y]
  #--------------------------------------------------------------------------#
    def create_ScriptMoveto_set(script)
      comm = SAC.new("MOVE", ["SCRIPT_TO", script])
      set  = SACS.new()
      set.list        << comm
      set.skip_procs  << get_defScript("MOVING")
      str = %Q(
        data = character.dungeon_obj.get_next_tile()
        data = [-1, -1] if data.nil?
        character.pos?(data[0], data[1])
      )
      set.break_procs << SCR.new(["character"], str)
      set.type = :loop
      return set
    end

  end

end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :sre_object # // Used for variable storage and such
  attr_accessor :sre_engine # // Used for AC processing

  #--------------------------------------------------------------------------#
  # * Public Reference Methods
  #--------------------------------------------------------------------------#
  # // For compat
  ref_accessor :rts_object, :sre_object # // Refer to the sre_object
  ref_accessor :rts_engine, :sre_engine # // Refer to the sre_engine
  ref_reader   :setup_rts , :setup_sre  # // Refer to the setup_sre
  ref_reader   :erase_rts , :erase_sre  # // Refer to the erase_sre

  #--------------------------------------------------------------------------#
  # * new-method :setup_sre
  #--------------------------------------------------------------------------#
  def setup_sre(gather=true)
    @sre_object = ::ISS::SRE::ObjectHandler.new(self) if gather
    @sre_engine = ::ISS::SRE::ActionCommandEngine.new(self)
  end

  #--------------------------------------------------------------------------#
  # * new-method :erase_sre
  #--------------------------------------------------------------------------#
  def erase_sre(gather=true)
    @sre_object.erase() if gather
    @sre_engine.erase()
    @sre_object = nil if gather
    @sre_engine = nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss_posarray
  #--------------------------------------------------------------------------#
  def iss_posarray() ; return [self.x, self.y] end

  #--------------------------------------------------------------------------#
  # * new-method :pos_array
  #--------------------------------------------------------------------------#
  def pos_array()    ; return iss_posarray() end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias iss005_gc_update update unless $@
  def update()
    iss005_gc_update()
    @rts_object.update() unless @sre_object.nil?()
    @rts_engine.update() unless @sre_engine.nil?()
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

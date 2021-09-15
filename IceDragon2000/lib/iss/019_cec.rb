#encoding:UTF-8
# ISS019 - CEC 1.0
#==============================================================================#
# ** ISS - CEC (Custom Event Commands)
#==============================================================================#
# ** Date Created  : 08/10/2011
# ** Date Modified : 08/10/2011
# ** Created By    : IceDragon
# ** For Game      : Kye-VX
# ** ID            : 019
# ** Version       : 1.0
# ** Requires      : ISS000 - Core(1.9 or above)
#==============================================================================#
($imported ||= {})["ISS-CEC"] = true
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
  install_script(19, :map)
end

#==============================================================================#
# ** ISS::CEC
#==============================================================================#
module ISS::CEC

  module_function()

  #--------------------------------------------------------------------------#
  # * new-method :parse_event_list
  #--------------------------------------------------------------------------#
  def parse_event_list(list)
    final_list = []
    list.each { |command|
      new_command = command.clone
      if [108, 408].include?(command.code)
        case command.parameters.to_s.upcase
        when /\/\/EVCOM:[ ](.*)/i
          new_command = RPG::EventCommand.new
          new_command.indent = command.indent
          case $1.to_s.upcase
          #when "CHECKDEFLECT"
          #  new_command.code = 1000
          when "DELETEEVENT"
            new_command.code = 1001
          when /RANDWAIT[ ](\d+),[ ](\d+)/i
            new_command.code = 1002
            new_command.parameters = [$1.to_i, $2.to_i]
          end
        end
      end
      final_list << new_command
    }
    return final_list
  end

end

#==============================================================================#
# ** RPG::Event
#==============================================================================#
class RPG::Event

  attr_accessor :lists_parsed

  #--------------------------------------------------------------------------#
  # * new-method :parse_lists
  #--------------------------------------------------------------------------#
  def parse_lists()
    self.pages.each { |pg| pg.list = ISS::CEC.parse_event_list(pg.list) }
    @lists_parsed = true
  end

end

#==============================================================================#
# ** RPG::Map
#==============================================================================#
class RPG::Map

  #--------------------------------------------------------------------------#
  # * new-method :do_on_load
  #--------------------------------------------------------------------------#
  def do_on_load ; end unless method_defined? :do_on_load

  #--------------------------------------------------------------------------#
  # * alias-method :do_on_load
  #--------------------------------------------------------------------------#
  alias :iss019_rpgmap_do_on_load :do_on_load unless $@
  def do_on_load()
    iss019_rpgmap_do_on_load()
    @events.values.each { |ev| ev.parse_lists() }
  end

end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  attr_accessor :direction

  #--------------------------------------------------------------------------#
  # * new-method :inverse_direction
  #--------------------------------------------------------------------------#
  def self.inverse_direction(indirection)
    case indirection
    when 2 ; return 8
    when 4 ; return 6
    when 6 ; return 4
    when 8 ; return 2
    end
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss019_gme_initialize :initialize unless $@
  def initialize(*args, &block)
    args[1].parse_lists(args[0]) unless args[1].lists_parsed
    iss019_gme_initialize(*args, &block)
  end

end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * alias-method :execute_command
  #--------------------------------------------------------------------------#
  alias :iss019_gmi_execute_command :execute_command unless $@
  def execute_command(*args, &block)
    unless @index >= @list.size-1
      @params = @list[@index].parameters
      @indent = @list[@index].indent
      ans = custom_commands(@list[@index].code)
      return ans unless ans.nil?()
    end
    iss019_gmi_execute_command(*args, &block)
  end

  #--------------------------------------------------------------------------#
  # * new-method :custom_commands
  #--------------------------------------------------------------------------#
  def custom_commands(code)
    case code
    when 1000 # // Deflect Event
      return command_1000
    when 1001 # // Delete Event
      return command_1001
    when 1002 # // Rand Wait
      return command_1002
    end
    return nil
  end

  def command_1000
    thisev = get_character(@event_id)
    return true if thisev.nil?()
    evs = $game_map.events_xy(*thisev.get_xy_infront( 1, 0 ))
    evs.each { |ev|
      thisev.direction = ev.invert_deflect ? ev.class.inverse_direction(ev.direction) : ev.direction if ev.deflector
      if ev.roundobject && thisev.roundobject
        case thisev.direction
        when 2
          rand(2) == 0 ? thisev.move_lower_left : thisev.move_lower_right
        when 4
          rand(2) == 0 ? thisev.move_upper_left : thisev.move_lower_left
        when 6
          rand(2) == 0 ? thisev.move_upper_right : thisev.move_lower_right
        when 8
          rand(2) == 0 ? thisev.move_upper_left : thisev.move_upper_right
        end
      end
    }
    return true
  end

  def command_1001
    thisev = get_character(@event_id)
    evs = $game_map.events_xy(thisev.x, thisev.y) - [thisev]
    evs.each { |ev| Spawner.remove_event(ev.id) }
    return true
  end

  def command_1002
    @wait_count = @params[0] + rand(@params[1]) ; return true
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

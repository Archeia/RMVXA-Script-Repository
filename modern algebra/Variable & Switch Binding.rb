#==============================================================================
#    Variable & Switch Binding
#    Version: 1.0a
#    Author: modern algebra (rmrk.net)
#    Date: June 8, 2012
#    Support: http://rmrk.net/index.php/topic,45809.0.html
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to bind in-game switches and variables to specified 
#   expressions such that they will always correspond. As an example, if you 
#   want a particular variable to always track the MP of a specified actor, you 
#   can use this script to bind it to that value, and whenever the MP of the 
#   actor increases or decreases, so will the value of the variable without any
#   further interference by you.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    This script may require some scripting knowledge in that you may need to 
#   know the code for desired expressions.
#
#    Please keep in mind that while a switch or variable is bound, it cannot be
#   operated on; you need to unbind the variable before you can operate on it.
#``````````````````````````````````````````````````````````````````````````````
#  Binding Switches:
#
#    At its most basic level, the following codes, placed in a script call, are
#   all that you need to know in order to bind or unbind switches:
#
#        bind_switch(switch_id, "expression", monitor?)
#        unbind_switch(switch_id)
#
#   switch_id  : replace this with the integer ID of the switch you are binding
#     (or unbinding).
#   expression : replace this with the particular scripting expression that you
#     are seeking to track. 
#   monitor?   : replace this with true or false. You should set this to true 
#     if the switch or variable you are binding are conditions on an event page
#     or common event and you expect the value to change in the relevant map.
#     This should be set to true only when necessary, as it can cause lag if 
#     you are monitoring hundreds of these values.
#
#  EXAMPLES:
#
#      bind_switch(7, "Input.press?(:CTRL)", true)
#
#        Switch 7 would be true whenever the player is pressing CTRL and false
#       otherwise. Since monitor? is true, event pages and common events will
#       be automatically updated whenever the player is pressing CTRL. If 
#       monitor? had been set to false, that would not happen. 
#
#      unbind_switch(7)
#
#        Switch 7 would no longer be bound to anything - its value will be the
#       current value of the previously bound expression, but it is freed from
#       it and can now be modified again.
#
#    Also, please be aware that if expressions are longer than one line, you
#   will need to split them up. You can do this by setting them to a local 
#   variable, like so:
#
#      a = "(Graphics.frame_count / 60)"
#      a += " % 2 == 0"
#      bind_switch(13, a)
#
#    That would bind the value of switch 13 to being ON when the number of 
#   seconds played is even and OFF when odd.
#``````````````````````````````````````````````````````````````````````````````
#  Binding Variables:
#
#    Variables can be set in a similar way with the codes:
#
#        bind_variable(variable_id, "expression", monitor?)
#        unbind_variable(variable_id)
#
#    However, with variables, you can also bind it to any of the regular Control 
#   Variable options by simply placing one of the following comments above a 
#   regular Control Variable event command:
#
#      Bind Variable
#      Bind and Monitor Variable
#
#   Naturally, the latter will both bind and monitor the next variable, while 
#   the former only binds it. Please note two things however. Firstly, it will 
#   only bind if you are setting it to a variable, to game data, or to a script. 
#   If you are setting it directly to an integer or setting it to a 
#   random number, then it will not bind. Secondly, if you are not directly 
#   setting but are performing some other operation like addition or division, 
#   then the current value of the variable will always be added to the 
#   expression. See the second example.
#
#  EXAMPLES:
#
#    @>Comment: Bind variable
#    @>Control Variable: [0007: Map] = Map ID
#
#      Variable 7 would now be bound to the map ID, so that it will always
#     return the ID of the map the party is currently within.
#
#    @>Control Variable: [0016: Hand Axes] = 3
#    @>Comment: bind and monitor variable
#    @>Control Variable: [0016: Hand Axes] -= [Hand Ax] in Inventory
#
#      Variable 16 would always be equal to 3 minus the current number of hand
#     axes in the inventory. Further, this is monitored so if you have an event
#     page with a condition like Variable 16 is 1 or above, then that event 
#     will update to that page as soon as the party has less than 3 Hand Axes. 
#
#  You can still only unbind variables with the call script noted at line 76.
#==============================================================================

$imported ||= {}
$imported[:MA_VariableSwitchBinding] = true


MAVSB_MONITOR_SCENES = [:Scene_Map, :Scene_Battle]
MAVSB_MONITOR_DEFAULT = false

#==============================================================================
# *** DataManager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - self.create_game_objects; self.extract_save_contents
#    new method - self.init_mavsb_data
#==============================================================================

class << DataManager
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Game Objects
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mavsb_creategmobj_1ji8 create_game_objects
  def create_game_objects(*args, &block)
    mavsb_creategmobj_1ji8(*args, &block)
    init_mavsb_data
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Extract Save Contents
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mavsb_extracsave_4hs6 extract_save_contents
  def extract_save_contents(*args, &block)
    mavsb_extracsave_4hs6(*args, &block) # Call Original Method
    init_mavsb_data if !$game_variables.is_a?(MA_SwitchVariableBinding)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize MAVSB Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def init_mavsb_data
    $game_switches.extend(MA_SwitchVariableBinding)
    $game_switches.initialize_mavsb_data
    $game_variables.extend(MA_SwitchVariableBinding)
    $game_variables.initialize_mavsb_data
  end
end

#==============================================================================
# *** MA Switch & Variable Binding
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module mixes in to Game_Switches and Game_Variables and provides the
# basic mechanism for binding.
#==============================================================================

module MA_SwitchVariableBinding
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize MAVSB Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize_mavsb_data
    @mavsb_bind_hash = {}
    @mavsb_monitor_array = []
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Monitored Values
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mavsb_update_monitered_values
    @mavsb_monitor_array.each {|data_id| self[data_id] }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Value
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def [](data_id, *args, &block)
    if @mavsb_bind_hash[data_id].is_a?(String)
      value = eval(@mavsb_bind_hash[data_id])
      self[data_id] = value if value != @data[data_id]
    end
    super(data_id, *args, &block) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Bind to Value
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mavsb_bind_to_value(data_id, expression = false, monitor = MAVSB_MONITOR_DEFAULT)
    @mavsb_monitor_array.delete(data_id) if @mavsb_monitor_array.include?(data_id)
    if !expression || expression.empty? || !expression.is_a?(String)
      self[data_id] = self[data_id]
      @mavsb_bind_hash.delete(data_id)
    else
      if expression.is_a?(String) 
        @mavsb_bind_hash[data_id] = expression
        @mavsb_monitor_array.push(data_id) if monitor
      else
        p "Expression passed is not a string, so it cannot be bound"
      end
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - command_108; command_122
#    new method - mavsb_interpret_bind_comment; bind_variable; unbind_variable
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Collect Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mavsb_cmnd108comment_2hb7 command_108
  def command_108(*args, &block)
    mavsb_cmnd108comment_2hb7(*args, &block) # Call Original Method
    mavsb_interpret_bind_comment(@comments.join)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Interpret Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mavsb_interpret_bind_comment(comment)
    @mavsb_bind_next_variable = true if comment[/\\?BIND(.*?)VARIABLE/i]
    @masvb_monitor_next_variable = $1 && !$1[/MONITOR/i].nil?
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Control Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mavsb_contrlvars122_3kj1 command_122
  def command_122(*args, &block)
    #  Only works if comment above is set to bind
    if @mavsb_bind_next_variable
      # Set expression to the method and only do the operation if not nil
      oper = ["", " + ", " - ", " * ", " / ", " % "][@params[2]]
      expr = mavsb_get_expression
      for i in @params[0]..@params[1] do
        # If directly setting or the current value is 0, ignore operation
        expr_f = (@params[2] == 0 || $game_variables[i] == 0) ? expr : 
        ($game_variables[i].to_s + oper + expr)
        bind_variable(i, expr_f, @masvb_monitor_next_variable) 
      end if expr # Only do it if the expression is not false
    end
    mavsb_contrlvars122_3kj1(*args, &block)
    # Turn off the binding automatically to prevent nasty bugs.
    @mavsb_bind_next_variable = false
    @masvb_monitor_next_variable = false
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Expression to bind against
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mavsb_get_expression
    return case @params[3]
    when 1 then "$game_variables[#{@params[4]}]"  # Variable
    when 3 then mavsb_game_data_expression(@params[4], @params[5], @params[6]) # Game Data
    when 4 then @params[4]                        # Script
    else false
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Game Data for Variable Operand
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mavsb_game_data_expression(type, param1, param2)
    case type
    when 0 then return "$game_party.item_number(#{$data_items[param1]})" # Items
    when 1 # Weapons
      return "$game_party.item_number(#{$data_weapons[param1]})" 
    when 2 # Armors
      then return "$game_party.item_number(#{$data_armors[param1]})" 
    when 3 # Actors
      if $game_actors[param1]
        case param2
        when 0 then return "$game_actors[#{param1}].level" # Level
        when 1 then return "$game_actors[#{param1}].exp"   # Exp
        when 2 then return "$game_actors[#{param1}].hp"    # HP
        when 3 then return "$game_actors[#{param1}].mp"    # MP
        when 4..11                                         # Parameter
          return "$game_actors[#{param1}].param(#{param2 - 4})"
        end
      end
    when 4  # Enemies
      if $game_troop.members[param1]
        case param2
        when 0 then return "$game_troop.members[#{param1}].hp" # HP
        when 1 then return "$game_troop.members[#{param1}].mp" # MP
        when 2..9                                              # Parameter
          return "$game_troop.members[#{param1}].param(#{param2 - 2})"
        end
      end
    when 5  # Character
      character = get_character(param1)
      if character
        char_e = character.is_a?(Game_Player) ? "$game_player" : 
          "$game_map.map_id == #{$game_map.map_id} ? $game_map.events[#{character.id}] : 0"
        case param2 
        when 0 then return "#{char_e}.x"         # X-coordinate
        when 1 then return "#{char_e}.y"         # Y-coordinate
        when 2 then return "#{char_e}.direction" # Direction
        when 3 then return "#{char_e}.screen_x"  # Screen X-coordinate
        when 4 then return "#{char_e}.screen_y"  # Screen Y-coordinate
        end
      end
    when 6  # Party
      return "$game_party.members[#{param1}] ? $game_party.members[#{param1}].id : 0"
    when 7  # Other
      case param1
      when 0 then return "$game_map.map_id"                           # Map ID
      when 1 then return "$game_party.members.size"                 # Party Size
      when 2 then return "$game_party.gold"                           # Gold
      when 3 then return "$game_party.steps"                          # Steps
      when 4 then return "Graphics.frame_count / Graphics.frame_rate" # Playtime
      when 5 then return "$game_timer.sec"                            # Timer
      when 6 then return "$game_system.save_count"                  # Save Count
      when 7 then return "$game_system.battle_count"              # Battle Count
      end
    end
    return "0"
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Bind/Unbind Variable
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def bind_variable(*args)
    $game_variables.mavsb_bind_to_value(*args)
  end
  def unbind_variable(*var_ids)
    var_ids.each {|i| $game_variables.mavsb_bind_to_value(i, "") }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Bind/Unbind Switch
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def bind_switch(*args)
    $game_switches.mavsb_bind_to_value(*args)
  end
  def unbind_switch(*switch_ids)
    switch_ids.each {|i| $game_switches.mavsb_bind_to_value(i, "") }
  end
end

# Add the Switch and Variable monitoring to the specified scenes
MAVSB_MONITOR_SCENES.each { |scene_name| 
  (Kernel.const_get(scene_name)).class_eval(
    "alias mavsb_#{scene_name.downcase}_update_1gk8 update
    def update(*args, &block)
      mavsb_#{scene_name.downcase}_update_1gk8(*args, &block)
      $game_switches.mavsb_update_monitered_values
      $game_variables.mavsb_update_monitered_values
    end")
}
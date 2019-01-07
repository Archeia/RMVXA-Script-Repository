=begin
#==============================================================================
 Title: Event Wrapper
 Author: Hime
 Date: Feb 14, 2015
------------------------------------------------------------------------------
 ** Change log
 Feb 14, 2015
   - added support for deleting custom events by event designation
 Dec 16, 2014
   - added asynchronous event spawning to address parallel process issues
 Nov 5, 2013
   - added a simple event exporter so you can look at the event in the editor
   - fixed bug where the boolean evaluation was not being done correctly
 Dec 18, 2012
   - removed storing original block. Will be replaced with a string later
     to allow Marshal'ing
 Oct 7, 2012
   - fixed a bug where the event's pattern could not be assigned
 Sep 3, 2012
   - added support for "compass-based" move commands
 Aug 16, 2012
   - added instance methods to the EventBuilder
 Aug 14, 2012
   - added a "delete" command to erase an event. Used for custom events.
 Aug 2, 2012
   - implemented conditional branching. Assumes input is a script call
 Jul 11, 2012
   - implemented move routes
   - normalized all boolean input from 0 and 1 to true/false
   - show_text command now accepts a block for the messages
   - created a standalone EventBuilder class
 Jul 10, 2012
   - implemented an event builder DSL
   - added proper command branching
   - added a bunch of event editor functions
 Jul 9, 2012
   - Initial release
------------------------------------------------------------------------------   
 This script provides a wrapper for the RPG::Event object. It adds
 additional methods to allow you to create event commands directly
 without having to go through the event editor, and provides intuitive
 names that are based on the command names available on the event editor.
 
 Creating an event is simple.
 
 1. Instantiate an Event object, passing in x,y coordinates
 
       event = Event.new(2, 4)
 
 2. Set some page properties. For a list of properties, refer to the help
    manual, or look through the Event class. You can either access the
    properties directly, or use some convenience methods defined 
    in the Event class. So for example, assuming we are on page 0,
    
       event.page[0].character_name = "actor1"
       event.character_name = "actor1"
    
    Both do the same thing. Note that the convenience methods always
    operate on the "current" page. When you first initialize a new event,
    the "current" page is 0. You can change the page by calling
    
       event.set_page(n)
       
    for some integer n

 3. Set some page conditions. Refer to the Event_Condition class for details.
 
       event.condition.switch1_id = 2   # this means switch 2 must be ON
       event.condition.actor_id = 4     # actor 4 must be in party
  
 4. Add the event to the map
 
       $game_map.add_event(event)
       
 For now, all you can really do is write some functions somewhere and then
 invoke them using script calls, so you might write them in Game_Interpreter
 or create your own module/class containing scripted events.
 
 Now, we want to add some event commands. I've provided an "Event Builder"
 that allows you to use a custom syntax to create your events in addition
 to regular ruby syntax.
    
 All of the methods are available in the EventCommands class.
 So for example, let's write an event that will display a simple message
    
   event.build {
      show_text("actor1", 1)
      add_message("Hello World")
   }
   
 If you call the script to create your event, you should be able to talk to
 your event and it will say "Hello World" with the appropriate face picture.
 
 The event builder supports branching, which is used in various commands
 such as showing a list of choices, conditional branching, and other things.
 
    event.build {
       show_text("actor1", 1)
       add_message("What do you like?")
       show_choices(["Health", "Mana"], 0)
       choice_branch(0) {
          show_text("actor1", 1)
          add_message("So you prefer health")
       }
       choice_branch(1) {
          show_text("actor1", 1)
          add_message("Mana is ok too")
       }
    }
    
 This example demonstrates how to using branching to create a list of
 choices that the player can select from, and how to define the commands
 that should be executed depending on the choice.
 
 Working with move routes is very similar to event commands.
 
    event.build {
       route = MoveRoute.new
       route.build {
          move_up
          move_down(2)
          move("2L2R")
       }
       set_move_route(-1, route)
    }
    
 You can build a move route just like you would with the event editor, except
 this script makes it a little more flexible and easier to do.
 
 It is also possible to use typical ruby syntax when building your commands.
    
    event.build {
      show_text("actor2", 5)
      add_message("Which party member do you wish to view?")
      actors = $game_party.members.collect {|actor| actor.name }
      show_choices(actors, 0)
      
      $game_party.members.each_with_index { |actor, i|
        choice_branch(i) {
          show_text(actor.face_name, actor.face_index)
          add_message("%s is a level %d %s" %[actor.name, actor.level, actor.class.name])
        }
      }
    }
    
 This example demonstrates how you would write an event that will go
 through all of the actors in your party, display their names in a choice
 list, and then when you select an actor, it will display information
 about the actor in a text box.
 
 However, note that because this code is run only when the event is created,
 the event commands have already been hardcoded into the event. 
 
 Some notes on boolean values
 -default engine uses 0 for true and 1 for false.
 -I have methods to accept true/false or 0/1 as valid input.
 -They default to false if you don't enter true or 0.
    
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Event_Wrapper"] = true  
#==============================================================================
# ** Rest of the script
#============================================================================== 
module Tsuki
  module Event_Wrapper
    
    # This hash maps "nice" names to internal ID's used by conditional branches
    Cond_Table = {
      "switch"      => 0,
      "variable"    => 1,  # ["variable", ID, value, value, operation]
      "self-switch" => 2,
      "timer"       => 3,
      "actor"       => 4,
      "enemy"       => 5,
      "character"   => 6,
      "gold"        => 7,
      "item"        => 8,
      "weapon"      => 9,
      "armor"       => 10,
      "button"      => 11,
      "script"      => 12,
      "vehicle"     => 13
    }
    
    Move_String_Regex = /(\d*)([UDLRQWAS])/
  end
end

module EventWrapper
  
  def self.export_event(map_id, x, y, event)
    event = Marshal.load(Marshal.dump(event))
    filename = sprintf("Data/Map%03d.rvdata2", map_id)
    map = load_data(filename)
    
    new_id = map.events.keys.max + 1
    rawEvent = to_raw_event(event, x, y)
    rawEvent.id = new_id
    map.events[new_id] = rawEvent
    save_data(map, filename)
  end

  def self.to_raw_event(event, x, y)
        
    event.pages.each do |page|
      
      # change condition
      condition = RPG::Event::Page::Condition.new
      condition.switch1_valid = page.condition.switch1_valid
      condition.switch2_valid  = page.condition.switch2_valid
      condition.variable_valid  = page.condition.variable_valid
      condition.self_switch_valid  = page.condition.self_switch_valid
      condition.item_valid  = page.condition.item_valid
      condition.actor_valid  = page.condition.actor_valid
      condition.switch1_id  = page.condition.switch1_id
      condition.switch2_id  = page.condition.switch2_id
      condition.variable_id  = page.condition.variable_id
      condition.variable_value  = page.condition.variable_value
      condition.self_switch_ch  = page.condition.self_switch_ch
      condition.item_id  = page.condition.item_id
      condition.actor_id  = page.condition.actor_id
      page.condition = condition
      
      # change move route
      page.list.each do |cmd|
        if cmd.code == 205
          rawRoute = RPG::MoveRoute.new
          route = cmd.parameters[1]
          rawRoute.repeat = route.repeat
          rawRoute.skippable = route.skippable
          rawRoute.wait = route.wait
          rawRoute.list = route.list
          cmd.parameters[1] = rawRoute
        end
      end
    end
    
    ev = RPG::Event.new(x, y)
    ev.name = event.name
    ev.pages = event.pages
    return ev
  end
end
  
# This class contains wrappers for all of event commands.
# It is used by the Event to build a list of event commands
class EventCommands
  
  def initialize(list, indent)
    @indent = indent
    @list = list
    @choices = []
  end
  
  # inserts an event command into the list. An empty command must be used to
  # indicate the end of the current branch or page.
  def add_command(code, parameters=[])
    @list.insert(@list.size - 1, RPG::EventCommand.new(code, @indent, parameters))
  end
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def eval_bool(value)
    return 0 if value.is_a?(TrueClass)
    return 1 if value.is_a?(FalseClass)
    return value
  end
  
  def process_block(&block)
    EventCommands.new(@list, @indent + 1).instance_eval(&block)
  end
  
  def process_method(receiver, method_name, *args)
    other_eb = receiver.send(method_name, *args)
    @list.insert(@list.size - 1, *other_eb.list[0...-1])
  end
  
  def method_missing(m, *args, &block)  
    raise "Error in Event Builder: there's no method called `#{m}`"  
  end  
  #=============================================================================
  # Message commands
  #=============================================================================
  
  # sets up the message window 
  def show_text(face_name="", face_index=0, background=0, position=2)
    add_command(101, [face_name, face_index, background, position])
  end
  
  # adds text to the message window. Must be added immediately after the
  # show_text command. Note that control characters need two forward-slashes
  # eg: "The variable value: \\v[2]"
  def add_message(*strings)
    strings.each {|str| add_command(401, [str]) }
  end
  
  # sets up the choice window. 
  #    choices: array of strings (eg: ["yes", "no"])
  #    cancel_option: which choice is selected if you hit cancel
  #        0 = disallow
  #        1 = option 1
  #        2 = option 2, ...
  #        5 = branch 
  def show_choices(choices, cancel_option)
    @choices = choices
    add_command(102, [choices, cancel_option])
  end
  
  # Set up logic to provide a choice branch. You should call this for
  # each choice that you've specified.
  #    index: 0 = first option, 1 = second option, ...
  #    option_name: doesn't seem important at all
  def choice_branch(index, name="", &block)
    name = @choices[index]
    add_command(402, [index, name])
    process_block(&block)
  end
  
  # not sure, maybe a cancel branch?
  def end_choices
    add_command(404)
  end
  
  def input_number(var_id, digit)
    add_command(103, [var_id, digit])
  end
  
  # Stores the ID of the key item in the variable
  def select_key_item(var_id)
    add_command(104, [var_id])
  end
  
  # displays scrolling text
  #    string_list: an array of strings that should be displayed
  #    speed: how fast it scrolls
  #    fast_forward: can speed it up
  def show_scrolling_text(string_list, speed=2, fast_forward=false)
    add_command(105, [speed, fast_forward])
    string_list.each { |str| add_command(405, [str]) }
  end
  
  #=============================================================================
  # Game Progression related commands
  #=============================================================================
  
  # start_var: variable ID
  # end_var: batch process - range end from start_var
  # bool: true = ON or false = OFF
  def control_switches(start_var, end_var, bool)
    value = eval_bool(bool)
    add_command(121, [start_var, end_var, value])
  end
  
  # not very friendly, but it works if you know what to pass in
  def control_variables(*args)
    add_command(122, args)
  end
  
  # sets a self switch
  #    id: self-switch to change. Default "A", "B", "C", "D"
  #    bool: true = ON; false = OFF
  def control_self_switch(id, bool)
    value = eval_bool(bool)
    add_command(123, [id, value])
  end
  
  def start_timer(minutes, seconds)
    add_command(124, [0, minutes * 60 + seconds])
  end
  
  def stop_timer
    add_command(124, [1])
  end
  
  #=============================================================================
  # Flow Control commands
  #=============================================================================
  
  # if conditional branch.
  # not friendly, but works if you know what to pass in
  def cond_if(*args, &block)
    
    # basically assumes a script call
    #add_command(111, args)
    add_command(111, [12, args[0]])
    process_block(&block)
  end
  
  # `else` branch. Requires an if branch.
  def cond_else(&block)
    add_command(411)
    process_block(&block)
  end

  # must close conditional branches with an end
  def cond_end
    add_command(412)
  end
  
  def loop(&block)
    add_command(112)
    process_block(&block)
    add_command(413)
  end
  
  def break_loop
    add_command(113)
  end
  
  def exit_event
    add_command(115)
  end
  
  def call_common_event(common_id)
    add_command(117, [common_id])
  end
  
  def label(str)
    add_command(118, [str])
  end
  
  def goto_label(str)
    add_command(119, [str])
  end
  
  def add_comment(comment)
    add_command(108, [comment])
  end
  
  #=============================================================================
  # Party related commands
  #=============================================================================
  
  #-----------------------------------------------------------------------------
  # Command_125: Changes gold
  #-----------------------------------------------------------------------------
  def add_gold(count=1, value_type=0) 
    add_command(125, [0, value_type, count])
  end
  
  def lose_gold(count=1, value_type=0)
    add_command(125, [1, value_type, count])
  end
  
  #-----------------------------------------------------------------------------
  # Command_126: Change item
  #   id: database ID of the item
  #   count: how many to add, or which variable to use
  #   type: 0 = constant, 1 = variable
  #-----------------------------------------------------------------------------
  def add_item(id, count, type=0)
    add_command(126, [id, 0, type, count])
  end
  
  def lose_item(id, count, type=0)
    add_command(126, [id, 1, type, count])
  end
  #-----------------------------------------------------------------------------
  # Command_127 and 128: Change weapon/armor
  #   id: database ID of the weapon
  #   count: how many to add, or which variable to use
  #   type: 0 = constant, 1 = variable
  #   include_equip: only used when decreasing equip. Will remove from equip
  #                  if none is available in inventory
  #-----------------------------------------------------------------------------
  def add_weapon(id, count, type, include_equip)
    add_command(127, [id, 0, type, count, include_equip])
  end
  
  def lose_weapon(id, count, type, include_equip)
    add_command(127, [id, 1, type, count, include_equip])
  end
  
  def add_armor(id, count, type, include_equip)
    add_command(128, [id, 0, type, count, include_equip])
  end
  
  def lose_armor(id, count, type, include_equip)
    add_command(128, [id, 1, type, count, include_equip])
  end
  
  #-----------------------------------------------------------------------------
  # Command_129: Change Party
  #    actor_id: ID of the actor to change
  #    initialize: 0 = false, 1 = true
  #-----------------------------------------------------------------------------
  def add_actor(actor_id, initialize=0)
    add_command(129, [actor_id, 0, initialize])
  end
  
  def lose_actor(actor_id, initialize=0)
    add_command(129, [actor_id, 1, initialize])
  end
  
  # changes all actors' HP in party
  #    amount: amount to change, or variable ID
  #    value_type: 0 = constant value, 1 = variable value
  #    allow_knockout: when decreasing, allow HP to drop to 0
  #
  # operand (3rd element) is always "increase" since the amount can be negative
  def change_party_hp(amount, value_type=0, allow_knockout=false)
     add_command(311, [0, 0, 0, value_type, amount, allow_knockout])
  end
  
  def change_party_mp(amount, value_type=0)
    add_command(312, [0, 0, 0, value_type, amount])
  end
  
  # add state to all party members
  def add_party_state(state_id)
    add_command(313, [0, 0, 0, state_id])
  end
  
  def remove_party_state(state_id)
    add_command(313, [0, 0, 1, state_id])
  end
  
  #=============================================================================
  # Actor related commands
  #=============================================================================
  
  #=============================================================================
  # Movement related commands
  #=============================================================================
  
  # transfers player to a map
  #   type: 0 = direct designation, 1 = variable designation
  #   direction: 0 = retained, 2 = down, 4 = left, 6 = right, 8 = up
  #   fadeout: 0 = normal, 1 = white, 2 = none
  #
  # When using variable designation, the map_id, x, and y all refer
  # to variable ID's
  def transfer_player(type, map_id, x, y, direction=0, fadeout=0)
    add_command(201, [type, map_id, x, y, direction, fadeout])
  end
  
  # transfers vehicle to a map
  #    vehicle: 0 = boat, 1 = ship, 2 = airship
  #    type: 0 = direct designation, 1 = variable designation
  def set_vehicle_location(vehicle, type, map_id, x, y)
    add_command(202, [vehicle, type, map_id, x, y])
  end 
  
  # changes the event location
  #    type: 0 = direct designation, 1 = variable designation
  def set_event_location(event_id, type, x, y, direction)
    add_command(203, [event_id, type, x, y, direction])
  end
  
  # swaps event location with another event
  def swap_event_location(event_id, target_event_id, direction)
    set_event_location(event_id, 2, target_event_id, 0, direction)
  end
  
  def scroll_map(direction, distance, speed=4)
    add_command(204, [direction, distance, speed])
  end
  
  #   event_id: -1 = player, 0 = "this event", 1+ = specified event
  #   move_route: a RPG::MoveRoute (or wrapped Move_Route) object
  def set_move_route(event_id, move_route)
    add_command(205, [event_id, move_route])
    
    # now add each move route as a separate command just for the editor
    move_route.list.each do |move_cmd|
      add_command(505, [move_cmd])
    end
  end
  
  # get on/off vehicle
  def toggle_vehicle
    add_command(206)
  end
  
  #=============================================================================
  # Character related commands
  #=============================================================================
  
  # turn on or off player invisibility
  #    bool: 0 = ON, 1 = OF
  def change_transparency(bool)
    value = eval_bool(bool)
    add_command(211, [value])
  end
  
  # turn on or off followers
  #    bool: 0 = ON, 1 = OFF
  def change_followers(bool)
    value = eval_bool(bool)
    add_command(216, [value])
  end
  
  def gather_followers
    add_command(217)
  end
  
  def show_animation(animation_id, event_id, wait_completion=true)
    add_command(212, [event_id, animation_id, wait_completion])
  end
  
  #-----------------------------------------------------------------------------
  # plays balloon animation above character
  #    balloon_id: Id of the balloon animation
  #    event_id: -1 = player; 0 = this event; 1 or up = specific event
  #    wait_completion: true or false
  #-----------------------------------------------------------------------------
  def show_balloon_icon(balloon_id=0, event_id=0, wait_completion=true)
    add_command(213, [event_id, balloon_id, wait_completion])
  end
  
  def erase
    add_command(214)
  end
  
  # custom command. Deletes the event permanently.
  def delete
    add_command(214)
    add_command(215)
  end
  #=============================================================================
  # Screen Effects related commands
  #=============================================================================
  
  def fadeout_screen
    add_command(221)
  end
  
  def fadein_screen
    add_command(222)
  end
  
  # tints the screen to the specified color.
  #    color is an array of the form (red, green, blue, gray)
  def tint_screen(color, frames, wait_completion=true)
    add_command(223, [Color.new(*color), frames, wait_completion])
  end
  
  # color is an array of the form (red, green, blue, strength)
  def flash_screen(color, frames, wait_completion=true)
    add_command(224, [Color.new(*color), frames, wait_completion])
  end
  
  def shake_screen(power, speed, frames, wait_completion=true)
    add_command(225, [power, speed, frames, wait_completion])
  end
  
  #=============================================================================
  # Timing related commands
  #=============================================================================
  
  def wait(frames)
    add_command(230, [frames])
  end
  
  #=============================================================================
  # Picture and Weather related commands
  #=============================================================================
  
  # Show a picture
  #    origin: 0 for upper left, 1 for center
  #    coord_type: 0 for constant, 1 for variable designation
  def show_picture(id, name, origin, coord_type, x, y, zoom_x, zoom_y, opacity, blend_type)
    add_command(231, [id, name, origin, coord_type, x, y, zoom_x, zoom_y, opacity, blend_type])
  end
  
  def move_picture(id, origin, coord_type, x, y, zoom_x, zoom_y, opacity, blend_type, frames=60, wait_complete=true)
    name = $game_screen.pictures[id].name
    add_command(232, [id, name, origin, coord_type, x, y, zoom_x, zoom_y, opacity, blend_type, frames, wait_complete])
  end
    
  def rotate_picture(id, speed)
    add_command(233, [id, speed])
  end
  
  def tint_picture(id, color, frames=60, wait_complete=true)
    add_command(234, [id, Color.new(*color), frames, wait_complete])
  end
  
  def erase_picture(id)
    add_command(235, [id])
  end
  
  # changes the weather
  #    type: one of :none, :rain, :storm, :snow
  def set_weather_effects(type, power, frames=0, wait_complete=false)
    add_command(236, [type, power, frames, wait_complete])
  end
  
  #=============================================================================
  # Music and Sounds related commands
  #=============================================================================
  def play_bgm(filename, volume=80, pitch=100)
    add_command(241, [RPG::BGM.new(filename, volume, pitch)])
  end
  
  def fadeout_bgm(seconds)
    add_command(242, [seconds])
  end
  
  def save_bgm
    add_command(243)
  end
  
  def replay_bgm
    add_command(244)
  end
  
  def play_bgs(filename, volume=80, pitch=100)
    add_command(245, [RPG::BGS.new(filename, volume, pitch)])
  end
  
  def fadeout_bgs(seconds)
    add_command(246, [seconds])
  end
  
  def play_me(filename, volume=100, pitch=100)
    add_command(249, [RPG::ME.new(filename, volume, pitch)])
  end
  
  def play_se(filename, volume=80, pitch=100)
    add_command(250, [RPG::SE.new(filename, volume, pitch)])
  end
  
  def stop_se
    add_command(251)
  end
  
  #=============================================================================
  # Scene Control commands
  #=============================================================================
  
  # id: troop ID or variable ID
  # enc_type: 0 = direct designation, 1 = variable
  def call_battle(id, enc_type=0, can_escape=false, can_lose=false, &block)
    add_command(301, [enc_type, id, can_escape, can_lose])
    
    if (can_lose || can_escape) 
      #hack because call_battle shouldn't be indenting
      @indent -= 1 
      process_block(&block)
      # insert 'branch end'
      add_command(604) 
    end
  end
  
  def battle_win(&block)
    add_command(601)
    process_block(&block)
  end
  
  def battle_lose(&block)
    add_command(603)
    process_block(&block)
  end
  
  def battle_escape(&block)
    add_command(602)
    process_block(&block)
  end
  
  # Same as call battle except treated as random encounter
  def random_battle(can_escape=false, can_lose=false)
    call_battle(0, 2, can_escape, can_lose)
  end
  
  # opens the shop scene
  #    item_type: 0 for item, 1 for weapon, 2 for armor
  #    id: database ID of the item
  #    price_type: 0 for standard, 1 for custom
  #    amount: 0 for standard, > 0 for custom
  def call_shop(item_type, id, price_type=0, amount=0, purchase_only=false)
    add_command(302, [item_type, id, price_type, amount, purchase_only])
  end
  
  # for adding additional items to the shop
  def add_shop_item(item_type, id, price_type, amount)
    add_command(605, [item_type, id, price_type, amount])
  end
  
  def process_name(actor_id, max_chars)
    add_command(303, [actor_id, max_chars])
  end
  
  def open_menu_screen
    add_command(351)
  end
  
  def open_save_screen
    add_command(352)
  end
  
  def game_over
    add_command(353)
  end
  
  def return_title
    add_command(354)
  end
  #=============================================================================
  # System Settings commands
  #=============================================================================
  
  def change_battle_bgm(name, volume=100, pitch=100)
    add_command(132, [RPG::BGM.new(name, volume, pitch)])
  end
  
  # change battle victory ME
  def change_battle_me(name, volume=80, pitch=100)
    add_command(133, [RPG::ME.new(name, volume, pitch)])
  end
  
  # enable/disable opening save scene
  def change_save_access(bool)
    value = eval_bool(bool)
    add_command(134, [value])
  end
  
  # enable/disable opening menu
  def change_menu_access(bool)
    value = eval_bool(bool)
    add_command(135, [value])
  end
  
  # enable/disable encounters
  def change_encounter(bool)
    value = eval_bool(bool)
    add_command(136, [value])
  end
  
  # enable/disable formation change
  def change_formation_access(bool)
    value = eval_bool(bool)
    add_command(137, [value])
  end
  
  # Changes the color of the window.
  def change_window_color(color)
    add_command(138, [Color.new(*color)])
  end
  
  # change character sprite and face picture
  def change_actor_graphics(actor_id, char_name, char_index, face_name, face_index)
    add_command(322, [actor_id, char_name, index, face_name, face_index])
  end
  
  # change character sprite
  def change_actor_char(actor_id, char_name, char_index)
    face_name = $game_actors[actor_id].face_name
    face_index = $game_actors[actor_id].face_index
    change_actor_graphics(actor_id, char_name, char_index, face_name, face_index)
  end
  
  # change face picture
  def change_actor_face(actor_id, face_name, face_index)
    char_name = $game_actors[actor_id].character_name
    char_index = $game_actors[actor_id].character_index
    change_actor_graphics(actor_id, char_name, char_index, face_name, face_index)
  end
  
  # change vehicle sprite
  #    vehicle_id: 0 = boat, 1 = ship, 2 = airship
  def change_vehicle_graphic(vehicle_id, name, index)
    add_command(323, [vehicle_id, name, index])
  end
  
  #=============================================================================
  # Movie commands
  #=============================================================================
  
  # play a movie
  def play_move(name)
    add_command(261, [name])
  end
  
  #=============================================================================
  # Map commands
  #=============================================================================
  
  # Enable/disable map name display when entering map
  #    value: 0 = disable, 1 = enable
  def change_map_name_display(value)
    add_command(281, [value])
  end
  
  # switch to the specified tileset by ID
  def change_tileset(tileset_id)
    add_command(282, [tileset_id])
  end
  
  # change the battleback
  def change_battleback(front_name, back_name)
    add_command(283, [front_name, back_name])
  end
  
  def change_parallax(name, h_loop, v_loop, h_scroll, v_scroll)
    add_command(284, [name, h_loop, v_loop, h_dir, v_dir])
  end
  
  def get_location_info
  end
  
  #=============================================================================
  # Battle commands
  #=============================================================================
  
  #=============================================================================
  # Advanced commands
  #=============================================================================
  
  def call_script(script)
    add_command(355, [script])
  end
end

class MoveCommands
  
  # note that all move command codes are available in Game_Character
  
  def initialize(list)
    @list = list
    @northDir = 8 # default "facing up"
  end
  
  def add_command(code, parameters=[])
    @list.insert(@list.size - 1, RPG::MoveCommand.new(code, parameters))
  end
  
  def move(string)
    cmds = string.scan(Tsuki::Event_Wrapper::Move_String_Regex)
    cmds.each do |cmd|
      num = cmd[0].empty? ? 1 : cmd[0].to_i rescue 1
      case cmd[1]
      when "U"; code = 4
      when "D"; code = 1
      when "L"; code = 2
      when "R"; code = 3
      when "Q"; code = 7
      when "W"; code = 8
      when "A"; code = 5
      when "S"; code = 6
      end
      num.times do |i|
        add_command(code)
      end
    end
  end
  
  # compass-direction based movement
  
  def set_north(direction)
    @northDir = direction
  end
  
  def move_north(count=1)
    case @northDir
    when 2
      move_down(count)
    when 4
      move_left(count)
    when 6
      move_right(count)
    when 8
      move_up(count)
    end
  end
  
  def move_west(count=1)
    case @northDir
    when 2
      move_right(count)
    when 4
      move_down(count)
    when 6
      move_up(count)
    when 8
      move_left(count)
    end
  end
  
  def move_east(count=1)
    case @northDir
    when 2
      move_left(count)
    when 4
      move_up(count)
    when 6
      move_down(count)
    when 8
      move_right(count)
    end
  end
  
  def move_south(count=1)
    case @northDir
    when 2
      move_up(count)
    when 4
      move_right(count)
    when 6
      move_left(count)
    when 8
      move_down(count)
    end
  end
  
  def turn_north
    case @northDir
    when 2
      turn_down
    when 4
      turn_left
    when 6
      turn_right
    when 8
      turn_up
    end
  end
  
  def turn_east
    case @northDir
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end
  
  def turn_west
    case @northDir
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end
  
  def turn_south
    case @northDir
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end
  
  def move_down(count=1)
    count.times { |i| add_command(1) }
  end
  
  def move_left(count=1)
    count.times { |i| add_command(2) }
  end
  
  def move_right(count=1)
    count.times { |i| add_command(3) }
  end
  
  def move_up(count=1)
    count.times { |i| add_command(4) }
  end
  
  def move_lower_left(count=1)
    count.times { |i| add_command(5) }
  end
  
  def move_lower_right(count=1)
    count.times { |i| add_command(6) }
  end
  
  def move_upper_left(count=1)
    count.times { |i| add_command(7) }
  end
  
  def move_upper_right(count=1)
    count.times { |i| add_command(8) }
  end
  
  def move_random(count=1)
    count.times { |i| add_command(9) }
  end
  
  def move_toward_player(count=1)
    count.times { |i| add_command(10) }
  end
  
  def move_away_from_player(count=1)
    count.times { |i| add_command(11) }
  end
  
  def step_forward(count=1)
    count.times { |i| add_command(12) }
  end
  
  def step_backward(count=1)
    count.times { |i| add_command(13) }
  end
  
  def jump(count=1)
    count.times { |i| add_command(14) }
  end
  
  def wait(frames)
    add_command(15, [frames])
  end
  
  def turn_down
    add_command(16)
  end
  
  def turn_left
    add_command(17)
  end
  
  def turn_right
    add_command(18)
  end
  
  def turn_up
    add_command(19)
  end
  
  def turn90_right(count=1)
    count.times { |i| add_command(20) }
  end
  
  def turn90_left(count=1)
    count.times { |i| add_command(21) }
  end
  
  def turn180(count=1)
    count.times { |i| add_command(22) }
  end
  
  # turn 90 degrees right or left
  def turn90_random(count=1)
    count.times { |i| add_command(23) }
  end
  
  def turn_random(count=1)
    count.times { |i| add_command(24) }
  end
  
  def turn_toward_player
    add_command(25)
  end
  
  def turn_away_from_player
    add_command(26)
  end
  
  def change_switch(id, value)
    value == 0 ? add_command(27, [id]) : add_command(28, [id])
  end
  
  def change_speed(number)
    add_command(29, [number])
  end
  
  def change_freq(number)
    add_command(30, [number])
  end
  
  # value: 0 = ON, 1 = OFF
  def walk_anim(value)
    value == 0 ? add_command(31) : add_command(32)
  end
  
  # value: 0 = ON, 1 = OFF
  def step_anim(value)
    value == 0 ? add_command(33) : add_command(34)
  end
  
  # value: 0 = ON, 1 = OFF
  def direction_fix(value)
    value == 0 ? add_command(35) : add_command(36)
  end
  
  # value: 0 = ON, 1 = OFF
  def through(value)
    value == 0 ? add_command(37) : add_command(38)
  end
  
  # value: 0 = ON, 1 = OFF
  def transparent(value)
    value == 0 ? add_command(39) : add_command(40)
  end
  
  def change_graphic(name, index)
    add_command(41, [name, index])
  end
  
  def change_opacity(value)
    add_command(42, [value])
  end
  
  def change_blending(value)
    add_command(43, [value])
  end
  
  def play_se(name, volume=80, pitch=100)
    add_command(44, [RPG::SE.new(name, volume, pitch)])
  end
  
  def call_script(string)
    add_command(45, [string])
  end
end

# This is a wrapper for RPG::MoveRoute. It provides methods that allow you
# to create move routes easily

class MoveRoute < RPG::MoveRoute
  
  # Instance Variables
  #    repeat
  #    skippable
  #    wait
  #    list
  def initialize
    super
    @repeat = false
    @skippable = true
  end
  
  def build(&block)
    MoveCommands.new(@list).instance_eval(&block)
  end
end

# This is a standalone event builder. It returns an event command list
# which you can then assign to an event to use. This allows you to
# write re-usable event creation methods

class EventBuilder
  
  attr_reader :list
  
  # this is preferred, since you can actually pass around a builder
  def initialize(list=nil, &block)
    @list = list || [RPG::EventCommand.new]
    @indent = 0
    EventCommands.new(@list, @indent).instance_eval(&block)
  end
  
  # if you just need to quickly build something
  def self.build(list=nil, &block)
    @list = list || [RPG::EventCommand.new]
    @indent = 0
    EventCommands.new(@list, @indent).instance_eval(&block)
    return @list
  end
end

# This is a wrapper for RPG::Event. It provides methods that allow you to
# create event commands the way you would do it with the editor

class Event < RPG::Event
  
  attr_reader :condition
  attr_reader :graphic
  attr_reader :list
  #=============================================================================
  # Basic methods
  #=============================================================================
  
  def initialize(x=0, y=0)
    super
    @page = @pages[0] = create_page
    @condition = @page.condition = Event_Condition.new
    @graphic = @page.graphic
    @list = @page.list
    @indent = 0
  end
  
  # change the current page.
  def set_page(page_number)
    @page = @pages[page_number] ||= create_page
    @condition = @page.condition
    @graphic = @page.graphic
    @list = @page.list
  end
  
  # create a new page, set some defaults
  def create_page
    page = RPG::Event::Page.new
    page.condition = Event_Condition.new
    page.priority_type = 1
    return page
  end
  
  # A builder method that recursively evaluates a block of commands
  # and creates the appropriate RPG::EventCommand objects.
  def build(&block)
    #@orig_block = block
    EventCommands.new(@list, @indent).instance_eval(&block)
  end
  
  # rebuilds all of the event's pages
  def rebuild
    # Not supported atm since proc's cannot be lambda'd
    #EventCommands.new(@list, @indent).instance_eval(&@orig_block)
  end

  #=============================================================================
  # Event page property related methods.
  #=============================================================================
  
  # set the event command list with the given list
  def list=(list)
    @page.list = list
  end
  
  def move_type=(type)
    @page.move_type = type
  end
  
  def move_speed=(speed)
    @page.move_speed = speed
  end
  
  def move_frequency=(freq)
    @page.move_frequency = freq
  end
  
  def move_route=(route)
    @page.move_route = route
  end
  
  def walk_anime=(bool)
    @page.walk_anime = bool
  end
  
  def step_anime=(bool)
    @page.step_anime = bool
  end
  
  def direction_fix=(bool)
    @page.direction_fix = bool
  end
  
  def through=(bool)
    @page.through = bool
  end

  # The priority type 
  #   0: below characters
  #   1: same as characters
  #   2: above characters
  def priority_type=(type)
    @page.priority_type = type
  end
  
  # The event trigger
  #   0: action button
  #   1: player touch
  #   2: event touch
  #   3: autorun
  #   4: parallel
  def trigger=(trigger_id)
    @page.trigger = trigger_id
  end
  
  #=============================================================================
  # Event graphic related methods. Same as accessing
  # event.pages[page_num].graphic
  #=============================================================================
  def tile_id=(id)
    @graphic.tile_id = id
  end
  
  def direction=(dir)
    @graphic.direction = dir
  end
  
  def pattern=(index)
    @graphic.pattern = index
  end
  
  def character_name=(name)
    @graphic.character_name = name
  end
  
  def character_index=(index)
    @graphic.character_index = index
  end
end

class Event_Condition < RPG::Event::Page::Condition
  #=============================================================================
  # Event conditions related methods. If a condition is specified then
  # it is automatically valid
  #=============================================================================
  def switch1_id=(switch_id)
    @switch1_valid = true
    @switch1_id = switch_id
  end
  
  def switch2_id=(switch_id)
    @switch2_valid = true
    @switch2_id = switch_id
  end
  
  def variable_cond=(var_id, value)
    @variable_valid = true
    @variable_id = var_id
    @variable_value = value
  end
  
  def self_switch=(letter)
    @self_switch_valid = true
    @self_switch_ch = letter
  end
  
  def item_id=(id)
    @item_valid = true
    @item_id = id
  end

  def actor_id=(id)
    @actor_valid = true
    @actor_id = id
  end
end

# Custom events are not saved in the map rvdata2 files, so a copy of the
# events are saved with the game system.

class Game_System
  
  def init_custom_events(map_id)
    @custom_events = {} if @custom_events.nil?
    @custom_events[map_id] = {} if @custom_events[map_id].nil?
  end
  
  def add_custom_event(map_id, event)
    init_custom_events(map_id)
    @custom_events[map_id][event.id] = event
    SceneManager.scene.refresh_spriteset if SceneManager.scene_is?(Scene_Map)
    $game_temp.queue_event(event)
  end
  
  def remove_custom_event(map_id, event_id)
    init_custom_events(map_id)
    @custom_events[map_id].delete(event_id)
    SceneManager.scene.refresh_spriteset if SceneManager.scene_is?(Scene_Map)
  end
  
  def clear_custom_events(map_id)
    init_custom_events(map_id)
    @custom_events[map_id] = {}
    SceneManager.scene.refresh_spriteset if SceneManager.scene_is?(Scene_Map)
  end
  
  def get_custom_events(map_id)
    init_custom_events(map_id)
    return @custom_events[map_id]
    SceneManager.scene.refresh_spriteset if SceneManager.scene_is?(Scene_Map)
  end
end

class Game_Temp
  
  attr_reader :queued_add_events
  
  alias :th_event_wrapper_initialize :initialize
  def initialize
    th_event_wrapper_initialize
    clear_queued_events
  end
  
  def queue_event(event)
    @queued_add_events[event.id] = event
  end
  
  def clear_queued_events
    @queued_add_events = {}
  end
end

class Game_Map
  
  alias :th_event_wrapper_setup_events :setup_events
  def setup_events
    th_event_wrapper_setup_events
    $game_system.get_custom_events(@map_id).each {|i, event|
      @events[i] = Game_Event.new(@map_id, event)
    }
  end
  
  alias :th_event_wrapper_update_events :update_events
  def update_events
    th_event_wrapper_update_events
    add_queued_events
  end
  
  # new
  def add_event(event)
    return unless event
    # find an available index
    if $game_temp.queued_add_events.empty?
      index = @events.empty? ? 1 : @events.keys.max + 1
    else
      index = $game_temp.queued_add_events.keys.max + 1
    end
    event.id = index
    # need to store this custom event somewhere
    $game_system.add_custom_event(@map_id, event)
  end
  
  def remove_event(event_id, map_id=$game_map.map_id)
    @events.delete(event_id)
    $game_system.remove_custom_event(map_id, event_id)    
  end
  
  #-----------------------------------------------------------------------------
  # There may be new events that need to be added
  #-----------------------------------------------------------------------------
  def add_queued_events
    events = $game_temp.queued_add_events
    return if events.empty?
    events.each do |index, ev|
      @events[index] = Game_Event.new(@map_id, ev)
    end    
    events.clear
    SceneManager.scene.refresh_spriteset if SceneManager.scene_is?(Scene_Map)
  end
end

class Scene_Map
  
  def refresh_spriteset
    @spriteset.refresh_characters
  end
end

class Game_Interpreter
  
  def command_215
    map_id = $game_map.map_id # bad implementation
    $game_system.remove_custom_event(map_id, @event_id)
  end
end
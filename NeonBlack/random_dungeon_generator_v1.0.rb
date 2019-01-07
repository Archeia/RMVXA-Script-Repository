###--------------------------------------------------------------------------###
#  CP Dungeon Generator script                                                 #
#  Version 1.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#  V1.0 - 9.6.2012~9.8.2012                                                    #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias:      - Game_Map: setup                                               #
#                Scene_Map: perform_transfer                                   #
#  Overwrites  - Game_Event: conditions_met?, update                           #
#  New Methods - Game_System: dungeon?, dungeon, create_dungeon                #
#                Game_Map: random_map?, setup_random_map, choose_random,       #
#                          get_block, get_random_index, convert_direction,     #
#                          setup_first_events, check_for_events,               #
#                          create_treasure, add_new_event,                     #
#                          reset_all_self_switches                             #
#                Game_Player: set_start_pos                                    #
#                Game_Interpreter: create_dungeon                              #
#                Game_Dungeon: initialize, new_dungeon, create_alts,           #
#                              add_path, get_direction, check_dir, invert,     #
#                              add_treasure, map_error, map, start_pos,        #
#                              end_pos                                         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above "Main".   #
#  This script has only a single setting but it still has quite a few          #
#  conditions for it to work properly.  Be sure to consult the user manual to  #
#  ensure everything is set up properly for it to work.  The tags used by the  #
#  system are defined below:                                                   #
#                                                                              #
#    <random> - This must be placed in a map's notebox for it to be a random   #
#               dungeon.  Without it, nothing will happen to the map.          #
#    <super> - Put this in an event's name on a random map and the event will  #
#              always appear in the upper left hand corner of the map.  This   #
#              is useful for parallel events that need to be running only in   #
#              the map, such as certain bits of dialogue.                      #
#    <treasure> - Put this in an event's name and it will appear on tiles set  #
#                 to region id 3 in "treasure rooms" on the map.  Only the     #
#                 one with the lowest ID will show up.                         #
#                                                                              #
#  To go to a random dungeon, use the following script call and then simply    #
#  transfer to any random dungeon map.                                         #
#                                                                              #
#    create_dungeon(length, alts, width, height)                               #
#                                                                              #
#      length - This is the length of the dungeon's main path.  This includes  #
#               the very end room.  Set this to a number to have that many     #
#               rooms between the start and end room.                          #
#      alts - The number of branching alternate paths to have.  These paths    #
#             can start from any existing room on the map and can be any       #
#             length between 1 and room and "lenth" rooms.                     #
#      width - The width of the total space allotted for rooms.  By default,   #
#              empty "rooms" are placed on all edges of the map.  Setting      #
#              this to a high number will give the generator more horizontal   #
#              room to build in.                                               #
#      height - Pretty much the same as "width" but with vertical room.        #
#                                                                              #
#      Maps:                                                                   #
#  Maps must be created with a total of 40 "rooms" that the dungeon selects    #
#  to draw from.  This creates a set of rooms that is 8 wide and 5 tall.       #
#  Every room must be the same size, but the size of the rooms and the size    #
#  of the set is pretty much infinite.  The first 16 rooms are the standard    #
#  rooms that will show up based on the random value you set in the config     #
#  section.  The open paths, in order, are as follows:                         #
#   (Note: U = Up, R = Right, D = Down, L = Left)                              #
#                                                                              #
#     [none] [  U ] [  R ] [ UR ] [  D ] [ UD ] [ DR ] [ URD]                  #
#     [  L ] [ UL ] [ LR ] [ LUR] [ LD ] [ UDL] [ LRD] [URDL]                  #
#                                                                              #
#  The next 16 tiles follow the same pattern.  These are the "uncommon" tiles  #
#  that only appear with a certain chance based on the random value set        #
#  below.                                                                      #
#                                                                              #
#  The final 8 tiles are the start and end points.  The first 4, your start    #
#  points follow the pattern up, right, down, left.  The last 4 are the end    #
#  points and follow the same pattern.                                         #
#                                                                              #
#  The end result map should be something like this crude ascii                #
#  representation:                                                             #
#                                                                              #
#       ╨ ╞ ╚ ╥ ║ ╔ ╠                                                          #
#     ╡ ╝ ═ ╩ ╗ ╣ ╦ ╬                                                          #
#       ╨ ╞ ╚ ╥ ║ ╔ ╠                                                          #
#     ╡ ╝ ═ ╩ ╗ ╣ ╦ ╬                                                          #
#     ╨ ╞ ╥ ╡ ╨ ╞ ╥ ╡                                                          #
#                                                                              #
#      Regions:                                                                #
#  Regions are very important for telling the map where certain things should  #
#  happen.  The region tags that are reserved by the generator are             #
#  1, 2, 3, 4, 6, and 8.                                                       #
#  Region 3 is used by the generator to determine where to put treasures.      #
#  When a room is designated as a treasure room (the end of an alt path) it    #
#  will search the room for a region 3 and place treasure chests on ANY found  #
#  (see above for how to mark these).                                          #
#  Regions 1, 2, 4, 6, and 8 are used for the start points.  As it is          #
#  creating the dungeon, it will take the last of these regions that it        #
#  copies and set it as the start point.  As a general rule, only put one of   #
#  any of these in each of the 4 start rooms.  When using region 1, the        #
#  player's facing direction is determined by the transfer event.  If you      #
#  want the direction to change based on which room the player ends up in,     #
#  user 2, 4, 6, or 8.  These will set the player to face the same direction   #
#  as the same number on the numpad, for example, region 8 will place the      #
#  player facing up.                                                           #
#                                                                              #
#      Events:                                                                 #
#  All other events work normally.  When a room is copied over to the newly    #
#  created map, all events are taken with it and placed in exactly the same    #
#  spot.  The only exceptions are events marked as treasures and events        #
#  marked as super.                                                            #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
module CP              # Do not edit                                           #
module RANDOM_DUNGEON  #  these two lines.                                     #
#                                                                              #
# This number determines the odds of the secondary room/tile appearing in a    #
# dungeon.  The higher the number, the less the odds.                          #
RANDOM = 5 # Default = 5                                                       #
###--------------------------------------------------------------------------###


end
end

module Console  ## Adds the console command for creating a map.
  class << self  ## Alias the addition method with a rescue escape.
    alias cp_rdg_new_console_commands new_console_commands rescue nil
  end
  
  def self.new_console_commands
    cp_rdg_new_console_commands  ## Adds the new command.
    new_command("map", :cp_rdg_draw_map_do, :cp_rdg_draw_map_help)
  end
  
  def self.cp_rdg_draw_map_help  ## The help text to be displayed.
    push_string("Draws the randomly generated map if set.")
  end
  
  def self.cp_rdg_draw_map_do(*args)
    dungeon = $game_system.dungeon  ## Checks if a map is created.
    return push_string("No dungeon drawn.") if dungeon.nil? || dungeon.map.nil?
    dh = dungeon.height + 2  ## Adds the outer edge to the map.
    dw = dungeon.width + 2
    dh.times do |i1|
      temp = []  ## Gets a row for the console.
      dw.times do |i2|  
        temp.push dungeon.map[i2, i1]
      end
      string = ""
      chars = "░╨╞╚╥║╔╠╡╝═╩╗╣╦╬"
      temp.each {|n| string += chars[n]}  ## Draws the map in ascii.
      push_string(string)  ## Displays a line of the map.
    end
  end
end

class Game_System
  def dungeon?  ## Check if a dungeon exists.
    return dungeon ? true : false
  end
  
  def dungeon  ## Returns either the dungeon or nil.
    return nil if @dungeon.nil? || @dungeon.map.nil?
    return @dungeon
  end
  
  def create_dungeon(length = nil, alts = 0, width = 100, height = 100)
    @dungeon = Game_Dungeon.new(length, alts, width, height)
  end  ## Stores a created dungeon.
end

class Game_Map
  attr_accessor :map_id
  
  alias cp_rdg_setup setup unless $@
  def setup(*args)  ## Aliased to create the random dungeon.
    cp_rdg_setup(*args)
    return unless random_map?  ## Return the old dungeon if not random.
    return if $game_system.dungeon.nil?
    old_data = @map.data.dup  ## Holds onto the old stuff.
    old_events = @map.events.dup
    width = @map.width  ## New dungeon is prepared.
    height = @map.height
    rwidth = width / 8
    rheight = height / 5
    @map.width = ($game_system.dungeon.width + 2) * rwidth
    @map.height = ($game_system.dungeon.height + 2) * rheight
    @map.data = Table.new(@map.width, @map.height, 4)
    @events = {}
    setup_first_events  ## Sets up the super events.
    setup_random_map(rwidth, rheight, old_data)  ## Creates the dungeon.
    reset_all_self_switches  ## Resets all self switches in the dungeon.
  end
  
  def random_map?  ## Checks if the map is a random map.
    return @map.note.include?("<random>")
  end
  
  def setup_random_map(rwidth, rheight, old_data)
    mapw = $game_system.dungeon.width + 2
    maph = $game_system.dungeon.height + 2
    mapw.times do |x|
      maph.times do |y|
        choose_random  ## Chooses the room to mimic (standard/special)
        rheight.times do |i1|
          rwidth.times do |i2|
            ndx = get_random_index(x, y)  ## Gets the room index.
            blockx = x * rwidth
            blocky = y * rheight  ## Checks and creates events.
            check_for_events(ndx, rwidth, rheight, i1, i2, blockx, blocky)
            4.times do |i3|  ## Creates the room.
              square = get_block(ndx, rwidth, rheight, i1, i2, i3, old_data)
              @map.data[blockx + i1, blocky + i2, i3] = square
              next unless i3 == 3
              region = square >> 8
              create_treasure(blockx + i1, blocky + i2, x, y) if region == 3
              next unless [32, 33, 34, 35].include?(ndx)
              next unless [1, 2, 4, 6, 8].include?(region)
              region = 0 if region == 1  ## Sets player start position.
              $game_player.set_start_pos(blockx + i1, blocky + i2, region)
            end
          end
        end
      end
    end
  end
  
  def choose_random  ## Sets the type of room (standard/special).
    rnum = rand(CP::RANDOM_DUNGEON::RANDOM)
    @random_tile = rnum == 0 ? true : false
  end
  
  def get_block(index, rwidth, rheight, x, y, layer, old_data)
    ndx = (@random_tile && index < 16) ? index + 16 : index
    ix = (ndx % 8) * rwidth + x  ## Gets a single tile from a room.
    iy = (ndx / 8) * rheight + y
    return old_data[ix, iy, layer]
  end
  
  def get_random_index(x, y)  ## Gets the index of the room.
    direction = $game_system.dungeon.map[x, y]
    index = direction  ## Start and end point index modifs.
    if [x - 1, y - 1] == $game_system.dungeon.start_pos
      index = convert_direction(direction, true)
    elsif [x - 1, y - 1] == $game_system.dungeon.end_pos
      index = convert_direction(direction, false)
    end
    return index
  end
  
  def convert_direction(dir, start)
    case dir  ## Converts the index for start and end points.
    when 1
      return start ? 32 : 36
    when 2
      return start ? 33 : 37
    when 4
      return start ? 34 : 38
    when 8
      return start ? 35 : 39
    end
  end
  
  def setup_first_events  ## Prepares the super events.
    @map.events.each do |i, event|
      next unless event.name.include?("<super>")
      add_new_event(event, 0, 0)
    end
  end
  
  def check_for_events(index, rwidth, rheight, x, y, placex, placey)
    ndx = (@random_tile && index < 16) ? index + 16 : index
    ix = (ndx % 8) * rwidth + x  ## Gets all events except tagged events.
    iy = (ndx / 8) * rheight + y
    px = placex + x
    py = placey + y
    @map.events.each do |i, event|
      next if event.name.include?("<treasure>") || event.name.include?("<super>")
      next unless event.x == ix && event.y == iy
      add_new_event(event, px, py)
      return
    end
  end
  
  def create_treasure(x, y, mx, my)  ## Sets up treasure events.
    return unless $game_system.dungeon.treasure.include?([mx - 1, my - 1])
    @map.events.each do |i, event|
      next unless event.name.include?("<treasure>")
      add_new_event(event, x, y)
      return
    end
  end
  
  def add_new_event(event, x, y)
    id = @events.size + 1  ## Places a new event on the map.
    @events[id] = Game_Event.new(@map_id, event)
    @events[id].moveto(x, y)
    @events[id].id = id
  end
  
  def reset_all_self_switches  ## Resets the self switches of all events.
    @events.each do |i, event|
      ["A", "B", "C", "D"].each do |switch|
        key = [@map_id, event.id, switch]
        $game_self_switches[key] = false
      end
    end
  end
end

class Game_CharacterBase
  attr_accessor :id  ## Allows the "@id" variable to be changed for above.
end

class Game_Event < Game_Character  ## Two changes required for events to work.
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid
      return false unless $game_switches[c.switch1_id]
    end
    if c.switch2_valid
      return false unless $game_switches[c.switch2_id]
    end
    if c.variable_valid
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid
      key = [@map_id, @id, c.self_switch_ch]  ## Only modded this line....
      return false if $game_self_switches[key] != true
    end
    if c.item_valid
      item = $data_items[c.item_id]
      return false unless $game_party.has_item?(item)
    end
    if c.actor_valid
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true
  end
  
  def update
    super
    check_event_trigger_auto
    return unless @interpreter  ## Also modded the line below for @id.
    @interpreter.setup(@list, @id) unless @interpreter.running?
    @interpreter.update
  end
end

class Game_Player < Game_Character
  attr_reader :new_map_id
  
  def set_start_pos(x, y, dir)  ## Allows a start position to be set.
    @new_x = x                  ## Required to place the player on a random map.
    @new_y = y
    set_direction(dir)
  end
end

class Game_Interpreter  ## Allows the new dungeon to be created.
  def create_dungeon(length = nil, alts = 0, width = 100, height = 100)
    $game_system.create_dungeon(length, alts, width, height)
  end
end

class Game_Dungeon
  attr_reader :width
  attr_reader :height
  attr_reader :treasure
  
  def initialize(length = nil, alts = 0, width = 100, height = 100)
    @width = [width, 1].max  ## Sets the default values of the dungeon.
    @height = [height, 1].max
    @alts = [alts, 0].max
    @length = length
    @iterations = 0  ## Resets iteration.
    new_dungeon unless length.nil?  ## Creates a dungeon.
  end
  
  def new_dungeon(length = @length)  ## Creates a dungeon of a certain length.
    @map = Table.new(@width + 2, @height + 2)
    @done = false
    @treasure = []
    @startx = rand(@width)
    @starty = rand(@height)
    posx = @startx
    posy = @starty
    length.times do
      dir = get_direction(posx, posy)
      if dir
        posx, posy = add_path(posx, posy, dir)
      else  ## Performs error handling.
        @iterations += 1
        return map_error if @iterations >= 50
        new_dungeon(length)
        break
      end
    end
    return if @done  ## Prevents section from being performed for each error.
    @endx = posx
    @endy = posy
    create_alts(length + 2, width * height) if @map
    @iterations = 0
    @done = true
  end
  
  def create_alts(length, area)  ## Creates several possible alt paths.
    return if @alts == 0
    @alts.times do
      return if length >= area
      x = rand(width)
      y = rand(height)
      redo unless @map[x + 1, y + 1] != 0
      redo if x == @startx && y == @starty
      redo if x == @endx && y == @endy
      dir = get_direction(x, y)
      redo if dir.nil?
      x, y = add_path(x, y, dir)
      length += 1
      rand(@length).times do
        dir = get_direction(x, y)
        break if dir.nil?
        x, y = add_path(x, y, dir)
        length += 1
      end
      add_treasure(x, y)  ## Creates treasure rooms at each section.
    end
  end
  
  def add_path(x, y, dir)  ## Adds an opening to the current and next blocks.
    @map[x + 1, y + 1] += dir
    x += 1 if dir == 2
    x -= 1 if dir == 8
    y += 1 if dir == 4
    y -= 1 if dir == 1
    @map[x + 1, y + 1] += invert(dir)
    return x, y
  end
  
  def get_direction(x, y)  ## Gets all possible directions to move.
    movements = [1, 2, 4, 8]
    movements -= check_dir(x, y)
    return nil if movements.nil?
    dir = rand(movements.size)  ## Returns nil or a random direction.
    return movements[dir]
  end
  
  def check_dir(x, y)  ## Shows which directions cannot be moved to.
    remove = []
    remove.push(1) if y == 0 || @map[x + 1, y] != 0
    remove.push(2) if x == @width - 1 || @map[x + 2, y + 1] != 0
    remove.push(4) if y == @height - 1 || @map[x + 1, y + 2] != 0
    remove.push(8) if x == 0 || @map[x, y + 1] != 0
    return remove
  end
  
  def invert(dir)  ## Inverts a direction.
    case dir
    when 1
      return 4
    when 2
      return 8
    when 4
      return 1
    when 8
      return 2
    else
      return 0
    end
  end
  
  def add_treasure(x, y)  ## Adds a treasure room.
    @treasure.push([x, y])
  end
  
  def map_error  ## Destroys the map on max iterations.
    @map = nil
    msgbox "Max iterations reached"
    @iterations = 0
  end
  
  def map  ## Shows other events a valid map if possible.
    return nil unless @map
    return @map
  end
  
  def start_pos  ## Shows the start location.
    return [@startx, @starty]
  end
  
  def end_pos  ## Shows the end location.
    return [@endx, @endy]
  end
end

class Scene_Map < Scene_Base
  alias cp_rdg_perform_transfer perform_transfer unless $@
  def perform_transfer  ## Redraws the map on same random map transfers.
    if $game_player.new_map_id == $game_map.map_id && $game_map.random_map?
      $game_map.map_id = -1
    end
    cp_rdg_perform_transfer
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###
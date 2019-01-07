##----------------------------------------------------------------------------##
## Composite Character v2.1
## Created by Neon Black
##
## Only for non-commercial use.  See full terms of use and contact info at:
## http://cphouseset.wordpress.com/liscense-and-terms-of-use/
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## V2.1 - 2.12.2013
##  Added new script calls
## V2.0 - 1.24.2013
##  Rewrote entire script from scratch
## V1.0 - 10.17.2012
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported = {} if $imported.nil?                                              ##
$imported["COMPOSITE"] = 2.1                                                  ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the "Materials" section of the scripts above "Main".
## To use this script you must have additional composite graphics in a folder
## for characters and a folder for faces.  Charactersets will use composites
## based on their names in the NAMES setting.  Some layers of the composite
## may also change based on the equipped items on the actor associated with
## file name.  There are several tags that work with both actors and equips.
##
##    Tags:
## tag init[Handler, hue]
##  - Can only be tagged in actors.  Changes composite layer :tag to handler
##    "Handler" with the defined hue.  Do not use colons for layer names or
##    quotes for file handler names.
## gender[male]
##  - Sets the character's initial gender to "male" or "female" depending on
##    which you place in the brackets.  This can only tag actors.
## alt name[Christopher]
##  - Sets the character's name for the opposite gender.  If the player changes
##    the gender in the GUI and has not changed the name, the new name will be
##    displayed.  The name "Christopher" here can be any name you desire.
## tag image[Handler, hue]
##  - Changes the default images for layer :tag to file handler "Handler".
##
##    Script Calls:
## The character creation screen can be called with either of these two script
## calls from an event.  Other script calls also exist.
##
## creation(id)  -or-  creation(id, array)
##  - The value "id" can be either the actor's ID or the name of the character
##    set to modify.  The "array" value does not need to be used ever.  This is
##    the array of handlers from "GUI_LISTS" to use.  If no array is defined,
##    "BASE_GUI" is used instead.
## composite_custom(id, handler, name, hue)
##  - Changes composite "id"'s layer "handler" into file "name" with a hue of
##    "hue".  This occurs on the same priority level as the character creation
##    screen, so it is covered by armour and can be modified by the player.
##    "id" must be a value from NAMES, "handler" a layer from COMPOSITE, "name"
##    a file from FILE_HANDLERS, and "hue" a number from 0 to 255.
## composite_force(id, handler, name, hue)
##  - Similar to the command above, but this takes the highest priority when
##    being drawn and cannot be changed by the player.
## composite_reset(id)
##  - Removes all layers added using the "composite_force" script call.
##
##    Special Layers:
## In order to allow a slight bit more customization, there are 3 types of
## special layers that link directly to other layers.  These layers end with
## "Back", "Hueless", and "All".
##
## Back Layers
##  - These layers do not actually need to be behind the normal layer.  They
##    are simply a second layer with all the same properties of the parent
##    layer.  An example would be :hairRear which would be a rear layer of
##    :hair.
## Hueless Layers
##  - These layers ignore the changed hue values.  The main use of these would
##    be objects with skin tone or perhaps objects that you only want to change
##    part of the colour on.  The only object that uses this in the example
##    is :eyesHueless which is a hueless layer of :eyes.
## All Layers
##  - These are special layers on the character.  They are a layer that appears
##    on the character no matter what the player does.  The file that appears
##    is still linked to the file part it is attatched to for the sake of hue.
##    The file that appears for one of these layers is defined in the hash
##    GUI_OPTIONS.
##----------------------------------------------------------------------------##
                                                                              ##
module CP        # Do not touch                                               ##
module COMPOSITE #  these lines.                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------

# The folders containing the composite parts for characters and for facesets.
CHAR_FOLDER = "Graphics/Composite/Charas/"
FACE_FOLDER = "Graphics/Composite/Faces/"

# Determines if the creation screen uses face sets are not.  Set to false if
# you do not want a faceset displayed.
USE_FACESETS = true

# The width and height of the character window in the creation screen.  The
# character in the screen is zoomed in to 200%.
WINDOW_WIDTH = 90
WINDOW_HEIGHT = 112

# The text options for the character selection GUI.  EMPTY_TEXT refers to an
# option which is blank for some reason.
GUI_CLOSE = "Finish Editing"
EMPTY_TEXT = "None"

# The number of allowed character spaces for names when input from the editor.
CHARACTERS = 6

# Names for the male and female genders.
GENDER_NAMES = ["Male", "Female"]

# Determines if male undefined characters start out as male characters.
MALE_DEFAULT = true

##------

# Determine the files that are recognized as composite images and the actor
# they are linked to, for the sake of armour, storage, etc.
NAMES ={
  "$Hero1" => 11,
  "$Hero2" => 12,
}

# The switches related to characters.  A switch is turned ON when the character
# is male and OFF when the character is female.
SWITCHES ={
  11 => 72,
  12 => 73,
}

# The order for composite layers.  The first layer is the lowest layer.
COMPOSITE =[
  :hairRear,
  :cape,
  :armorRear,
  :headAll,
  :head,
  :eyes,
  :eyesAll,
  :eyesHueless,
  :armor,
  :hair,
  :glasses,
  :helmet,
]

# These are the handlers for all files in the composite folders.  Actor and
# equip tags as well as GUI options point to a handler and the handler
# determines the male and female files to look up.  Make sure every handler
# has a different name.
FILE_HANDLERS ={
# "Handler"       => ["Male_File", "Female_File"],
  "Shaggy"        => ["Hair1M", nil],
  "Slick"         => ["Hair2M", nil],
  "Spiked"        => ["Hair3M", nil],
  "Fancy"         => ["Hair4M", nil],
  "Stylish"       => [nil, "Hair1F"],
  "Waist Length"  => [nil, "Hair2F"],
  "Curled"        => [nil, "Hair3F"],
  "Pigtails"      => [nil, "Hair4F"],
  "Short"         => ["Hair1U", "Hair1U"],
  "Long"          => ["Hair2U", "Hair2U"],
  "Observant"     => ["Eye1M", "Eye1F"],
  "Closed"        => ["Eye2M", "Eye2F"],
  "Intent"        => ["Eye3M", "Eye3F"],
  
  "HeadBase"      => ["HeadAll", "HeadAll"],
  "FaceBase"      => ["FaceM", "FaceF"],
  "BodyBase"      => ["BaseM", "BaseF"],
  
  "Clothes"       => ["ClothesM", "ClothesF"],
  "Cloth"         => ["ClothM", "ClothF"],
  "Armor"         => ["ArmourM", "ArmourF"],
  "Glasses"       => ["Glasses", "Glasses"],
  "Sunglasses"    => ["Sunglasses", "Sunglasses"],
  "Goggles"       => ["Goggles", "Goggles"],
}

# Standard handlers.  These are default handlers of certain layers.
STANDARD ={
  :headAll  => "HeadBase",
  :head     => "FaceBase",
  :armor    => "BodyBase",
}

# The GUI options that may be called from an array.  If the "Name" field is set
# to a :symbol like the :barber example, it will point back to another option
# and use that option's name and layer.  The point is simply to link different
# handlers to it as well as giving it different colour options.  The colorize?
# option can be set to a value of 0, 1, or 2 depending on the style of hue bar
# you would like displayed.  If it is set to 0, no bar will be displayed.
GUI_OPTIONS ={
# :handler  => ["Name",   colorize?, "AllFile"],
  :Name     => ["Name",   0,         nil],
  :Gender   => ["Gender", 0,         nil],
  :hair     => ["Hair",   1,         nil],
  :eyes     => ["Eyes",   1,         "EyeAll"],
  
  :barber   => [:hair,    true,      nil],
}

# These are the basic options to use in the GUI if no array is defined.
BASE_GUI = [:Name, :Gender, :hair, :eyes]

# These are the lists that refer to the options.  Male and Female only options
# are automatically filtered depending on the character's gender.
GUI_LISTS ={
  :hair     => ["Shaggy", "Slick", "Spiked", "Fancy", "Stylish", "Waist Length",
                "Curled", "Pigtails"],
  :eyes     => ["Observant", "Intent", "Closed"],
  
  
  :barber   => ["Shaggy", "Slick", "Spiked", "Fancy", "Stylish", "Waist Length",
                "Curled", "Pigtails", "Short", "Long"],
}

##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


end
end

module Cache
  class << self  ## Alias for the used methods in this module.
    alias cp_cm_character character
    alias cp_cm_face face
    alias cp_cm_clear clear
  end
  
  def self.character(*args)  ## Checks if the file is a composite.
    return cp_cm_character(*args) unless Composites.include?(args[0])
    create_composite(args[0], "Graphics/Characters/")
    hue = args[1] ? args[1] : 0
    load_bitmap("Graphics/Characters/", args[0], hue)
  end
  
  def self.face(*args)  ## Checks if the face is a composite.
    return cp_cm_face(*args) unless Composites.include?(args[0])
    create_composite(args[0], "Graphics/Faces/")
    hue = args[1] ? args[1] : 0
    load_bitmap("Graphics/Faces/", args[0], hue)
  end
  
  def self.need_comp_ref?(file, path)  ## Checks refresh status.
    return true if Composites.refresh?(file)
    return true if @cache[path].nil? || @cache[path].disposed?
    return false
  end
  
  def self.create_composite(file, folder)  ## Find and create the composite.
    path = "#{folder}#{file}"
    return unless need_comp_ref?(file, path)
    foldrs = ["Graphics/Characters/", "Graphics/Faces/"]
    Composites.constants.each_with_index do |fld, i|
      paths = "#{foldrs[i]}#{file}"
      array = Composites.images(file)
      Composites.layers do |i|
        image = array[i]
        unless @temp
          @temp = Bitmap.new("#{fld}#{image}") rescue next
          @temp.hue_change(Composites.hues(file)[i]) unless Composites.hues(file)[i].nil?
        else
          t = Bitmap.new("#{fld}#{image}") rescue next
          t.hue_change(Composites.hues(file)[i]) unless Composites.hues(file)[i].nil?
          @temp.blt(0, 0, t, t.rect)
          t.dispose; t = nil
        end
      end
      @temp = Bitmap.new unless @temp
      Composites.refreshed(file)
      @cache[paths] = Bitmap.new(@temp.width, @temp.height)
      @cache[paths].blt(0, 0, @temp, @temp.rect)
      @temp.dispose; @temp = nil
    end
    Composites.remove_temp_layers(file)
  end
  
  def self.clear  ## Reset the composite cache.
    cp_cm_clear
    Composites.clear
  end
end

module Composites
  def self.include?(file)  ## Checks if a file is a composite.
    return CP::COMPOSITE::NAMES.include?(file)
  end
  
  def self.options  ## Easy access of the options hash.
    return CP::COMPOSITE::GUI_OPTIONS
  end
  
  def self.lists  ## Easy access of the gui lists hash.
    return CP::COMPOSITE::GUI_LISTS
  end
  
  def self.list_by_block(handler, block)  ## Returns a list based on gender.
    return [] unless [0, 1].include?(block) && lists.include?(handler)
    return lists[handler].select {|a| !files[a][block].nil?}
  end
  
  def self.layers  ## Gets each layer key one at a time.
    CP::COMPOSITE::COMPOSITE.each do |key|
      yield key
    end
  end
  
  def self.constants  ## Gets the folder constants.
    if CP::COMPOSITE::USE_FACESETS
      return [CP::COMPOSITE::CHAR_FOLDER, CP::COMPOSITE::FACE_FOLDER]
    else
      return [CP::COMPOSITE::CHAR_FOLDER]
    end
  end
  
  def self.files  ## Gets the file handler hash.
    return CP::COMPOSITE::FILE_HANDLERS
  end
  
  def self.include_block?(block, handler)  ## Checks gender blocks to handlers.
    return false unless files.include?(handler)
    return !files[handler][block].nil?
  end
  
  def self.standard  ## Gets the standard GUI display.
    return CP::COMPOSITE::STANDARD
  end
  
  def self.get_first_handler(block, key)  ## Gets the init files based on block.
    return nil if ![0, 1].include?(block) || !lists.include?(key)
    lists[key].each do |handler|
      next unless files.include?(handler)
      return handler unless files[handler][block].nil?
    end
    return nil
  end
  
  def self.n(file)  ## Returns a number from a file.
    return CP::COMPOSITE::NAMES[file]
  end
  
  def self.refreshed(file)  ## Resets a file's refresh status.
    return unless n(file)
    actor(file).composite_refresh = false
  end
  
  def self.images(file)  ## Get all images of a file.
    return @temp_images[file] if @temp_images && @temp_images[file]
    return actor(file).composite_images
  end
  
  def self.hues(file)  ## Get all hues of a file.
    return @temp_hues[file] if @temp_hues && @temp_hues[file]
    return actor(file).composite_hues
  end
  
  def self.remove_temp_layers(file)  ## Removes temporary (save) layers.
    @temp_images.delete(file) if @temp_images
    @temp_hues.delete(file) if @temp_hues
  end
  
  def self.make_temp_file(file, handlers)  ## Create a new temp of a file.
    @temp_images = {} if @temp_images.nil?; @temp_hues = {} if @temp_hues.nil?
    @temp_images[file] = {}; @temp_hues[file] = {}
    handlers.each do |key, array|
      @temp_images[file][key] = array[0]
      @temp_hues[file][key] = array[1]
    end
  end
  
  def self.refresh?(file)  ## Check if a file needs refreshing.
    return false unless n(file)  ## Includes temp file checking.
    return true if @temp_images && @temp_images.include?(file)
    return actor(file).composite_refresh
  end
  
  def self.actor(file)  ## Gets a game actor from a file name.
    return $game_actors[n(file)]
  end
  
  def self.clear  ## Allows forced reset of each file.
    CP::COMPOSITE::NAMES.keys.each do |file|
      actor(file).composite_refresh = true
    end
  end
end

class Game_Actor < Game_Battler
  attr_accessor :composite_refresh
  
  alias cp_cmpst_init initialize
  def initialize(*args)  ## Sets the initial values for composites.
    cp_cmpst_init(*args)
    @composite_refresh = true
    @editor_changes = {}
    @editor_hues = {}
    @forced_composites = {}
  end
  
  def composite_images  ## Returns the composite images for an actor.
    make_composite_lists if @composite_refresh
    return @composite_images
  end
  
  def composite_hues  ## Returns the composite hues.
    make_composite_lists if @composite_refresh
    return @composite_hues
  end
  
  def edd_additions(hueless, rear)  ## Make a new filename based on layers.
    a = ""
    b = hueless ? "#{a}Hueless" : a
    c = rear ? "#{b}Rear" : b
    return c
  end
  
  def get_composite_lists  ## Gets a composite list for save files.
    return {} unless Composites.include?(character_name)
    make_composite_lists
    r = {}
    @composite_images.each {|k, v| r[k] = [v, @composite_hues[k]]}
    return r
  end
  
  def make_composite_lists  ## Makes the list of composites and hues.
    @composite_images = {}
    @composite_hues = {}
    @composite_male = get_base_gender  ## Sets gender.
    if CP::COMPOSITE::SWITCHES.include?(@actor_id)  ## Sets a gender switch.
      $game_switches[CP::COMPOSITE::SWITCHES[@actor_id]] = @composite_male
    end
    block = @composite_male ? 0 : 1
    make_equip_hashes(block)  ## Ensures equips are set up.
    Composites.layers do |key|  ## Check each layer.
      @composite_hues[key] = 0  ## Gets init values for variables.
      name = nil
      string = key.to_s
      hueless = string.include?("Hueless")
      rear = string.include?("Rear")
      all = string.include?("All")
      string.gsub!(/(Hueless|All|Rear)/, '')
      edd = edd_additions(hueless, rear)
      line = CP::COMPOSITE::GUI_OPTIONS[string.to_sym]
      handler = get_composite_handler(key)
      parent = get_composite_handler(string.to_sym)
      hues = get_composite_hue(key)
      if all && !line.nil?  ## Determines the needed value.
        name = line[2]
      elsif handler && Composites.files.include?(handler) &&
            Composites.files[handler][block]
        name = "#{Composites.files[handler][block]}#{edd}"
      elsif parent && Composites.files.include?(parent) &&
            Composites.files[parent][block] && (rear || hueless)
        name = "#{Composites.files[parent][block]}#{edd}"
      elsif Composites.standard.include?(key)
        name = Composites.files[Composites.standard[key]][block]
      end
      next unless name  ## Skips if there is no name.
      @composite_images[key] = name  ## Creates the hashes.
      @composite_hues[key] = hueless ? 0 : hues
    end
  end
  
  def get_base_gender  ## Gets the gender.
    return @editor_changes[:Gender] if @editor_changes.include?(:Gender)
    return actor.gender_base
  end
  
  def get_composite_handler(key)  ## Complex method to find the file handler.
    block = @composite_male ? 0 : 1
    if @forced_composites.include?(key) && Composites.include_block?(block,
       @forced_composites[key][0])
      hues = @forced_composites[key][0]
    elsif @equip_hashes.include?(key) && Composites.include_block?(block,
       @equip_hashes[key][0])
      handler = @equip_hashes[key][0]
    elsif @editor_changes.include?(key) && Composites.include_block?(block,
          @editor_changes[key])
      handler = @editor_changes[key]
    elsif actor.composite_init.include?(key) && Composites.include_block?(block,
          actor.composite_init[key][0])
      handler = actor.composite_init[key][0]
    elsif Composites.get_first_handler(block, key)
      handler = Composites.get_first_handler(block, key)
    else
      handler = nil
    end
    return handler
  end
  
  def get_composite_hue(key)  ## Same as above but for hues.
    block = @composite_male ? 0 : 1
    if @forced_composites.include?(key) && Composites.include_block?(block,
       @forced_composites[key][0])
      hues = @forced_composites[key][1]
    elsif @equip_hashes.include?(key) && Composites.include_block?(block,
       @equip_hashes[key][0])
      hues = @equip_hashes[key][1]
    elsif @editor_changes.include?(key) && Composites.include_block?(block,
          @editor_changes[key])
      hues = @editor_hues[key]
    elsif actor.composite_init.include?(key) && Composites.include_block?(block,
          actor.composite_init[key][0])
      hues = actor.composite_init[key][1]
    else
      hues = 0
    end
    return hues
  end
  
  def make_equip_hashes(block)  ## Makes the handler hash for equips.
    @equip_hashes = {}
    equips.each do |eq|
      next unless eq
      eq.composite_hash.each do |key, array|
        next if Composites.files[array[0]][male? ? 0 : 1].nil?
        @equip_hashes[key] = array
      end
    end
  end
  
  alias cp_composite_change_eq change_equip
  def change_equip(*args)  ## Ensures refreshing on equip change.
    cp_composite_change_eq(*args)
    @composite_refresh = true
  end
  
  def change_composite(hand, value = nil, hue = nil)
    array = ["#{hand}".to_sym, "#{hand}Rear".to_sym, "#{hand}Hueless".to_sym,
             "#{hand}All".to_sym]
    array.each do |handler|  ## Changes values for a layer and sublayers.
      unless value.nil?
        @editor_changes[handler] = value
        @editor_hues[handler] = hue if hue
      else
        @editor_changes.delete(handler)
        @editor_hues.delete(handler)
      end
    end
    @composite_refresh = true
  end
  
  def force_composite(hand, value = nil, hue = nil)
    array = ["#{hand}".to_sym, "#{hand}Rear".to_sym, "#{hand}Hueless".to_sym,
             "#{hand}All".to_sym]
    array.each do |handler|  ## Changes values for a layer and sublayers.
      unless value.nil?
        @forced_composites[handler] = []
        @forced_composites[handler][0] = value
        @forced_composites[handler][1] = hue if hue
      else
        @forced_composites.delete(handler)
      end
    end
    @composite_refresh = true
  end
  
  def reset_composite
    @forced_composites = {}
    @composite_refresh = true
  end
  
  def reset_name  ## Changes the name to a default name.
    return if actor.alt_name.empty?
    @composite_male = get_base_gender
    if @composite_male == actor.gender_base
      @name = actor.name if @name == actor.alt_name
    else
      @name = actor.alt_name if @name == actor.name
    end
  end
  
  def male?  ## Check if the actor is male.
    return @composite_male
  end
end

class Window_SaveFile < Window_Base
  def draw_party_characters(x, y)  ## Creates a temp array for the save file.
    header = DataManager.load_header(@file_index)
    return unless header
    header[:characters].each_with_index do |data, i|
      Composites.make_temp_file(data[0], data[2])
      draw_character(data[0], data[1], x + i * 48, y)
    end
  end
end

class Game_Party < Game_Unit
  def characters_for_savefile  ## Adds the composite arrays to a save file.
    battle_members.collect do |actor|
      [actor.character_name, actor.character_index, actor.get_composite_lists]
    end
  end
end

class Scene_Load < Scene_File  ## Clears the composites on a load.
  alias cp_comp_load_succ on_load_success
  def on_load_success
    Composites.clear
    cp_comp_load_succ
  end
end

class Scene_Save < Scene_File  ## Clears the composites on save.
  alias cp_comp_save_ok on_savefile_ok
  def on_savefile_ok
    Composites.clear
    cp_comp_save_ok
  end
end

class Bitmap
  def draw_rainbow(*args)  ## Draws a rainbow rectangle.
    case args.size
    when 1
      rect = args[0].clone
    when 4
      rect = Rect.new(args[0], args[1], args[2], args[3])
    end
    ca = rainbow_colours
    6.times do |i|
      wv = rect.width / (6 - i)
      n = i == 5 ? 0 : 1
      r2 = Rect.new(rect.x, rect.y, wv + n, rect.height)
      self.gradient_fill_rect(r2, ca[i], ca[(i + 1) % 6])
      rect.width -= wv
      rect.x += wv
    end
  end
  
  def rainbow_colours  ## Colours for the rectangle.
    c1 = Color.new(255,   0,   0); c2 = Color.new(255, 255,   0)
    c3 = Color.new(  0, 255,   0); c4 = Color.new(  0, 255, 255)
    c5 = Color.new(  0,   0, 255); c6 = Color.new(255,   0, 255)
    return [c1, c2, c3, c4, c5, c6]
  end
  
  @@wheel = Bitmap.new(360, 1)
  @@wheel.draw_rainbow(0, 0, 360, 1)
  
  def self.hue_colour_wheel(hue)  ## Show the new hue colour.
    if @@wheel.disposed?
      @@wheel = Bitmap.new(360, 1)
      @@wheel.draw_rainbow(0, 0, 360, 1)
    end
    return @@wheel.get_pixel(hue % 360, 0)
  end
end

## The core bits of the script scene are below.
class Window_CCFace < Window_Base
  def initialize(actor, input)
    super(0, 0, 120, 120)
    self.visible = CP::COMPOSITE::USE_FACESETS
    @input_window = input
    self.y = @input_window.y
    self.x = @input_window.x - (self.width + 8)
    @actor = $data_actors[actor]
    refresh
  end
  
  def refresh
    contents.clear
    draw_face(@actor.face_name, @actor.face_index, 0, 0)
  end
end

class Window_CCCharacter < Window_Base
  def initialize(actor, input)
    super(0, 0, CP::COMPOSITE::WINDOW_WIDTH, CP::COMPOSITE::WINDOW_HEIGHT)
    @input_window = input
    self.y = @input_window.y
    self.x = @input_window.x + @input_window.width + 8
    @actor = $data_actors[actor]
    @ticker = 10
    @last_frame = 1
    @frame = 1
    refresh
  end
  
  def update
    @ticker += 1
    @frame = (@ticker % 40) / 10; @frame = 1 if @frame == 3
    return if @frame == @last_frame
    @last_frame = @frame
    refresh
  end
  
  def refresh
    contents.clear
    x = contents.width / 2
    y = contents.height - 6
    draw_character(@actor.character_name, @actor.character_index, x, y, @frame)
  end
  
  def draw_character(character_name, character_index, x, y, frame = 1)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+frame)*cw, (n/4*4)*ch, cw, ch)
    ret_rect = Rect.new(x - cw, y - cw * 2, cw * 2, ch * 2)
    contents.stretch_blt(ret_rect, bitmap, src_rect)
  end
end

class Window_CCGui < Window_Selectable
  def initialize(file, list)
    @list = list
    extra_width = CP::COMPOSITE::WINDOW_WIDTH + 8
    extra_width += 128 if CP::COMPOSITE::USE_FACESETS
    x = (Graphics.width - (180 + extra_width)) / 2
    x += 128 if CP::COMPOSITE::USE_FACESETS
    y = (Graphics.height - window_height) / 2
    h = window_height
    super(x, y, 180, h)
    @file = file
    refresh
  end
  
  def window_height
    [fitting_height(item_max * 2), Graphics.height].min
  end
  
  def item_max
    @list.size + 1
  end
  
  def contents_height
    (item_max * 2) * line_height
  end
  
  def item_height
    line_height * 2
  end
  
  def refresh
    contents.clear
    draw_all_items
  end
  
  def data
    @list[@index]
  end
  
  def adj_data
    if Composites.options[data][0].is_a?(Symbol)
      return Composites.options[data][0]
    else
      return data
    end
  end
  
  def draw_item(index)
    rect = item_rect(index)
    lh = line_height
    if index == @list.size
      text = CP::COMPOSITE::GUI_CLOSE
      change_color(normal_color)
      draw_text(rect.x + 2, rect.y + lh / 2, rect.width - 4, lh, text, 1)
    else
      block = Composites.options[@list[index]]
      if block[0].is_a?(Symbol)
        title = Composites.options[block[0]][0]
      else
        title = block[0]
      end
      value = (CP::COMPOSITE::COMPOSITE.include?(@list[index]) ||
              @list[index] == :Gender || @list[index] == :Name)
      sym = value ? @list[index] : block[0]
      change_color(system_color)
      draw_text(rect.x + 2, rect.y, rect.width - 4, lh, title)
      case sym
      when :Gender
        na = CP::COMPOSITE::GENDER_NAMES
        name = Composites.actor(@file).male? ? na[0] : na[1]
      when :Name
        name = Composites.actor(@file).name
      else
        name = Composites.actor(@file).get_composite_handler(sym)
        name = CP::COMPOSITE::EMPTY_TEXT if name.nil?
        hue = Composites.actor(@file).get_composite_hue(sym)
        if block[1]
          c1 = Bitmap.hue_colour_wheel(hue)
          c2 = Color.new(c1.red, c1.green, c1.blue, 0)
          r2 = contents.text_size(name).width
          hr = Rect.new(contents.width - (r2 + 6), rect.y + lh + 3, r2 + 1, lh - 6)
          contents.gradient_fill_rect(hr, c2, c1)
        end
      end
      change_color(normal_color)
      draw_text(rect.x + 2, rect.y + lh, rect.width - 6, lh, name, 2)
    end
  end
end

class Window_CCSelect < Window_Selectable
  attr_reader :hue
  
  def initialize(file, input)
    super(0, 0, 160, 0)
    @input_window = input
    @file = file
    @data = nil
    @hue = 0
  end
  
  def item_max
    return 1 if @data.nil? || @data.empty?
    return @data.size
  end
  
  def refresh
    contents.clear
    draw_all_items
    draw_hue_wheel
  end
  
  def draw_item(index)
    rect = item_rect(index); rect.x += 2; rect.width -= 4
    change_color(normal_color)
    draw_text(rect, @data[index])
  end
  
  def draw_hue_wheel
    rect = item_rect(item_max); contents.clear_rect(rect)
    rect.y += 4; rect.height -= 8; rect.x += 8; rect.width -= 16
    ind = Composites.options[@input_window.data]
    return if !ind || ind[1] == 0
    if ind[1] == 2
      value = @hue >= 180 ? @hue - 360 : @hue
      rect.height /= 2; rect.height -= 1; rect.x -= 60
      contents.draw_rainbow(rect)
      rect.y += (rect.height + 1); rect.x -= value / 3
      contents.draw_rainbow(rect)
      rect.x += 119
      contents.draw_rainbow(rect)
      rect.y -= (rect.height + 1); rect.x += value / 3
      contents.draw_rainbow(rect)
      bitmap2 = Bitmap.new(10, 19)
      bitmap2.fill_rect(0, 0, 10, 19, Color.new(255, 255, 255))
      c1 = Bitmap.hue_colour_wheel(0)
      c2 = Bitmap.hue_colour_wheel(@hue)
      bitmap2.gradient_fill_rect(1, 1, 8, 17, c1, c2, true)
      rect = item_rect(item_max)
      contents.blt((rect.width - 10) / 2, rect.y + 2, bitmap2, bitmap2.rect)
      rect.width = 10
      contents.clear_rect(rect)
      rect.x = contents.width - rect.width
      contents.clear_rect(rect)
    elsif ind[1] == 1
      contents.draw_rainbow(rect)
      bitmap2 = Bitmap.new(7, 20)
      bitmap2.fill_rect(0, 0, 7, 20, Color.new(255, 255, 255))
      bitmap2.fill_rect(1, 2, 5, 16, Bitmap.hue_colour_wheel(@hue))
      off = @hue / 3
      contents.blt(rect.x - 3 + off, rect.y - 2, bitmap2, bitmap2.rect)
    end
  end
  
  def show
    val = @input_window.adj_data
    ind = @input_window.data
    actor = Composites.actor(@file)
    block = Composites.actor(@file).male? ? 0 : 1
    @name = Composites.list_by_block(ind, block).index(actor.get_composite_handler(val))
    @index = val != :Gender ? @name : Composites.actor(@file).male? ? 0 : 1
    @index = 0 if @index.nil?
    @hue = actor.get_composite_hue(val) unless val == :Gender
    cont = Composites.options[ind]
    if val == :Gender
      @data = CP::COMPOSITE::GENDER_NAMES
    else
      @data = Composites.list_by_block(ind, block)
    end
    add = Composites.options[ind][1] ? 1 : 0
    add = 0 if val == :Gender
    self.height = fitting_height(@data.size + add)
    create_contents
    refresh
    self.x = @input_window.x + 16
    iw = @input_window
    self.y = iw.y + iw.standard_padding + (iw.index * (iw.line_height * 2)) - iw.oy + 28
    self.y = Graphics.height - self.height if y + height > Graphics.height
    super
    activate
  end
  
  def cursor_right(wrap)
    return if Composites.options.include?(@input_window.data) &&
              !Composites.options[@input_window.data][1]
    @hue /= 12; @hue *= 12
    @hue += 12; @hue -= 360 if @hue >= 360
    draw_hue_wheel
  end
  
  def cursor_left(wrap)
    return if Composites.options.include?(@input_window.data) &&
              !Composites.options[@input_window.data][1]
    @hue /= 12; @hue *= 12
    @hue -= 12; @hue += 360 if @hue < 0
    draw_hue_wheel
  end
end

class Game_Interpreter
  def creation(char, list = nil)  ## Allows for easy calling of the scene.
    return if $game_party.in_battle
    if char.is_a?(Integer)
      return unless CP::COMPOSITE::NAMES.has_value?(char)
      char = CP::COMPOSITE::NAMES.index(char)
    else
      return unless Composites.include?(char)
    end
    list = CP::COMPOSITE::BASE_GUI if list.nil?
    return unless list.is_a?(Array)
    SceneManager.call(Scene_CharacterCreation)
    SceneManager.scene.prepare(char, list)
    Fiber.yield
  end
  
  def composite_force(char, handler, name, hue = 0)
    if char.is_a?(Integer)
      return unless CP::COMPOSITE::NAMES.has_value?(char)
    else
      return unless Composites.include?(char)
      char = CP::COMPOSITE::NAMES[char]
    end
    $game_actors[char].force_composite(handler, name, hue)
  end
  
  def composite_custom(char, handler, name, hue = 0)
    if char.is_a?(Integer)
      return unless CP::COMPOSITE::NAMES.has_value?(char)
    else
      return unless Composites.include?(char)
      char = CP::COMPOSITE::NAMES[char]
    end
    $game_actors[char].change_composite(handler, name, hue)
  end
  
  def composite_reset(char)
    if char.is_a?(Integer)
      return unless CP::COMPOSITE::NAMES.has_value?(char)
    else
      return unless Composites.include?(char)
      char = CP::COMPOSITE::NAMES[char]
    end
    $game_actors[char].reset_composite
  end
end

class Scene_CharacterCreation < Scene_MenuBase
  def prepare(file, list)
    @file = file
    @list = list
  end
  
  def start
    super
    @actor = Composites.actor(@file)
    create_windows
  end
  
  def create_windows
    @input_window = Window_CCGui.new(@file, @list)
    @input_window.set_handler(:ok,      method(:gui_ok))
    @input_window.set_handler(:cancel,  method(:gui_cancel))
    @select_window = Window_CCSelect.new(@file, @input_window)
    @select_window.set_handler(:ok,     method(:select_ok))
    @select_window.set_handler(:cancel, method(:select_cancel))
    @chara_window = Window_CCCharacter.new(@actor.id, @input_window)
    @face_window = Window_CCFace.new(@actor.id, @input_window)
    @input_window.activate.select(0)
    @select_window.hide
  end
  
  def gui_ok
    val = @input_window.data
    if val == :Name
      SceneManager.call(Scene_Name)
      SceneManager.scene.prepare(Composites.actor(@file).id, CP::COMPOSITE::CHARACTERS)
      @input_window.refresh
    elsif val == nil
      return_scene
    else
      @select_window.show
    end
  end
  
  def gui_cancel
    @input_window.activate.select(@input_window.item_max - 1)
  end
  
  def select_ok
    val = @input_window.data
    adj = @input_window.adj_data
    id = @select_window.index
    if adj == :Gender
      if id == 0
        Composites.actor(@file).change_composite(:Gender, true)
        Composites.actor(@file).reset_name
      elsif id == 1
        Composites.actor(@file).change_composite(:Gender, false)
        Composites.actor(@file).reset_name
      end
    else
      block = Composites.actor(@file).male? ? 0 : 1
      handler = Composites.list_by_block(val, block)[@select_window.index]
      hue = @select_window.hue
      Composites.actor(@file).change_composite(adj, handler, hue)
    end
    @select_window.hide
    @chara_window.refresh
    @face_window.refresh
    @input_window.activate.refresh
  end
  
  def select_cancel
    @select_window.hide
    @input_window.activate
  end
end

class RPG::BaseItem
  def composite_hash
    add_composite_data if @composite_hash.nil?
    return @composite_hash
  end
  
  def composite_init
    add_composite_data if @composite_init.nil?
    return @composite_init
  end
  
  def gender_base
    add_composite_data if @gender_base.nil?
    return @gender_base
  end
  
  def alt_name
    add_composite_data if @alt_name.nil?
    return @alt_name
  end
  
  INITI_RE = /(.+) init\[(.+)[,]\s*(\d+)\]/i
  IMAGE_RE = /(.+) image\[(.+)[,]\s*(\d+)\]/i
  GENDER_RE = /gender\[(male|female)\]/i
  ALT_NAME = /alt name\[(.+)\]/i
  
  def add_composite_data
    @gender_base = CP::COMPOSITE::MALE_DEFAULT
    @composite_hash = {}; @composite_init = {}; @alt_name = ""
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when INITI_RE
        @composite_init[$1.to_sym] = [$2.to_s, $3.to_i]
        @composite_init["#{$1.to_s}Rear".to_sym] = [$2.to_s, $3.to_i]
        @composite_init["#{$1.to_s}Hueless".to_sym] = [$2.to_s, 0]
        @composite_init["#{$1.to_s}All".to_sym] = [$2.to_s, $3.to_i]
      when IMAGE_RE
        @composite_hash[$1.to_sym] = [$2.to_s, $3.to_i]
        @composite_hash["#{$1.to_s}Rear".to_sym] = [$2.to_s, $3.to_i]
        @composite_hash["#{$1.to_s}Hueless".to_sym] = [$2.to_s, 0]
        @composite_hash["#{$1.to_s}All".to_sym] = [$2.to_s, $3.to_i]
      when GENDER_RE
        @gender_base = true if $1.to_s.downcase == "male"
        @gender_base = false if $1.to_s.downcase == "female"
      when ALT_NAME
        @alt_name = $1.to_s
      end
    end
  end
end

###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###
# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Rename Anything                                       │ v1.1 │ (7/31/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Mithran, regexp magician
#     YF, code reference
#     Tsukihime, save data correction
#--------------------------------------------------------------------------
# This script allows players to rename game objects in the database from 
# within a game.
#
# Why would you want to do that? I don't know, but now you can.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.1 : Any renames are now properly saved and loaded from save files.
#      : Actors are no longer renamable with this script (7/31/2012)
# v1.0 : Initial release. (7/31/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox.
#       Use common sense.
#
# The following Notetag is for Classes, Skills, Items, Weapons, Armors, 
# Enemies, and States:
#
# <rename image: filename>
#   This tag allows you to assign an image from the Graphics/Pictures/
#   folder to represent the object in the renaming scene where filename
#   is the name of the image without the extension. The recommended
#   image resolution is [width: 96, height: 96]. If you have YEA Shop
#   Options also installed in the same project, this script will use the
#   image defined with the <image: filename> tag for any objects that
#   have it.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Script Calls are meant to be used in "Script..." event 
# commands found under Tab 3 when creating a new event.
#
# rename_object( :class,   id,  max_char)
# rename_object( :skill,   id,  max_char)
# rename_object( :item,    id,  max_char)
# rename_object( :weapon,  id,  max_char)
# rename_object( :armor,   id,  max_char)
# rename_object( :enemy,   id,  max_char)
# rename_object( :state,   id,  max_char)
#   This script call opens up the rename anything scene with the object
#   that you want to rename. The first argument is the type of object
#   it is. The second argument is the ID number of the object found
#   in your database. The third argument is the maximum limit of
#   characters the player is allowed to name the object. If the object
#   does not exist, this script call will do nothing.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#   DataManager#make_save_contents
#   DataManager#extract_save_contents
#
# There are no default method overwrites.
#
# This script has built-in compatibility with the following scripts:
#
#   -Yanfly Engine Ace - Shop Options
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported ||= {}
$imported["BubsRenameAnything"]


#==========================================================================
# ++ This script contains no customization module ++
#==========================================================================



#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    RENAME_IMAGE_TAG = /<RENAME[_\s]?IMAGE:\s*(\w+)>/i
  end # module Regexp
end # module Bubs

#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :renaming_image
  #--------------------------------------------------------------------------
  # common cache : rename_image
  #--------------------------------------------------------------------------
  def rename_image
    @renaming_image ||= note =~ Bubs::Regexp::RENAME_IMAGE_TAG ? $1 : false
  end

end # class RPG::BaseItem


#==============================================================================
# ++ DataManager
#==============================================================================
module DataManager
  #--------------------------------------------------------------------------
  # make_save_contents
  #--------------------------------------------------------------------------
  class << self; alias make_save_contents_bubs_rename make_save_contents; end
  def self.make_save_contents
    contents = make_save_contents_bubs_rename
    contents[:renameanything] = save_rename_data
    contents
  end
  
  #--------------------------------------------------------------------------
  # extract_save_contents
  #--------------------------------------------------------------------------
  class << self; alias extract_save_contents_bubs_rename extract_save_contents; end
  def self.extract_save_contents(contents)
    extract_save_contents_bubs_rename(contents)
    load_rename_data(contents[:renameanything])
  end
  
  #--------------------------------------------------------------------------
  # save_rename_data
  #--------------------------------------------------------------------------
  def self.save_rename_data
    keys = [:classes, :skills, :items, :weapons, :armors, 
      :enemies, :states]
    groups = [$data_classes, $data_skills, $data_items, $data_weapons, 
      $data_armors, $data_enemies, $data_states]
    hash = {}
    for key, group in keys.zip(groups)
      hash[key] = {}
      for obj in group
        next if obj.nil?
        hash[key][obj.id] = obj.name
      end # for obj
    end # for group
    return hash
  end # def
  
  #--------------------------------------------------------------------------
  # load_rename_data
  #--------------------------------------------------------------------------
  def self.load_rename_data(data)
    keys = [:classes, :skills, :items, :weapons, :armors, 
      :enemies, :states]
    groups = [$data_classes, $data_skills, $data_items, $data_weapons, 
      $data_armors, $data_enemies, $data_states]
    for key, group in keys.zip(groups)
      for obj in group
        next if obj.nil?
        obj.name = data[key][obj.id]
      end # for obj
    end # for group
  end # def
  
end # module DataManager


#==============================================================================
# ++ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # rename_object
  #--------------------------------------------------------------------------
  def rename_object(symbol, id, max_char = 20)
    return if $game_party.in_battle
    case symbol
    when :actor
      obj = nil
    when :skill 
      obj = $data_skills[id]
    when :item 
      obj = $data_items[id]
    when :armor, :armour
      obj = $data_armors[id]
    when :weapon
      obj = $data_weapons[id]
    when :state
      obj = $data_states[id]
    when :enemy
      obj = $data_enemies[id]
    when :class
      obj = $data_classes[id]
    when :skilltype, :weapontype, :armortype, :element, :currency
      obj = nil
    end
    if obj
      SceneManager.call(Scene_RenameAnything)
      SceneManager.scene.prepare(obj, max_char, symbol)
      Fiber.yield
    end
  end
end # class Game_Interpreter


#==============================================================================
# ++ Window_RenameAnythingEdit
#==============================================================================
class Window_RenameAnythingEdit < Window_Base
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :name                     # name
  attr_reader   :index                    # cursor position
  attr_reader   :max_char                 # maximum number of characters
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(obj, max_char, symbol)
    x = (Graphics.width - 360) / 2
    y = (Graphics.height - (fitting_height(4) + fitting_height(9) + 8)) / 2
    super(x, y, 360, fitting_height(4))
    @obj = obj
    @type = symbol
    @max_char = max_char
    @default_name = @name = obj.name[0, @max_char]
    @index = @name.size
    deactivate
    refresh
  end
  
  #--------------------------------------------------------------------------
  # restore_default
  #--------------------------------------------------------------------------
  def restore_default
    @name = @default_name
    @index = @name.size
    refresh
    return !@name.empty?
  end
  
  #--------------------------------------------------------------------------
  # add
  #   ch : character to add
  #--------------------------------------------------------------------------
  def add(ch)
    return false if @index >= @max_char
    @name += ch
    @index += 1
    refresh
    return true
  end
  
  #--------------------------------------------------------------------------
  # back
  #--------------------------------------------------------------------------
  def back
    return false if @index == 0
    @index -= 1
    @name = @name[0, @index]
    refresh
    return true
  end
  
  #--------------------------------------------------------------------------
  # face_width
  #--------------------------------------------------------------------------
  def face_width
    return 96
  end
  
  #--------------------------------------------------------------------------
  # char_width
  #--------------------------------------------------------------------------
  def char_width
    text_size($game_system.japanese? ? "あ" : "A").width 
  end
  
  #--------------------------------------------------------------------------
  # left
  #--------------------------------------------------------------------------
  def left
    name_center = (contents_width + face_width) / 2
    name_width = (@max_char + 1) * char_width
    return [name_center - name_width / 2, contents_width - name_width].min
  end
  
  #--------------------------------------------------------------------------
  # item_rect
  #--------------------------------------------------------------------------
  def item_rect(index)
    Rect.new(left + index * char_width, 36, char_width, line_height)
  end
  
  #--------------------------------------------------------------------------
  # underline_rect
  #--------------------------------------------------------------------------
  def underline_rect(index)
    rect = item_rect(index)
    rect.x += 1
    rect.y += rect.height - 4
    rect.width -= 2
    rect.height = 2
    rect
  end
  
  #--------------------------------------------------------------------------
  # underline_color
  #--------------------------------------------------------------------------
  def underline_color
    color = normal_color
    color.alpha = 48
    color
  end
  
  #--------------------------------------------------------------------------
  # draw_underline
  #--------------------------------------------------------------------------
  def draw_underline(index)
    contents.fill_rect(underline_rect(index), underline_color)
  end
  
  #--------------------------------------------------------------------------
  # draw_char
  #--------------------------------------------------------------------------
  def draw_char(index)
    rect = item_rect(index)
    rect.x -= 1
    rect.width += 4
    change_color(normal_color)
    draw_text(rect, @name[index] || "")
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_obj_image(0, 0)
    @max_char.times {|i| draw_underline(i) }
    @name.size.times {|i| draw_char(i) }
    cursor_rect.set(item_rect(@index))
  end
  
  #--------------------------------------------------------------------------
  # draw_obj_image
  #--------------------------------------------------------------------------
  def draw_obj_image(x, y)
    case @type
    when :skill, :item, :armor, :weapon, :state, :armour
      draw_item_image
    when :enemy
      draw_enemy_image
    when :class
      draw_class_image
    when :skilltype, :weapontype, :armortype, :element, :currency
      
    end
  end
    
  #--------------------------------------------------------------------------
  # draw_item_image               # Referenced from YF
  #--------------------------------------------------------------------------
  def draw_item_image
    draw_bg_gradient
    if @obj.rename_image
      draw_rename_image
    elsif $imported["YEA-ShopOptions"] && @obj.image
      draw_shop_options_image
    else
      icon_index = @obj.icon_index
      bitmap = Cache.system("Iconset")
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      target = Rect.new(0, 0, 96, 96)
      contents.stretch_blt(target, bitmap, rect)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_enemy_image
  #--------------------------------------------------------------------------
  def draw_enemy_image
    draw_bg_gradient
    if @obj.rename_image
      draw_rename_image
    elsif $imported["YEA-ShopOptions"] && @obj.image
      draw_shop_options_image
    else
      bitmap = Cache.battler(@obj.battler_name, @obj.battler_hue)
      target = Rect.new(0, 0, 96, 96)
      contents.stretch_blt(target, bitmap, bitmap.rect)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_class_image
  #--------------------------------------------------------------------------
  def draw_class_image
    if @obj.rename_image
      draw_rename_image 
    elsif $imported["YEA-ShopOptions"] && @obj.image
      draw_shop_options_image
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_bg_gradient
  #--------------------------------------------------------------------------
  def draw_bg_gradient
    color = Color.new(0, 0, 0, translucent_alpha / 2)
    rect = Rect.new(1, 1, 94, 94)
    contents.fill_rect(rect, color)
  end
  
  #--------------------------------------------------------------------------
  # draw_rename_image
  #--------------------------------------------------------------------------
  def draw_rename_image
    bitmap = Cache.picture(@obj.rename_image)
    contents.blt(0, 0, bitmap, bitmap.rect, 255)
  end
  
  #--------------------------------------------------------------------------
  # draw_shop_options_image
  #--------------------------------------------------------------------------
  def draw_shop_options_image
    return unless $imported["YEA-ShopOptions"]
    bitmap = Cache.picture(@obj.image)
    contents.blt(0, 0, bitmap, bitmap.rect, 255)
  end
  
end # class Window_RenameAnythingEdit


#==============================================================================
# ++ Scene_RenameAnything
#==============================================================================
class Scene_RenameAnything < Scene_MenuBase
  #--------------------------------------------------------------------------
  # prepare
  #--------------------------------------------------------------------------
  def prepare(obj, max_char, symbol)
    @obj = obj
    @max_char = max_char
    @symbol = symbol
  end
  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    super
    @edit_window = Window_RenameAnythingEdit.new(@obj, @max_char, @symbol)
    @input_window = Window_NameInput.new(@edit_window)
    @input_window.set_handler(:ok, method(:on_input_ok))
  end
  #--------------------------------------------------------------------------
  # on_input_ok
  #--------------------------------------------------------------------------
  def on_input_ok
    @obj.name = @edit_window.name
    return_scene
  end
end # class Scene_RenameAnything
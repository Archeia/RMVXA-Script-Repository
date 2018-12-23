# ╔══════════════════════════════════════════════════════╤═══════╤═══════════╗
# ║ Tactics Ogre PSP Crafting System                     │ v2.04 │ (5/18/13) ║
# ╚══════════════════════════════════════════════════════╧═══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Mithran, regexp references
#     estriole, assistance with scene interpreter
#--------------------------------------------------------------------------
# This item crafting script is modeled after the crafting system implemented
# in the PSP remake of Tactics Ogre: Let Us Cling Together. It's a very
# simple crafting system with a very simple GUI which I also used as
# a model.
#
# Players must have recipe books in their inventory when entering the
# crafting scene. Any recipe books owned by the player will be displayed 
# in a list. When a recipe book is selected, all possible items, armors,
# and weapons in the recipe book will be listed and you will be able to
# craft them provided that the player has the necessary ingredients.
#
# The script "Info Pages Window" is required.
#
# Feel free to reguest custom information to be added to item info pages
# in the crafting scene.
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v2.04 : Italian language support added.
#       : Shifted some code. (5/18/2013)
# v2.03 : Compatibility Update: "TH_SceneInterpreter"
#       : Bugfix: Fixed bug where selecting the number to craft
#       : ignores the amount of ingredients available. (5/11/2013)
# v2.02 : Bugfix: Fixed categories nil error.
# v2.01 : Bugfix: Fixed ingredient numbers in info window.
#       : New tag: <craft result>. See comments for more info.
#       : You can now run a common event after crafting an item.
#       : You can now change how many of an item you gain per 
#       : set of ingredients. (5/02/2013)
# v2.00 : Now requires script: "Info Pages Window".
#       : This script will now check if any required scripts are
#       : missing. If any are missing, the game will be exited.
#       : Many crafting customization options related to the info
#       : pages window have been removed.
#       : Changed version number format.
#       : $imported variable now uses version number.
#       : Changed some methods, add-ons/patches may not work anymore.
#       : Removed about 700+ lines of code. (5/02/2013)
# v1.14 : Calling the crafting scene directly with SceneManager will 
#       : no longer crash the game. (4/28/2013)
# v1.13 : Bugfix: Custom craft result sound effects should no longer 
#       : crash the game.
#       : Equippable members info page added. 
#       : Cleaned up some code. (3/26/13)
# v1.12 : Quick compatibility update with Tsukihime's TO Crafting Shop
#       : script. (3/13/13)
# v1.11 : You can now require specific actors in the party as a crafting 
#       : requirement.
#       : New ingredient notetag added.
#       : New options in the customization module added.
#       : Slight code efficiency update. (2/06/2013)
# v1.10 : TP Recovery now displays the correct value.
#       : Recipebook images are now centered by default. (9/04/2012)
# v1.09 : State resistance item info is now viewable.
#       : Footer text is now properly aligned. (8/28/2012)
# v1.08 : Compatibility: "YEA-AceMenuEngine" support added.
#       : You can now view item details in the crafting scene if the
#       : script "Reader Functions for Features/Effects" is installed.
#       : Info window style has changed.
#       : Any amount of ingredients can now be displayed, not just 6.
#       : Configuration module has many new settings.
#       : Some method names have changed.
#       : Removed a chunk of redundant code.
#       : Efficiency update. (8/25/2012)
# v1.07 : Fixed issue where you can still craft from a recipebook even if
#       : you have zero left as a result of using it in a crafting recipe.
#       : Script call for the crafting scene has changed. The old one can
#       : still be used though.
#       : New Notetag for recipebooks added.
#       : You can now choose which recipebooks can be included in the
#       : crafting scene by category. 
#       : Efficiency update. (8/18/2012)
# v1.06 : Compatibility: "XAS VX Ace" support added. (8/08/2012)
# v1.05 : You can now change the recipebook pictures directory.
#       : You can now assign sound effects for crafted items.
#       : Slight code efficiency update. (7/29/2012)
# v1.04 : Added the option to use images as recipebook covers.
#       : New Notetag for recipebooks added. 
#       : New option in customization module for book images. (7/27/2012)
# v1.03 : Colon between type and ID no longer needed.
#       : Updated comments to reflect changes.
#       : Tool regexp updated. (7/27/2012)
# v1.02 : You can now change the Gold icon in the customization module.
#       : You can now change the name of Gold in windows. (7/27/2012)
# v1.01 : Fixed issue with long item names getting cut off in windows.
#       : Confirm window removed. 
#       : Quantity selection window implemented.
#       : Crafting Gold fee implemented.
#       : Crafting tool requirement implemented.
#       : New options added in customization module. (7/26/2012)
# v1.00 : Initial release. (7/25/2012)
#--------------------------------------------------------------------------
#      Installation & Requirements
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor BELOW the script "Info Pages Window".
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#      Notetags   
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetags are for Items, Weapons, and Armors only:
#
# <recipebook>
# setting
# setting
# </recipebook>
#   This tag allows you define a recipe book. You can add as many 
#   settings between the <recipebook> tags as you like. Only items with 
#   this tag will appear in the recipes window in the crafting scene. 
#   The following settings are available:
#
#     item: id
#     item: id, id, id ...
#     i: id
#     i: id, id, id ...
#       This setting defines the items that can be crafted from the 
#       recipe book where id is the Item ID number found in your database. 
#       You can list multiple id numbers on the same line separated by commas. 
#       This setting can be used multiple times within the <recipebook> tags.
#
#     weapon: id
#     weapon: id, id, id ...
#     w: id
#     w: id, id, id ...
#       This setting defines the weapons that can be crafted from the 
#       recipe book where id is the Weapon ID number found in your database. 
#       You can list multiple id numbers on the same line separated by commas. 
#       This setting can be used multiple times within the <recipebook> tags.
#       
#     armor: id
#     armor: id, id, id ...
#     armour: id
#     armour: id, id, id ...
#     a: id
#     a: id, id, id ...
#       This setting defines the armors that can be crafted from the 
#       recipe book where id is the Armor ID number found in your database. 
#       You can list multiple id numbers on the same line separated by commas. 
#       This setting can be used multiple times within the <recipebook> tags.
#
#     picture: filename
#     pic: filename
#     cover: filename
#       This setting defines the image used to represent the recipe book
#       in the crafting scene where filename is the name of a picture
#       located in the Graphics/Pictures/ folder of your project. Do
#       not include the filename's extension. Recommended picture 
#       resolutions are [width: 248, height: 320] for default resolutions 
#       and [width: 296, height: 384] for 480x640 resolutions.
#
#     category: name
#       This setting defines the recipebook's category label. Category
#       labels are used by developers to determine which recipebooks
#       they want included in the crafting scene. If a category label is
#       not defined, the default category is "none". This is a completely
#       optional setting.
#   
# <ingredients>
# setting
# setting
# </ingredients>
#   This tag allows you define the ingredients required to craft an item. 
#   You can add as many settings between the <ingredients> tags as you like.
#   If an item, weapon, or armor has no ingredients, you can still craft it.
#   The following settings are available:
#
#     item: id
#     item: id xN
#     i: id
#     i: id xN
#       This setting defines the item ingredients required to craft the
#       item, weapon, or armor where id is the Item ID number found in 
#       your database. xN is total number of that ingredient required if
#       it is included after the id number where N is a whole number 
#       (ex. x2, x3, x4, etc.). If xN is not included, the script will
#       automatically assume x1. You can list multiple id numbers on the 
#       same line separated by commas. This setting can be used multiple 
#       times within the <ingredients> tags.
#
#     weapon: id
#     weapon: id xN
#     w: id
#     w: id xN
#       This setting defines the weapon ingredients required to craft the
#       item, weapon, or armor where id is the Weapon ID number found in 
#       your database. xN is total number of that ingredient required if
#       it is included after the id number where N is a whole number 
#       (ex. x2, x3, x4, etc.). If xN is not included, the script will
#       automatically assume x1. You can list multiple id numbers on the 
#       same line separated by commas. This setting can be used multiple 
#       times within the <ingredients> tags.
#
#     armor: id
#     armor: id xN
#     armour: id
#     armour: id xN
#     a: id
#     a: id xN
#       This setting defines the armor ingredients required to craft the
#       item, weapon, or armor where id is the Weapon ID number found in 
#       your database. xN is total number of that ingredient required if
#       it is included after the id number where N is a whole number 
#       (ex. x2, x3, x4, etc.). If xN is not included, the script will
#       automatically assume x1. You can list multiple id numbers on the 
#       same line separated by commas. This setting can be used multiple 
#       times within the <ingredients> tags.
#
#     gold: amount
#       This setting defines the amount of Gold required to craft
#       the item, armor, or weapon where amount is any amount of gold. 
#       If this setting is omitted, it will use the default fee defined 
#       in the customization module.
#
#     tool: item id
#     tool: i id
#     tool: weapon id
#     tool: w id
#     tool: armor id
#     tool: armour id
#     tool: a id
#       This setting defines the tools required to craft the item, weapon, 
#       or armor where id is the item, weapon, or armor ID number found in 
#       your database. Tools are not consumed in the crafting process. 
#       This setting can be used multiple times within the <ingredients> 
#       tags.
#
#     actor: actor_id
#       This setting defines the actor required to craft the item, weapon,
#       or armor where actor_id is the actor ID number from your database.
#       Currently, nothing happens to the actor after crafting an item
#       that requires one. This setting can be used multiple times within
#       the <ingredients> tags.
#
# <craft result>
# setting
# setting
# </craft result>
#   This tag allows you to define what happens after an item is 
#   crafted. You can add as many settings between the <craft result> 
#   tags as you like.
#   The following settings are available:
#
#     se: filename, volume, pitch
#       This setting defines the custom sound effect played when the
#       item is crafted. filename is a sound effect filename found in
#       the Audio/SE/ folder. volume is a value between 0~100. pitch is 
#       a value between 50~150. If this setting is omitted, the default
#       crafting sound effect defined in the customization module will
#       play instead.
#
#     amount: n
#       This setting defines the amount that is produced from one
#       set of ingredients, where n is a number. By default, the
#       amount produced from one set of ingredients is 1.
#
#     common_event: id
#     cev: id
#       This setting defines a common event that runs right after an
#       item is crafted where id is a common event ID number
#       from your database.
#
# Here are some examples of proper <recipebook> tags and <ingredients> tags:
#
#     <recipebook>
#     weapon: 1, 2, 7, 8, 13, 14, 19, 20
#     weapon: 25, 37, 38
#     armor: 1, 2, 3, 4, 5
#     item: 40
#     </recipebook>
#
# It is important to know that Note boxes have iffy word wrap distinction. 
# If a line is too long and overflows into the next line, that next line 
# might be treated as a new line in the Note box. To stay on the safe side, 
# if you have a long list of ids for a single item type setting, you 
# should start the next line with the similar type setting. See the 
# "weapon:" settings in this example tag.
#
#     <ingredients>
#     item: 29 x3
#     item: 30 x2
#     item: 31
#     </ingredients>
#
# Each ingredient id must be on its own line, unlike the recipebook tag. 
# More than 6 ingredients are possible, but the Required Ingredients
# window will not display more than 6. The last setting tag "item: 31" does
# not have an "xN" multiplier which means the script will automatically
# assume "x1".
#
#     <ingredients>
#     fee: 30
#     se: Bell3, 80, 100
#     tool: item 40
#     item: 21
#     item: 22 x2
#     </ingredients>
#
# This tag is an example of how to use the "fee" and "tool" setting tags.
# Item ID 40 is required to craft the item, but it will not be consumed.
# Each item crafted costs 30 gold. The sound effect Bell3 will play
# when the item is crafted.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#      Script Calls   
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Script Calls are meant to be used in "Script..." event 
# commands found under Tab 3 when creating a new event.
#
# call_tocrafting_scene
#   This script call opens up a Tactics Ogre Crafting scene with all 
#   recipebooks the player has in their inventory.
#
# call_tocrafting_scene( :category, :category, ...)
#   This script call opens up the Tactics Ogre Crafting scene with 
#   only recipebooks that have the category included in one of the
#   script call's arguments. You can list as many categories in the 
#   script call's arguments separated by commas as you like. Category
#   names must always be preceeded by a colon (:).
#
# Here is an example of a script call using call_tocrafting_scene with
# category arguments:
#
#   call_tocrafting_scene( :smithing )
#   
# This script call will open up the crafting scene with only recipebooks
# that have the category of "smithing".
#
#--------------------------------------------------------------------------
#      FAQ   
#--------------------------------------------------------------------------
# --Why am I allowed to craft items that have no required ingredients?
#
#     This was done on purpose to ease game development. I assumed that
#     when people finalize a game, they will have an appropriate list of
#     ingredients for each craftable item defined by then.
#
# --Can an item/armor/weapon have a <recipebook> tag AND an <ingredients> 
#   tag?
#   
#     Yes.
#
# --Why isn't "Success Rate" also implemented in this script from 
#   Tactics Ogre PSP?
#
#     Because I think Success Rate on crafting in single-player games
#     is annoying and pointless due to save and load. But if there is
#     demand for it, I can implement it.
#--------------------------------------------------------------------------
#      Compatibility   
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     DataManager#load_database
#    
# There are no default method overwrites.
#
# This script has built-in compatibility with the following scripts:
#
#     -Xiderwong Action System (XAS) VX Ace
#     -Yanfly Engine Ace - Ace Menu Engine by YF
#     -Scene Interpreter by Tsukihime
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["BubsTOCrafting"] = 2.04

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ TO Crafting Settings
  #==========================================================================
  module TOCrafting
  #--------------------------------------------------------------------------
  #   Ingredients List Display Settings
  #--------------------------------------------------------------------------
  INGREDIENTS_HEADER_TEXT = "Ingredients" # Header text
  INGREDIENTS_PAGE_SIZE = 5 # 6 is recommended for 640x480 resolutions
  NOT_ENOUGH_INGREDIENTS_COLOR = 10 # Windowskin color index, default 10 (red)

  #--------------------------------------------------------------------------
  #   Ingredients Info Page Footer Text
  #--------------------------------------------------------------------------
  # Recommended length: 22 characters "                      "
  INGREDIENTS_VIEW_MORE_FOOTER_TEXT = "←A  Shift: More...  S→"

  #--------------------------------------------------------------------------
  #   Tools Display Settings
  #--------------------------------------------------------------------------
  TOOL_AVAILABLE_TEXT = "Available"
  TOOL_AVAILABLE_TEXT_COLOR = 3 # Windowskin color index, default 3 (green)
  TOOL_UNAVAILABLE_TEXT = "Unavailable"
  TOOL_UNAVAILABLE_TEXT_COLOR = 10 # Windowskin color index, default 10 (red)
  
  #--------------------------------------------------------------------------
  #   Faded Requirement Not Met Display Settings
  #--------------------------------------------------------------------------
  # true  : Ingredient quantity and Tool requirement text will be faded
  #         out like the item name if the requirement isn't met
  # false : Ingredient quantity and Tool requirement text will not be faded
  FADED_REQUIREMENT_QUANTITY = false
    
  #--------------------------------------------------------------------------
  #   Crafting Gold Fee Default Markdown/Markup Rate
  #--------------------------------------------------------------------------
  # If a "gold: amount" setting is not included in an <ingredients> tag,
  # it will use the item's Price in the database by default. This setting
  # allows you to automatically increase or decrease that item, armor
  # or weapon price by a specified rate where 100.0 is normal price and
  # 0.0 is free.
  CRAFTING_FEE_PRICE_RATE = 0.0
  #--------------------------------------------------------------------------
  #   Gold Window Settings
  #--------------------------------------------------------------------------
  # true  : Gold window appears in crafting scene
  # false : Gold crafting fees appear in ingredients list, no gold window
  USE_GOLD_WINDOW = true
  GOLD_WINDOW_ICON_INDEX = 361 # Icon Index number
  GOLD_WINDOW_TEXT = "Gold"
  
  #--------------------------------------------------------------------------
  #   Crafting Result Header Text
  #--------------------------------------------------------------------------
  RESULT_WINDOW_HEADER_TEXT = "You Received"
  
  #--------------------------------------------------------------------------
  #   Stretch Recipebook Pictures Setting
  #--------------------------------------------------------------------------
  # Recommended width and height for book covers images:
  #
  #     width: 248, height: 320 (default resolutions)
  #     width: 296, height: 384 (480x640 resolutions)
  #
  # true  : Book cover pics are stretched to fit the contents of the window.
  # false : Book cover pics are drawn normally.
  STRETCH_RECIPEBOOK_PICTURES = false
  #--------------------------------------------------------------------------
  #   Recipebook Images Folder Directory
  #--------------------------------------------------------------------------
  # Project folder where recipebook pictures are located.
  #
  # Default: "Graphics/Pictures/"
  RECIPEBOOK_PICTURES_DIRECTORY = "Graphics/Pictures/"
  
  #--------------------------------------------------------------------------
  #   Default Crafting Result Sound Effect
  #--------------------------------------------------------------------------
  # Filename : SE filename in Audio/SE/ folder
  # Volume   : Between 0~100
  # Pitch    : Between 50~150
  #
  #                       Filename, Volume, Pitch
  CRAFTING_RESULT_SE = [   "Bell2",     80,   100]
    
  #--------------------------------------------------------------------------
  #   Actor Requirement Display Settings
  #--------------------------------------------------------------------------
  ACTOR_AVAILABLE_TEXT = "Available"
  ACTOR_AVAILABLE_TEXT_COLOR = 3 # Windowskin color index, default 3 (green)
  ACTOR_UNAVAILABLE_TEXT = "Unavailable"
  ACTOR_UNAVAILABLE_TEXT_COLOR = 10 # Windowskin color index, default 10 (red)
  
  #--------------------------------------------------------------------------
  #   Change Ingredident Page Button
  #--------------------------------------------------------------------------
  # This setting determine which gamepad button changes the ingredient
  # window page. Possible buttons include :LEFT, :RIGHT, :UP, :DOWN,
  # :A, :B, :C, :X, :Y, :Z, :L, :R
  NEXT_INGREDIENT_PAGE_BUTTON = :A
    
  #--------------------------------------------------------------------------
  #   YEA Ace Menu Engine - Custom Menu Command Setting
  #--------------------------------------------------------------------------
  # This setting only takes effect when YEA - Ace Menu Engine is installed
  # in the same project.
  #
  # To add the TOCrafting scene to Ace Menu Engine, look for a 
  # configuration setting called "- Main Menu Settings -". There is a
  # variable called COMMANDS that has an array of orange symbols. Add
  # the symbol :tocrafting to the COMMANDS array to add the crafting
  # command to your menu.
  #
  # The setting here working exactly the same as the CUSTOM_COMMAND
  # setting in Ace Menu Engine. For more information, please refer to
  # the Ace Menu Engine script.
  TOCRAFTING_CUSTOM_COMMAND = {
  #             ["Display Name", EnableSwitch, ShowSwitch,      Handler Method],
    :tocrafting => [  "Crafting",           0,          0, :command_tocrafting],
  } # <- Do not delete.

  end # module TOCrafting
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================


#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  #--------------------------------------------------------------------------
  # new method : play_tocrafting_result
  #--------------------------------------------------------------------------
  def self.play_tocrafting_result
    filename = Bubs::TOCrafting::CRAFTING_RESULT_SE[0]
    volume   = Bubs::TOCrafting::CRAFTING_RESULT_SE[1]
    pitch    = Bubs::TOCrafting::CRAFTING_RESULT_SE[2]
    Audio.se_play("Audio/SE/" + filename, volume, pitch) 
  end
  
  #--------------------------------------------------------------------------
  # new method : play_custom_tocrafting_result
  #--------------------------------------------------------------------------
  def self.play_custom_tocrafting_result(filename, volume, pitch)
    Audio.se_play("Audio/SE/" + filename, volume, pitch) 
  end
  
  #--------------------------------------------------------------------------
  # new method : play_page_change
  #--------------------------------------------------------------------------
  def self.play_page_change
    filename = Bubs::TOCrafting::PAGE_CHANGE_SE[0]
    volume   = Bubs::TOCrafting::PAGE_CHANGE_SE[1]
    pitch    = Bubs::TOCrafting::PAGE_CHANGE_SE[2]
    Audio.se_play("Audio/SE/" + filename, volume, pitch) 
  end
end # module Sound


#==============================================================================
# ++ Cache
#==============================================================================
module Cache
  #--------------------------------------------------------------------------
  # new method : recipebook_cover
  #--------------------------------------------------------------------------
  def self.recipebook_cover(filename)
    load_bitmap(Bubs::TOCrafting::RECIPEBOOK_PICTURES_DIRECTORY, filename)
  end
end # module Cache


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    RECIPEBOOK_START_TAG = /<(?:RECIPE[_\s]?BOOK|ricetta)>/i
    RECIPEBOOK_END_TAG = /<\/(?:RECIPE[_\s]?BOOK|ricetta)>/i
    RECIPEBOOK_OBJ_TAG = /(\w+):\s*(\d+(?:\s*,\s*\d+)*)/i
    RECIPEBOOK_COVER_TAG = /(?:PICTURE|PIC|COVER|immagine|IMG):\s*(\w+)/i
    RECIPEBOOK_CATEGORY_TAG = /category?:\s*(\w+)/i

    INGREDIENT_START_TAG = /<(?:INGREDIENTS?|ingredienti)>/i
    INGREDIENT_END_TAG = /<\/(?:INGREDIENTS?|ingredienti)>/i
    INGREDIENT_OBJ_TAG = /(\w+):\s*[×x]?(\d+)\s*[×x]?(\d+)?/i
    
    CRAFT_RESULT_START_TAG = /<(?:CRAFT[_\s]RESULT?|risultato)>/i
    CRAFT_RESULT_END_TAG = /<\/(?:CRAFT[_\s]RESULT?|risultato)>/i
    CRAFT_RESULT_OBJ_TAG = /(\w+):\s*[×x]?(\d+)\s*[×x]?(\d+)?/i
    
    REQUIRED_TOOLS_TAG = /(?:TOOLS?|strumento):\s*(\w+)\s*(\d+)/i
    
    CRAFTING_CUSTOM_SE_TAG = /SE:\s*(\w+)\s*,\s*(\d+)\s*,\s*(\d+)/i
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_tocrafting load_database; end
  def self.load_database
    load_database_bubs_tocrafting # alias
    load_notetags_bubs_tocrafting
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_tocrafting
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_tocrafting
    groups = [$data_items, $data_weapons, $data_armors]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_tocrafting
      end # for obj
    end # for group
  end # def
  
end # module DataManager


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :recipe_list
  attr_accessor :ingredient_list
  attr_accessor :tocrafting_tools
  attr_accessor :tocrafting_actors
  attr_accessor :tocrafting_skills
  attr_accessor :tocrafting_gold_fee
  attr_accessor :tocrafting_bookcover
  attr_accessor :tocrafting_se
  attr_accessor :tocrafting_category
  attr_accessor :tocrafting_amount
  attr_accessor :tocrafting_cev
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_tocrafting
  #--------------------------------------------------------------------------
  def load_notetags_bubs_tocrafting
    @recipe_list = []
    @ingredient_list = []
    @tocrafting_tools = []
    @tocrafting_actors = []
    @tocrafting_skills = []
    @tocrafting_gold_fee = self.price
    @tocrafting_bookcover = ""
    @tocrafting_se = []
    @tocrafting_category = :none
    @tocrafting_amount = 1
    @tocrafting_cev = 0
  
    load_notetags_default_fee_bubs_tocrafting
    
    recipe_tag = false
    ingredient_tag = false
    result_tag = false
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::RECIPEBOOK_START_TAG
        recipe_tag = true
      when Bubs::Regexp::RECIPEBOOK_END_TAG
        recipe_tag = false
        
      when Bubs::Regexp::INGREDIENT_START_TAG
        ingredient_tag = true
      when Bubs::Regexp::INGREDIENT_END_TAG
        ingredient_tag = false
        
      when Bubs::Regexp::CRAFT_RESULT_START_TAG
        result_tag = true
      when Bubs::Regexp::CRAFT_RESULT_END_TAG
        result_tag = false
        
      when Bubs::Regexp::RECIPEBOOK_COVER_TAG
        next unless recipe_tag
        @tocrafting_bookcover = $1
        
      when Bubs::Regexp::RECIPEBOOK_CATEGORY_TAG
        next unless recipe_tag
        @tocrafting_category = $1.to_sym
        
      when Bubs::Regexp::REQUIRED_TOOLS_TAG # tools
        next unless ingredient_tag
        load_notetags_tools_bubs_tocrafting(line)
        
      when Bubs::Regexp::CRAFTING_CUSTOM_SE_TAG
        next unless ingredient_tag || result_tag
        @tocrafting_se = [$1, $2.to_i, $3.to_i]

      else
        load_notetags_recipelist_bubs_tocrafting(line) if recipe_tag
        load_notetags_ingredients_bubs_tocrafting(line) if ingredient_tag
        load_notetags_craft_result_bubs_tocrafting(line) if result_tag
      end # case
    } # self.note.split
    @recipe_list.compact!
    @ingredient_list.compact!
    @tocrafting_tools.compact!
    @tocrafting_actors.compact!
    @tocrafting_skills.compact!
  end # load_notetags_bubs_tocrafting
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_default_fee_bubs_tocrafting
  #--------------------------------------------------------------------------
  def load_notetags_default_fee_bubs_tocrafting
    rate = Bubs::TOCrafting::CRAFTING_FEE_PRICE_RATE
    @tocrafting_gold_fee = (@tocrafting_gold_fee * (rate * 0.01)).to_i
  end

  #--------------------------------------------------------------------------
  # common cache : load_notetags_recipelist_bubs_tocrafting
  #--------------------------------------------------------------------------
  def load_notetags_recipelist_bubs_tocrafting(line)
    return unless line =~ Bubs::Regexp::RECIPEBOOK_OBJ_TAG ? true : false
    match = $~.clone
    id_array = match[2].scan(/\d+/)
    
    case match[1].upcase
    when "I", "ITEM", "OGGETTO"
      for id in id_array
        @recipe_list.push( $data_items[id.to_i] )
      end
      
    when "W", "WEAPON", "WEP", "ARMA"
      for id in id_array
        @recipe_list.push( $data_weapons[id.to_i] )
      end
      
    when "A", "ARMOR", "ARMOUR", "ARM", "ARMATURA"
      for id in id_array
        @recipe_list.push( $data_armors[id.to_i] )
      end # for
      
    end # case
  end # def load_notetags_recipelist_bubs_tocrafting
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_ingredients_bubs_tocrafting
  #--------------------------------------------------------------------------
  def load_notetags_ingredients_bubs_tocrafting(line)
    return unless line =~ Bubs::Regexp::INGREDIENT_OBJ_TAG ? true : false
    amount = $3 ? $3.to_i : 1
    
    case $1.upcase
    when "I", "ITEM", "OGGETTO"
      amount.times do @ingredient_list.push( $data_items[$2.to_i] ) end
      
    when "W", "WEAPON", "WEP", "ARMA"
      amount.times do @ingredient_list.push( $data_weapons[$2.to_i] ) end
      
    when "A", "ARMOR", "ARMOUR", "ARM", "ARMATURA"
      amount.times do @ingredient_list.push( $data_armors[$2.to_i] ) end
    
    when "FEE", "GOLD", "PREZZO", "ORO"
      @tocrafting_gold_fee = $2.to_i
      
    when "SKILL"
      @tocrafting_skills.push( $2.to_i )
      
    when "ACTOR", "EROE"
      @tocrafting_actors.push( $2.to_i )
      
    end # case $1.upcase
  end # def load_notetags_ingredients_bubs_tocrafting
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_tools_bubs_tocrafting
  #--------------------------------------------------------------------------
  def load_notetags_tools_bubs_tocrafting(line)
    line =~ Bubs::Regexp::REQUIRED_TOOLS_TAG
      
    case $1.upcase
    when "I", "ITEM", "OGGETTO"
      @tocrafting_tools.push( $data_items[$2.to_i] )
      
    when "W", "WEAPON", "WEP", "ARMA"
      @tocrafting_tools.push( $data_weapons[$2.to_i] )
      
    when "A", "ARMOR", "ARMOUR", "ARM", "ARMATURA"
      @tocrafting_tools.push( $data_armors[$2.to_i] )
      
    end # case
  end # def load_notetags_tools_bubs_tocrafting
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_craft_result_bubs_tocrafting
  #--------------------------------------------------------------------------
  def load_notetags_craft_result_bubs_tocrafting(line)
    line =~ Bubs::Regexp::CRAFT_RESULT_OBJ_TAG
    
    case $1.upcase
    when "COMMON_EVENT", "CEV", "EVENTO_COMUNE", "EVC" # common event
      @tocrafting_cev = $2.to_i
    
    when "AMOUNT", "AMT", "QUANTITÀ" # amount
      @tocrafting_amount = $2.to_i

    end
  end
  #--------------------------------------------------------------------------
  # new method : recipebook?
  #--------------------------------------------------------------------------
  def recipebook?
    return false unless self.is_a?(RPG::UsableItem) || self.is_a?(RPG::EquipItem)
    return !@recipe_list.empty?
  end
end # class RPG::BaseItem


#==============================================================================
# ++ Window_TOCraftingRecipeList
#==============================================================================
class Window_TOCraftingRecipeList < Window_ItemList
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_reader :info_window
  attr_reader :header_window
  attr_reader :cover_window
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
  end

  #--------------------------------------------------------------------------
  # categories=
  #--------------------------------------------------------------------------
  def categories=(categories)
    @categories = categories
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?           # Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  
  #--------------------------------------------------------------------------
  # enable?                               # Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if item.nil?
    return true
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end

  #--------------------------------------------------------------------------
  # include?                              # Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item.nil?
    return include_recipebook?(item) if item.recipebook?
    return false
  end
  
  #--------------------------------------------------------------------------
  # include_recipebook?
  #--------------------------------------------------------------------------
  def include_recipebook?(item)
    @categories ||= []
    return true if @categories.empty?
    return true if @categories.include?(item.tocrafting_category)
    return false
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item), rect.width - 24)
    end
  end
  
  #--------------------------------------------------------------------------
  # info_window=
  #--------------------------------------------------------------------------
  def info_window=(info_window)
    @info_window = info_window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # header_window=
  #--------------------------------------------------------------------------
  def header_window=(header_window)
    @header_window = header_window
  end
  
  #--------------------------------------------------------------------------
  # cover_window=
  #--------------------------------------------------------------------------
  def cover_window=(cover_window)
    @cover_window = cover_window
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @info_window.item = item if @info_window
    @header_window.item = item if @header_window
    @cover_window.item = item if @cover_window
  end

end # Window_TOCraftingRecipeList


#==============================================================================
# ++ Window_TOCraftingItemListHeader
#==============================================================================
class Window_TOCraftingItemListHeader < Window_Base
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @item = nil
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(1)
  end
  
  #--------------------------------------------------------------------------
  # item=                                   # Set window header item
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_itemlist_header_item(0, 0)
  end
  
  #--------------------------------------------------------------------------
  # draw_itemlist_header_item
  #--------------------------------------------------------------------------
  def draw_itemlist_header_item(x, y)
    return unless @item
    draw_item_name(@item, x, y, true, contents.width - 28)
  end
  
end # class Window_TOCraftingItemListHeader


#==============================================================================
# ++ Window_TOCraftingItemList
#==============================================================================

class Window_TOCraftingItemList < Window_ItemList
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
    @item = nil
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    if $imported["TH_SceneInterpreter"]
      return if SceneManager.scene.interpreter.running?
    end
    super
  end
  
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  
  #--------------------------------------------------------------------------
  # item=
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  
  #--------------------------------------------------------------------------
  # info_window=
  #--------------------------------------------------------------------------
  def info_window=(info_window)
    @info_window = info_window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # gold_window=
  #--------------------------------------------------------------------------
  def gold_window=(gold_window)
    @gold_window = gold_window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?           # Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  
  #--------------------------------------------------------------------------
  # enable?                               # Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if item.nil?
    return false unless has_recipebook?
    return false if item.tocrafting_gold_fee > $game_party.gold
    return false if $game_party.item_max?(item)
    return false unless have_tools?(item)
    return false unless have_actors?(item)
    return true if item.ingredient_list.empty?
    return have_ingredients?(item)
  end
  
  #--------------------------------------------------------------------------
  # has_recipebook?                       
  #--------------------------------------------------------------------------
  def has_recipebook?
    return true if $imported["TH_TOCraftingShop"]
    return true if $game_party.item_number(@item) > 0
    return false
  end
  
  #--------------------------------------------------------------------------
  # have_ingredients?                            
  #--------------------------------------------------------------------------
  def have_ingredients?(item)
    item.ingredient_list.uniq.each do |ingredient|
      party_amount = $game_party.item_number(ingredient)
      required_amount = item.ingredient_list.count(ingredient)
      return false if party_amount < required_amount  
    end # do
    return true
  end
  
  #--------------------------------------------------------------------------
  # have_tools?                            
  #--------------------------------------------------------------------------
  def have_tools?(item)
    item.tocrafting_tools.each do |tool|
      return false if !$game_party.has_item?(tool)
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # have_actors?
  #--------------------------------------------------------------------------
  def have_actors?(item)
    item.tocrafting_actors.each do |id|
      return false unless $game_party.members.include?($game_actors[id])
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # include?                              # Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item.nil?
    return true
  end
  
  #--------------------------------------------------------------------------
  # make_item_list
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @item.recipe_list.each { |item| include?(item) } if @item
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @info_window.item = item if @info_window
    @gold_window.item = item if @gold_window
  end
  
  #--------------------------------------------------------------------------
  # update_open
  #--------------------------------------------------------------------------
  def update_open
    self.openness += 24
    @opening = false if open?
  end

end # class Window_TOCraftingItemList


#==============================================================================
# ++ Window_TOCraftingInfo
#==============================================================================
# If you get an error on this line, place this crafting script BELOW
# the script "Info Pages Window" in your script editor list.
class Window_TOCraftingInfo < Window_InfoPages
  #--------------------------------------------------------------------------
  # Constants (Starting Number of Buff/Debuff Icons)
  #--------------------------------------------------------------------------
  ICON_BUFF_START       = 64              # buff (16 icons)
  ICON_DEBUFF_START     = 80              # debuff (16 icons)
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :number
  attr_accessor :page_change
  attr_accessor :vert_page_index
  attr_reader   :ingredients
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @number = 1
    @ingredients = []
    set_page_keys
  end
  
  #--------------------------------------------------------------------------
  # inh ov : set_page_keys
  #--------------------------------------------------------------------------
  def set_page_keys
    @page_index = @vert_page_index = 0
    @item_pages = Bubs::InfoPages::ITEM_INFO_PAGES.clone
    @equipitem_pages  = Bubs::InfoPages::EQUIP_INFO_PAGES.clone
    @item_pages.unshift(:ingredients)
    @equipitem_pages.unshift(:ingredients)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    create_ingredients_array(@item) if @item
    standard_page_doodads(4, 0)
    return unless @item
    draw_page_contents(4, line_height * 2, @item)
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    if $imported["TH_SceneInterpreter"]
      return if SceneManager.scene.interpreter.running?
    end
    super
  end

  #--------------------------------------------------------------------------
  # item=                                        # Set Item
  #--------------------------------------------------------------------------
  def item=(item)
    @vert_page_index = 0
    super
  end


  #--------------------------------------------------------------------------
  # draw_page_contents
  #--------------------------------------------------------------------------
  def draw_page_contents(x, y, item)
    draw_ingredients(x, y) if current_page == :ingredients
    super
  end # def
    
  #--------------------------------------------------------------------------
  # update_page
  #--------------------------------------------------------------------------
  def update_page
    if visible
      if Input.trigger?(next_ingredient_page_button) && vert_page_max > 1
        next_ingredient_page if current_page == :ingredients
      end
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # next_ingredient_page_button
  #--------------------------------------------------------------------------
  def next_ingredient_page_button
    Bubs::TOCrafting::NEXT_INGREDIENT_PAGE_BUTTON
  end

  #--------------------------------------------------------------------------
  # inh ov : draw_info_footer_text
  #--------------------------------------------------------------------------
  def draw_info_footer_text(x, y)
    if current_page == :ingredients
      draw_ingredients_footer_text(x, y)
    else
      super
    end
  end
  
  #--------------------------------------------------------------------------
  # ingredients_view_more_footer_text
  #--------------------------------------------------------------------------
  def ingredients_view_more_footer_text
    Bubs::TOCrafting::INGREDIENTS_VIEW_MORE_FOOTER_TEXT
  end
  
  #--------------------------------------------------------------------------
  # draw_ingredients_footer_text
  #--------------------------------------------------------------------------
  def draw_ingredients_footer_text(x, y)
    y = y + line_height * (contents.height / line_height - 1)
    rect = standard_rect(x, y)
    change_color(normal_color)
    if vert_page_max > 1
      draw_text(rect, ingredients_view_more_footer_text, 1)
    else
      draw_text(rect, normal_footer_text, 1)
    end
  end
  
  #--------------------------------------------------------------------------
  # next_ingredient_page
  #--------------------------------------------------------------------------
  def next_ingredient_page
    @vert_page_index = (@vert_page_index + 1) % vert_page_max
    refresh
  end
  
  #--------------------------------------------------------------------------
  # required_ingredients
  #--------------------------------------------------------------------------
  def required_ingredients
    @item.ingredient_list
  end
  
  #--------------------------------------------------------------------------
  # required_tools
  #--------------------------------------------------------------------------
  def required_tools
    @item.tocrafting_tools
  end
  
  #--------------------------------------------------------------------------
  # required_actors
  #--------------------------------------------------------------------------
  def required_actors
    @item.tocrafting_actors
  end
  
  #--------------------------------------------------------------------------
  # ingredients_header_text
  #--------------------------------------------------------------------------
  def ingredients_header_text
    Bubs::TOCrafting::INGREDIENTS_HEADER_TEXT
  end
  
  #--------------------------------------------------------------------------
  # inh ov : draw_info_header_text
  #--------------------------------------------------------------------------
  def draw_info_header_text(x, y)
    if current_page == :ingredients
      draw_ingredients_header_text(x, y)
    else
      super
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_ingredients_header_text
  #--------------------------------------------------------------------------
  def draw_ingredients_header_text(x, y)
    rect = standard_rect(x, y)
    change_color(system_color)
    draw_text(rect, ingredients_header_text)
    draw_icon(@item.icon_index, rect.width - 24, y) if @item
  end
  
  #--------------------------------------------------------------------------
  # use_gold_window?
  #--------------------------------------------------------------------------
  def use_gold_window?
    Bubs::TOCrafting::USE_GOLD_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # create_ingredient_array
  #--------------------------------------------------------------------------
  def create_ingredients_array(item)
    @ingredients = []
    container = Struct.new(:type, :obj)
    
    if !use_gold_window? && @item.tocrafting_gold_fee > 0
      ingredient = container.new(:gold, @item.tocrafting_gold_fee)
      @ingredients.push( ingredient )
    end
    
    required_actors.uniq.each do |id|
      ingredient = container.new(:actor, $game_actors[id])
      @ingredients.push( ingredient )
    end
    
    required_tools.uniq.each do |obj|
      ingredient = container.new(:tool, obj)
      @ingredients.push( ingredient )
    end
    
    required_ingredients.uniq.each do |obj|
      ingredient = container.new(:ingredient, obj)
      @ingredients.push( ingredient )
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_ingredients
  #--------------------------------------------------------------------------
  def draw_ingredients(x, y)
    return unless @item
    i = 0
    @vert_page_index = 0 if viewable_ingredients.nil?
    for ingredient in viewable_ingredients
      
      case ingredient.type
      when :gold
        draw_gold_info(ingredient.obj, x, y)
        i += 1
      when :actor
        draw_actor_req_info(ingredient.obj, x, y + line_height * (i * 2))
        i += 1
      when :tool
        draw_tools_info(ingredient.obj, x, y + line_height * (i * 2))
        i += 1
      when :ingredient
        draw_ingredient_info(ingredient.obj, x, y + line_height * (i * 2))
        i += 1
      end
    end
  end

  #--------------------------------------------------------------------------
  # viewable_ingredients
  #--------------------------------------------------------------------------
  def viewable_ingredients
    @ingredients[@vert_page_index * vert_page_size, vert_page_size]
  end
  
  #--------------------------------------------------------------------------
  # vert_page_size                 # Number of Ingredients Displayable at Once
  #--------------------------------------------------------------------------
  def vert_page_size
    Bubs::TOCrafting::INGREDIENTS_PAGE_SIZE
  end

  #--------------------------------------------------------------------------
  # vert_page_max                            # Get Maximum Number of Pages
  #--------------------------------------------------------------------------
  def vert_page_max
    (@ingredients.size + vert_page_size) / vert_page_size
  end
  
  #--------------------------------------------------------------------------
  # required_amount
  #--------------------------------------------------------------------------
  def required_amount(item)
    required_ingredients.count(item) * @number
  end
  
  #--------------------------------------------------------------------------
  # party_amount
  #--------------------------------------------------------------------------
  def party_amount(item)
    $game_party.item_number(item)
  end
  
  #--------------------------------------------------------------------------
  # crafting_fee
  #--------------------------------------------------------------------------
  def crafting_fee
    @item.tocrafting_gold_fee
  end
  
  #--------------------------------------------------------------------------
  # party_gold
  #--------------------------------------------------------------------------
  def party_gold
    $game_party.gold
  end
  
  #--------------------------------------------------------------------------
  # currency_unit
  #--------------------------------------------------------------------------
  def currency_unit
    Vocab::currency_unit
  end
  
  #--------------------------------------------------------------------------
  # draw_tools_info
  #--------------------------------------------------------------------------
  def draw_tools_info(item, x, y)
    enabled = $game_party.has_item?(item)
    width = contents.width - 4 - x
    
    draw_item_name(item, x, y, enabled, width)
    draw_tool_availability_text(item, x, y, enabled)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_req_info
  #--------------------------------------------------------------------------
  def draw_actor_req_info(actor, x, y)
    enabled = $game_party.members.include?(actor)
    width = contents.width - 4 - x
    icon_index = actor_icon_id(actor.id)
    draw_icon(icon_index, x, y, enabled)
    draw_actor_availability_text(actor.id, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, actor.name)
  end
  
  #--------------------------------------------------------------------------
  # draw_tool_availability_text
  #--------------------------------------------------------------------------
  def draw_tool_availability_text(item, x, y, enabled)
    rect = Rect.new(x, y + line_height, contents.width - 4 - x, line_height)
    if enabled
      change_color(text_color(Bubs::TOCrafting::TOOL_AVAILABLE_TEXT_COLOR))
      draw_text(rect, Bubs::TOCrafting::TOOL_AVAILABLE_TEXT, 2)
    else
      change_color(text_color(Bubs::TOCrafting::TOOL_UNAVAILABLE_TEXT_COLOR))
      draw_text(rect, Bubs::TOCrafting::TOOL_UNAVAILABLE_TEXT, 2)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_availability_text
  #--------------------------------------------------------------------------
  def draw_actor_availability_text(item, x, y, enabled)
    rect = Rect.new(x, y + line_height, contents.width - 4 - x, line_height)
    if enabled
      change_color(text_color(Bubs::TOCrafting::ACTOR_AVAILABLE_TEXT_COLOR))
      draw_text(rect, Bubs::TOCrafting::ACTOR_AVAILABLE_TEXT, 2)
    else
      change_color(text_color(Bubs::TOCrafting::ACTOR_UNAVAILABLE_TEXT_COLOR))
      draw_text(rect, Bubs::TOCrafting::ACTOR_UNAVAILABLE_TEXT, 2)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_ingredient_info
  #--------------------------------------------------------------------------
  def draw_ingredient_info(item, x, y)
    enabled = party_amount(item) >= required_amount(item)
    width = contents.width - 4 - x
    
    draw_item_name(item, x, y, enabled, width)
    not_enough_ingredients_color unless enabled     
    rect = Rect.new(x, y + line_height, contents.width - 4 - x, line_height)
    draw_text(rect, sprintf("×%2d/%2d", required_amount(item), party_amount(item)), 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_gold_info
  #--------------------------------------------------------------------------
  def draw_gold_info(item, x, y)
    return if item.nil?
    enabled = party_gold >= crafting_fee
    cx = text_size(currency_unit).width
    width = contents.width - 4 - x
    
    draw_gold_name(x, y, enabled)
    
    change_color(system_color)
    draw_text(x, y + line_height, width, line_height, currency_unit, 2)
    change_color(normal_color)
    
    not_enough_ingredients_color unless enabled
    text = sprintf("%8d/%8d", crafting_fee * @number, party_gold)
    draw_text(x, y + line_height, width - cx - 2, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_gold_name
  #--------------------------------------------------------------------------
  def draw_gold_name(x, y, enabled = true)
    draw_icon(Bubs::TOCrafting::GOLD_WINDOW_ICON_INDEX, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, Bubs::TOCrafting::GOLD_WINDOW_TEXT)
  end
  
  #--------------------------------------------------------------------------
  # not_enough_ingredients_color
  #--------------------------------------------------------------------------
  def not_enough_ingredients_color
    enabled = !Bubs::TOCrafting::FADED_REQUIREMENT_QUANTITY
    color_index = Bubs::TOCrafting::NOT_ENOUGH_INGREDIENTS_COLOR
    change_color(text_color(color_index), enabled)
  end



end # class Window_TOCraftingInfo


#==============================================================================
# ++ Window_TOCraftingResult
#==============================================================================
class Window_TOCraftingResult < Window_Selectable
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    @item = nil
    @number = 0
    super(x, y, window_width,window_height)
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(2)
  end
  
  #--------------------------------------------------------------------------
  # set
  #--------------------------------------------------------------------------
  def set(item, number)
    @item = item
    @number = number
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    process_cursor_move
    process_handling
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_result_header_text(4, 0)
    draw_result_item(4, line_height)
  end
  
  #--------------------------------------------------------------------------
  # draw_result_header_text
  #--------------------------------------------------------------------------
  def draw_result_header_text(x, y)
    return unless @item
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Bubs::TOCrafting::RESULT_WINDOW_HEADER_TEXT, 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_result_item
  #--------------------------------------------------------------------------
  def draw_result_item(x, y)
    return unless @item
    draw_item_name(@item, x, y, true)
    draw_item_amount(x, y, @number)
  end
  
  #--------------------------------------------------------------------------
  # draw_item_amount
  #--------------------------------------------------------------------------
  def draw_item_amount(x, y, number)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    draw_text(rect, sprintf("×%2d", number), 2)
  end

end # class Window_TOCraftingResult


#==============================================================================
# ++ Window_TOCraftingGold
#==============================================================================
class Window_TOCraftingGold < Window_Base
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :number
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(2))
    @item = nil
    @number = 1
    refresh
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # item=
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_gold_info(4, 0)
  end

  #--------------------------------------------------------------------------
  # currency_unit
  #--------------------------------------------------------------------------
  def currency_unit
    Vocab::currency_unit
  end
  
  #--------------------------------------------------------------------------
  # open
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
  
  #--------------------------------------------------------------------------
  # crafting_fee
  #--------------------------------------------------------------------------
  def crafting_fee
    @item.tocrafting_gold_fee
  end
  
  #--------------------------------------------------------------------------
  # party_gold
  #--------------------------------------------------------------------------
  def party_gold
    $game_party.gold
  end
  
  #--------------------------------------------------------------------------
  # draw_gold_info
  #--------------------------------------------------------------------------
  def draw_gold_info(x, y)
    return if @item.nil?
    enabled = party_gold >= crafting_fee
    cx = text_size(currency_unit).width
    width = contents.width - 4 - x
    
    draw_gold_name(x, y, enabled)
    
    change_color(system_color)
    draw_text(x, y + line_height, width, line_height, currency_unit, 2)
    change_color(normal_color)
    
    not_enough_ingredients_color unless enabled
    text = sprintf("%8d/%8d", crafting_fee * @number, party_gold)
    draw_text(x, y + line_height, width - cx - 2, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_gold_name
  #--------------------------------------------------------------------------
  def draw_gold_name(x, y, enabled = true)
    draw_icon(Bubs::TOCrafting::GOLD_WINDOW_ICON_INDEX, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, Bubs::TOCrafting::GOLD_WINDOW_TEXT)
  end
  
  #--------------------------------------------------------------------------
  # not_enough_ingredients_color
  #--------------------------------------------------------------------------
  def not_enough_ingredients_color
    enabled = !Bubs::TOCrafting::FADED_REQUIREMENT_QUANTITY
    color_index = Bubs::TOCrafting::NOT_ENOUGH_INGREDIENTS_COLOR
    change_color(text_color(color_index), enabled) 
  end
end # class Window_TOCraftingGold


#==============================================================================
# ++ Window_TOCraftingNumber
#==============================================================================
class Window_TOCraftingNumber < Window_Selectable
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor   :number                   # quantity entered
  attr_reader     :item
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
    @item = nil
    @info_window = nil
    @max = 1
    @price = 0
    @number = 1
    @currency_unit = Vocab::currency_unit
    @hold_max = 1
    @actual_max = 1
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # info_window=
  #--------------------------------------------------------------------------
  def info_window=(info_window)
    @info_window = info_window
  end
  
  #--------------------------------------------------------------------------
  # gold_window=
  #--------------------------------------------------------------------------
  def gold_window=(gold_window)
    @gold_window = gold_window
  end
  
  #--------------------------------------------------------------------------
  # set
  #--------------------------------------------------------------------------
  def set(item, max, price, currency_unit = nil)
    @item = item
    @max = max
    @price = price
    @currency_unit = currency_unit if currency_unit
    @number = item.tocrafting_amount
    
    @hold_max = $game_party.max_item_number(item) - $game_party.item_number(item)
    temp = @hold_max % item.tocrafting_amount
    @actual_max = [[(@max * item.tocrafting_amount), @hold_max - temp].min, 0].max
    refresh
  end
  
  #--------------------------------------------------------------------------
  # currency_unit
  #--------------------------------------------------------------------------
  def currency_unit=(currency_unit)
    @currency_unit = currency_unit
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_item_name(@item, 0, item_y)
    draw_number
    update_info_window
    update_gold_window
  end
  
  #--------------------------------------------------------------------------
  # draw_number
  #--------------------------------------------------------------------------
  def draw_number
    change_color(normal_color)
    draw_text(cursor_x - 28, item_y, 22, line_height, "×")
    draw_text(cursor_x, item_y, cursor_width - 4, line_height, @number, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_total_price
  #--------------------------------------------------------------------------
  def draw_total_price
    return if @item.nil?
    return if @item.tocrafting_gold_fee == 0
    width = contents_width - 8
    total_price = @price * (@number / @item.tocrafting_amount)
    draw_currency_value(total_price, @currency_unit, 4, price_y, width)
  end
  
  #--------------------------------------------------------------------------
  # item_y                        # Y Coordinate of Item Name Display Line
  #--------------------------------------------------------------------------
  def item_y
    contents_height / 2 - line_height * 3 / 2
  end
  
  #--------------------------------------------------------------------------
  # price_y                       # Y Coordinate of Price Display Line
  #--------------------------------------------------------------------------
  def price_y
    contents_height / 2 + line_height / 2
  end
  
  #--------------------------------------------------------------------------
  # cursor_width
  #--------------------------------------------------------------------------
  def cursor_width
    figures * 10 + 12
  end
  
  #--------------------------------------------------------------------------
  # cursor_x                      # Get X Coordinate of Cursor
  #--------------------------------------------------------------------------
  def cursor_x
    contents_width - cursor_width - 4
  end
  
  #--------------------------------------------------------------------------
  # figures              # Get Maximum Number of Digits for Quantity Display
  #--------------------------------------------------------------------------
  def figures
    return 2
  end
  
  #--------------------------------------------------------------------------
  # update                        # Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if active
      last_number = @number
      update_number
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # update_number                         # Update Quantity
  #--------------------------------------------------------------------------
  def update_number
    change_number(1) if Input.repeat?(:RIGHT)
    change_number(-1) if Input.repeat?(:LEFT)
    change_number(10) if Input.repeat?(:UP)
    change_number(-10) if Input.repeat?(:DOWN)
  end

  #--------------------------------------------------------------------------
  # change_number
  #--------------------------------------------------------------------------
  def change_number(amount)
    craft_amt = @item.tocrafting_amount
    temp = (@number + (amount * craft_amt)) 
    temp_mod = temp % craft_amt
    @number = [[temp - temp_mod, @actual_max].min, craft_amt].max
  end
  
  #--------------------------------------------------------------------------
  # update_cursor
  #--------------------------------------------------------------------------
  def update_cursor
    cursor_rect.set(cursor_x, item_y, cursor_width, line_height)
  end
  
  #--------------------------------------------------------------------------
  # update_info_window
  #--------------------------------------------------------------------------
  def update_info_window
    @info_window.number = (@number / @item.tocrafting_amount)
    @info_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # update_gold_window
  #--------------------------------------------------------------------------
  def update_gold_window
    @gold_window.number = (@number / @item.tocrafting_amount)
    @gold_window.refresh
  end

end # class Window_TOCraftingNumber


#==============================================================================
# ++ Window_TOCraftingCover
#==============================================================================
class Window_TOCraftingCover < Window_Base
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_bookcover(0, 0)
  end
  
  #--------------------------------------------------------------------------
  # item=
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  
  #--------------------------------------------------------------------------
  # stretch_pictures?
  #--------------------------------------------------------------------------
  def stretch_pictures?
    Bubs::TOCrafting::STRETCH_RECIPEBOOK_PICTURES
  end
  
  #--------------------------------------------------------------------------
  # draw_bookcover
  #--------------------------------------------------------------------------
  def draw_bookcover(x, y)
    return unless @item
    bitmap = Cache.recipebook_cover(@item.tocrafting_bookcover)
    rect = Rect.new(0, 0, contents.width, contents.height)
    if stretch_pictures?
      contents.stretch_blt(rect, bitmap, bitmap.rect)
    else
      x = (contents.width - bitmap.width) / 2
      y = (contents.height - bitmap.height) / 2
      contents.blt(x, y, bitmap, rect)
    end
    bitmap.dispose
  end
  
end # class Window_TOCraftingCover


#==============================================================================
# ++ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # new method : call_tocrafting_scene
  #--------------------------------------------------------------------------
  def call_tocrafting_scene(*args)
    SceneManager.call(Scene_TOCrafting)
    SceneManager.scene.prepare(args)
  end
  alias open_tocrafting_shop call_tocrafting_scene
end


#==============================================================================
# ++ Scene_TOCrafting
#==============================================================================
class Scene_TOCrafting < Scene_MenuBase
  #--------------------------------------------------------------------------
  # prepare
  #--------------------------------------------------------------------------
  def prepare(categories)
    @categories = categories
  end

  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    super
    check_required_scripts
    create_help_window
    create_gold_window
    create_cover_window
    create_info_window
    create_itemlist_header_window
    create_itemlist_window
    create_recipelist_window
    create_number_window
    create_result_window
  end
  
  #--------------------------------------------------------------------------
  # check_required_scripts
  #--------------------------------------------------------------------------
  def check_required_scripts
    return if $imported["BubsInfoPages"]
    msgbox("Tactics Ogre PSP Crafting System requires the script \"Info Pages Window\"\n" +
    "Find it at http://mrbubblewand.wordpress.com/")
    exit
  end

  
  #--------------------------------------------------------------------------
  # create_gold_window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_TOCraftingGold.new
    @gold_window.viewport = @viewport
    @gold_window.hide.close
    @gold_window.x = 0
    @gold_window.y = Graphics.height - @gold_window.height
  end
  
  #--------------------------------------------------------------------------
  # create_recipelist_window
  #--------------------------------------------------------------------------
  def create_recipelist_window
    wx = 0
    wy = @help_window.height
    wh = Graphics.height - wy
    @recipelist_window = Window_TOCraftingRecipeList.new(wx, wy, wh)
    @recipelist_window.viewport = @viewport
    @recipelist_window.help_window = @help_window
    @recipelist_window.info_window = @info_window
    @recipelist_window.header_window = @itemlist_header_window
    @recipelist_window.cover_window = @cover_window
    @recipelist_window.categories = @categories
    @recipelist_window.set_handler(:ok,     method(:on_recipelist_ok))
    @recipelist_window.set_handler(:cancel, method(:on_recipelist_cancel))
    @recipelist_window.refresh
    @recipelist_window.show.activate.select(0)
  end
  
  #--------------------------------------------------------------------------
  # on_recipelist_ok
  #--------------------------------------------------------------------------
  def on_recipelist_ok
    @recipelist_window.close
    @itemlist_window.item = @recipelist_window.item
    @gold_window.show.open if gold_window?
    @cover_window.hide
    @info_window.show
    @info_window.set_page_keys
    activate_itemlist_window
  end
  
  #--------------------------------------------------------------------------
  # on_recipelist_cancel
  #--------------------------------------------------------------------------
  def on_recipelist_cancel
    refresh
    return_scene
  end
  
  #--------------------------------------------------------------------------
  # activate_recipelist_window
  #--------------------------------------------------------------------------
  def activate_recipelist_window
    refresh
    @recipelist_window.show.open.activate
  end
  
  #--------------------------------------------------------------------------
  # create_itemlist_window
  #--------------------------------------------------------------------------
  def create_itemlist_window
    wx = 0
    wy = @help_window.height + @itemlist_header_window.height
    wh = Graphics.height - wy
    wh = wh - @gold_window.height if gold_window?
    @itemlist_window = Window_TOCraftingItemList.new(wx, wy, wh)
    @itemlist_window.viewport = @viewport
    @itemlist_window.help_window = @help_window
    @itemlist_window.info_window = @info_window
    @itemlist_window.gold_window = @gold_window
    @itemlist_window.hide
    @itemlist_window.close
    @itemlist_window.set_handler(:ok,     method(:on_itemlist_ok))
    @itemlist_window.set_handler(:cancel, method(:on_itemlist_cancel))
    @itemlist_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # on_itemlist_ok
  #--------------------------------------------------------------------------
  def on_itemlist_ok
    @item = @itemlist_window.item
    @itemlist_window.close.hide
    @number_window.set(@item, max_craft, crafting_fee)
    @info_window.page_change = false
    @info_window.set_page_keys
    @number_window.show.open.activate
  end
  
  #--------------------------------------------------------------------------
  # on_itemlist_cancel
  #--------------------------------------------------------------------------
  def on_itemlist_cancel
    @itemlist_window.close
    @itemlist_header_window.close
    @gold_window.close.hide if gold_window?
    @info_window.hide
    @cover_window.show
    activate_recipelist_window
  end
  
  #--------------------------------------------------------------------------
  # activate_itemlist_window
  #--------------------------------------------------------------------------
  def activate_itemlist_window
    refresh
    @itemlist_header_window.show.open
    @itemlist_window.show.open.activate.select(0)
  end
  
  #--------------------------------------------------------------------------
  # create_number_window
  #--------------------------------------------------------------------------
  def create_number_window
    wx = 0
    wy = @itemlist_header_window.y + @itemlist_header_window.height
    wh = Graphics.height - wy
    wh = wh - @gold_window.height if gold_window?
    @number_window = Window_TOCraftingNumber.new(wx, wy, wh)
    @number_window.viewport = @viewport
    @number_window.info_window = @info_window
    @number_window.gold_window = @gold_window
    @number_window.hide.close
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
  
  #--------------------------------------------------------------------------
  # on_number_ok
  #--------------------------------------------------------------------------
  def on_number_ok
    @number_window.close.hide
    @number_window.number
    do_crafting(@item, @number_window.number)
    @result_window.set(@item, @number_window.number)
    @result_window.show.open.activate
    @itemlist_window.show.open
    @info_window.page_change = true
    
    @gold_window.number = @info_window.number = 1
    refresh
    @result_window.show.open.activate
  end
  
  #--------------------------------------------------------------------------
  # on_number_cancel
  #--------------------------------------------------------------------------
  def on_number_cancel
    @number_window.close.hide
    @gold_window.number = @info_window.number = 1
    @info_window.page_change = true
    @itemlist_window.show.open.activate
  end

  #--------------------------------------------------------------------------
  # create_result_window
  #--------------------------------------------------------------------------
  def create_result_window
    wx = Graphics.width / 4
    wy = 0
    @result_window = Window_TOCraftingResult.new(wx, wy)
    @result_window.y = (Graphics.height / 2) - (@result_window.height / 2)
    @result_window.viewport = @viewport
    @result_window.hide.close
    @result_window.set_handler(:ok,     method(:on_result_ok))
    @result_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # on_result_ok
  #--------------------------------------------------------------------------
  def on_result_ok
    @result_window.close.hide
    @itemlist_window.activate
    check_common_event(@item)
  end
  
  #--------------------------------------------------------------------------
  # create_itemlist_header_window
  #--------------------------------------------------------------------------
  def create_itemlist_header_window
    wx = 0
    wy = @help_window.height
    @itemlist_header_window = Window_TOCraftingItemListHeader.new(wx, wy)
    @itemlist_header_window.viewport = @viewport
    @itemlist_header_window.hide
    @itemlist_header_window.close
    @itemlist_header_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # create_cover_window
  #--------------------------------------------------------------------------
  def create_cover_window
    wx = Graphics.width / 2
    wy = @help_window.height
    wh = Graphics.height - @help_window.height
    ww = Graphics.width - wx
    @cover_window = Window_TOCraftingCover.new(wx, wy, ww, wh)
    @cover_window.viewport = @viewport
    @cover_window.refresh
    @cover_window.show
  end
  
  #--------------------------------------------------------------------------
  # create_info_window
  #--------------------------------------------------------------------------
  def create_info_window
    wx = Graphics.width / 2
    wy = @help_window.height
    ww = Graphics.width - wx
    wh = Graphics.height - @help_window.height
    @info_window = Window_TOCraftingInfo.new(wx, wy, ww, wh)
    @info_window.viewport = @viewport
    @info_window.hide
    @info_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @info_window.refresh
    @help_window.refresh
    @itemlist_window.refresh
    @recipelist_window.refresh
    @result_window.refresh
    @itemlist_header_window.refresh
    @gold_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # do_crafting
  #--------------------------------------------------------------------------
  def do_crafting(item, number)
    return unless item
    play_crafting_se(item)
    lose_ingredients(item, number)
    pay_crafting_fee(item, number)
    gain_crafted_item(item, number)
  end
  
  #--------------------------------------------------------------------------
  # play_crafting_se
  #--------------------------------------------------------------------------
  def play_crafting_se(item)
    if item.tocrafting_se.empty?
      Sound.play_tocrafting_result
    else
      se = item.tocrafting_se
      Sound.play_custom_tocrafting_result(se[0], se[1], se[2])
    end
  end
  
  #--------------------------------------------------------------------------
  # check_common_event
  #--------------------------------------------------------------------------
  def check_common_event(item)
    return unless item.tocrafting_cev > 0
    $game_temp.reserve_common_event(item.tocrafting_cev)
    if $imported["TH_SceneInterpreter"]
      a = $game_temp.common_event_reserved?
      b = $data_common_events[$game_temp.common_event_id].run_scene == :current
      return if !a || (a && b)
    end
    SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
  end
  
  #--------------------------------------------------------------------------
  # lose_ingredients
  #--------------------------------------------------------------------------
  def lose_ingredients(item, number)
    item.ingredient_list.each do |ingredient|
      $game_party.lose_item(ingredient, number / @item.tocrafting_amount)
    end
  end
  
  #--------------------------------------------------------------------------
  # pay_crafting_fee
  #--------------------------------------------------------------------------
  def pay_crafting_fee(item, number)
    amt = @item.tocrafting_amount
    $game_party.lose_gold(item.tocrafting_gold_fee * (number / amt))
  end
  
  #--------------------------------------------------------------------------
  # gain_crafted_item
  #--------------------------------------------------------------------------
  def gain_crafted_item(item, number)
    $game_party.gain_item(item, number)
  end
  
  #--------------------------------------------------------------------------
  # crafting_fee
  #--------------------------------------------------------------------------
  def crafting_fee
    @item.tocrafting_gold_fee
  end
  
  #--------------------------------------------------------------------------
  # gold_window?
  #--------------------------------------------------------------------------
  def gold_window?
    Bubs::TOCrafting::USE_GOLD_WINDOW
  end

  #--------------------------------------------------------------------------
  # party_gold
  #--------------------------------------------------------------------------
  def party_gold
    $game_party.gold
  end
  
  #--------------------------------------------------------------------------
  # max_craft
  #--------------------------------------------------------------------------
  def max_craft
    max = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    max = crafting_fee == 0 ? max : [max, party_gold / crafting_fee].min
    for ingredient in @item.ingredient_list.uniq.each
      break if max == 0
      count = @item.ingredient_list.count(ingredient)
      temp_max = 0
      for i in 1..max
        break if (i * count) > $game_party.item_number(ingredient)
        temp_max += 1
      end # for
      max = temp_max if max > temp_max
    end # for
    return max
  end
  
end # class Scene_TOCrafting


if $imported["TH_SceneInterpreter"]
#==============================================================================
# ++ Scene_Base
#==============================================================================
class Scene_Base
  #--------------------------------------------------------------------------
  # for compatibility : interpreter
  #--------------------------------------------------------------------------
  def interpreter
    @interpreter
  end
end

end # if $imported["TH_SceneInterpreter"]


if defined?(XAS_SYSTEM)
#==============================================================================
# ++ Window_ItemList
#==============================================================================
class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # compatibility alias : can_equip_item_action?
  #--------------------------------------------------------------------------
  alias can_equip_item_action_bubs_tocrafting can_equip_item_action?
  def can_equip_item_action?
    return false if SceneManager.scene_is?(Scene_TOCrafting)
    return can_equip_item_action_bubs_tocrafting # alias
  end
end # class Window_ItemList

end # if defined?(XAS_SYSTEM)


if $imported["YEA-AceMenuEngine"]
  
if !YEA::MENU::CUSTOM_COMMANDS.include?(:tocrafting)
  YEA::MENU::CUSTOM_COMMANDS.merge!(Bubs::TOCrafting::TOCRAFTING_CUSTOM_COMMAND)
end

#==============================================================================
# ++ Scene_Menu
#==============================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # compatibility method : command_tocrafting
  #--------------------------------------------------------------------------
  def command_tocrafting(*args)
    SceneManager.call(Scene_TOCrafting)
    SceneManager.scene.prepare(args)
  end
end # class Scene_Menu

end # if $imported["YEA-AceMenuEngine"]
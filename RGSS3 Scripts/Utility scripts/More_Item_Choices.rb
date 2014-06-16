#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ More Item Choices
#  Author: Kread-EX
#  Version 1.0
#  Release date: 18/02/2012
#
#  For Greensburg the 4th.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Adds three item choices commands, for weapons armors and normal items.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Use those three script calls:
# # weapon_choice(variable_id)
# # armor_choice(variable_id)
# # item_choice(variable_id)
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # Game_Interpreter
# # command_104 (alias)
# # weapon_choice (new method)
# # armor_choice (new method)
# # item_choice (new method)
# #
# # Game_Temp
# # item_choice_category (new attr method)
# #
# # Window_KeyItem
# # start (overwrite)
# # enable? (overwrite)
#-------------------------------------------------------------------------------------------------

#==============================================================================
# ■ Game_Temp
#==============================================================================

class Game_Temp
  attr_accessor :item_choice_category
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● Key Item choice processing
  #--------------------------------------------------------------------------
  alias_method(:krx_itemchoice_gi104, :command_104)
  def command_104
    $game_temp.item_choice_category = :key_item
    krx_itemchoice_gi104
  end
  #--------------------------------------------------------------------------
  # ● Weapon choice processing
  #--------------------------------------------------------------------------
  def weapon_choice(variable_id)
    $game_temp.item_choice_category = :weapon
    @params = [variable_id]
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while $game_message.item_choice?
  end
  #--------------------------------------------------------------------------
  # ● Armor choice processing
  #--------------------------------------------------------------------------
  def armor_choice(variable_id)
    $game_temp.item_choice_category = :armor
    @params = [variable_id]
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while $game_message.item_choice?
  end
  #--------------------------------------------------------------------------
  # ● Regular Item choice processing
  #--------------------------------------------------------------------------
  def item_choice(variable_id)
    $game_temp.item_choice_category = :item
    @params = [variable_id]
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while $game_message.item_choice?
  end
end

#==============================================================================
# ■ Window_KeyItem
#==============================================================================

class Window_KeyItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Starts the window setup
  #--------------------------------------------------------------------------
  def start
    self.category = $game_temp.item_choice_category
    update_placement
    refresh
    select(0)
    open
    activate
  end
  #--------------------------------------------------------------------------
  # ● Determine if an item can be used
  #--------------------------------------------------------------------------
  def enable?(item)
   true
  end
end
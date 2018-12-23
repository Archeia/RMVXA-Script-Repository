#==============================================================================
#    Select Any Item
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 9 September 2014
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    Normally, you can only select items marked as key items from the Select
#   Key Item event command. This allows you to change it so that any category
#   of items can be selected, and you can also create custom categories that 
#   will only include the items you specify. This will allow you to create 
#   different types of key categories that you can bring up at different times.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor (F11), above Main 
#   but below Materials.
#
#    When you want to change how the item list will show up, you just need to
#   use the following code in a script call:
#
#      $game_system.masai_category = :category
#
#   Replace :category with one of the following:
#      :key_item - All key items the party has will be shown (default)
#      :item     - All items the party has will be shown
#      :weapon   - All weapons the party has will be shown
#      :armor    - All armors the party has will be shown
#      :all      - All items, weapons, and armors the party has will be shown
#
#    Then, the next time you use the event command "Select Key Item", it will
#   show items from the category you've chosen instead of just key items. The 
#   ID of the item, weapon, or armor you select will be saved to the variable
#   you choose through the event command.
#
#    However, you have to remember to set the category every time you want it
#   to be special, or else it will just show key items.
#
#    You can also create your own special categories that only include the 
#   items you specifically identify. You can do this by using the following 
#   code in an item, weapon, or armor's notebox:
#
#      \key_category[anything]
#   
#    Then, if you set the category to :anything, then all items, weapons, and 
#   armors marked that way that the party has will show up in the window. As
#   an example, let's say you have three items: a "Bloody Cloth" (item), a 
#   "Hatchet" (weapon), and a "Torn Shawl" (armor). In the note field of each, 
#   you put the following code:
#
#      \key_category[evidence]
#
#    Now, whenever you set the category to :evidence, whichever of those items
#   the party possesses will show up in the next Select Key Item window.
#
#    An item, weapon, or armor can have as many custom categories as you want
#   to set. So even if you want one of those items to be evidence, you can also
#   give it other categories and it will show up in them too.
#
#    Of course, if you use the :all category or a mixed special category like
#   the one above, then just knowing the ID of the item will not be enough to
#   operate on it. You will also need to know whether it is an item, weapon or
#   armor. There are two ways to record that. First, you can go to line xy and
#   change the value of MASAI_TYPE_VARIABLE_ID to any positive integer. Then,
#   the type of the selected item will be saved to the in-game variable with 
#   that ID after every item selection. If the value of that variable is 1, it
#   was an item. If 2, then it was a weapon. If 3, it was an armor.
#
#    However, you will have to be sure to reserve that variable always for that
#   purpose, and never use it for anything else. Otherwise, the data you wanted
#   to save to it will be overwritten every time you select an item.
#
#    Another way to do it is to choose the variable it will be saved to through
#   a script call before each key selection. You can do that with the code:
#
#      $game_system.masai_type_variable_id = 1
#
#   Replace 1 with the ID of the variable you want to use. The same danger 
#   arises, so you have to be sure you aren't using the variable for anything
#   else.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_SelectAnyItem] = true

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#  Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# MASAI_TYPE_VARIABLE_ID : This allows you to specify an in-game variable that
#  will save the type of item selected in any Key Item selection (i.e. whether
#  it is an item, weapon, or armor). This is only useful if you intend to have 
#  selections that include more than one type of item. Otherwise, it should be
#  set to false. If you do want to use it, just set it to any positive integer
#  and the item type will be saved to the in-game variable with that ID.
MASAI_TYPE_VARIABLE_ID = false
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#  END Editable Region
#//////////////////////////////////////////////////////////////////////////////

#==============================================================================
# ** RPG::BaseItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - masai_special_categories
#==============================================================================

class RPG::BaseItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Special Categories
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def masai_special_categories
    unless @masai_special_categories
      @masai_special_categories = []
      note.scan(/\\KEY[_\s*]CATEGORY\s*\[(.+?)\]/i) {  
        @masai_special_categories << $1.strip.to_sym
      }
      @masai_special_categories.uniq!
    end
    # If using my Customizable Item Menu script
    if $imported[:"MA Customizable Item Menu 1.0.x"] && self.is_a?(MACIM_RPG_ItemWeaponArmor)
      # Inherit any special categories set up through that script
      (@masai_special_categories + macim_categories).uniq
    else
      @masai_special_categories
    end
  end
end

#==============================================================================
# ** Game_System
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public accessor variable - masai_category
#==============================================================================

class Game_System
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :masai_category
  attr_accessor :masai_type_variable_id
end

#==============================================================================
# *** MASAI_Window_KeyItem_Mixin
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    changed methods - close; category=; include?
#==============================================================================

module MASAI_Window_KeyItem_Mixin
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Close Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def close(*args, &block)
    $game_system.masai_category = nil
    super(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Category
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def category=(cat, *args, &block)
    cat = $game_system.masai_category if $game_system.masai_category.is_a?(Symbol)
    # Run Original Method
    super(cat, *args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Include in Item List?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def include?(item, *args, &block)
    if @category == :all
      return true
    elsif ![:item, :weapon, :armor, :none].include?(@category) && item.is_a?(RPG::BaseItem)
      return item.masai_special_categories.include?(@category)
    else
      super(item, *args, &block)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Enable in Item List?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def enable?(*args, &block)
    return true
  end
end

#==============================================================================
# ** Window_KeyItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    mixed in modules - MASAI_Window_KeyItem_Mixin
#    aliased method - on_ok
#==============================================================================

class Window_KeyItem
  include MASAI_Window_KeyItem_Mixin
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # *  Press OK
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias masai_onok_1cq6 on_ok
  def on_ok(*args, &block)
    # Get ID of variable to save the type result in.
    v_id = $game_system.masai_type_variable_id
    v_id = MASAI_TYPE_VARIABLE_ID if !v_id
    if v_id && v_id > 0
      # Remember Item Type
      result = case item
      when RPG::Item then 1
      when RPG::Weapon then 2
      when RPG::Armor then 3
      else 0
      end
      $game_variables[v_id] = result 
    end
    masai_onok_1cq6(*args, &block) # Call Original Method
  end
end
=begin
Improved Item Processing
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Allows you to define which items appear in the item
processing window.
----------------------
Instructions
----------------------
Set VARIABLE_CAT to the id of the variable you wish 
to use to define what appears.
By defualt:
VARIABLE -> What appear
0 -> Normal Items
1 -> Weapons
2 -> Armours
3 -> Key Items
4 -> All Items
5+ will open up a custom selection window.
You define the items to be included in it by note tagging.
<itemp x>
Where x is the value of the variable you want to use.
----------------------
Known bugs
----------------------
None
=end
class Window_KeyItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Change the number to the id of the variable you wish to use
  #--------------------------------------------------------------------------
  VARIABLE_CAT = 2
  #--------------------------------------------------------------------------
  # ● Replaces the inherited method.
  #--------------------------------------------------------------------------
  def include?(item)
    case $game_variables[VARIABLE_CAT]
    when 0 # Normal Items
      item.is_a?(RPG::Item) && !item.key_item?
    when 1 # Weapons
      item.is_a?(RPG::Weapon)
    when 2 # Armours
      item.is_a?(RPG::Armor)
    when 3 # Key Items
      item.is_a?(RPG::Item) && item.key_item?
    when 4 # All Items
      item.is_a?(RPG::Item)
    else
      item.is_a?(RPG::Item) && item.note.include?("<itemp " + $game_variables[VARIABLE_CAT].to_s + ">")
    end
  end
  #--------------------------------------------------------------------------
  # ● Otherwise weapons and armours are not clickable - hopefully this won't
  #   have any unforseen consequences.
  #--------------------------------------------------------------------------
  def enable?(item)
    return true
  end
end
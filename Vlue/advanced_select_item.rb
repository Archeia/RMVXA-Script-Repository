#Advanced Select Item v1.1.1
#----------#
#Features: Let's you decide what items appear in Select Key Item.
#
#Usage:    Set up category in KEYITEM_CATEGORY as needed and use the supplied
#           functions to determine the behaviour of Select Key Item in game.
#
#          keyitem_category(id)   - Determines what category is ued
#          keyitem_column(value)  - Sets the number of columns to be displayed
#          keyitem_height(value)  - Sets the number of rows to be displayed
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
 
#Select Key Item defaults: [category,column,height)
$key_item_details = [0,2,4]
 
#The fun parts! Setting the categories. Less simple. It goes like this:
#
#      id => ["mod",[ [:symbol,condition,inventory] ... ] ] ],
#
#  You can add as many comparisons as you want, seperated by a comma
#   There are examples below to show you how to do it, and never fear
#   to ask questions!
#
# "mod" is either "&" or "|", where "&" will show each item that
#   satisfies every comparison, and "|" will show each item that
#   satisfies at least one comparison
#
# Options for :symbol include:
#   :weapon, :armor, :item, :key_item, :note, :script
#
# Condition is what determines if the item makes it to the list!
#  For :weapon, :armor, :item, and :key_item, condition is true or false.
#  For :note, it's whatever you want, and if that is found in the note box of
#    the item, then it's included! (That's right, you can make your own notetags)
#  For :script, it's whatever script call you want it to be
 
#This variable will store whether the chosen item was a weapon, armor or item
#And will be either 0 for weapon, 1 for armor, or 2 for item
SECONDARY_KI_VARIABLE = 10
 
KEYITEM_CATEGORY = {
   0 => ["&",[[:key_item, true]]],
   1 => ["|",[[:weapon, true],[:note, "<is_tool>"]]],
   2 => ["&",[[:note, "<is_tool>"]]],
   3 => ["&",[[:script, "item.params[2] > 15", true]]],
   }
 
 
class Window_KeyItem
  alias ki_start start
  def start
    make_item_list
    self.height = $key_item_details[2]*line_height
    ki_start
  end
  def include?(item,id)
    return false if KEYITEM_CATEGORY[$key_item_details[0]].nil?
    begin
      return false if item.nil?
      symbol = ki_symbol(id)
      extra = param(id)
      case symbol
      when :weapon
        if extra
          return true if item.is_a?(RPG::Weapon)
        else
          return true if !item.is_a?(RPG::Weapon)
        end
      when :armor
        if extra
          return true if item.is_a?(RPG::Armor)
        else
          return true if !item.is_a?(RPG::Armor)
        end
      when :item
        if extra
          return true if item.is_a?(RPG::Item)
        else
          return true if !item.is_a?(RPG::Item)
        end
      when :key_item
        if extra
          return true if item.is_a?(RPG::Item) && item.key_item
        else
          return true if !item.is_a?(RPG::Item) && !item.key_item
        end
      when :note
        #msgbox(extra)
        return true if item.note.include?(extra)
      when :script
        return true if eval(extra)
      end
      return false
    rescue
      return false
    end
  end
  def make_item_list
    @data = nil
    if !category.nil?
      category.each_index do |id|
        if all_items?(id)
          weapon = $data_weapons.select {|item| include?(item,id) }
          armor = $data_armors.select {|item| include?(item,id) }
          items = $data_items.select {|item| include?(item,id) }
          if @data.nil?
            @data = weapon + armor + items
          else
            if modifier == "&"
              @data & weapon
              @data & armor
              @data & items
            elsif modifier == "|"
              @data | weapon
              @data | armor
              @data | items
            else
              @data = weapon + armor + items
            end
          end
        else
          items = $game_party.all_items.select {|item| include?(item,id) }
          if @data.nil?
            @data = items
          else
            if modifier == "&"
              @data = @data & items
            elsif modifier == "|"
              @data = @data | items
            else
              @data += items
            end
          end
        end
      end
    else
      @data = $game_party.all_items.select {|item| include?(item,0) }
    end
  end
  def enable?(item)
    return true
  end
  def col_max
    return $key_item_details[1]
  end
  def category
    KEYITEM_CATEGORY[$key_item_details[0]][1]
  end
  def ki_symbol(id)
    KEYITEM_CATEGORY[$key_item_details[0]][1][id][0]
  end
  def param(id)
    KEYITEM_CATEGORY[$key_item_details[0]][1][id][1]
  end
  def all_items?(id)
    KEYITEM_CATEGORY[$key_item_details[0]][1][id][2]
  end
  def modifier
    KEYITEM_CATEGORY[$key_item_details[0]][0]
  end
  def on_ok
    result = item ? item.id : 0
    $game_variables[$game_message.item_choice_variable_id] = result
    $game_variables[SECONDARY_KI_VARIABLE] = 0 if item.is_a?(RPG::Weapon)
    $game_variables[SECONDARY_KI_VARIABLE] = 1 if item.is_a?(RPG::Armor)
    $game_variables[SECONDARY_KI_VARIABLE] = 2 if item.is_a?(RPG::Item)
    close
  end
end
 
class Game_Interpreter
  def keyitem_category(id)
    $key_item_details[0] = id
  end
  def keyitem_column(id)
    $key_item_details[1] = id
  end
  def keyitem_height(id)
    $key_item_details[2] = id
  end
end
 
class RPG::BaseItem
  def ==(object)
    return false if object.nil?
    self.name == object.name && self.id == object.id
  end
end
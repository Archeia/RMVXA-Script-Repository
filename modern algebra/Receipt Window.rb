#==============================================================================
#    Receipt Window
#    Version: 1.1
#    Author: modern algebra (rmrk.net)
#    Date: March 16, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to show a window at the top of the screen with any
#   items you identify. Unlike a text box, the window will not prevent the 
#   player from moving or engaging with other events. The purpose of the script
#   is to allow you to show when a player finds items without having to pause 
#   the gameplay. It can be set to work automatically whenever items are gained
#   or lost through event commands on the map, or you can show things manually.
#   You control whether it is automatic or manual by an in-game switch of your
#   choice.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    There are a number of configuration options for this script. See the 
#   Editable Region starting at line 94 for instructions on those and what
#   each option does.
#
#    This script can be set to show the window automatically or manually 
#   through the operation of a switch. You choose which switch by setting the
#   ID of your choice at line 101.
#
#    Alternatively, the window can be set manually to show items of your 
#   choice (whether switch is on or not) with the following command:
#     
#        show_item_receipt(label, item_1, item_2, ..., item_n)
#
#    label  - this should be a string, and if added it will take up the entire
#      first line of the window. Message codes are recognized, but if you use 
#      double quotes (" "), then you will need to use two backslashes before 
#      special codes instead of one. In other words, it is \\c[16], not \c[16].
#      This can be excluded, in which case it will use the default label set at
#      line 102.
#    item_n - These are the items to show in the window, and you put as many of
#      them as you want in the window. These can be either RPG::BaseItem 
#      objects, like $data_items[n] (Item n in the Database) or you can use
#      arrays to hold them. The format for those arrays are any of the 
#      following, where id is the ID of the item, weapon, or armor; and n is
#      the amount:
#          [:I, id, n]         -> Item
#          [:W, id, n]         -> Weapon
#          [:A, id, n]         -> Armor
#          [:G, n]             -> Gold
#          [:S, icon, text, n] -> Special : icon = icon_index; text = "string"
#
#    Since there are space limitations in the script field, it is recommended
#   that you set each of the items to short local variables. See the example.
#
#  EXAMPLE:
#
#    The following is placed in the Script event command.
#
#      lab  = "\\c[16]You Received:\\c[0]"
#      i1 = $data_items[5]
#      i2 = [:A, 7]
#      i3 = [:W, 4, 2]
#      i4 = [:S, 217, "Lamp"]
#      i5 = [:S, 13, "", 200]
#      show_item_receipt(lab, i1, i2, i3, i4, i5)
#
#  That would show up as:
#
#    You received:
#    [] Item 5        [] Armor 7
#    [] Weapon 4  +2  [] Lamp
#    []         2000
#
#  The [] are icons, and Item 5, Armor 7, & Weapon 4 would show up as the names
#  of those items.
#
#    Finally, you can use the following code to manually add extra items to the
#   window. If in the same frame, it will show up with the most recently added
#   items. Use the following code:
#
#        add_to_receipt(item_1, item_2, ..., item_n)
#
#    where item_1 ... item_n are the same as described at line 42.
#==============================================================================

$imported ||= {}
$imported[:MA_ReceiptWindow] = true
$imported[:"MA_ReceiptWindow_1.1"] = true

MARW_CONFIGURATION = {
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#    BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  # manual_switch: If the Switch with the specified ID is OFF, then the item 
  #  receipt window is updated automatically everytime the party receives a new 
  #  item, weapon, armor, or gold through an event. If the switch is ON, the 
  #  item receipt window will only ever show when you manually show it with the
  #  call script: show_item_receipt (See line 34).
  manual_switch:   22,  
  vocab_label_default: "",
  # gain_label: Text above items when gaining. Can use message codes
  vocab_gain_label: "\\c[16]You received:\\c[0]",
  # lose_label: Text above items when losing. Can use message codes
  vocab_lose_label: "\\c[16]You lost:\\c[0]", 
  # vocab_amount: Text to show amount of item gained or lost. Passed through
  #  sprintf with the amount as the argument.
  vocab_amount: "%+d",
  open_se: ["Chime2"], # SE played when window opens. ["Name", volume, pitch]
  # open_gain_se: SE played when window opens and gaining. ["Name", volume, pitch]
  open_gain_se: ["Chime2"], 
  # open_lose_se: SE played when window opens and losing. ["Name", volume, pitch]
  open_lose_se: ["Down1"], 
  close_se:        [], # SE played when window closes. ["Name", volume, pitch]
  frames_to_show: 120, # The number of frames to leave the window open for
  gold_icon:      262, # The icon to signify when the party is receiving gold
  colour_name:      0, # Colour of the Name text. Must be 0-31
  colour_amount:    0, # Colour of the amount text. Must be 0-31
  window_width:   416, # Width of the receipt window. If -1, then full screen
  window_x:        -1, # X position of the receipt window. If -1, centred
  windowskin:      "", # The skin of the receipt window. If "", uses default
  window_tone:     [], # The tone of the window: [R, G, B]. If [], uses default
  window_opacity: 255, # The opacity of the receipt window.
  window_fontname: "", # Font to be used in receipt window. If "", uses default
  window_fontsize: -1, # Size of text in receipt window. If -1, uses default
  line_height:     -1, # The height of lines in the window. If -1, uses default
  column_num:       2, # The number of columns in the window
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#    END Editable Region
#//////////////////////////////////////////////////////////////////////////////
}

[:open_se, :open_gain_se, :open_lose_se, :close_se].each { |sym|
  MARW_CONFIGURATION[sym] = (MARW_CONFIGURATION[sym].is_a?(Array) &&
    !MARW_CONFIGURATION[sym].empty?) ? RPG::SE.new(*MARW_CONFIGURATION[sym]) : nil
}

#==============================================================================
# ** MARW_ItemReceipt
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This Struct holds a list of items to be shown in the Receipt Window
#==============================================================================

MARW_ItemReceipt = Struct.new(:label, :item_array, :balance, :closed)

#==============================================================================
# ** Game_Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - marw_item_number_plus_equips
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item Number and Equips
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def marw_item_number_plus_equips(item)
    equip_num = 0
    members.each { |actor| equip_num += actor.equips.count(item) }
    item_number(item) + equip_num
  end
end

#==============================================================================
# ** Game Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new attr_accessor - marw_queue; marw_label_default
#    aliased method - initialize
#    new method - show_receipt_window; add_to_receipt
#==============================================================================

class Game_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :marw_queue
  attr_reader   :marw_label_default
  def marw_label_default=(value)
    show_receipt_window(value, [], 0) if value != @marw_label_default
    @marw_label_default = value
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias marw_initializ_4ks1 initialize
  def initialize(*args, &block)
    @marw_queue = []
    @marw_label_default = MARW_CONFIGURATION[:vocab_label_default]
    marw_initializ_4ks1(*args, &block) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Show Receipt Window
  #    label      : the text to identify what is happening
  #    item_array : An array of items to draw
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def show_receipt_window(label, item_array, balance = 0)
    @marw_queue.push(MARW_ItemReceipt.new(label, item_array, balance, false))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add to Receipt
  #    item : An item to add to the last receipt in queue
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def add_to_receipt(item)
    balance = item.is_a?(Array) ? item[2] ? item[2].to_i <=> 0 : 0 : 0
    if @marw_queue.empty? || @marw_queue.all? { |receipt| 
      receipt.closed || balance != receipt.balance }
      label = (balance == 0 ? marw_label_default : (balance > 0 ? 
        MARW_CONFIGURATION[:vocab_gain_label] : MARW_CONFIGURATION[:vocab_lose_label]))
      show_receipt_window(label, [], balance)
    end
    @marw_queue.reverse.each { |receipt| 
      if !receipt.closed && receipt.balance == balance
        receipt.item_array.push(item) 
        break
      end
    }
  end
end

#==============================================================================
# ** Game Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - command_125, command_126, command_127, command_128
#    new methods - show_receipt_window; add_to_receipt; marw_format_item_array
#==============================================================================

class Game_Interpreter
  [125, 126, 127, 128].each { |code| 
    alias_method(:"marw_command#{code}_8qu7", :"command_#{code}") }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Gold
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_125(*args, &block)
    old_value = $game_party.gold
    marw_command125_8qu7(*args, &block) # Call Original Method
    # Add to receipt if the possessed amount of gold has changed
    if $game_party.gold != old_value && !$game_switches[MARW_CONFIGURATION[:manual_switch]]
      add_to_receipt([:G, $game_party.gold - old_value])
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_126(*args, &block)
    old_value = $game_party.marw_item_number_plus_equips($data_items[@params[0]])
    marw_command126_8qu7(*args, &block) # Call Original Method
    # Add to receipt if the possessed number of this item has changed
    new_value = $game_party.marw_item_number_plus_equips($data_items[@params[0]])
    update_item_receipt(:I, @params[0], new_value, old_value)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Weapon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_127(*args, &block)
    old_value = $game_party.marw_item_number_plus_equips($data_weapons[@params[0]])
    marw_command127_8qu7(*args, &block) # Call Original Method
    # Add to receipt if the possessed number of this weapon has changed
    new_value = $game_party.marw_item_number_plus_equips($data_weapons[@params[0]])
    update_item_receipt(:W, @params[0], new_value, old_value)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Armor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def command_128(*args, &block)
    old_value = $game_party.marw_item_number_plus_equips($data_armors[@params[0]])
    marw_command128_8qu7(*args, &block) # Call Original Method
    # Add to receipt if the possessed number of this armor has changed
    new_value = $game_party.marw_item_number_plus_equips($data_armors[@params[0]])
    update_item_receipt(:A, @params[0], new_value, old_value)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Item Receipt
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_item_receipt(code, id, new_value, old_value)
    if new_value != old_value && !$game_switches[MARW_CONFIGURATION[:manual_switch]]
      add_to_receipt([code, id, new_value - old_value])
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Show Receipt Window
  #    *items - The items to show, in the format: [:I or :W or :A, ID]
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def show_item_receipt(*items)
    item_data = []
    # Extract first and last element if meant to be label and balance
    label = items[0].is_a?(String) ? items.shift : $game_map.marw_label_default
    balance = items[-1].is_a?(Integer) ? items.pop : 0
    # Cycle through items and properly format them
    for item in items do item_data << marw_format_item_array(item) end
    $game_map.show_receipt_window(label, item_data, balance)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add to Receipt
  #    item : An item to add to the last receipt in queue
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def add_to_receipt(*items)
    items.each {|item| $game_map.add_to_receipt(marw_format_item_array(item)) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format Item Array
  #    item_array : an array signifying an item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def marw_format_item_array(item_array)
    if item_array.is_a?(RPG::BaseItem)
      return [item_array.icon_index, item_array.name]
    elsif item_array.is_a?(Array)
      amount = (item_array[2].is_a?(Integer) ? sprintf(MARW_CONFIGURATION[:vocab_amount], item_array[2]) : "")
      return case item_array[0]
      when :I, :i, :item,    :Item,    0
        item = $data_items[item_array[1]]
        [item.icon_index, item.name, amount] 
      when :W, :w, :weapon,  :Weapon,  1 
        item = $data_weapons[item_array[1]]
        [item.icon_index, item.name, amount] 
      when :A, :a, :armor,   :Armor,   2
        item = $data_armors[item_array[1]]
        [item.icon_index, item.name, amount] 
      when :G, :g, :gold,    :Gold,    3
        [MARW_CONFIGURATION[:gold_icon], "", sprintf(MARW_CONFIGURATION[:vocab_amount], item_array[1])]
      when :S, :s, :special, :Special, 4
        item_array[3] = sprintf(MARW_CONFIGURATION[:vocab_amount], item_array[3]) if item_array[3].is_a?(Integer)
        item_array.drop(1)
      else item_array
      end
    else
      item_array
    end
  end
end

#==============================================================================
# ** Window_ItemReceipt
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window displays the items received.
#==============================================================================

class Window_ItemReceipt < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize
    @label = ""
    @item_array = []
    @balance = 0
    @frames_to_close = 0
    super(0, 0, window_width, window_height)
    self.windowskin = Cache.system(MARW_CONFIGURATION[:windowskin]) unless 
      MARW_CONFIGURATION[:windowskin].empty?
    self.opacity = MARW_CONFIGURATION[:window_opacity]
    self.openness = 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh
    contents.clear
    reset_font_settings
    @draw_y = 0
    draw_label
    for i in 0...@item_array.size do draw_entry(i) end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_label
    unless @label.empty?
      draw_text_ex(0, @draw_y, @label)
      @draw_y += calc_line_height(@label, true)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_entry(i)
    item = @item_array[i]
    col_num = MARW_CONFIGURATION[:column_num]
    w = (contents_width / col_num) - (spacing / 2)
    x = (i % col_num)*(w + spacing)
    y = @draw_y + ((i / col_num)*line_height)
    item.is_a?(Array) ? draw_entry_array(x, y, w, item) : draw_entry_other(x, y, w, item)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Entry Array
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_entry_array(x, y, w, array)
    draw_icon(array[0].to_i, x, y + (line_height - 24) / 2)
    change_color(text_color(MARW_CONFIGURATION[:colour_name]))
    tw_r = array[2] ? text_size(array[2].to_s).width + 4 : 0
    draw_text(x + 24, y, w - 24 - tw_r, line_height, array[1].to_s)
    change_color(text_color(MARW_CONFIGURATION[:colour_amount]))
    draw_text(x + 24, y, w - 24, line_height, array[2].to_s, 2) if array[2]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Other
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_entry_other(x, y, w, item)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Show
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def show(receipt)
    self.openness = 0
    @label = receipt.label
    @item_array = receipt.item_array
    @balance = receipt.balance
    remake_window
    reposition_window
    open
    marw_play_open_se(receipt.balance)
    refresh
    @frames_to_close = MARW_CONFIGURATION[:frames_to_show]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Play Open SE
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def marw_play_open_se(balance)
    if balance == 0
      MARW_CONFIGURATION[:open_se].play if MARW_CONFIGURATION[:open_se]
    elsif balance > 0
      MARW_CONFIGURATION[:open_gain_se].play if MARW_CONFIGURATION[:open_gain_se]
    else
      MARW_CONFIGURATION[:open_lose_se].play if MARW_CONFIGURATION[:open_lose_se]
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update(*args, &block)
    super(*args, &block)
    self.visible = !($game_message.visible && $game_message.position == 0)
    # Update Timer
    if visible
      if @frames_to_close > 0
        @frames_to_close -= 1
      elsif self.openness > 0 && !@closing
        MARW_CONFIGURATION[:close_se].play if MARW_CONFIGURATION[:close_se]
        close
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Tone
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_tone(*args, &block)
    !MARW_CONFIGURATION[:window_tone].size.between?(3,4) ? super(*args, &block) :
      self.tone.set(*MARW_CONFIGURATION[:window_tone]) 
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Remake Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def remake_window
    self.width = window_width
    self.height = window_height
    create_contents
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Reposition Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reposition_window
    config = MARW_CONFIGURATION
    self.x = config[:window_x] == -1 ? (Graphics.width - window_width) / 2 : config[:window_x]
    self.y = 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Reset Font Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reset_font_settings(*args, &block)
    super(*args, &block)
    self.contents.font.name = MARW_CONFIGURATION[:window_fontname] unless
      MARW_CONFIGURATION[:window_fontname].empty?
    self.contents.font.size = MARW_CONFIGURATION[:window_fontsize] unless
      MARW_CONFIGURATION[:window_fontsize] < 8
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Window Width/Height
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def window_width
    MARW_CONFIGURATION[:window_width] == -1 ? Graphics.width : MARW_CONFIGURATION[:window_width]
  end
  def window_height
    if @item_array.empty?
      standard_padding*2 + line_height
    else
      col_num = MARW_CONFIGURATION[:column_num]
      h = standard_padding*2
      h += line_height unless @label.empty?
      h += line_height*(@item_array.size / col_num)
      h += line_height if (@item_array.size % col_num) != 0
      h
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Line Height
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def line_height(*args, &block)
    MARW_CONFIGURATION[:line_height] < 18 ? super(*args, &block) : MARW_CONFIGURATION[:line_height]
  end
  def spacing; 16; end
end 

#==============================================================================
# ** Scene_Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - create_all_windows; update_all_windows
#    new methods - create_item_receipt_window; update_item_receipt_checks
#==============================================================================

class Scene_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create All Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias marw_creatallwins_2ku8 create_all_windows
  def create_all_windows(*args, &block)
    marw_creatallwins_2ku8(*args, &block) # Call Original Method
    create_item_receipt_window
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Item Receipt Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_item_receipt_window
    @item_receipt_window = Window_ItemReceipt.new
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update All Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias marw_updallwindows_5gz6 update_all_windows
  def update_all_windows(*args, &block)
    marw_updallwindows_5gz6(*args, &block) # Call Original Method
    update_item_receipt_checks
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Item Receipt Checks
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_item_receipt_checks
    if !$game_map.marw_queue.empty?
      $game_map.marw_queue.each { |receipt| receipt.closed = true }
      if @item_receipt_window.close?
        while !$game_map.marw_queue.empty?
          receipt = $game_map.marw_queue.shift
          break unless receipt.item_array.empty?
        end
        @item_receipt_window.show(receipt) unless receipt.nil?
      end
    end
  end
end
#==============================================================================
#    Customizable Main Menu
#    Version: 1.0c
#    Author: modern algebra (rmrk.net)
#    Date: February 17, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script is a base menu script which allows you to create custom menu
#   commands and to move, add, or remove them from the menu easily. Not only  
#   can you easily add a command which directly calls a scene, you can also add 
#   commands which call common events or which call a particular method (the
#   method needs to be defined). At the same time, the script is also designed
#   to recongize and include any commands that are added by another script, 
#   without requiring setup in this one.
#
#    Additionally, this script allows easy creation of custom windows which 
#   show simple data, so you are not limited to just the gold window - you 
#   could, for instance, show data such as the value of particular variables or
#   the playtime, etc.. These optional windows can be added and removed at 
#   will, and they show up beneath the command window in the menu.
#
#    Since too many windows could overlap with the command window, this script
#   also allows you to set a row max for the command window so that you need to
#   scroll the window down to see the other commands. Additionally, you can
#   change the width of the command and data windows and the Menu Status window
#   will now better accomodate different resolutions. Finally, you can also 
#   change the alignment so that the status window is on the left and the 
#   command window is on the right.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main and 
#   below Materials. If you are using any scripts which require this menu, then 
#   this script should be above them as well.
#
#    Aside from that, you can go to the Editable Region at line 64 to figure 
#   out how to configure the menu. If you do not change anything, then the 
#   menu will operate exactly like the default menu.
#
#    I understand that the configuration can be very difficult. If you do not
#   understand it, please do not hesitate to visit me at RMRK and ask for help
#   adding any specific command or window to the menu. The topic link is:
#
#       http://rmrk.net/index.php/topic,44906.0.html
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Thanks:
#
#    Yanfly, as the configuration for my Full Status Menu in VX was inspired 
#   by his Menu scripts for VX, and this script borrows from the FSCMS
#==============================================================================

$imported = {} unless $imported
$imported[:MA_CustomizableMenu] = true

#==============================================================================
# *** MA_CustomizableMenu
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module holds configuration data for the CMS
#==============================================================================

module MA_CustomizableMenu
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #  Editable Region
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  CUSTOM_COMMANDS - This is where you can set up your own commands. You can 
  # add here almost any type of command you want here as long as you know the
  # syntax. Given that, however, I understand that it may be difficult to 
  # understand for the scripter, so if you want any assistance in adding a 
  # command to the menu for any purpose, then I encourage you to ask me at this 
  # script's thread at RMRK and I will be happy to oblige. That said, I will 
  # nevertheless go over everything here, starting with the simplest setups and 
  # and then going into the rest. 
  #
  #  Firstly, I will note that every new command requires a unique symbol by
  # which you can identify it and add it to the command list. I will refer to 
  # that symbol as :unique in all generic examples, but essentially it can be
  # anything you choose and must be different for each command. The format for
  # all of the following commands will be:
  #
  #    :unique => [],
  #
  #  The content of the array will change depending on what you are trying 
  # to do, so I will go over everything in detail.
  #``````````````````````````````````````````````````````````````````````````
  #  To call a custom scene, the format is as follows:
  #    :unique => ["command name", enable_condition, :Scene_Name, select_actor],
  #
  #  Note that if it ends up being too long, you can press enter after any of 
  # the commas and split it into more than one line. That is fine.
  #
  #  To help explain each of these parameters, I will use an example of adding
  # the Debug scene to the menu:
  #    :debug => ["Debug", true, :Scene_Debug],
  #  
  #    -Command Name-
  #
  #  So, the first thing is the name. This is what shows up in the command list
  # when the menu is opened. So, if :debug is added to COMMAND_LIST (see below
  # at line xx), then when the player opens the menu, they will see that Debug
  # is there. The command name must have quotations around it.
  #
  # However, you can also evaluate an expression to return the name. To do so,
  # all you need to do is make a symbol with the expression you want to call. 
  # So, for instance, if you used something like:
  #    :debug => [:"Vocab::Continue", true, :Scene_Debug]
  #
  #  When you went to the menu, your Debug command would show up as whatever 
  # word you set for Continue in the Terms section of the Database.
  #
  #    -Enable Condition-
  #
  #  Second, we have the enable_condition. This allows you to set a condition 
  # such that, if it is not met, the command is unselectable. In our example it
  # is true. This means that it will always be enabled. However, there are a 
  # number of ways you can use an enable condition. I will go over them one by 
  # one:
  #
  #  1. Always enabled - to set a command to always be enabled, simply use 
  #     true, as in the example.
  #  2. In-game switch - if you use an integer instead of true, then the 
  #     command can only be selected if the switch with that ID is on. EX:
  #      :debug => ["Debug", 7, :Scene_Debug],
  #     The Debug command will only be enabled if Switch 7 is on.
  #  3. Method call - This requires some knowledge of scripting, but this 
  #     allows you to call a method in the Window_MenuCommand class. Just put
  #     a symbol of the method name. By default, there are three that might be
  #     relevant - 
  #       (a) :main_commands_enabled - enabled when Skill, Equip, Status are
  #       (b) :save_enabled - enabled when Save is
  #       (c) :formation_enabled - enabled when Formation is
  #     EX:
  #       :debug => ["Debug", :main_commands_enabled, :Scene_Debug],
  #     The Debug command would only be enabled if Status, Equip, and Skill
  #     are (by default, this is when there are actors in the party).
  #  4. Expression - This also requires some knowledge of scripting, but this
  #     option allows you to set the enabled condition to be the result of 
  #     any scripting expression. Just set it up as a string Ex:
  #       :debug => ["Debug", "$game_variables[10] > 5", :Scene_Debug],
  #     The Debug command would only be enabled if the variable with ID 10 
  #     had a value greater than 5. 
  #
  #    -Scene_Name-
  #
  #  This is a symbol containing the name of the class you want to run. In our
  # example, we are calling :Scene_Debug, but we could also use any scene, 
  # such as :Scene_Item, :Scene_Equip, :Scene_Load, etc. This is most useful
  # if you are installing a custom script that includes a scene and you want
  # it accessible through the menu. 
  #
  #  However, despite the fact that I labelled it as Scene_Name, you can do 
  # more than just call a scene. You can also:
  #    (1) call a common event. To do that, just put the ID of the common
  #       event you want to call. Ex:
  #         :sonata => ["Sonata", true, 14],
  #       That would call common event 14 when you choose the "Sonata" option
  #       from the menu.
  #    (2) evaluate an expression. To do this, just put the expression you
  #       want to evaluate when the player selects this option as a string. EX:
  #         :rmrk => ["RMRK", true, 
  #                   "Thread.new { system(\"start http://rmrk.net\") }
  #                    @command_window.activate"],
  #       That would be a command called "RMRK" which, when selected, would 
  #       open up the RMRK website in the player's browser.
  #
  #    -Select Actor-
  #
  #  If you add a fourth entry, you can do even more. In particular, if you 
  # add a true after your command:
  #
  #    :debug => ["Debug", true, :Scene_Debug, true],
  #
  # Then that will mean that when the player selects the Debug command, it 
  # will then go on to permit the player to select an actor. That is not 
  # useful for Debug, but would be useful for any scene that shows something
  # about a particular actor. For instance, if you were to make a command
  # for showing Equip (which you don't need to do, since it is default), you
  # could do the following:
  #
  #    :equip => [:"Vocab::equip", :main_commands_enabled, :Scene_Equip, true],
  #
  # Then, when the player selects the Equip option, it will behave exactly
  # as the Equip option should - it will let you select an Actor, and it will
  # then bring you to that actor's Equip scene.
  #
  #  However, like with Scene_Name, although I have called this option 
  # Select_Actor, that is not the only thing you can put here, although the 
  # others require some scripting knowledge. In any case, you can also call a 
  # method - it can be useful, but you might need a script specifically 
  # designed to use it. As an example though, the following code would be 
  # identical to using true in this position:
  #
  #   :equip => [:"Vocab::equip", :main_commands_enabled, :Scene_Equip, 
  #              :command_personal],
  #``````````````````````````````````````````````````````````````````````````
  #   EXAMPLES
  #
  #  To assist in your understanding of this script, I will show you, 
  # essentially, how you could add the default commands. Obviously, it is 
  # unnecessary to do this, since they are set up this way by default, but I
  # just figure that since you know how the default commands behave, it will 
  # help you understand how to use custom commands if you see how that 
  # behaviour could be captured through the custom command framework. 
  # Additionally, I will add just a few other examples. Without further ado:
  #
  #  CUSTOM_COMMANDS = {
  #    :item =>        [:"Vocab::item", :main_commands_enabled, :Scene_Item],
  #    :skill =>       [:"Vocab::skill", :main_commands_enabled, :Scene_Skill,
  #                     true],
  #    :equip =>       [:"Vocab::equip", :main_commands_enabled, :Scene_Equip,
  #                     true],
  #    :status =>      [:"Vocab::status", :main_commands_enabled, :Scene_Status,
  #                     true],
  #    :formation =>   [:"Vocab::formation", :formation_enabled, 
  #                     "command_formation"],
  #    :save =>        [:"Vocab::save", :save_enabled, :Scene_Save],
  #    :game_end =>    [:"Vocab::game_end", true, :Scene_Title],
  #    :rmrk =>        ["RMRK", true, 
  #                     "Thread.new { system(\"start http://rmrk.net\") }; @command_window.activate"],
  #    :debug =>       ["Debug", "$TEST", :Scene_Debug],
  #    :cust_scene1 => ["Command Name", 5, :Scene_Custom1],
  #    :cust_scene2 => ["Command Name", :main_commands_enabled, :Scene_Custom2,
  #                     true],
  #    :commonevent => ["Camp", "$game_party.item_number($data_items[7]) > 0",
  #                     13],
  #  }
  #
  #    :rmrk would open up the RMRK website when selected. It is always enabled
  #    :debug would open the Debug scene, but is only enabled in Test Play
  #    :cust_scene1 would call Scene_Custom1 (not a real scene), but is only
  #      enabled if Switch 5 is on.
  #    :cust_scene2 would call Scene_Custom2 (not a real scene), but would only
  #      be available when there are actors in the party
  #    :commonevent would call Common Event 13 if the party has one or more of
  #      Item 7. 
  #
  #  All that said, it is important to remember that none of the custom 
  # commands will show up in the menu unless you add their unique identifier
  # into the COMMAND_LIST array, just below this hash, around line 275. That is
  # a REQUIRED step.
  CUSTOM_COMMANDS = { # <- Do not touch!
    # Call Debug scene - enabled always
    :debug => ["Debug", true, :Scene_Debug],
    # Opens up RMRK in your browser - enabled always
    :rmrk =>  ["RMRK", true, 
              "Thread.new { system(\"start http://rmrk.net\") }
              @command_window.activate"],
    # Call Load scene - enabled if a save file is in the game folder
    :load =>  [:"Vocab::continue", "DataManager.save_file_exists?", :Scene_Load],
    # Call common event 4 - enabled if party has Item 7 (a tent).
    :camp =>  ["Camp", "$game_party.has_item?($data_items[7])", 4],
  } # <- Do not touch!
  # COMMAND_LIST - In this array, add the unique identifer of the custom 
  # commands that you want added to the menu. Additionally, there are 7 default 
  # commands which you can add, each corresponding to the default menu 
  # commands. These are:
  #   :item, :skill, :equip, :status, :formation, :save, and :game_end.
  #
  #  You can, of course, delete them from the array and then they won't be 
  # available. In fact, no command will show up unless it is included in this 
  # array! You can modify the contents of this array in-game with the following
  # script calls: 
  #
  #    add_menu_command(:unique, index)
  #    remove_menu_command(:unique)
  #
  #  :unique is the unique identifier of the custom or default command you want
  # to add or remove.
  #  index is an integer which allows you to choose where the command shows up
  # in the list when it is added. If you exclude it and just put:
  #
  #    add_menu_command(:unique)
  # 
  # then it will be the last command in the command window.
  COMMAND_LIST = [ # <- Do not touch!
    :item, 
    :skill, 
    :equip,
    :status,
    :formation,
    :save,
    :game_end,
  ] # <- Do not touch!
  #  COMMAND_WINDOW_ROWMAX - This lets you determine how many commands will be
  # in the command window before the rest are hidden and only become visible
  # when scrolling down. If set to 0, then it will show all commands at once.
  COMMAND_WINDOW_ROWMAX = 0
  #  COMMAND_WINDOW_WIDTH - This determines how wide the command window and 
  # optional windows are. If you need more room horizontal room for your 
  # commands, then just increase this value.
  COMMAND_WINDOW_WIDTH = 160
  #  COMMAND_WINDOW_ON_RIGHT - If set to true, then the command window will be
  # on the right of the screen and the actor window will be on the left.
  COMMAND_WINDOW_ON_RIGHT = false 
  #  CUSTOM_WINDOWS - Here you can set up your own windows to show simple 
  # data, like the gold window. Basically, you can show a label, and then real
  # data. The format is as follows:
  #
  #    :unique => ["Label", value],
  #
  #  As with the CUSTOM_COMMANDS, :unique must be a unique identifier so that 
  # you can add it into the OPTIONAL_WINDOWS_LIST.
  #
  #  "Label" is a String which will show up on the left hand side. It 
  # recognizes special message codes, but if you are using double quotation
  # marks (" "), then you need to use \\, not \. Ie, it would be \\c[16], not
  # \c[16]. 
  #
  #  value can show one of three things:
  #   (1) The value of a variable - to show this, just put the ID of the 
  #      variable you want to show. 
  #   (2) Any expression you evaluate - this requires some scripting knowledge,
  #      but if you know the correct code then just put it in a string. Ex:
  #        :steps =>     ["\\c[6]Steps\\c[0]", "$game_party.steps"],
  #        :keys =>      ["Keys", "$game_party.item_number($data_items[8])"],
  #   (3) Playtime - To show playtime, you need to just use :playtime. Ex:
  #        :playtime =>  ["\\i[280]", :playtime],
  #   (4) Other - If you know how to script, then it is possible to add 
  #      special data as well, like playtime.
  #
  #  Additionally, you can make windows that have more than one data line, 
  # simply by adding further lines. So, for instance:
  #
  #   :combined => ["\\i[280]", :playtime, 
  #                 "\\i[467]", "$game_party.steps", 
  #                 "\\i[347]", 5],
  #
  #  That would show all of that data in one line. It is the same format, they
  # just need to be within the same [].
  CUSTOM_WINDOWS = { # <- Do not touch!
    :playtime =>  ["\\i[280]", :playtime],
    :variable5 => ["\\i[122]", 5],
    :steps =>     ["\\c[6]Steps\\c[0]", "$game_party.steps"],
    :item8 =>     ["Keys", "$game_party.item_number($data_items[8])"],
    :combined =>  ["\\i[280]", :playtime, 
                   "\\i[467]", "$game_party.steps", 
                   "\\i[347]", 5,
                   "\\i[262]", "$game_party.gold"],
  } # <- Do not touch!
  #  OPTIONAL_WINDOWS_LIST - Like the COMMAND_LIST, any windows you want to add
  # to the menu need to be included in this array. Just add the :unique 
  # identifier, and that is the position the window will show up. The only
  # default option is :gold, which shows the regular gold window. You can 
  # delete it if you want. To add windows in-game, you can use the following
  # script calls:
  #   
  #    add_menu_window(:unique, index)
  #    remove_menu_window(:unique)
  #
  #  :unique is the unique identifier of the window you want to add or remove.
  #  index is an integer which allows you to choose where the command shows up
  # in the list when it is added. If you exclude it and just put:
  #
  #    add_menu_window(:unique)
  # 
  # then it will be the placed at the bottom.
  OPTIONAL_WINDOWS_LIST = [ # <- Do not touch!
    :gold, 
  ] # <- Do not touch!
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  END Editable Region
  #//////////////////////////////////////////////////////////////////////////
  #============================================================================
  # *** Alter_MenuStatus
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  This module is to be mixed in to the metaclass to the Window_MenuStatus 
  # created in Scene_Menu, since I don't want to change it in any other scene.
  #============================================================================
  
  module Alter_MenuStatus
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Draw Actor Simple Status
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def draw_actor_simple_status(actor, x, y, *args, &block)
      y += (item_height - 96) / 2
      if contents_width.between?(346, 394)
        # Only need to alter the x value if within this range.
        if contents_width < 354
          x -= (354 - contents_width)
        elsif contents_width > 360
          x += (contents_width - 360) / 2
        end
        super(actor, x, y, *args, &block)
      else # If outside that range, will need to reduce width
        if contents_width < 346
          x -= 8
          room_needed = 346 - contents_width
          space = room_needed > 4 ? 4 : 8 - room_needed
          # Take first four pixels off w2, then equally off w1 and w2
          w1 = room_needed > 8 ? 112 - ((room_needed - 8) / 2) : 112
          w2 = contents_width - w1 - space - x
        else
          x += 17
          room_needed = contents_width - 394
          space = 8
          w2 = 124
          if room_needed > 8
            w1 = 120
            if room_needed > 16
              space += 8
              w2 += (room_needed - 16)
            else
              space += room_needed
            end
          else
            w1 = 112 + room_needed
          end
        end
        draw_actor_name(actor, x, y, w1)
        draw_actor_level(actor, x, y + line_height * 1)
        draw_actor_icons(actor, x, y + line_height * 2, w1)
        draw_actor_class(actor, x + w1 + space, y, w2)
        draw_actor_hp(actor, x + w1 + space, y + line_height * 1, w2)
        draw_actor_mp(actor, x + w1 + space, y + line_height * 2, w2)
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Item Height
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def item_height(*args, &block)
      total_height = height - (standard_padding * 2)
      if total_height > 96
        total_height / (total_height / 96)
      else
        super(*args, &block)
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Item Rect
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def item_rect(*args, &block)
      rect = super(*args, &block)
      rect.y += [(rect.height - 98) / 2, 0].max
      rect.height = 98
      rect
    end
  end
end

#==============================================================================
# *** DataManager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - self.extract_save_contents
#==============================================================================

module DataManager
  class << self
    alias macmm_extrctsvcon_2qk8 extract_save_contents
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Extract Save Contents
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.extract_save_contents(*args, &block)
    macmm_extrctsvcon_2qk8(*args, &block) # Run Original Method
    # Preserve old save files
    $game_system.macmm_initialize_menubase_data if !$game_system.macmm_command_list
  end
end

#==============================================================================
# ** Game System
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variable - macmm_command_list; macmm_optional_windows
#    aliased method - initialize
#==============================================================================

class Game_System
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :macmm_command_list
  attr_reader   :macmm_optional_windows
  attr_accessor :macmm_row_max
  attr_accessor :macmm_command_width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_cmsb_initilz_6dq1 initialize
  def initialize(*args, &block)
    ma_cmsb_initilz_6dq1(*args, &block) # Run Original Method
    macmm_initialize_menubase_data
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize MenuBase Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_initialize_menubase_data
    @macmm_command_list = MA_CustomizableMenu::COMMAND_LIST.compact
    @macmm_optional_windows = MA_CustomizableMenu::OPTIONAL_WINDOWS_LIST.compact
    @macmm_row_max = MA_CustomizableMenu::COMMAND_WINDOW_ROWMAX
    @macmm_command_width = MA_CustomizableMenu::COMMAND_WINDOW_WIDTH
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new methods - add_menu_command; remove_menu_command; add_menu_window;
#      remove_menu_window
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add & Remove Menu Commands
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def add_menu_command(command, index = -1)
    remove_menu_command(command)
    $game_system.macmm_command_list.insert(index, command)
  end
  def remove_menu_command(command)
    $game_system.macmm_command_list.delete(command)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add & Remove Menu Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def add_menu_window(win, index = -1)
    remove_menu_window(win)
    $game_system.macmm_optional_windows.insert(index, win)
  end
  def remove_menu_window(win)
    $game_system.macmm_optional_windows.delete(win)
  end
end

#==============================================================================
# ** Window_MenuCommand
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    overwritten method - window_width
#    aliased method - make_command_list; visible_line_number
#    new method - macmm_remake_command_list; macmm_preserve_noncustom_commands
#      macmm_add_custom_command
#==============================================================================

class Window_MenuCommand
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Window Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def window_width
    $game_system.macmm_command_width
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add Original Commands
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_cmsb_makecndlist_5fk8 make_command_list
  def make_command_list(*args, &block)
    #  I know that this is a very strange way to do this, but my purpose is to
    # interfere as little as possible with unknown scripts which add scenes
    # to the menu. In order to do that, I call the original method and only 
    # afterwards reconfigure things.
    ma_cmsb_makecndlist_5fk8(*args, &block)
    # Retain unknown commands, as well as non-overridden default commands
    macmm_preserve_noncustom_commands
    clear_command_list
    # Remake command list with order specified
    macmm_remake_command_list
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Preserve Non-Custom Commands
  #``````````````````````````````````````````````````````````````````````````
  #  This method scans the current list and retains all commands that are
  # either unknown (from another script) or default and not overridden (so 
  # that, unless specified by the user, it will act exactly as it would 
  # without having this sctipt. That is important in case there is some other
  # script which modifies the default commands.)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_preserve_noncustom_commands
    default_list = [:item, :skill, :equip, :status, :formation, :save, :game_end]
    @noncustom_commands = {}
    for i in 0...@list.size
      cmnd = @list[i]
      sym = cmnd[:symbol] 
      # Don't preserve any command defined in CUSTOM_COMMANDS
      if $game_system.macmm_command_list.include?(sym)
        next if MA_CustomizableMenu::CUSTOM_COMMANDS.key?(sym)
      else # Don't preserve default commands that are not specified
        next if default_list.include?(sym) 
      end
      # Retain the index and the command
      @noncustom_commands[sym] = [i, cmnd]
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Remake Command List
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_remake_command_list
    # Go through the command list in order
    $game_system.macmm_command_list.each { |sym|
      if MA_CustomizableMenu::CUSTOM_COMMANDS.key?(sym)
        macmm_add_custom_command(sym)
      elsif @noncustom_commands.key?(sym)
        # Add default command to the list
        @list.push(@noncustom_commands[sym][1])
        @noncustom_commands.delete(sym)
      else
        p "Error: MA_MenuBase - No command is set up for #{sym}"
      end
    }
    #  Add all remaining noncustom commands, under the assumption that they are
    # intentionally placed there by an unknown script.
    @noncustom_commands.values.each { |el| @list.insert([el[0], @list.size].min, el[1]) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add Custom Command
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_add_custom_command(symbol)
    cc = MA_CustomizableMenu::CUSTOM_COMMANDS[symbol] # Get custom command setup
    # Get the command name
    name = cc[0].is_a?(Symbol) ? eval(cc[0].to_s) : cc[0]
    # Add the command to the list
    add_command(name, symbol, macmm_custom_command_enabled(cc[1]))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Custom Command Enabled
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_custom_command_enabled(enable_condition)
    # Check whether enabled
    return case enable_condition
    when Integer then $game_switches[enable_condition]
    when String then eval(enable_condition)
    when Symbol then self.send(enable_condition)
    else
      return true
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Visible Line Number
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mlgb_cmsb_vislnnum_4rk9 visible_line_number
  def visible_line_number(*args, &block)
    r = mlgb_cmsb_vislnnum_4rk9(*args, &block) # Run Original Method
    return r if $game_system.macmm_row_max < 1
    [r, $game_system.macmm_row_max].min
  end
end

#==============================================================================
# ** Window_MACMM_AutoCustom
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window displays some specified data, along with an identifying label 
#==============================================================================

class Window_MACMM_AutoCustom < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(cw_data = ["", 0])
    @cw_data = cw_data
    x = MA_CustomizableMenu::COMMAND_WINDOW_ON_RIGHT ? Graphics.width - window_width : 0
    super(x, 0, window_width, fitting_height(@cw_data.size / 2))
    refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Window Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def window_width
    $game_system.macmm_command_width
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh
    contents.clear
    for i in 0...(@cw_data.size / 2)
      draw_text_ex(0, line_height*i, "\\c[16]" + @cw_data[i*2])
      reset_font_settings
      draw_text(0, line_height*i, contents_width, line_height, value(@cw_data[i*2 + 1]), 2)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Value
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def value(val = 0)
    return case val
    when Integer then $game_variables[val].to_s
    when String then (eval(val)).to_s
    when Symbol then manual_value(val)
    else
      return ""
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Manual Value
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def manual_value(val)
    if val == :playtime
      @total_sec = Graphics.frame_count / Graphics.frame_rate
      hour = @total_sec / 60 / 60
      min = @total_sec / 60 % 60
      sec = @total_sec % 60
      return sprintf("%02d:%02d:%02d", hour, min, sec)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Open Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def open
    refresh
    super
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    super
    refresh if @cw_data.include?(:playtime) && Graphics.frame_count / Graphics.frame_rate != @total_sec
  end
end

#==============================================================================
# ** Scene_Menu
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - start; create_command_window; create_gold_window;
#      create_status_window; on_personal_ok
#    new method - macmm_command_custom; macmm_command_common_event; 
#      create_optional_windows; manual_custom_window; auto_custom_window;
#      set_custom_window_y; macmm_set_custom_handler
#==============================================================================

class Scene_Menu
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_cmsb_strt_7tg9 start
  def start(*args, &block)
    @opt_y = Graphics.height
    ma_cmsb_strt_7tg9(*args, &block) # Run Original Method
    create_optional_windows
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Command Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_cmsb_crtcmndwin_5ta4 create_command_window
  def create_command_window(*args, &block)
    ma_cmsb_crtcmndwin_5ta4(*args, &block) # Run Original Method
    # Add handlers for all custom commands
    $game_system.macmm_command_list.each { |sym|
      next unless MA_CustomizableMenu::CUSTOM_COMMANDS.key?(sym)
      macmm_set_custom_handler(sym)
    }
    @command_window.x = Graphics.width - $game_system.macmm_command_width if MA_CustomizableMenu::COMMAND_WINDOW_ON_RIGHT
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Status Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macmm_createstatusw_9ja2 create_status_window
  def create_status_window(*args, &block)
    macmm_createstatusw_9ja2(*args, &block) # Call Original Method
    @status_window.extend(MA_CustomizableMenu::Alter_MenuStatus)
    @status_window.width = Graphics.width - $game_system.macmm_command_width
    @status_window.x = 0 if MA_CustomizableMenu::COMMAND_WINDOW_ON_RIGHT
    @status_window.create_contents
    @status_window.refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Gold Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_cmsb_crtgldwin_5yx1 create_gold_window
  def create_gold_window(*args, &block)
    if $game_system.macmm_optional_windows.include?(:gold) && !MA_CustomizableMenu::CUSTOM_WINDOWS.key?(:gold)
      ma_cmsb_crtgldwin_5yx1(*args, &block) # Run Original Method
      @gold_window.width = $game_system.macmm_command_width
      @gold_window.x = Graphics.width - $game_system.macmm_command_width if MA_CustomizableMenu::COMMAND_WINDOW_ON_RIGHT
      @gold_window.create_contents
      @gold_window.refresh
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Optional Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_optional_windows
    @macmm_optional_windows = []
    $game_system.macmm_optional_windows.reverse.each { |sym|
      cw = MA_CustomizableMenu::CUSTOM_WINDOWS[sym]
      if cw.nil?
        manual_custom_window(sym)
      else
        auto_custom_window(sym)
      end
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Custom Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def auto_custom_window(symbol)
    cw = MA_CustomizableMenu::CUSTOM_WINDOWS[symbol]
    window = Window_MACMM_AutoCustom.new(cw)
    set_custom_window_y(window)
    @macmm_optional_windows << window
    instance_variable_set(:"@macmm_#{symbol.to_s}_window", window)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Manually Set Custom Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def manual_custom_window(symbol)
    case symbol
    when :gold then set_custom_window_y(@gold_window)
    else
      p "Error: MA_MenuBase - No window setup for #{symbol}"
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Y for Custom Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_custom_window_y(window)
    @opt_y -= window.height
    window.y = @opt_y
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Personal OK
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mala_cmsb_prsnlok_8yj7 on_personal_ok
  def on_personal_ok(*args, &block)
    if MA_CustomizableMenu::CUSTOM_COMMANDS.include?(@command_window.current_symbol)
      # If calling a common event
      case MA_CustomizableMenu::CUSTOM_COMMANDS[@command_window.current_symbol][2]
      when Integer then macmm_command_common_event
      when Symbol then send(MA_CustomizableMenu::CUSTOM_COMMANDS[@command_window.current_symbol][2])
      when String then eval(MA_CustomizableMenu::CUSTOM_COMMANDS[@command_window.current_symbol][2])
      else
        macmm_command_custom # If nil or anything else, normal
      end
    else
      mala_cmsb_prsnlok_8yj7(*args, &block) # Run Original Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Custom Handler
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_set_custom_handler(symbol)
    cc = MA_CustomizableMenu::CUSTOM_COMMANDS
    handler = case cc[symbol][3]
    when Symbol then method(cc[symbol][3])
    when TrueClass then method(:command_personal)
    else
      handler = case cc[symbol][2]
      when Integer then method(:macmm_command_common_event) 
      when String then lambda { eval(cc[symbol][2]) }
      else
        handler = method(:macmm_command_custom) # If nil or anything else, normal
      end
    end
    @command_window.set_handler(symbol, handler)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Custom Command
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_command_custom
    SceneManager.call(Kernel.const_get(MA_CustomizableMenu::CUSTOM_COMMANDS[@command_window.current_symbol][2]))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Command Common Event
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macmm_command_common_event
    $game_temp.reserve_common_event(MA_CustomizableMenu::CUSTOM_COMMANDS[@command_window.current_symbol][2])
    return_scene
  end
end
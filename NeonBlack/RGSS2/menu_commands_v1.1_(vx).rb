###--------------------------------------------------------------------------###
#  Menu Commands script                                                        #
#  Version 1.1                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neon Black                                                #
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
#      Revision information:                                                   #
#  V1.1 - 10.15.2012                                                           #
#   Fixed a crash for when numbers are not properly sorted                     #
#   General script cleanup                                                     #
#  V1.0b - 4.16.2012                                                           #
#   Added submenu support                                                      #
#   Polished code                                                              #
#  V1.0  - 4.15.2012                                                           #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Scene_Menu: initialize, terminate, start_actor_selection      #
#  Overwrites  - Scene_Menu: create_command_window, update_command_selection   #
#                            update_actor_selection, update,                   #
#                            end_actor_selection                               #
#  New Methods - Scene_Menu: update_submenu_selection, create_submenu          #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is pretty much plug and play with a few options available to    #
#  change below.                                                               #
#                                                                              #
#      Menu Items:                                                             #
#  The menu items are added and controlled by a hash.  You can edit the menu   #
#  items to your liking using the following guide.                             #
#                                                                              #
#    ID => [ "Name" , Scene_GoTo.new(@args) , party, :save , :no1, :submenu ], #
#                                                                              #
#  ID - This is the item position in the menu.  You can use this to re-order   #
#       options within the menu.  Make sure each one is unique.                #
#  "Name" - The text that will be displayed for the item in the menu.  Make    #
#           sure this is in quotes or it will not work properly.               #
#  Scene_GoTo.new - This is the scene that the option in the menu will call.   #
#                   You do not need the "$scene ="; the script will do that    #
#                   on its own.  You can only define certain arguments at the  #
#                   moment, listed below.                                      #
#           @args - The arguments section for the script.  You can use most    #
#                   arguments normally, however local variables will not       #
#                   work.  If the script requires you to select a character,   #
#                   "@char" can be used in conjuntion with the next option.    #
#  party - Put "true" or "false" here.  Use this spot to tell the script if    #
#          it should start party selection before opening.  Use with the       #
#          "@char" argument to properly select a party member.  This is used   #
#          for menus such as the equip menu.                                   #
#  :save (optional) - Add this tag after all other options and the menu        #
#                     option can be enabled/disabled along with saving.        #
#  :no1 (optional) - Add this tag after all other options and the menu option  #
#                    will still be selectable with an empty party.             #
#  :submenu (opt.) - Places this item into the submenu with this ID tag.       #
#                    Items with this item in them will not appear in the main  #
#                    menu.  A submenu is required.                             #
#                                                                              #
#      Submenus:                                                               #
#  A submenu can be created similar to how normal menu items can be created.   #
#  Submenus will be empty unless there are menu items with a submenu tag in    #
#  them.  A single item can be in several submenu items by having several      #
#  submenu tags in it.  Submenus are never disabled but the items in them can  #
#  be disabled.                                                                #
#                                                                              #
#    ID => [ "Name" , :submenu ],                                              #
#                                                                              #
#  ID - This is the submenu position in the menu.  You can use this to         #
#       re-order option within the menu.  Make sure each is unique.  These     #
#       must also be different from normal menu IDs.                           #
#  "Name" - The text that will be displayed for the submenu in the menu.       #
#           Make sure this is in quotes or it will not work properly.          #
#  :submenu - The submenu tag.  All other items with this tag will appear in   #
#             this submenu.  Make sure each one is unique.                     #
#                                                                              #
#  NOTE - Submenu commands cannot have any other tags in them due to how they  #
#         are identified.  You also cannot nest submenus in other submenus.    #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP               #  Do not                                              #
module MENU_COMMANDS    #   alter                                              #
def self.LIST           #    these                                             #
@commands ={            #     4 lines.                                         #
#                                                                              #
# This is where you define the options used in the main menu.  Refer to the    #
# instructions section above to find out what each element does.  Note that    #
# each option will place the cursor on it's option when you back out, so       #
# there is no need to change it in each script.                                #
  0 => ["Status", Scene_Status.new(@char), true],                              #
  1 => ["Item", Scene_Item.new, false],                                        #
  2 => ["Skill", Scene_Skill.new(@char), true],                                #
  3 => ["Equip", Scene_Equip.new(@char), true],                                #
  4 => ["Data", :data],                                                        #
  5 => ["End Game", Scene_End.new, false, :no1],                               #
                                                                               #
  6 => ["Save", Scene_File.new(true, false, false), false, :save, :no1, :data],#
  7 => ["Load", Scene_File.new(false, false, false), false, :no1, :data],      #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


} ## End of the hash here so people hopefully don't screw with it.
end

def self.COMMANDS ## Returns a list of the commands.
  result = []
  @commands.keys.sort.each {|key| result.push(@commands[key])}
  return result
end

def self.set_char(char) ## Sets the party character.  Used by actor selection.
  @char = char
end

end ## End of the modules.
end

$imported = {} if $imported == nil
$imported["CP_MENUCOMMANDS"] = true

class Scene_Menu < Scene_Base
  
  ##-----
  ## Alias the initialize method.  A global variable is added that saves the
  ## cursor index when a scene is called.  If the global variable is not nil, it
  ## takes priority for placing the cursor when this scene is called.
  ##-----
  alias cp_nmc_init initialize unless $@
  def initialize(menu_index = 0)
    cp_nmc_init(menu_index)
    @menu_index = $menu_index if $menu_index
    $menu_index = nil
    CP::MENU_COMMANDS.LIST
  end
  
  ##-----
  ## Alias the terminate process for the new window.
  ##-----
  alias cp_nmc_term terminate unless $@
  def terminate
    cp_nmc_term
    @submenu_window.dispose if @submenu_window
  end
  
  ##-----
  ## Overwrite command window drawing.
  ##-----
  def create_command_window
    c_list = []
    @cm_list = []
    CP::MENU_COMMANDS.COMMANDS.each_with_index do |comm, index|
      in_op = comm.size
      if in_op > 3
        in_op -= 1 if comm.include?(:no1)
        in_op -= 1 if comm.include?(:save)
      end
      next if in_op > 3
      c_list.push(comm[0])
      @cm_list.push(index)
    end
    @command_window = Window_Command.new(160, c_list)
    @command_window.index = @menu_index
    save_op = !$game_system.save_disabled
    char_op = $game_party.members.size != 0
    CP::MENU_COMMANDS.COMMANDS.each_with_index do |comm, index|
      i = @cm_list.index(index)
      next unless i
      if comm.include?(:save)
        @command_window.draw_item(i, save_op)
      end
      if comm.include?(:no1)
        @command_window.draw_item(i, char_op)
      end
    end
  end
  
  ##-----
  ## Overwrite the update phase due to the new window.
  ##-----
  def update
    super
    update_menu_background
    @command_window.update
    @gold_window.update
    @status_window.update
    if @submenu_window
      @submenu_window.update
      @submenu_window.dispose if @submenu_window.openness == 0
      @submenu_window = nil if @submenu_window.disposed?
    end
    if @command_window.active
      update_command_selection
    elsif @status_window.active
      update_actor_selection
    elsif @submenu_window.active
      update_submenu_selection
    end
  end
  
  ##-----
  ## Overwrite command selection.  Checks for extra tags.
  ##-----
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      cwi = @cm_list[@command_window.index]
      if $game_party.members.size == 0 && !CP::MENU_COMMANDS.COMMANDS[cwi].include?(:no1)
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled && CP::MENU_COMMANDS.COMMANDS[cwi].include?(:save)
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      if CP::MENU_COMMANDS.COMMANDS[cwi].size == 2
        $menu_index = @command_window.index
        create_submenu(cwi)
      else
        if CP::MENU_COMMANDS.COMMANDS[cwi][2]
          start_actor_selection
        else
          $menu_index = @command_window.index
          $scene = CP::MENU_COMMANDS.COMMANDS[cwi][1]
        end
      end
    end
  end
  
  ##-----
  ## New method for the submenu.
  ##-----
  def update_submenu_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @submenu_window.active = false
      @command_window.active = true
      $menu_index = nil
      @submenu_window.openness = 0
    elsif Input.trigger?(Input::C)
      cwi = @sw_list[@submenu_window.index]
      if $game_party.members.size == 0 && !CP::MENU_COMMANDS.COMMANDS[cwi].include?(:no1)
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled && CP::MENU_COMMANDS.COMMANDS[cwi].include?(:save)
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      if CP::MENU_COMMANDS.COMMANDS[cwi][2]
        start_actor_selection
      else
        $scene = CP::MENU_COMMANDS.COMMANDS[cwi][1]
      end
    end
  end
  
  ##-----
  ## Alias or overwrite several things for the new window.
  ##-----
  alias cp_nmc_start_a_s start_actor_selection unless $@
  def start_actor_selection
    @submenu_window.active = false if @submenu_window
    cp_nmc_start_a_s
  end
  
  def end_actor_selection
    if @submenu_window
      @submenu_window.active = true
    else
      @command_window.active = true
    end
    @status_window.active = false
    @status_window.index = -1
  end
  
  ##-----
  ## Actor selection.  Makes the "@char" argument work.
  ##-----
  def update_actor_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      cwi = @cm_list[@command_window.index]
      cwi = @sw_list[@submenu_window.index] if @submenu_window
      CP::MENU_COMMANDS.set_char(@status_window.index)
      CP::MENU_COMMANDS.LIST
      $menu_index = @command_window.index
      $scene = CP::MENU_COMMANDS.COMMANDS[cwi][1]
    end
  end
  
  ##-----
  ## New method to create the submenu.
  ##-----
  def create_submenu(item)
    submenu = CP::MENU_COMMANDS.COMMANDS[item][1]
    c_list = []
    @sw_list = []
    CP::MENU_COMMANDS.COMMANDS.each_with_index do |comm, index|
      next unless comm.include?(submenu)
      next if index == item
      c_list.push(comm[0])
      @sw_list.push(index)
    end
    @submenu_window = Window_Command.new(120, c_list)
    save_op = !$game_system.save_disabled
    char_op = $game_party.members.size != 0
    CP::MENU_COMMANDS.COMMANDS.each_with_index do |comm, index|
      i = @cm_list.index(index)
      next unless i
      if comm.include?(:save)
        @submenu_window.draw_item(i, save_op)
      end
      if comm.include?(:no1)
        @submenu_window.draw_item(i, char_op)
      end
    end
    @submenu_window.x = @command_window.x + 32
    @submenu_window.y = @command_window.y + 26 + @command_window.index * 24
    @submenu_window.y -= @command_window.oy
    @submenu_window.active = true
    @command_window.active = false
  end
end


##----------------------------------------------------------------------------##
##  END OF SCRIPT                                                             ##
##----------------------------------------------------------------------------##
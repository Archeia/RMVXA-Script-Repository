##-----------------------------------------------------------------------------
## State Graphics v1.3
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.3 - 8.17.2013
##  Fixed an issue with character sprite changing
## v1.2 - 3.16.2013
##  Added stacking states functions
## v1.1 - 3.15.2013
##  Fixed bug related to death transitions
## v1.0 - 3.15.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["Graphics_States"] = 1.3                                            ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows states to change an actor or enemy's graphics.  This
## change remains active as long as the battler is afflicted with the state.
## If multiple states change graphics, the state with the highest priority
## determines the graphic.  These changes are applied using script calls:
##
## battler gfx["name" 0]  -or-  enemy battler gfx["name" 0 1, 2, 3]  -or-
## actor battler gfx["name" 0 1, 2, 3]
##  - Sets a battlers graphic name and hue while the state is applied.  "name"
##    is the file name and must be surrounded by quotes while 0 can be a number
##    from 0-255 for the hue.  If this tag is prefixed with "actor" or "enemy"
##    it must also include actor or enemy IDs at the end each separated by
##    commas (such as the 1, 2, 3 in this example).  Note that actor/enemy tags
##    take priority over the short tag, but higher priority states will always
##    be applied first.
## character gfx["name" 5]  -or-  face gfx["name" 5]  -or-
## actor face gfx["name" 5 1, 2, 3]  -etc-
##  - Changes the face or character walking sprites of the battler with this
##    state.  Either of these can be prefixed with actor or enemy and work
##    pretty much the same way as the battler gfx tags.  The only difference is
##    that the number behind the name changes the index (from 0-7).  This has
##    no effect on enemies without alternate scripts.
## name change["name"]  -or-  enemy name change["name" 1, 2, 3]
##  - Changes the name of the battler the that is applied to.  Works exactly
##    like all the other tags except it does not have a second argument.
##
## This script can also function with CP's Stacking States.  States can have
## different graphics for certain levels of stacks by adding a tag to the line
## you want to only occur on that stack.  This tag is as follows:
##
## stack gfx[1]
##  - Causes the line graphic to only occur when the stack condition is met.
##    To use this tag, simply place the tag after any other tag in this script.
##    You can use any number from 1 on up.  If this tag is not behind another
##    tag, the tag is assumed to work on all levels.  Note that this tag takes
##    priority over similar untagged lines.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Compatibility:
## This script assumes that enemies cannot have faces and characters by default
## so if it happens to interfere with another script, try placing this script
## ABOVE the other script.  If that does not work, copy lines 111 to 142 and
## overwrite lines 152 to 178 with them.
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


class Game_BattlerBase
  def state_graphic_bit(bit)  ## Gets the info from an array using the ID.
    states.each do |state|
      stack_pos = get_stack(state.id); ary = nil
      id = enemy? ? -@enemy_id : @actor_id
      if state.graphics_change.include?(id) &&
         state.graphics_change[id].include?(bit)
        ary = state.graphics_change[id][bit]
      end
      if state.graphics_change.include?(0) &&
         state.graphics_change[0].include?(bit)
        ary = state.graphics_change[0][bit] if ary.nil?
      end
      
      if ary
        return ary[stack_pos] if ary[stack_pos]
        return ary[0] if ary[0]
      end
    end
    return nil
  end
  
  def get_stack(state) ## Gets the ID from the hash if Stack_States is used.
    if ($imported["Stack_States"] || 0) >= 1.0
      return state_stack(state)
    else
      return 1
    end
  end
end

class Game_Battler < Game_BattlerBase
  alias :cpgfxc_item_apply :item_apply
  def item_apply(*args)
    cpgfxc_item_apply(*args)
    $game_player.refresh
  end
end

class Game_Actor < Game_Battler  ## If no replacement is found, use the old one.
  alias :cpgfxc_state_face_name :face_name
  alias :cpgfxc_state_face_index :face_index
  alias :cpgfxc_state_character_name :character_name
  alias :cpgfxc_state_character_index :character_index
  alias :cpgfxc_state_battler_name :battler_name
  alias :cpgfxc_state_battler_hue :battler_hue
  alias :cpgfxc_state_name :name
  
  def face_name
    state_graphic_bit(:face) || cpgfxc_state_face_name
  end
  
  def face_index
    state_graphic_bit(:face_ind) || cpgfxc_state_face_index
  end
  
  def character_name
    state_graphic_bit(:chara) || cpgfxc_state_character_name
  end
  
  def character_index
    state_graphic_bit(:chara_ind) || cpgfxc_state_character_index
  end
  
  def battler_name
    @held_battler_name = state_graphic_bit(:battler) if alive?
    @held_battler_name || cpgfxc_state_battler_name
  end
  
  def battler_hue
    state_graphic_bit(:battler_hue) || cpgfxc_state_battler_hue
  end
  
  def name
    state_graphic_bit(:name) || cpgfxc_state_name
  end
end


class Game_Enemy < Game_Battler
  alias :cpgfxc_state_original_name :original_name
  alias :cpgfxc_state_battler_name :battler_name
  alias :cpgfxc_state_battler_hue :battler_hue
  
  def face_name
    state_graphic_bit(:face)
  end
  
  def face_index
    state_graphic_bit(:face_ind)
  end
  
  def character_name
    state_graphic_bit(:chara)
  end
  
  def character_index
    state_graphic_bit(:chara_ind)
  end
  
  def battler_name
    @held_battler_name = state_graphic_bit(:battler) if alive?
    @held_battler_name || cpgfxc_state_battler_name
  end
  
  def battler_hue
    state_graphic_bit(:battler_hue) || cpgfxc_state_battler_hue
  end
  
  def original_name
    state_graphic_bit(:name) || cpgfxc_state_original_name
  end
  
  def name
    get_name = state_graphic_bit(:name)
    (get_name ? get_name : @original_name) + (@plural ? letter : "")
  end
end

class Game_Interpreter
  alias :cpgfxc_command_313 :command_313
  def command_313
    cpgfxc_command_313
    $game_player.refresh
  end
end

class Sprite_Battler < Sprite_Base
  alias :cpgfxc_state_init_visibility :init_visibility
  alias :cpgfxc_state_initialize :initialize
  
  def initialize(*args)
    @first_run = true
    cpgfxc_state_initialize(*args)
  end
  
  def init_visibility
    if @first_run
      cpgfxc_state_init_visibility
      @first_run = false
    else
      cpgfxc_state_init_visibility unless !@battler_visible && @battler.alive?
    end
  end
end

module CP
module STATEGFX

ACTOR  = /actor (battler|character|face) gfx\["(.+)" (\d+) ([\d, ]+)\]/i
ENEMY  = /enemy (battler|character|face) gfx\["(.+)" (\d+) ([\d, ]+)\]/i
COMMON = /(battler|character|face) gfx\["(.+)" (\d+)\]/i
NAME   = /(actor |enemy )?name change\["(.+)"([\d, ]*)\]/i
STACK  = /stack gfx\[(\d+)\]/i

end
end

class RPG::State < RPG::BaseItem  ## REGEXPs and a few time savers.
  def graphics_change
    create_state_graphic_list if @graphics_change_hash.nil?
    @graphics_change_hash
  end
  
  def create_state_graphic_list
    @graphics_change_hash = {}
    note.split(/[\r\n]+/).each do |line|
      if line =~ CP::STATEGFX::STACK
        stack_pos = $1.to_i
      else stack_pos = 0 end
      case line
      when CP::STATEGFX::ACTOR
        bit, num = get_bit_num_61513($1.to_s.downcase)
        package_61513($2.to_s, $3.to_i, to_a_61513($4.to_s), bit, num, stack_pos)
      when CP::STATEGFX::ENEMY
        bit, num = get_bit_num_61513($1.to_s.downcase)
        package_61513($2.to_s, $3.to_i, to_a_61513($4.to_s), bit, num, stack_pos, true)
      when CP::STATEGFX::COMMON
        bit, num = get_bit_num_61513($1.to_s.downcase)
        package_61513($2.to_s, $3.to_i, [0], bit, num, stack_pos)
      when CP::STATEGFX::NAME
        case $1.to_s.downcase
        when "actor "; ary, invert = to_a_61513($3.to_s), false
        when "enemy "; ary, invert = to_a_61513($3.to_s), true
        else; ary, invert = [0], false
        end
        package_61513($2.to_s, 0, ary, :name, nil, stack_pos, invert)
      end
    end
  end
  
  def get_bit_num_61513(state)
    case state
    when "battler";   bit, num = :battler, :battler_hue
    when "character"; bit, num = :chara,   :chara_ind
    when "face";      bit, num = :face,    :face_ind
    else;             bit, num = nil,      nil
    end
    return [bit, num]
  end
  
  def package_61513(string, int, array, bit, num, pos = 0, inverse = false)
    array.each do |id|
      id = inverse ? -id.to_i : id.to_i
      @graphics_change_hash[id] ||= {}
      @graphics_change_hash[id][bit] ||= {}
      @graphics_change_hash[id][bit][pos] = string
      @graphics_change_hash[id][num] ||= {}
      @graphics_change_hash[id][num][pos] = int
    end
  end
  
  def to_a_61513(string)
    string.split(/,/)
  end
end


##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------
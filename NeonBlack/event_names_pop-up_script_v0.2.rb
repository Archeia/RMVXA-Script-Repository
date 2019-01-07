###--------------------------------------------------------------------------###
#  Event Names Pop-up script                                                   #
#  Version 0.2                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#  Requested by: Kilim                                                         #
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
#  V0.2 - 7.20.2012                                                            #
#   Debug                                                                      #
#  V0.1 - 7.20.2012                                                            #
#   Wrote main script                                                          #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Game_Map: update                                              #
#  New Objects - Game_Map: update_events_pop_check                             #
#                Game_Event: check_player_over, get_tp_name,                   #
#                            display_pop_name, hide_pop_name                   #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This allows you to make a name pop up above an event while the player is    #
#  standing on top of it.  To do this, place a comment inside the event with   #
#  the following tag:                                                          #
#                                                                              #
#      tp name<text> - Simply change "text" to the text you would like to      #
#                      display.  For example, to display "Dark Forest" you     #
#                      would use "tp name<Dark Forest>".                       #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP             # Do not                                                 #
module TRANSFER_NAMES #  change these.                                         #
#                                                                              #
###-----                                                                -----###
# Settings for the pop-up text.                                                #
BOLD = false # Default = false                                                 #
SIZE = 28 # Default = 28                                                       #
#                                                                              #
# The number of pixels the pop-up appears over the event.                      #
Y_OFFSET = 40 # Default = 40                                                   #
#                                                                              #
###-----                                                                -----###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


EXP_NAME = /tp[ ]name\<([\d\s\w]+)\>/i  ## The REGEXP check thing....

end
end

$imported = {} if $imported.nil?
$imported["CP_TRANSFER_NAMES"] = 0.2

class Game_Event < Game_Character
  def check_player_over  ## Check if the player is on the event.
    $game_player.pos?(@x, @y)
  end
  
  def get_tp_name
    return nil if (@list.nil? || @list.empty?)
    @list.each do |line|  ## Looks for the name in the code.
      next unless (line.code == 108 || line.code == 408)
      case line.parameters[0]
      when CP::TRANSFER_NAMES::EXP_NAME
        tn = $1.to_s
        return tn
      end
    end
    return nil
  end
end
  
class Sprite_Character < Sprite_Base
  alias cp_ct_update update unless $@
  def update  ## Alias update.
    cp_ct_update
    display_pop_name
  end
  
  alias cp_ct_dispose dispose unless $@
  def dispose  ## Alias dispose.
    hide_pop_name
    cp_ct_dispose
  end
  
  def display_pop_name  ## Creates the pop-up.
    return unless @character.is_a?(Game_Event)
    return hide_pop_name unless @character.check_player_over
    tn = @character.get_tp_name
    return if tn.nil?
    if @pop_sprite.nil?
      display = ::Sprite.new
      temp = Bitmap.new(Graphics.width, 32)
      temp.font.bold = CP::TRANSFER_NAMES::BOLD
      temp.font.size = CP::TRANSFER_NAMES::SIZE
      bw = temp.text_size(tn).width + 4
      bh = temp.text_size(tn).height + 4
      display.bitmap = Bitmap.new(bw, bh)
      display.bitmap.font.bold = CP::TRANSFER_NAMES::BOLD
      display.bitmap.font.size = CP::TRANSFER_NAMES::SIZE
      display.bitmap.draw_text(0, 0, bw, bh, tn)
      display.z = 301
      display.ox = display.width / 2
      display.oy = display.height
      @pop_sprite = display
    end
    @pop_sprite.x = @character.screen_x
    @pop_sprite.y = @character.screen_y - CP::TRANSFER_NAMES::Y_OFFSET
  end
  
  def hide_pop_name  ## Hides the pop-up.
    return if @pop_sprite.nil?
    @pop_sprite.dispose
    @pop_sprite = nil
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###
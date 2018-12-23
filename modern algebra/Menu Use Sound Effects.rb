#==============================================================================
#    Menu Use Sound Effects
#    Version: 1.0a
#    Author: modern algebra (rmrk.net)
#    Date: January 18, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script restores the lost RMXP ability to set individual sound effects
#   when using items and skills in the menu.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Insert this script into its own slot in the Script Editor, above Main but 
#   below Materials. 
#
#    To set up a sound effect to be played when an item or skill is used in the
#   menu, simply add the following code to the item or skill's notebox:
#
#        \menu_se["filename", v80, p100]
#          filename : the name of the SE file you are using from Audio/SE
#          v80      : the volume you want the sound to be played at. Just put 
#                    v, followed immediately by the volume you want, between 0
#                    and 100. Ex: v60 would play the sound at 60% volume. If
#                    excluded, it defaults to 80.
#          p100     : the pitch to play the sound at. Just put p, followed by
#                    the pitch you want. Can be from 50 - 150. If excluded, it 
#                    defaults to 100
#
#    EXAMPLES:
#
#      \menu_se["Item3", p75]
#          When the item or skill with this note is used from the menu, it will  
#         play the Item3 SE at 80 volume and 75 pitch.
#      \menu_se["Fire4"]
#          When the item or skill with this note is used from the menu, it will  
#         play the Fire4 SE at 80 volume and 100 pitch.
#      \menu_se["Thunder1", v90, p120]
#          When the item or skill with this note is used from the menu, it will  
#         play the Thunder1 SE at 90 volume and 120 pitch.
#==============================================================================

$imported ||= {}
$imported[:MA_MenuUseSE] = true

#==============================================================================
# ** RPG::UsableItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - menu_use_se
#==============================================================================

class RPG::UsableItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Menu Use SE
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mamus_menu_use_se
    if @mamus_menu_se.nil?
      if self.note[/\\MENU[_ ]SE\[(.+?)\]/im] != nil
        attrs = $1.gsub(/[\r\n]/, "")
        @mamus_menu_se = ["", 80, 100]
        @mamus_menu_se[0] = $1 if attrs.sub!(/["'](.+)['"]/, "") != nil
        @mamus_menu_se[1] = $1.to_i if attrs[/[Vv](\d+)/] != nil
        @mamus_menu_se[2] = $1.to_i if attrs[/[Pp](\d+)/] != nil
      else
        @mamus_menu_se = []
      end
    end
    @mamus_menu_se
  end
end

#==============================================================================
# ** Scene Item / Scene Skill
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    In both, aliased method - play_se_for_item
#==============================================================================

[:Scene_Item, :Scene_Skill].each { |scene|
mamus_playitemses = 
 "class #{scene}
    alias mamus_#{scene.downcase}_playitemse_2ed8 play_se_for_item
    def play_se_for_item(*args, &block)
      if !item.mamus_menu_use_se.empty?
        begin
          RPG::SE.new(*item.mamus_menu_use_se).play
        rescue
          mamus_#{scene.downcase}_playitemse_2ed8(*args, &block)
        end
      else
        mamus_#{scene.downcase}_playitemse_2ed8(*args, &block)
      end
    end
  end"
eval(mamus_playitemses)
}

=begin
#===============================================================================
 Title: Item Rarity
 Author: Hime
 Date: Mar 26, 2014
 URL: http://www.himeworks.com/2014/03/25/item-rarity/
--------------------------------------------------------------------------------
 ** Change log
 Apr 11, 2014
   - fixed bug where item color affects other rows as well
 Mar 26, 2014
   - Fixed bug where loading skills crashed. You can now tag skills with rarity
   - Extended to all base item objects
 Mar 25, 2014
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to assign item rarities to items and equips.
 
 Rarity is indicated by name colour: by default, all names are white. 
 You can customize this so that different rarity levels have different
 colours.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To specify rarity, note-tag items and equips with
 
   <item rarity: x>
   
 Where x is a number.
 In the configuration, you can set up the colours associated with each rarity
 level.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_ItemRarity] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Item_Rarity
    
    # Colours associated with each rarity. The colours are specified as
    # RGB values. So for example, White is [255, 255, 255]
    Colour_Map = {
      1 => [255, 255, 255],
      2 => [204, 255, 137],
      3 => [197, 122, 255],
      4 => [255, 84, 0],
    }
    
    Regex = /<item[-_ ]rarity:\s*(\d+)\s*>/i
    
#===============================================================================
# ** Rest of script
#===============================================================================
    @@rarity_colour_map = nil
    
    def self.rarity_colour_map
      unless @@rarity_colour_map
        @@rarity_colour_map = {}
        Colour_Map.each do |i, arr|
          @@rarity_colour_map[i] = Color.new(*arr)
        end
      end
      return @@rarity_colour_map
    end
  end
end

module RPG
 
  class BaseItem
    def rarity
      load_notetag_item_rarity unless @rarity
      return @rarity
    end
    
    def load_notetag_item_rarity
      @rarity = 1
      res = self.note.match(TH::Item_Rarity::Regex)
      if res
        @rarity = res[1].to_i
      end
    end
    
    def rarity_colour
      TH::Item_Rarity.rarity_colour_map[self.rarity]
    end
  end
end

class Window_Base < Window
  
  #-----------------------------------------------------------------------------
  # Replaced
  #-----------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(item.rarity_colour, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
		change_color(normal_color, enabled)
  end
end


#===============================================================================
# Instance Item extension
#===============================================================================
if $imported["TH_InstanceItems"]
  module RPG
    class BaseItem
      alias :th_item_rarity_refresh :refresh
      def refresh
        th_item_rarity_refresh
        refresh_item_rarity
      end
      
      def refresh_item_rarity
        var = InstanceManager.get_template(self).rarity
        @rarity = make_item_rarity(InstanceManager.make_full_copy(var))
      end

      def make_item_rarity(rarity)
        rarity
      end
    end
  end
end
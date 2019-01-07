=begin
#===============================================================================
 Title: Custom Icon Sheets
 Author: Hime
 Date: Jun 1, 2016
--------------------------------------------------------------------------------
 ** Change log
 Jun 1, 2015
   - added patch for yanfly's ace item menu
 May 27, 2015
   - fixed bug with yanfly's shop options
 Jun 13, 2013
   - icon width and height is now specified for each sheet individually
 Mar 31, 2013
   - now correctly draws icons of non-default sizes
 Mar 25, 2013
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
 
 This script allows you to designate which icon sheet you want to draw your
 icon from. This allows you to organize your icons so that you don't need
 to load one large iconset just to draw one icon.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 -- Installation --
 
 Place this script below Materials and above Main.
 
 -- Setting up custom icon sheets --
 
 Place any custom icon sheets in your Graphics/System folder.
 In the configuration below, add the filenames (without extensions) to the
 `Icon_Sheets` array. You must also include the default icon sheet to use,
 which is "Iconset"
 
 -- Using custom icon indices --
 
 Now that you have set up your icon sheets, you can begin using them.
 In your database, note-tag objects with
 
   <icon: name index>
   
 Where
   `name` is the exact filename of the icon index, without extensions
   `index` is the index of the icon in the specified file.

--------------------------------------------------------------------------------
 ** Compatibility
 
 This script overwrites the following methods:
 
   Window_Base
     draw_icon
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CustomIconSheets"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Custom_Icon_Sheets
    
    # List of icon sheets to load. Case-insensitive.
    # All icon sheets must be placed in the System folder
    # You must provide the dimensions of the icons as well
    Icon_Sheets = {
      "Iconset"     => [24, 24],
      "Weapons_1"     => [24, 24],
      #"CustomIcons" => [24, 24],
      #"LargeIcons"  => [65, 65]
    }
    
    # The default sheet to use if none is specified
    Default_Sheet = "Iconset"
    
    # Note-tag format.
    Regex = /<icon:\s*(\w+)\s*(\d+)>/i

#===============================================================================
# ** Rest of script
#===============================================================================

    #---------------------------------------------------------------------------
    # Each sheet starts at a specific icon index. 
    #---------------------------------------------------------------------------
    def self.icon_offsets
      @icon_offsets
    end
    #---------------------------------------------------------------------------
    # Load all icon sheets. This script uses a look-up table to map icon
    # indices to specific icon sheets.
    #---------------------------------------------------------------------------
    def self.load_sheets
      @icon_offsets = {}
      @icon_table = []
      icon_count = 0
      Icon_Sheets.each {|sheet, (width, height)|
        sheet = sheet.downcase
        bmp = Cache.system(sheet)
      
        # update the "icon index offset" for the current icon sheet.
        # This is used by the look-up table to determine how the icon index
        # is offset
        @icon_offsets[sheet] = icon_count
        @icon_table.push([sheet, icon_count, width, height])
        
        # number of icons per sheet is given by the number of icons per row
        # times the number of icons per height, including empty spaces.
        icon_count += (bmp.width / width) * (bmp.height / height)
      }
      
      # store the icon table in reverse order
      @icon_table.reverse!
    end
    
    def self.load_icon_sheet(index)
      @icon_table.each {|sheet, offset, width, height|
        if index >= offset
          index -= offset
          return Cache.system(sheet), index, width, height
        end
      }
    end
  end
end

module RPG
  class BaseItem
    def icon_sheet
      return @icon_sheet unless @icon_sheet.nil?
      load_notetag_custom_icon_sheet
      return @icon_sheet
    end
    
    def load_notetag_custom_icon_sheet
      res = self.note.match(TH::Custom_Icon_Sheets::Regex)
      if res
        @icon_sheet = res[1].downcase
        @custom_icon_index = res[2].to_i
      else
        @icon_sheet = TH::Custom_Icon_Sheets::Default_Sheet.downcase
        @custom_icon_index = @icon_index
      end
    end
    
    alias :th_custom_icon_sheets_icon_index :icon_index
    def icon_index
      parse_custom_icon_index unless @custom_icon_index_checked
      th_custom_icon_sheets_icon_index
    end
    
    #---------------------------------------------------------------------------
    # Automatically updates the icon index based on the appropriate icon sheet
    # to use.
    #---------------------------------------------------------------------------
    def parse_custom_icon_index
      # offset the index as necessary, using the icon sheet to look up the offset
      self.icon_index = TH::Custom_Icon_Sheets.icon_offsets[self.icon_sheet] + @custom_icon_index
      @custom_icon_index_checked = true
    end
  end
end

module DataManager
    
  class << self
    alias :th_custom_icon_sheets_load_database :load_database
  end
  
  #-----------------------------------------------------------------------------
  # Prepare the custom icon database
  #-----------------------------------------------------------------------------
  def self.load_database
    th_custom_icon_sheets_load_database
    TH::Custom_Icon_Sheets.load_sheets
  end
end

class Window_Base < Window
  
  #-----------------------------------------------------------------------------
  # Overwrite. Get the appropriate bitmap to draw from.
  #-----------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap, icon_index, icon_width, icon_height = TH::Custom_Icon_Sheets.load_icon_sheet(icon_index)
    rect = Rect.new(icon_index % 16 * icon_width, icon_index / 16 * icon_height, icon_width, icon_height)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end
end

#===============================================================================
# Compatibility patches. This script must be placed under the other scripts
#===============================================================================
class CSCA_Window_EncyclopediaInfo < Window_Base
  def csca_draw_icon(item)
    if item.csca_custom_picture == ""
      bitmap, icon_index, icon_width, icon_height = TH::Custom_Icon_Sheets.load_icon_sheet(icon_index)
      rect = Rect.new(icon_index % 16 * icon_width, icon_index / 16 * icon_height, icon_width, icon_height)
      target = Rect.new(0,0,72,72)
      contents.stretch_blt(target, bitmap, rect)
    else
      bitmap = Bitmap.new("Graphics/Pictures/"+item.csca_custom_picture+".png")
      target = Rect.new(0,0,72,72)
      contents.stretch_blt(target, bitmap, bitmap.rect, 255)
    end
  end
end if $imported["CSCA-Encyclopedia"]

#===============================================================================
# Compatibility with Yanfly Ace Shop Options: drawing custom icon in shop
#===============================================================================
class Window_ShopData < Window_Base
  def draw_item_image
    colour = Color.new(0, 0, 0, translucent_alpha/2)
    rect = Rect.new(1, 1, 94, 94)
    contents.fill_rect(rect, colour)
    if @item.image.nil?
      
      bitmap, icon_index, icon_width, icon_height = TH::Custom_Icon_Sheets.load_icon_sheet(@item.icon_index)
      rect = Rect.new(icon_index % 16 * icon_width, icon_index / 16 * icon_height, icon_width, icon_height)
      target = Rect.new(0, 0, 96, 96)
      contents.stretch_blt(target, bitmap, rect)
    else
      bitmap = Cache.picture(@item.image)
      contents.blt(0, 0, bitmap, bitmap.rect, 255)
    end
  end
end if $imported["YEA-ShopOptions"]

#===============================================================================
# Compatibility with Yanfly Ace Item Menu: drawing custom icon in item menu
#===============================================================================
class Window_ItemStatus < Window_Base
  def draw_item_image
    colour = Color.new(0, 0, 0, translucent_alpha/2)
    rect = Rect.new(1, 1, 94, 94)
    contents.fill_rect(rect, colour)
    if @item.image.nil?
      
      bitmap, icon_index, icon_width, icon_height = TH::Custom_Icon_Sheets.load_icon_sheet(@item.icon_index)
      rect = Rect.new(icon_index % 16 * icon_width, icon_index / 16 * icon_height, icon_width, icon_height)
      target = Rect.new(0, 0, 96, 96)
      contents.stretch_blt(target, bitmap, rect)
    else
      bitmap = Cache.picture(@item.image)
      contents.blt(0, 0, bitmap, bitmap.rect, 255)
    end
  end
end if $imported["YEA-ItemMenu"]

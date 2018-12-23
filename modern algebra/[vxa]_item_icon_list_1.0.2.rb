#==============================================================================
#    Icon Item List
#    Version: 1.0.2
#    Author: modern algebra (rmrk.net)
#    Date: 16 June 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script changes the item window so that it shows only icons to
#   represent the item and a number to show how many are held.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    You can also customize the size of each icon space, as well as various 
#   aspects of the font to draw the number, including size, colour, and whether
#   it is bolded. As well, you can set it so that the name of the item shows up
#   in the help window, and you can set its format as well. To do so, go to the
#   Editable Region at line 53 and read the instructions contained there.
#
#    The script also allows you to set it so that each icon has a background
#   colour and a shadow. Those are set at lines 90-95. You can also set it so
#   that each item has its own background colour by using either of the 
#   following codes in its notebox
#
#      \back_colour[x]
#      \back_colour[r, g, b, a]
#
#    If the former, the xth colour on the windowskin palette will be used. If
#   the latter, then it will choose a colour with those rgb and alpha values.
#
#    Note: using the Name feature will reduce the amount of space you have for
#   the actual description of your items. By default, it takes a whole line 
#   (although you can change that by altering the NAME_FORMAT string). If that 
#   is a problem, you could turn the feature off (but then it would not show 
#   the name anywhere). Another solution would be to increase the size of the
#   help window. That can be done by using my Customizable Item Menu script, 
#   which you can find here:
#
#      http://rmrk.net/index.php/topic,46516.0.html
#
#   If you use the Image in Description feature, you should probably remove the
#   \\icon from the NAME_FORMAT at line 112.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_IconItemList] = true

module MA_IconItemList
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#    BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Size Settings
  RECT_WIDTH = 28    # The width of each slot for the icon
  RECT_HEIGHT = 28   # The height of each slot for the icon
  SPACING = 12       # The space between icon slots
  # Number Settings
  #  NUM_FONTNAME - The font for the numbers. It should be an array of strings,
  # with each string being a font name ranked by priority. It will use the
  # first font in the array that exists on the user's computer. It will use 
  # the default if set to nil.
  NUM_FONTNAME = nil
  NUM_FONTSIZE = 20  # The size of the font showing how many items possessed
  NUM_BOLD = true    # Whether the number of items should be bolded
  NUM_ITALIC = false # Whether the number of items should be italicized
  NUM_SHADOW = true  # Whether the number of items should have a shadow
  NUM_OUTLINE = true # Whether the number of items should have an outline
  NUM_ALIGN = 2      # Alignment of number. 0 => Left; 1 => Centre; 2 => Right
  DO_NOT_DRAW_NUM_IF_1 = false # Don't draw num if only possess 1 of item
  # Colours
  #  Each of the colour settings can be either an integer, an array, or a 
  # Color object. If an integer (0, 1, ..., 31), it will take its colour from
  # that index of the windowskin's colour palette. If an array, then it must 
  # be in the form: [red, green, blue, alpha], where each is an integer between
  # 0 and 255. alphas is optional. Color objects may also be used, in which 
  # case it is: Color.new(red, green, blue, alpha)
  #
  #  Examples:
  #    NUM_COLOUR = 0
  #    NUM_COLOUR_WHEN_MAX = [100, 200, 145]
  #    NUM_OUT_COLOUR = Color.new(75, 75, 75, 160)
  #
  #  If you set NUM_OUT_COLOUR to nil, then it will just use the default 
  # outline colour.
  NUM_COLOUR = 0     # The colour of the number
  NUM_COLOUR_WHEN_MAX = 17 # The colour of the number if holding maximum
  NUM_OUT_COLOUR = nil # The colour of the outline, if showing. If nil, default
  # Back Settings
  #  These allow you to set a background colour for your items. The same
  # The same options for setting colours are available here as they are above.
  # Additionally, if set to nil, there will not be any colour.
  #  
  #  If you do decide to use them, recommended values for each are:
  #    BACK_DEFAULT_COLOUR = Color.new(64, 64, 64, 160)
  #    BACK_SHADOW_COLOUR = Color.new(0, 0, 0, 128)
  BACK_DEFAULT_COLOUR = nil # Default Main Colour
  BACK_SHADOW_COLOUR = nil  # Colour of Shadow
  # Name Settings
  #  SHOW_NAME_IN_DESCRIPTION - Set to true if you want to show the name of the 
  # item in the description window. Set it to false otherwise.
  SHOW_NAME_IN_DESCRIPTION = true 
  #  NAME_FORMAT - This is the format of the name, if shown in the description
  # window. The code \\icon will be replaced with the icon of the currently 
  # selected item, and \\name will be replaced with the name of the currently 
  # selected item. All the other message codes are also recognized, but you 
  # need to use two backslashes (\\), not one (\). Examples: 
  #    Good:     \\c[16]
  #    Bad:      \c[16]
  # The code \n (one backslash) will make a new line.
  NAME_FORMAT = "\\icon \\c[16]\\name\\c[0]\n"
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#    END Editable Region
#//////////////////////////////////////////////////////////////////////////////
end

#==============================================================================
# *** RPG::BaseItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - back_colour
#==============================================================================

class RPG::BaseItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Back Colour
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maiil_back_colour
    unless @maiil_back_colour
      if note[/\\BACK_COLOU?R\[(.+?)\]/i]
        dig = $1.scan(/\d+/).collect { |x| x.to_i }
        @maiil_back_colour = dig.empty? ? nil : dig.size == 1 ? dig[0] : dig
      else
        @maiil_back_colour = MA_IconItemList::BACK_DEFAULT_COLOUR
      end
    end
    return @maiil_back_colour
  end
end


#==============================================================================
# *** Window_MAIIL_Help
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window can mix in to a help window to show the names of items.
#==============================================================================

module Window_MAIIL_Help
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_item(item, *args)
    if item                                     # if Item passed
      text = MA_IconItemList::NAME_FORMAT.dup     # Get Name Format
      text.gsub!(/\\ICON/i, "\\i[#{item.icon_index}]") # Replace Icon
      text.gsub!(/\\NAME/i, item.name)            # Replace Name
      text += item.description                    # Add Description
      if $imported[:"MA Customizable Item Menu 1.0.x"] && self.is_a?(Window_MACIM_Help) # if using Custom Item Menu
        image = item.is_a?(MACIM_RPG_ItemWeaponArmor) ? item.macim_desc_image : ""
        set_text(text, image)                       # Set Text (CIM)
      else
        set_text(text)                              # Set Text (NO CIM)
      end
    else                                        # if nil Passed
      set_text("")                                # Set Text when no item
    end
  end
end

#==============================================================================
# ** Window_ItemList
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    overwritten methods - create_contents; text_color; draw_item; 
#      draw_item_number; col_max; spacing; line_height
#    aliased method - help_window=
#    new method - maiil_draw_item_icon
#==============================================================================

class Window_ItemList
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Contents
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_contents(*args)
    super(*args)
    maiil_reset_font
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Font
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maiil_reset_font
    fn = MA_IconItemList::NUM_FONTNAME ? MA_IconItemList::NUM_FONTNAME : Font.default_name
    contents.font = Font.new(fn, MA_IconItemList::NUM_FONTSIZE) # name and size
    contents.font.bold = MA_IconItemList::NUM_BOLD       # Set Bold
    contents.font.italic = MA_IconItemList::NUM_ITALIC   # Set Italic
    contents.font.shadow = MA_IconItemList::NUM_SHADOW   # Set Shadow
    contents.font.outline = MA_IconItemList::NUM_OUTLINE # Set outline
    oc = MA_IconItemList::NUM_OUT_COLOUR ? MA_IconItemList::NUM_OUT_COLOUR : Font.default_out_color
    contents.font.out_color = text_color(oc) # outline color
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Text Colour
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def text_color(n)
    case n
    when Integer then super(n)
    when Array then Color.new(*n)
    when Color then n
    else super(0)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item(index)
    item = @data[index]              # get item
    if item                          # if Item passed
      rect = item_rect(index)        # get rect
      contents.clear_rect(rect)
      maiil_draw_item_icon(rect, item) # draw icon
      draw_item_number(rect, item)     # draw number of items held
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item Icon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maiil_draw_item_icon(rect, item)
    x, y = rect.x + 2, rect.y + ((rect.height - 24) / 2) # Get coordinates
    if item.maiil_back_colour # Draw Border
      bcs = MA_IconItemList::BACK_SHADOW_COLOUR
      contents.fill_rect(x, y, 26, 26, text_color(bcs)) if bcs
      contents.fill_rect(x - 1, y - 1, 26, 26, text_color(item.maiil_back_colour))
    end
    draw_icon(item.icon_index, x, y, enable?(item))      # Draw Icon
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item Number
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item_number(rect, item)
    num = $game_party.item_number(item) # Get Number
    return if MA_IconItemList::DO_NOT_DRAW_NUM_IF_1 && num < 2
    # Set Number Colour
    if num == $game_party.max_item_number(item)
      contents.font.color = text_color(MA_IconItemList::NUM_COLOUR_WHEN_MAX)
    else
      contents.font.color = text_color(MA_IconItemList::NUM_COLOUR)
    end
    contents.font.color.alpha = translucent_alpha unless enable?(item) # Set Alpha
    # Adjust Rect
    rect2 = rect.dup
    rect2.y += (rect.height - contents.font.size)
    rect2.height = contents.font.size
    # Draw Number
    draw_text(rect2, num, MA_IconItemList::NUM_ALIGN)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Column Max
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def col_max; (contents_width / (MA_IconItemList::RECT_WIDTH + spacing)); end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Spacing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def spacing; MA_IconItemList::SPACING; end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Line Height
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def line_height; MA_IconItemList::RECT_HEIGHT; end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Help Window=
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if MA_IconItemList::SHOW_NAME_IN_DESCRIPTION # IF showing name in Description
    # If #help_window= has been redefined in Window_ItemList
    if instance_methods(false).include?(:"help_window=")
      alias maiil_helpwinset_4ka5 help_window=
      def help_window=(*args)
        maiil_helpwinset_4ka5(*args) # Call Original Method
        @help_window.extend(Window_MAIIL_Help)
      end
    else # Inheriting #help_window= from Window_Selectable
      def help_window=(*args)
        super(*args) # Call Original Method
        @help_window.extend(Window_MAIIL_Help)
      end
    end
  end
end

#==============================================================================
# *** Scene_ItemBase
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    overwritten method - cursor_left?
#==============================================================================

class Scene_ItemBase
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Determine if Cursor Is in Left Column
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def cursor_left?
    true
  end
end
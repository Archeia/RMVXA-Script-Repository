#==============================================================================
#    Customizable Item Menu
#    Version: 1.0.1
#    Author: modern algebra (rmrk.net)
#    Date: August 10, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to customize various features of the default item 
#   menu. It lets you:
#
#      - Increase the number of lines you can use in the description window.
#      - Change the position of the description window.
#      - Show an enlarged picture of the item in the description window.
#      - Make new categories to make the item menu cleaner to navigate.
#      - Represent categories by icons instead of plain text.
#      - Give descriptions to the categories.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials and other custom scripts.
#
#    All of the configuration for this script is done within the Editable 
#   Region starting at line 71. It is heavily commented and explains what each
#   option does, so I encourage you to read it. Here, however, I will explain
#   the configuration you can do within the note field of each item.
#``````````````````````````````````````````````````````````````````````````````
#    If you set the image_in_description value at line 83 to true, then you can
#   assign an image to any given item with the following code in a note field:
#
#      \image[filename]
#    where filename is the name of an image file in the Pictures folder of
#   Graphics.
#``````````````````````````````````````````````````````````````````````````````
#    If you set the description_lines value at line 79 to more than 2, then
#   you can add new lines to the description of an item with the followinf
#   code in a note field:
#
#      \desc+{new line of description}
#   You can add as many lines as you like, and message codes like \c[n] are 
#   recognized.
#``````````````````````````````````````````````````````````````````````````````
#    If you are using custom categories, then you can assign an item to appear
#   in the new category with the following code:
#
#      \cim_category[unique_1, unique_2, etc...]
#    where unique_1, unique_2, etc... are the names of the custom categories to
#    which you want to assign the item. Also, if you do not want the item to 
#    appear in its default category (a weapon in Weapons, an armour in Armours,
#    etc...), then all you need to do is place an ! after category and the 
#    item will then only appear in the categories you specify, like so:
#
#      \cim_category![unique_1, unique_2, etc...]
#
#    EXAMPLE:
#  Say the following is in the note field of item 1:
#      \cim_category[potion]
#        This item will now appear in the :all, :item, and :potion categories.
#
#  However, if the following is used:
#      \cim_category![potion]
#        then the item will only appear in the :all and :potion categories.
#==============================================================================

$imported ||= {}
$imported[:"MA Customizable Item Menu 1.0.x"] = true

MA_CUSTOM_ITEM_MENU = {
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#    BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# DESCRIPTION OPTIONS
#``````````````````````````````````````````````````````````````````````````````
#  description_at_top - If true, the description window will be at the top of
# the screen. If false, it will be at the bottom.
description_at_top: false,
#  description_lines - The number of lines to show in the description.
description_lines: 3,
#  image_in_description - If false, there will be no image shown in the
# description. If true, there will be. See line 29 for instructions on how to
# assign an image to an item through its notefield.
image_in_description: true,
#  image_width - If showing an image in the description window, this value is
# the number of pixels the description image requires horizontally.
  image_width: 48,
#  use_enlarged_icons_as_default - If you are showing images in the description
# window and this value is true, then for any item which has no assigned image,
# an enlarged version of its icon will be shown instead. If false, then no 
# image will be shown unless one is specifically assigned.
  use_enlarged_icons_as_default: true,
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# CATEGORY OPTIONS
#``````````````````````````````````````````````````````````````````````````````
#  use_icons_for_categories - If true, the categories will be represented by
# icons. If false, the categories will just be shown as text, as is normal
use_icons_for_categories: true,
#  show_category_label - if using icons for categories, this determines whether
# the name of the category is shown in a parallel window. If this value is true,
# then the category name is shown. If false, then it will just be the icons.
  show_category_label: true,
#  icon_category_width - if using icons for categories and are showing labels, 
# this determines the width of the icon category window.
    icon_category_width: 288,
#  category_label_position - If using icons for categories and showing the
# category label, this determines the position of the label window relative to
# the icon window. If :left, will be to the left. If :right, will be to the 
# right.
    category_label_position: :left,
#``````````````````````````````````````````````````````````````````````````````
#  custom_categories - This option allows you to choose which categories are
# shown in the Item Menu. There are five default categories: :item, :weapon,
# :armor, :key_item, and :all. As you would expect, the :item shows non-key
# items, :weapon shows all weapons, :armor shows all armors, :key_item shows
# all key items, and :all shows all items held by the party. They will appear 
# in the order that you set below. You can also create your own categories - 
# all you need to do is first create a symbol for the category and add it to 
# the array below. This can be anything as long as it is unique and in the 
# format:
#      :unique
# Next, you will need to go to the category_vocab and category_icons hashes and
# assign to it a Label (if showing labels) and an icon (if using category 
# icons). See the instructions above those hashes for details. 
#
#    EXAMPLE:
#  If we wanted to add a Potions category, we could call it :potion and the
# array would look as follows:
#
#    custom_categories: [:item, :potion, :weapon, :armor, :key_item],
#
# To find out how to assign an item to one of the custom categories you create,
# see line 44.
custom_categories: [:item, :weapon, :armor, :key_item],
#  category_vocab - In this hash, you can set the name of each category. You 
# need to set a name for every category included in the custom_categories 
# array unless you are using icons and not showing any label at all. You set
# each label as a "string" and that will be what shows up in-game. You can also
# set it so that the name is retrieved by evaluating an expression. To do that,
# just put a : in front of the quotation marks, like so:
#
#     :"expression"
#
#  Below, you will see examples of both - the :all category is set, by default,
# to an ordinary string, while the others are all set to retrieve the name for
# the category that is assigned in the Database.
#
#  Now, to set the name of a custom category that you create, all you need to
# do is make a new line before the } line in the following format:
#
#    :unique => "",
#
#    EXAMPLE:
#  To set the name of our new potions category, we could do the following:
#
#    :potion => "Potions",
category_vocab: {
  :all =>      "All Items",
  :item =>     :"Vocab::item",
  :potion =>   "Potions", 
  :weapon =>   :"Vocab::weapon",
  :armor =>    :"Vocab::armor",
  :key_item => :"Vocab::key_item",
}, # END VOCAB HASH
#  category_icons - If using icons to represent categories, then this is where
# you set which icons will show for each category. Just set it to whichever
# icon index you want. Similar to the vocab hash, the format is:
#
#    :unique => 0,
#
#    EXAMPLE:
#  Our potions category could be set as follows:
#    
#    :potion => 192,
category_icons: {
  :all =>      270,
  :item =>     260,
  :potion =>   192,
  :weapon =>   115,
  :armor =>    506,
  :key_item => 240,
}, # END ICONS HASH
#  category_descriptions - If you wish you can make it so that each category 
# has a description which will be shown in the help window whenever you are
# selecting a category. Similar to the above hashes, the format is:
#
#    :unique => "",
#
#  To make a new line, simply put a \\n within the string. 
#
#    EXAMPLE:
#  Our potions category could have a new description as follows:
#
#    :potion => "Alchemical concoctions to \\c[3]remedy\\c[0] various\\nillnesses.",
#
#  If you are showing an image in the description of items, you can also set 
# an image to show for the category description by the following code:
#
#    :unique => ["description", "image filename"],
#
#  where description is the regular description and image filename is the 
# filename of an image in the Pictures folder of Graphics. You could also just
# put an integer, in which case it would draw an enlarged version of the icon
# with that index.
#
#    EXAMPLES:
#  If you wanted your potions category to show an enlarged version of icon 192
# and be described as "Alchemical concoctions", you would add the following 
# line:
#
#    :potion => ["Alchemical concoctions", 192],
#
#  If you instead wanted to use a graphic from Pictures called "Potion01", then
# the line would be:
#
#    :potion => ["Alchemical concoctions", "Potion01"],
category_descriptions: {
  :all =>      "",
  :item =>     "",
  :weapon =>   "",
  :armor =>    "",
  :key_item => "",
}, # END DESCRIPTIONS HASH
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#    END Editable Region
#//////////////////////////////////////////////////////////////////////////////
}
MA_CUSTOM_ITEM_MENU[:category_vocab].default = ""
MA_CUSTOM_ITEM_MENU[:category_descriptions].default = ""
MA_CUSTOM_ITEM_MENU[:category_icons].default = 0

#==============================================================================
# *** MACIM_RPG_ItemWeaponArmor
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This method mixes in with RPG::Item, RPG::Weapon, and RPG::Armor, adding
# the following:
#    new method - macim_categories
#==============================================================================

module MACIM_RPG_ItemWeaponArmor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Custom Categories
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macim_categories
    if !@macim_categories
      @macim_categories = [macim_default_category]
      if self.note[/\\CIM[_ ]CATEGOR(Y|IES)(!?)\s*\[\s*(.+?)\s*\]/i]
        @macim_categories.delete(macim_default_category) unless $2.empty?
        cats = $3.scan(/[^:,;\s]+/)
        cats.each { |category| @macim_categories.push(category.to_sym) }
      end
    end
    @macim_categories
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Image 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macim_desc_image
    if !@macim_desc_image
      @macim_desc_image = ""
      if self.note[/\\IMAGE\[(.+?)\]/i]
        @macim_desc_image = $1 
      elsif MA_CUSTOM_ITEM_MENU[:use_enlarged_icons_as_default]
        @macim_desc_image = $imported[:MAIcon_Hue] ? [icon_index, icon_hue] : icon_index
      end
    end
    @macim_desc_image
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Description
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def description(*args, &block)
    result = super(*args, &block)
    if !@macim_description_plus
      @macim_description_plus = ""
      self.note.scan(/\\(DESC|DESCRIPTION)\+\{(.+?)\}/im) { |line|
        desc_plus = line[1].gsub(/\s*[\r\n]+\s*/, " ")
        desc_plus.gsub!(/\\[Nn]/, "\n")
        @macim_description_plus += "\n" + desc_plus
      }
    end
    result + @macim_description_plus
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Default Category
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macim_default_category; :item; end
end

#==============================================================================
# *** RPG
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This adds a few methods to the Item, Weapon, and Armor classes by mixing in 
# the MACIM_RPG_ItemWeaponArmor module.
#==============================================================================

module RPG
  class Item
    include MACIM_RPG_ItemWeaponArmor
    def macim_default_category; key_item? ? :key_item : :item; end
  end
  class Weapon
    include MACIM_RPG_ItemWeaponArmor
    def macim_default_category; :weapon; end
  end
  class Armor
    include MACIM_RPG_ItemWeaponArmor
    def macim_default_category; :armor; end
  end
end

unless $imported[:"MA_ParagraphFormat_1.0"]
#==============================================================================
# ** MA_Window_ParagraphFormat
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module inserts into Window_Base and provides a method to format the
# strings so as to go to the next line if it exceeds a set limit. This is 
# designed to work with draw_text_ex, and a string formatted by this method 
# should go through that, not draw_text.
#==============================================================================

module MA_Window_ParagraphFormat
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Calc Line Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_calc_line_width(line, tw = 0, contents_dummy = false)
    return tw if line.nil?
    line = line.clone
    unless contents_dummy
      real_contents = contents # Preserve Real Contents
      # Create a dummy contents
      self.contents = Bitmap.new(contents_width, 24)
      reset_font_settings
    end
    pos = {x: 0, y: 0, new_x: 0, height: calc_line_height(line)}
    while line[/^(.*?)\e(.*)/]
      tw += text_size($1).width
      line = $2
      # Remove all ancillaries to the code, like parameters
      code = obtain_escape_code(line)
      # If direct setting of x, reset tw.
      tw = 0 if ($imported[:ATS_SpecialMessageCodes] && code.upcase == 'X') ||
        ($imported["YEA-MessageSystem"] && code.upcase == 'PX')
      #  If I need to do something special on the basis that it is testing, 
      # alias process_escape_character and differentiate using @atsf_testing
      process_escape_character(code, line, pos)
    end
    #  Add width of remaining text, as well as the value of pos[:x] under the 
    # assumption that any additions to it are because the special code is 
    # replaced by something which requires space (like icons)
    tw += text_size(line).width + pos[:x]
    unless contents_dummy
      contents.dispose # Dispose dummy contents
      self.contents = real_contents # Restore real contents
    end
    return tw
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format Paragraph
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_format_paragraph(text, max_width = contents_width)
    text = text.clone
    #  Create a Dummy Contents - I wanted to boost compatibility by using the 
    # default process method for escape codes. It may have the opposite effect, 
    # for some :( 
    real_contents = contents # Preserve Real Contents
    self.contents = Bitmap.new(contents_width, 24)
    reset_font_settings
    paragraph = ""
    while !text.empty?
      text.lstrip!
      oline, nline, tw = mapf_format_by_line(text.clone, max_width)
      # Replace old line with the new one
      text.sub!(/#{Regexp.escape(oline)}/m, nline)
      paragraph += text.slice!(/.*?(\n|$)/)
    end
    contents.dispose # Dispose dummy contents
    self.contents = real_contents # Restore real contents
    return paragraph
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format By Line
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_format_by_line(text, max_width = contents_width)
    oline, nline, tw = "", "", 0
    loop do
      #  Format each word until reach the width limit
      oline, nline, tw, done = mapf_format_by_word(text, nline, tw, max_width)
      return oline, nline, tw if done
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Format By Word
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_format_by_word(text, line, tw, max_width)
    return line, line, tw, true if text.nil? || text.empty?
    # Extract next word
    if text.sub!(/(\s*)([^\s\n\f]*)([\n\f]?)/, "") != nil
      prespace, word, line_end = $1, $2, $3
      ntw = mapf_calc_line_width(word, tw, true)
      pw = contents.text_size(prespace).width
      if (pw + ntw >= max_width)
        # Insert
        if line.empty?
          # If one word takes entire line
          return prespace + word, word + "\n", ntw, true 
        else
          return line + prespace + word, line + "\n" + word, tw, true
        end
      else
        line += prespace + word
        tw = pw + ntw
        # If the line is force ended, then end 
        return line, line, tw, true if !line_end.empty?
      end
    else
      return line, line, tw, true
    end
    return line, line, tw, false
  end
end

class Window_Base
  include MA_Window_ParagraphFormat
end

$imported[:"MA_ParagraphFormat_1.0"] = true
end

unless $imported[:"MA_IconHorzCommand_1.0"]
#==============================================================================
# ** Window_MA_IconHorzCommand
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window is a base window to show a horizontal command window populated
# with icons.
#==============================================================================

class Window_MA_IconHorzCommand < Window_HorzCommand
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variable
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :observing_procs
  attr_accessor :cursor_hide
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(*args, &block)
    @observing_procs = {}
    super(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Column Max
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def col_max; [(width - standard_padding) / (24 + spacing), item_max].min; end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def item
    @list[index] ? @list[index][:symbol] : nil
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Enabled? / Current Item Enabled?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def enable?(index); self.index == index; end
  def current_item_enabled?; !current_data.nil?; end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item(index)
    rect = item_rect(index)
    contents.clear_rect(rect)
    draw_icon(@list[index][:ext], rect.x + ((rect.width - 24) / 2), rect.y, enable?(index))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Index
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def index=(index)
    old_index = self.index
    super(index)
    draw_item(old_index)
    draw_item(self.index)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    super
    @observing_procs.values.each { |block| block.call(item) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add/Remove Observing Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def add_observing_proc(id, &block)
    @observing_procs[id] = block
    update
  end
  def remove_observing_proc(id)     ; @observing_procs.delete(id) ; end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Cursor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_cursor
    super
    cursor_rect.empty if @cursor_hide
  end
end
$imported[:"MA_IconHorzCommand_1.0"] = true
end

#==============================================================================
# ** Window_ItemCategory
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    overwritten method - make_command_list; update_help
#==============================================================================

class Window_ItemCategory
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Command List
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def make_command_list
    categories = MA_CUSTOM_ITEM_MENU[:custom_categories]
    vocab = MA_CUSTOM_ITEM_MENU[:category_vocab]
    categories.each {|category|
      text = vocab[category].is_a?(Symbol) ? eval(vocab[category].to_s) : vocab[category]
      add_command(text, category) 
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Help
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_help
    @help_window.set_text(MA_CUSTOM_ITEM_MENU[:category_descriptions][current_symbol])
  end
end

#==============================================================================
# ** Window_ItemCategory
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - include?
#==============================================================================

class Window_ItemList
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Include in Item List?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_cim_includecheck_2hj7 include?
  def include?(item, *args, &block)
    return true if @category == :all
    if item.is_a?(MACIM_RPG_ItemWeaponArmor)
      item.macim_categories.include?(@category)
    else
      ma_cim_includecheck_2hj7(item, *args, &block)
    end
  end
end

#==============================================================================
# ** Window_MACIM_ItemIconCategory
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window shows categories represented by icons
#==============================================================================

class Window_MACIM_ItemIconCategory < Window_MA_IconHorzCommand
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(x = 0, y = 0, categories = MA_CUSTOM_ITEM_MENU[:custom_categories])
    @cursor_hide = false
    @categories = categories
    super(x, y)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Window Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def window_width
    !MA_CUSTOM_ITEM_MENU[:show_category_label] ? Graphics.width :
      MA_CUSTOM_ITEM_MENU[:icon_category_width] 
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Category=
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def category=(category)
    self.index = @categories.index(category) if @categories.include?(category)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Command List
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def make_command_list
    icons = MA_CUSTOM_ITEM_MENU[:category_icons]
    @categories.each {|category|
      add_command("", category, false, icons[category]) 
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Item Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def item_window=(window, *args)
    add_observing_proc(:list) {|category| window.category = category }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Help
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_help
    desc = MA_CUSTOM_ITEM_MENU[:category_descriptions][current_symbol]
    desc = [desc] if !desc.is_a?(Array)
    @help_window.set_text(*desc)
  end
end

#==============================================================================
# ** Window Category Label
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window simply shows a label for category currently selected
#==============================================================================

class Window_MACIM_CategoryLabel < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(x, y, label = "")
    super(x, y, window_width, window_height)
    refresh(label)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Window Attributes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def window_width; Graphics.width - MA_CUSTOM_ITEM_MENU[:icon_category_width]; end
  def window_height; line_height + (standard_padding*2); end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh(label = @label)
    @label = label.is_a?(String) ? convert_escape_characters(label) : ""
    contents.clear
    reset_font_settings
    tw = mapf_calc_line_width(@label)
    draw_text_ex((contents_width - tw) / 2, 0, @label)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Category
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def category=(category)
    return if @category == category
    @category = category
    vocab = MA_CUSTOM_ITEM_MENU[:category_vocab][@category]
    label = vocab.is_a?(Symbol) ? eval(vocab.to_s) : vocab
    refresh(label)
  end
end

#==============================================================================
# ** Window_MACIM_Help
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window is a help window with adjustable height and can show an image
#==============================================================================

class Window_MACIM_Help < Window_Help
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Text
  #    Adds argument to change the image associated with the description
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_text(text, filename = "")
    if filename != @image || text != @text
      @text = text
      @image = filename
      refresh
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Item
  #     item : Skills and items etc.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_item(item)
    item ? set_text(item.description, item.is_a?(MACIM_RPG_ItemWeaponArmor) ? item.macim_desc_image : "") : set_text("", "")
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh
    contents.clear
    draw_image(0, 0, MA_CUSTOM_ITEM_MENU[:image_width], contents_height, @image) unless @image == ""
    # Adjust x position for text to give room for image
    x = 4
    x += MA_CUSTOM_ITEM_MENU[:image_width]
    draw_text_ex(x, 0, @text)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Image
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_image(x, y, w, h, filename)
    contents.clear_rect(x, y, w, h)
    bmp = make_image_bmp(filename, w, h)
    # Adjust position and src_rect
    src_rect = Rect.new(0, 0, w, h)
    if w >= bmp.rect.width # If width allowed greater than width of image
      x += ((w - bmp.rect.width) / 2) # Centre
      src_rect.width = bmp.rect.width
    else # If width allowed is less than width of image
      src_rect.x += ((bmp.rect.width - w) / 2) # Cut to centre
    end
    if h >= bmp.rect.height # If height allowed is greater than height of image
      y += ((h - bmp.rect.height) / 2) # Centre
      src_rect.height = bmp.rect.height
    else # If height allowed is less than height of image
      src_rect.y += ((bmp.rect.height - h) / 2) # Cut to centre
    end
    contents.blt(x, y, bmp, src_rect)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Make the image bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def make_image_bmp(filename, w, h)
    case filename 
    when String then Cache.picture(filename)                  # Filename
    when Integer then get_enlarged_icon([w, h].min, filename) # icon index
    when Array                                              # [icon index, hue]
      filename = filename.select {|num| num.is_a?(Integer) }
      filename.slice!(2, filename.size - 2) if filename.size > 2
      return if filename.empty?
      get_enlarged_icon([w, h].min, *filename)
    else                                                      # empty
      Cache.picture("")
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Enlarged Icon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def get_enlarged_icon(size, icon_index, icon_hue = 0)
    iconset = Cache.system("Iconset")
    src_rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bmp = Bitmap.new(size, size)
    bmp.stretch_blt(bmp.rect, iconset, src_rect)
    # Compatibility with Icon Hues
    bmp.change_hue(icon_hue) if icon_hue != 0
    bmp
  end
end

#==============================================================================
# ** Scene_Item
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - start; create_category_window; create_help_window;
#      create_item_window
#    new method - create_category_label_window
#==============================================================================

class Scene_Item 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start Processing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macim_start_2hz7 start
  def start(*args, &block)
    macim_start_2hz7(*args, &block) # Call Original Method
    create_category_label_window if MA_CUSTOM_ITEM_MENU[:use_icons_for_categories] &&
      MA_CUSTOM_ITEM_MENU[:show_category_label]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Help Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macim_createhelp_2sk4 create_help_window
  def create_help_window(*args, &block)
    if MA_CUSTOM_ITEM_MENU[:description_lines] == 2 && 
        !MA_CUSTOM_ITEM_MENU[:image_in_description]
      macim_createhelp_2sk4(*args, &block) # Call Original Method
    else 
      # Create special help window if showing image - otherwise normal
      @help_window = MA_CUSTOM_ITEM_MENU[:image_in_description] ? 
        Window_MACIM_Help.new(MA_CUSTOM_ITEM_MENU[:description_lines]) : 
        Window_Help.new(MA_CUSTOM_ITEM_MENU[:description_lines])
      @help_window.viewport = @viewport
    end
    @help_window.y = Graphics.height - @help_window.height unless MA_CUSTOM_ITEM_MENU[:description_at_top]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Category Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macim_createcatwind_7jc4 create_category_window
  def create_category_window(*args, &block)
    if MA_CUSTOM_ITEM_MENU[:use_icons_for_categories] # If Icon Categories
      # Create Icon Categories window instead of regular
      x = (!MA_CUSTOM_ITEM_MENU[:show_category_label] || 
        MA_CUSTOM_ITEM_MENU[:category_label_position] == :right) ? 0 : 
        Graphics.width - MA_CUSTOM_ITEM_MENU[:icon_category_width]
      y = MA_CUSTOM_ITEM_MENU[:description_at_top] ? @help_window.height : 0
      @category_window = Window_MACIM_ItemIconCategory.new(x, y)
      @category_window.viewport = @viewport
      @category_window.help_window = @help_window
      @category_window.set_handler(:ok,     method(:on_category_ok))
      @category_window.set_handler(:cancel, method(:return_scene))
    else # Create regular category window if not using icons
      macim_createcatwind_7jc4(*args, &block) # Call Original Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Item Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macim_cretitmwdow_4gz9 create_item_window
  def create_item_window(*args, &block)
    macim_cretitmwdow_4gz9(*args, &block) # Call Original Method
    unless MA_CUSTOM_ITEM_MENU[:description_at_top]
      @item_window.height -= @help_window.height
      @item_window.refresh
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Category Label Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_category_label_window
    # Determine position
    x = MA_CUSTOM_ITEM_MENU[:category_label_position] == :right ? 
      MA_CUSTOM_ITEM_MENU[:icon_category_width] : 0
    y = MA_CUSTOM_ITEM_MENU[:description_at_top] ? @help_window.height : 0
    # Create label window
    @macim_categorylabel_window = Window_MACIM_CategoryLabel.new(x, y)
    @macim_categorylabel_window.viewport = @viewport
    @category_window.add_observing_proc(:label) { |category| 
      @macim_categorylabel_window.category = category }
  end
end

#==============================================================================
# ** Scene_Battle
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - create_help_window
#==============================================================================

class Scene_Battle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Help Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macim_crthelpwind_2kf6 create_help_window
  def create_help_window(*args, &block)
    if MA_CUSTOM_ITEM_MENU[:description_lines] == 2 && 
        !MA_CUSTOM_ITEM_MENU[:image_in_description]
      macim_crthelpwind_2kf6(*args, &block) # Call Original Method
    else 
      # Create special help window if showing image - otherwise normal
      @help_window = MA_CUSTOM_ITEM_MENU[:image_in_description] ? 
        Window_MACIM_Help.new(MA_CUSTOM_ITEM_MENU[:description_lines]) : 
        Window_Help.new(MA_CUSTOM_ITEM_MENU[:description_lines])
      @help_window.visible = false
    end
  end
end

#==============================================================================
# ** Scene_Equip
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - create_help_window
#==============================================================================

class Scene_Equip
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Help Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macim_catehelp_3nb7 create_help_window
  def create_help_window(*args, &block)
    if MA_CUSTOM_ITEM_MENU[:description_lines] == 2 && 
        !MA_CUSTOM_ITEM_MENU[:image_in_description]
      macim_catehelp_3nb7(*args, &block) # Call Original Method
    else 
      # Create special help window if showing image - otherwise normal
      @help_window = MA_CUSTOM_ITEM_MENU[:image_in_description] ? 
        Window_MACIM_Help.new(MA_CUSTOM_ITEM_MENU[:description_lines]) : 
        Window_Help.new(MA_CUSTOM_ITEM_MENU[:description_lines])
      @help_window.viewport = @viewport
    end
  end
end
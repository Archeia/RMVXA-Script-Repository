# ╔═══════════════════════════════════════════════════════╤═══════╤═══════════╗
# ║ Info Pages Window                                     │ v1.01 │ (5/03/13) ║
# ╚═══════════════════════════════════════════════════════╧═══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This script is meant to be used with other scripts and has no effect
# by itself. However, if you are a regular user, please read the 
# user customization module since you can still change settings
# related to this script.
#
# This script was made as an API for my own purposes, but other scripters
# may utilize it as well. However, I do not expect any other scripters to 
# actually use this. This means documentation on how to implement this 
# script into your own custom scenes is not yet available. If you are 
# interested in how to implement this window into your own scenes, feel 
# free to ask.
#--------------------------------------------------------------------------
#      Changelog
#--------------------------------------------------------------------------
# v1.01 : Added more info pages for equipment. (5/03/2013)
# v1.00 : Initial release. (4/14/2013)
#--------------------------------------------------------------------------
#      Installation and Requirements
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#
# This script also requires "Reader Functions for Features/Effects" 
# installed in your project as well.
#--------------------------------------------------------------------------
#      Compatibility   
#--------------------------------------------------------------------------
# There are no default method overwrites.
#
# This script has built-in compatibility with the following scripts:
#
#     -Yami Engine Symphony - Equipment Learning
#     -Shield Blocking
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                          http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["BubsInfoPages"] = 1.01

#==========================================================================
#    START OF USER CUSTOMIZATION MODULE   
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Info Page Settings
  #==========================================================================
  module InfoPages
  #--------------------------------------------------------------------------
  #   Item Info Pages
  #--------------------------------------------------------------------------
  # This setting determines the order of info pages for usable items. 
  # Each kind of info page is represented by a symbol.
  #
  # The following symbols require the script "Reader Functions 
  # for Features/Effects":
  #
  #   :basic_page
  #       Display HP/MP/TP Recovery values and states added or removed.
  #   :use_page
  #       Display infomation related to the item's usability.
  #   :learn_skill_page
  #       Display a list of skills that the item teaches.
  #   :misc_page
  #       Display miscellaneous information for debugging/testing.
  #       Not recommended for completed games.
  ITEM_INFO_PAGES = [:basic_page,         # Page 1
                     :use_page,           # Page 2
                     :learn_skill_page,   # Page 3
                     :misc_page,          # Page 4
                     # Add more symbols here
                     
                    ] # <- Do not delete.
                    
  #--------------------------------------------------------------------------
  #   Equip Info Page List
  #--------------------------------------------------------------------------
  # This setting determines the order of info pages for equippable items. 
  # Each kind of info page is represented by a symbol. Possible symbols
  # include:
  #
  #   :equippable_page
  #       Display a list of actors in the party that can equip the item.
  #
  # The following symbols require the script "Reader Functions 
  # for Features/Effects":
  #
  #   :param_page       
  #       Display basic parameter modification values and rates.
  #   :xparam_page
  #       Display X-parameter modification rates.
  #   :sparam_page
  #       Display Sp-parameter modification rates.
  #   :attack_page
  #       Display attack-related properties.
  #   :element_page
  #       Display element resistance modifiers.
  #   :state_page
  #       Display state resistance modifiers and state immunities.
  #   :added_skills_page
  #       Display a list of skills that the item grants while equipped.
  #   :sealed_skills_page
  #       Display a list of skills that the item disables while equipped.
  #   :equip_types_page
  #       Display the equip types the item allows the actor to equip.
  #   :equip_slots_page
  #       Display information related to equip slots.
  #   :added_skill_types_page
  #       Display a list of skill types the item allows the actor to cast.
  #   :special_flag_page
  #       Display a list special effects the item grants.
  #
  # The following symbols display unique information created by
  # other custom scripts:
  #
  #   :yes_equip_learn_page
  #       Display a list of skills learnable with AP points.
  #       Requires "Yami Engine Symphony - Equipment Learning"
  #   :bubs_blocking_page
  #       Display parameters related to blocking.
  #       Requires "Shield Blocking" by Mr. Bubble.
  EQUIP_INFO_PAGES = [:param_page,            # Page 1
                      :xparam_page,           # Page 2
                      :sparam_page,           # Page 3
                      :attack_page,           # Page 4
                      :element_page,          # etc...
                      :state_page,      
                      :equippable_page,
                      :added_skills_page,
                      :sealed_skills_page,
                      :added_skill_types_page,
                      :equip_slots_page,
                      :equip_types_page,
                      :special_flag_page,
                      # Add more symbols here
                      
                     ] # <- Do not delete.

  #--------------------------------------------------------------------------
  #   Change Page Buttons
  #--------------------------------------------------------------------------
  # This setting determine which gamepad buttons change aspects of the
  # item scene such as changing categories or changing the info window.
  # Default buttons that you can use include: 
  #
  # :LEFT, :RIGHT
  # :A, :B, :C, :X, :Y, :Z, :L, :R
  # :SHIFT, :CTRL, :ALT 
  PAGE_BUTTONS = {
    :next_info_page     => :Y,
    :prev_info_page     => :X,
  } # <- Do not delete.
  #--------------------------------------------------------------------------
  #   Page Button Icons
  #--------------------------------------------------------------------------
  # This setting defines the icons that represent buttons in the
  # info window.
  PAGE_BUTTON_ICONS = {
    :next_info_page     => 0, # Next Info Page Button Icon Index
    :prev_info_page     => 0, # Previous Info Page Button Icon Index
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Info Page Footer Text
  #--------------------------------------------------------------------------
  # This setting defines the footer text that is displayed at the bottom
  # of all info pages.
  #
  # Recommended length: 22 characters "                      "
  NORMAL_FOOTER_TEXT                = "←A                  S→"

  #--------------------------------------------------------------------------
  #   Actor Icon Index Numbers
  #--------------------------------------------------------------------------
  # This setting lets you define the icon index number that represents
  # an actor in info windows.
  ACTOR_ICONS = {
  # actor_id => icon_index,
           1 => 16,
           
           
  } # <- Do not delete.
  ACTOR_ICONS.default = 16 # Default icon if an actor icon is not found
  
  #--------------------------------------------------------------------------
  #   Use Full Parameter Names
  #--------------------------------------------------------------------------
  #  true : Use full parameter names in certain info windows.
  # false : Use abbreviated parameter names in info windows.
  USE_FULL_PARAMETER_NAMES = true
  #--------------------------------------------------------------------------
  #   Parameter Full Names
  #--------------------------------------------------------------------------
  PARAM_VOCAB_FULL = ["Health Points",    # HP
                      "Magic Points",     # MP
                      "Attack",           # ATK
                      "Defense",          # DEF
                      "Magic Attack",     # MAT
                      "Magic Defense",    # MDF
                      "Agility",          # AGI
                      "Luck"]             # LUK
  #--------------------------------------------------------------------------
  #   X-Parameter Abbreviations
  #--------------------------------------------------------------------------
  XPARAM_VOCAB = [  "HIT",    # HIT rate
                    "EVA",    # EVAsion rate
                    "CRI",    # CRItical rate
                    "CEV",    # Critical EVasion rate
                    "MEV",    # Magic EVasion rate
                    "MRF",    # Magic ReFlection rate
                    "CNT",    # CouNTer attack rate
                    "HRG",    # Hp ReGeneration rate
                    "MRG",    # Mp ReGeneration rate
                    "TRG"]    # Tp ReGeneration rate
  #--------------------------------------------------------------------------
  #   X-Parameter Full Names
  #--------------------------------------------------------------------------
  XPARAM_VOCAB_FULL = [ "Hit",              # HIT rate
                        "Evasion",          # EVAsion rate
                        "Critical",         # CRItical rate
                        "Critical Evasion", # Critical EVasion rate
                        "Magic Evasion",    # Magic EVasion rate
                        "Magic Reflection", # Magic ReFlection rate
                        "Counter Attack",   # CouNTer attack rate
                        "HP Regeneration",  # Hp ReGeneration rate
                        "MP Regeneration",  # Mp ReGeneration rate
                        "TP Regeneration"]  # Tp ReGeneration rate
  #--------------------------------------------------------------------------
  #   Sp-Parameter Abbreviations
  #--------------------------------------------------------------------------
  SPARAM_VOCAB   = ["TGR",    # TarGet Rate
                    "GRD",    # GuaRD effect rate
                    "REC",    # RECovery effect rate
                    "PHA",    # PHArmacology
                    "MCR",    # Mp Cost Rate
                    "TCR",    # Tp Charge Rate
                    "PDR",    # Physical Damage Rate
                    "MDR",    # Magical Damage Rate
                    "FDR",    # Floor Damage Rate
                    "EXR"]    # EXperience Rate
  #--------------------------------------------------------------------------
  #   Sp-Parameter Full Names
  #--------------------------------------------------------------------------
  SPARAM_VOCAB_FULL= ["Target Rate",      # TarGet Rate
                      "Guard Effect",     # GuaRD effect rate
                      "Recovery Effect",  # RECovery effect rate
                      "Pharmacology",     # PHArmacology
                      "MP Cost Rate",     # Mp Cost Rate
                      "TP Charge Rate",   # Tp Charge Rate
                      "Physical Damage",  # Physical Damage Rate
                      "Magical Damage",   # Magical Damage Rate
                      "Floor Damage",     # Floor Damage Rate
                      "Experience Bonus"] # EXperience Rate
                     
  #--------------------------------------------------------------------------
  #   Info Page Label Text
  #--------------------------------------------------------------------------
  INFO_LABEL_TEXT = {
    # General
    :main_header      => "Information",
    
    # Weapons and Armor
    :atk_elements       => "Attack Elements",
    :atk_speed          => "Attack Speed",
    :atk_times_add      => "Number of Attacks",
    :atk_states         => "Attack States",
    :element_rate       => "Element Resistances",
    :state_rate         => "State Resistances",
    :state_resist_set   => "State Immunity",
    :equippable         => "Equippable Members",
    :special_flag       => "Special Effects",
    :added_skills       => "Added Skills",
    :sealed_skills      => "Sealed Skills",
    :added_skill_types  => "Added Skill Types",
    :sealed_skill_types => "Sealed Skill Types",
    :equip_wtypes       => "Added Weapon Types",
    :equip_atypes       => "Added Armor Types",
    :fixed_equips       => "Fixed Equipment",
    :sealed_equips      => "Sealed Equipment",
    
    # Slot Type
    :dual_wield       => "Dual Wield",
    
    # Items and Skills
    :hp_recovery      => "HP Recovery",
    :mp_recovery      => "MP Recovery",
    :tp_recovery      => "TP Recovery",
    :add_states       => "Adds",
    :remove_states    => "Removes",
    :learn_skill      => "Teaches Skills",
    :common_event     => "Common Event ID",
    :scope            => "Target",
    :animation        => "Animation ID",
    
    # Hit Type
    :hit_type         => "Hit Type",
    :certain_hit      => "-",
    :physical_atk     => "Physical",
    :magical_atk      => "Magical",
    
    # Occasion
    :occasion         => "Usable",
    :always_use       => "Anywhere",
    :battle_use       => "Battle",
    :menu_use         => "Menu",
    :never_use        => "-",
    
    # Invocation
    :speed            => "Speed",
    :success_rate     => "Hit Rate",
    :repeats          => "Number of Hits",
    :tp_gain          => "TP Gain",
        
    # Special Flags
    :auto_battle      => "Auto-Battle",
    :guard            => "Super Guard",
    :substitute       => "Substitute",
    :preserve_tp      => "Preserve TP",
    
    # Party Ability
    :encounter_half   => "Encounter Half",
    :encounter_none   => "Encounter None",
    :cancel_surprise  => "Cancel Surprise",
    :raise_preemptive => "Raise Pre-emptive",
    :gold_double      => "Double Gold Drop",
    :drop_item_double => "Double Item Drop",
    
    # Yami Engine Symphony - Equipment Learning
    :yes_equip_learn  => "Available Skills",
    
    # Bubs Shield Blocking
    :blocking        => "Blocking",
    :crit_blocking   => "Critical Blocking",
    :blocking_yes    => "Yes",
    :blocking_no     => "No",
    :unblockable     => "Unblockable",
    
    
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Scope Label Text
  #--------------------------------------------------------------------------
  SCOPE_TEXT = {
    0   => "None",
    1   => "One Enemy",
    2   => "All Enemies",
    3   => "One Random Enemy",
    4   => "Two Random Enemies",
    5   => "Three Random Enemies",
    6   => "Four Random Enemies",
    7   => "One Ally",
    8   => "All Allies",
    9   => "One Dead Ally",
    10  => "All Dead Allies",
    11  => "User",
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Special Flag Icon Index Numbers
  #--------------------------------------------------------------------------
  SPECIAL_FLAG_ICONS = {
    # Slot Type
    :dual_wield       =>  11,

    # Special Flags
    :auto_battle      =>  14,
    :guard            => 161,
    :substitute       =>  12,
    :preserve_tp      =>  13,
    
    # Party Ability
    :encounter_half   => 123,
    :encounter_none   => 122,
    :cancel_surprise  =>  10,
    :raise_preemptive => 143,
    :gold_double      => 360,
    :drop_item_double => 495,

  } # <- Do not delete.

  #--------------------------------------------------------------------------
  #   Element Icon Index Numbers
  #--------------------------------------------------------------------------
  # This setting lets you define the icon index number that represents
  # an element in info pages
  #
  # Requires "Reader Functions for Features/Effects" to see effects.
  ELEMENT_ICONS = {
    1 => 116, # Physical
    2 => 113, # Absorb
    3 =>  96, # Fire
    4 =>  97, # Ice
    5 =>  98, # Thunder
    6 =>  99, # Water
    7 => 100, # Earth
    8 => 101, # Wind
    9 => 102, # Light
   10 => 103, # Dark
   # Add more element definitions here.
   
  } # <- Do not delete.
    
  #--------------------------------------------------------------------------
  #   Element ID List for Info Page
  #--------------------------------------------------------------------------
  # This setting determines which elements are seen in an item's element
  # info page where each number in the array is an Element ID number from
  # your database.
  #
  # Requires "Reader Functions for Features/Effects" to see effects.
  DISPLAYED_ELEMENT_RESISTS = [1,2,3,4,5,6,7,8,9,10]
  
  #--------------------------------------------------------------------------
  #   State ID List for Info Page
  #--------------------------------------------------------------------------
  # This setting determines which states are seen in an item's state
  # info page where each number in the array is a State ID number from
  # your database.
  #
  # Requires "Reader Functions for Features/Effects" to see effects.
  DISPLAYED_STATE_RESISTS   = [1,2,3,4,5,6,7,8]

  #--------------------------------------------------------------------------
  #   Page Change Sound Effect
  #--------------------------------------------------------------------------
  # Filename : SE filename in Audio/SE/ folder
  # Volume   : Between 0~100
  # Pitch    : Between 50~150
  #
  #                  Filename, Volume, Pitch
  PAGE_CHANGE_SE = ["Cursor1",     80,   100]
    
  #--------------------------------------------------------------------------
  #   Maximum Icon Columns
  #--------------------------------------------------------------------------
  # Recommended value: 2
  MAX_COLUMNS = 2
  
  end # module InfoPages
end # module Bubs


#==========================================================================
#     END OF USER CUSTOMIZATION MODULE 
#==========================================================================




#==============================================================================
# ++ Sound
#==============================================================================
module Vocab
  #--------------------------------------------------------------------------
  # new method : xparam
  #--------------------------------------------------------------------------
  def self.xparam(param_id)
    Bubs::InfoPages::XPARAM_VOCAB[param_id]
  end
  
  #--------------------------------------------------------------------------
  # new method : sparam
  #--------------------------------------------------------------------------
  def self.sparam(param_id)
    Bubs::InfoPages::SPARAM_VOCAB[param_id]
  end
  
  #--------------------------------------------------------------------------
  # new method : param_f
  #--------------------------------------------------------------------------
  def self.param_f(param_id)
    Bubs::InfoPages::PARAM_VOCAB_FULL[param_id]
  end
  
  #--------------------------------------------------------------------------
  # new method : xparam_f
  #--------------------------------------------------------------------------
  def self.xparam_f(param_id)
    Bubs::InfoPages::XPARAM_VOCAB_FULL[param_id]
  end
  
  #--------------------------------------------------------------------------
  # new method : sparam_f
  #--------------------------------------------------------------------------
  def self.sparam_f(param_id)
    Bubs::InfoPages::SPARAM_VOCAB_FULL[param_id]
  end

end # module Vocab



#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  #--------------------------------------------------------------------------
  # new method : play_info_page_change
  #--------------------------------------------------------------------------
  def self.play_info_page_change
    filename = Bubs::InfoPages::PAGE_CHANGE_SE[0]
    volume   = Bubs::InfoPages::PAGE_CHANGE_SE[1]
    pitch    = Bubs::InfoPages::PAGE_CHANGE_SE[2]
    Audio.se_play("Audio/SE/" + filename, volume, pitch) 
  end
end # module Sound




#==============================================================================
# ++ Window_InfoPages
#==============================================================================
class Window_InfoPages < Window_Base
  #--------------------------------------------------------------------------
  # Constants (Starting Number of Buff/Debuff Icons)
  #--------------------------------------------------------------------------
  ICON_BUFF_START       = 64              # buff (16 icons)
  ICON_DEBUFF_START     = 80              # debuff (16 icons)
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :number
  attr_accessor :page_change
  attr_accessor :page_index
  attr_reader   :last_item
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @last_item = nil
    @pages = [:nothing]
    @page_change = true
    @page_index = 0
    setup_page_types
  end
  
  #--------------------------------------------------------------------------
  # setup_page_types
  #--------------------------------------------------------------------------
  def setup_page_types
    @item_pages = Bubs::InfoPages::ITEM_INFO_PAGES
    @skill_pages = [:nothing]
    @equipitem_pages  = Bubs::InfoPages::EQUIP_INFO_PAGES
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    standard_page_doodads(4, 0)
    return unless @item
    draw_page_contents(4, line_height * 2, @item)
  end
  
  #--------------------------------------------------------------------------
  # item=                                        # Set Item
  #--------------------------------------------------------------------------
  def item=(item)
    @last_item = @item
    @item = item
    change_page_type
    refresh
  end
  
  #--------------------------------------------------------------------------
  # change_page_type
  #--------------------------------------------------------------------------
  def change_page_type
    if @item.is_a?(RPG::Item)
      @pages = @item_pages
      @page_index = 0 if @last_item && !@last_item.is_a?(RPG::Item)
    elsif @item.is_a?(RPG::Skill)
      @pages = @skill_pages
      @page_index = 0 if @last_item && !@last_item.is_a?(RPG::Skill)
    elsif @item.is_a?(RPG::EquipItem)
      @pages = @equipitem_pages
      @page_index = 0 if @last_item && !@last_item.is_a?(RPG::EquipItem)
    end
  end

  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  
  #--------------------------------------------------------------------------
  # update_page               # Checks for button input for page changing
  #--------------------------------------------------------------------------
  def update_page
    if visible && @page_change
      next_info_page if Input.trigger?(next_page_button) 
      prev_info_page if Input.trigger?(prev_page_button)
    end
  end
  
  #--------------------------------------------------------------------------
  # current_page
  #--------------------------------------------------------------------------
  def current_page
    @pages[@page_index]
  end

  #--------------------------------------------------------------------------
  # draw_page_contents
  #--------------------------------------------------------------------------
  def draw_page_contents(x, y, item)
    case current_page
    when :basic_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_usableitem_page(item, x, y)
      
    when :use_page
      draw_use_page(item, x, y)
      
    when :learn_skill_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_learn_skill_page(item, x, y)
      
    when :misc_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_misc_page(item, x, y)
      
    when :special_flag_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_special_flag_page(item, x, y)

    when :param_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_param_page(item, x, y)
      
    when :xparam_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_xparam_page(item, x, y)
      
    when :sparam_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_sparam_page(item, x, y)
      
    when :attack_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_attack_info(item, x, y)
      
    when :element_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_element_resists_page(item, x, y)
      
    when :state_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_state_resists_page(item, x, y)
      
    when :added_skills_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_added_skills_page(item, x, y)
      
    when :sealed_skills_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_sealed_skills_page(item, x, y)
      
    when :added_skill_types_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_added_skill_types_page(item, x, y)
      
    when :equip_types_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_equip_types_page(item, x, y)
      
    when :equip_wtypes_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_equip_wtypes_page(item, x, y)
      
    when :equip_atypes_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_equip_atypes_page(item, x, y)
      
    when :equip_slots_page
      return feature_reader_req(x, y) unless $imported["BubsFeaturesReader"]
      draw_equip_slots_page(item, x, y)
      
    when :yes_equip_learn_page
      return yes_equip_learn_req(x, y) unless $imported["YES-EquipmentLearning"]
      draw_yes_equip_learn_page(item, x, y)
      
    when :bubs_blocking_page
      return unless $imported["BubsBlocking"]
      draw_bubs_blocking_page(item, x, y)
      
    when :equippable_page
      draw_equippable_page(item, x, y) 
      
    end # case
  end # def
    
  #--------------------------------------------------------------------------
  # standard_page_doodads
  #--------------------------------------------------------------------------
  def standard_page_doodads(x, y)
    draw_info_header_text(x, y)
    draw_info_footer_text(x, y)
    draw_horz_line(line_height)
    draw_info_button_icons(x, y)
  end
  
  #--------------------------------------------------------------------------
  # feature_reader_req
  #--------------------------------------------------------------------------
  def feature_reader_req(x, y)
    change_color(normal_color)
    lh = line_height
    rect = Rect.new(x, y, contents.width - 4 - x, lh)
    text = "This page requires"
    rect.y += lh
    draw_text(rect, text, 1)
    text = "the script"
    rect.y += lh
    draw_text(rect, text, 1)
    text = "\"Reader Functions for "
    rect.y += lh
    draw_text(rect, text, 1)
    text = "Features\/Effects\""
    rect.y += lh
    draw_text(rect, text, 1)
    text = "to be properly viewed."
    rect.y += lh
    draw_text(rect, text, 1)
  end
  
  #--------------------------------------------------------------------------
  # yes_equip_learn_req
  #--------------------------------------------------------------------------
  def yes_equip_learn_req(x, y)
    change_color(normal_color)
    lh = line_height
    rect = Rect.new(x, y, contents.width - 4 - x, lh)
    text = "This page requires"
    rect.y += lh
    draw_text(rect, text, 1)
    text = "the script"
    rect.y += lh
    draw_text(rect, text, 1)
    text = "\"Yami Engine Symphony -"
    rect.y += lh
    draw_text(rect, text, 1)
    text = "Equipment Learning\""
    rect.y += lh
    draw_text(rect, text, 1)
    text = "to be properly viewed."
    rect.y += lh
    draw_text(rect, text, 1)
  end
  
  #--------------------------------------------------------------------------
  # icon_width
  #--------------------------------------------------------------------------
  def icon_width
    return 24
  end
  
  #--------------------------------------------------------------------------
  # prev_page_button
  #--------------------------------------------------------------------------
  def prev_page_button
    Bubs::InfoPages::PAGE_BUTTONS[:prev_info_page]
  end
  
  #--------------------------------------------------------------------------
  # next_page_button
  #--------------------------------------------------------------------------
  def next_page_button
    Bubs::InfoPages::PAGE_BUTTONS[:next_info_page]
  end
  
  #--------------------------------------------------------------------------
  # normal_footer_text
  #--------------------------------------------------------------------------
  def normal_footer_text
    Bubs::InfoPages::NORMAL_FOOTER_TEXT
  end
  
  #--------------------------------------------------------------------------
  # use_full_param_names?
  #--------------------------------------------------------------------------
  def use_full_param_names?
    Bubs::InfoPages::USE_FULL_PARAMETER_NAMES
  end
  
  #--------------------------------------------------------------------------
  # vocab_param
  #--------------------------------------------------------------------------
  def vocab_param(param_id)
    return Vocab::param_f(param_id) if use_full_param_names?
    return Vocab::param(param_id)
  end
  
  #--------------------------------------------------------------------------
  # vocab_xparam
  #--------------------------------------------------------------------------
  def vocab_xparam(param_id)
    return Vocab::xparam_f(param_id) if use_full_param_names?
    return Vocab::xparam(param_id)
  end
  
  #--------------------------------------------------------------------------
  # vocab_sparam
  #--------------------------------------------------------------------------
  def vocab_sparam(param_id)
    return Vocab::sparam_f(param_id) if use_full_param_names?
    return Vocab::sparam(param_id)
  end
  
  #--------------------------------------------------------------------------
  # button_icon_id
  #--------------------------------------------------------------------------
  def button_icon_id(symbol)
    Bubs::InfoPages::PAGE_BUTTON_ICONS[symbol]
  end
  
  #--------------------------------------------------------------------------
  # actor_icons
  #--------------------------------------------------------------------------
  def actor_icon_id(actor_id)
    Bubs::InfoPages::ACTOR_ICONS[actor_id]
  end

  #--------------------------------------------------------------------------
  # element_icon_id
  #--------------------------------------------------------------------------
  def element_icon_id(element_id)
    Bubs::InfoPages::ELEMENT_ICONS[element_id]
  end
  
  #--------------------------------------------------------------------------
  # special_flag_icon_id
  #--------------------------------------------------------------------------
  def special_flag_icon_id(symbol)
    Bubs::InfoPages::SPECIAL_FLAG_ICONS[symbol]
  end
  
  #--------------------------------------------------------------------------
  # listed_elements
  #--------------------------------------------------------------------------
  def listed_elements
    Bubs::InfoPages::DISPLAYED_ELEMENT_RESISTS
  end
  
  #--------------------------------------------------------------------------
  # listed_states
  #--------------------------------------------------------------------------
  def listed_states
    Bubs::InfoPages::DISPLAYED_STATE_RESISTS
  end
  
  #--------------------------------------------------------------------------
  # label_text
  #--------------------------------------------------------------------------
  def label_text(symbol)
    Bubs::InfoPages::INFO_LABEL_TEXT[symbol]
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    Bubs::InfoPages::MAX_COLUMNS
  end
  
  #--------------------------------------------------------------------------
  # scope_text
  #--------------------------------------------------------------------------
  def scope_text(scope_id)
    Bubs::InfoPages::SCOPE_TEXT[scope_id]
  end
  
  #--------------------------------------------------------------------------
  # draw_label_text
  #--------------------------------------------------------------------------
  def draw_label_text(symbol, x, y, align = 0)
    change_color(system_color)
    rect = standard_rect(x, y) 
    text = label_text(symbol)
    draw_text(rect, text, align)
  end
  
  #--------------------------------------------------------------------------
  # item_width
  #--------------------------------------------------------------------------
  def item_width
    (width - standard_padding * 2 + 4) / col_max - 4
  end
  
  #--------------------------------------------------------------------------
  # next_info_page
  #--------------------------------------------------------------------------
  def next_info_page
    @page_index = (@page_index + 1) % @pages.size
    Sound.play_info_page_change
    refresh
  end
  
  #--------------------------------------------------------------------------
  # prev_info_page
  #--------------------------------------------------------------------------
  def prev_info_page
    @page_index = (@page_index - 1) % @pages.size
    Sound.play_info_page_change
    refresh
  end
  
  #--------------------------------------------------------------------------
  # line_color                              # Get Color of Horizontal Line
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
    
  #--------------------------------------------------------------------------
  # standard_rect
  #--------------------------------------------------------------------------
  def standard_rect(x, y)
    Rect.new(x, y, contents.width - 4 - x, line_height)
  end
  
  #--------------------------------------------------------------------------
  # draw_horz_line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  
  #--------------------------------------------------------------------------
  # draw_info_footer_text
  #--------------------------------------------------------------------------
  def draw_info_footer_text(x, y)
    y = y + line_height * (contents.height / line_height - 1)
    rect = standard_rect(x, y)
    #rect.x += 0
    change_color(normal_color)
    draw_text(rect, normal_footer_text, 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_info_button_icons
  #--------------------------------------------------------------------------
  def draw_info_button_icons(x, y)
    y = y + line_height * (contents.height / line_height - 1)
    draw_icon(button_icon_id(:prev_info_page), x, y)
    x = contents.width - icon_width - 4
    draw_icon(button_icon_id(:next_info_page), x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_equippable_page
  #--------------------------------------------------------------------------
  def draw_equippable_page(item, x, y)
    draw_label_text(:equippable, x, y)
    draw_equippable_members_info(item, x, y + line_height)
  end
  
  #--------------------------------------------------------------------------
  # draw_equippable_members_info
  #--------------------------------------------------------------------------
  def draw_equippable_members_info(item, x, y)
    change_color(normal_color)
    temp = $game_party.members.select { |member| member.equippable?(item) }
    temp.each_with_index do |member, index|
      y_plus = line_height * (index / col_max)
      x_plus = index % col_max * item_width
      icon_index = actor_icon_id(member.id) ? member.id : :default
      draw_icon(actor_icon_id(icon_index), x + x_plus, y + y_plus)
      rect = Rect.new(x, y, contents.width / col_max - 4 - x, line_height)
      rect.x += x_plus
      rect.y += y_plus
      text = sprintf("%s", member.name)
      draw_text(rect, text, 2)
    end
  end
    
  #--------------------------------------------------------------------------
  # draw_param_page
  #--------------------------------------------------------------------------
  def draw_param_page(item, x, y)
    8.times do |i|
      y_plus = line_height * i
      x_plus = 0 #i % col_max * item_width
      draw_param_name(x + x_plus, y + y_plus, i)
      draw_param_value(item, x + x_plus, y + y_plus, i)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_xparam_page
  #--------------------------------------------------------------------------
  def draw_xparam_page(item, x, y)
    10.times do |i|
      y_plus = line_height * i
      x_plus = 0 #i % col_max * item_width
      draw_xparam_name(x + x_plus, y + y_plus, i)
      draw_xparam_value(item, x + x_plus, y + y_plus, i)
    end
  end

  #--------------------------------------------------------------------------
  # draw_sparam_page
  #--------------------------------------------------------------------------
  def draw_sparam_page(item, x, y)
    10.times do |i|
      y_plus = line_height * i
      x_plus = 0 #i % col_max * item_width
      draw_sparam_name(x + x_plus, y + y_plus, i)
      draw_sparam_value(item, x + x_plus, y + y_plus, i)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_attack_info
  #--------------------------------------------------------------------------
  def draw_attack_info(item, x, y)
    draw_attack_elements(item, x, y + line_height * 0)
    draw_attack_speed(item, x, y + line_height * 1)
    draw_number_of_attacks(item, x, y + line_height * 2)
    draw_label_text(:atk_states, x, y + line_height * 4)
    draw_attack_states(item, x, y + line_height * 5)
  end
  
  #--------------------------------------------------------------------------
  # draw_attack_elements
  #--------------------------------------------------------------------------
  def draw_attack_elements(item, x, y)
    draw_label_text(:atk_elements, x, y)
    draw_attack_elements_icons(item, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_info_header_text
  #--------------------------------------------------------------------------
  def draw_info_header_text(x, y)
    rect = standard_rect(x, y)
    draw_label_text(:main_header, x, y)
    draw_icon(@item.icon_index, rect.width - icon_width, y) if @item
  end
  
  #--------------------------------------------------------------------------
  # draw_attack_elements_icons
  #--------------------------------------------------------------------------
  def draw_attack_elements_icons(item, x, y)
    icons = item.atk_elements
    icons.reverse.each_with_index do |id, i|
      n = element_icon_id(id) ? element_icon_id(id) : 0
      draw_icon(n, contents.width - 4 - x - (icon_width * (i + 1)), y)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_attack_speed
  #--------------------------------------------------------------------------
  def draw_attack_speed(item, x, y)
    draw_label_text(:atk_speed, x, y)
    rect = standard_rect(x, y)
    value = item.atk_speed
    change_color(param_change_color(value))
    draw_text(rect, sprintf("%+d", value), 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_number_of_attacks
  #--------------------------------------------------------------------------
  def draw_number_of_attacks(item, x, y)
    draw_label_text(:atk_times_add, x, y)
    rect = standard_rect(x, y)
    value = item.atk_times_add
    change_color(param_change_color(value))
    draw_text(rect, sprintf("%+d", value), 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_attack_states
  #--------------------------------------------------------------------------
  def draw_attack_states(item, x, y)
    change_color(normal_color)
    item.atk_states.each_with_index do |state_id, index|
      y_plus = line_height * (index / col_max)
      x_plus = index % col_max * item_width
      icon_index = $data_states[state_id].icon_index
      draw_icon(icon_index, x + x_plus, y + y_plus)
      rect = Rect.new(x, y, contents.width / col_max - 4 - x, line_height)
      rect.x += x_plus
      rect.y += y_plus
      rate = item.atk_states_rate(state_id) * 100
      text = sprintf("%d%%", rate)
      draw_text(rect, text, 2)
    end
  end  
  
  #--------------------------------------------------------------------------
  # draw_element_resists_page
  #--------------------------------------------------------------------------
  def draw_element_resists_page(item, x, y)
    draw_label_text(:element_rate, x, y)
    draw_element_resists(item, x, y + line_height * 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_state_resists_page
  #--------------------------------------------------------------------------
  def draw_state_resists_page(item, x, y)
    draw_label_text(:state_rate, x, y)
    draw_state_resists(item, x, y + line_height * 1)
    draw_label_text(:state_resist_set, x, y + line_height * 8)
    draw_state_immunity(item, x, y + + line_height * 9)
  end
  
  #--------------------------------------------------------------------------
  # draw_state_resists
  #--------------------------------------------------------------------------
  def draw_state_resists(item, x, y)
    listed_states.each_with_index do |state_id, index|
      y_plus = line_height * (index / col_max)
      x_plus = index % col_max * item_width
      icon_index = $data_states[state_id].icon_index
      draw_icon(icon_index, x + x_plus, y + y_plus)
      rect = Rect.new(x, y, contents.width / col_max - 4 - x, line_height)
      rect.x += x_plus
      rect.y += y_plus
      rate = item.state_rate(state_id) * 100 - 100
      change_color(param_change_color(-rate))
      text = sprintf("%+d%%", -rate)
      draw_text(rect, text, 2)    
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_state_immunity
  #--------------------------------------------------------------------------
  def draw_state_immunity(item, x, y)
    item.state_resist_set.each_with_index do |state_id, index|
      icon_row_max = (contents.width - 4 - x) / icon_width
      y_plus = (index / icon_row_max) * line_height
      x_plus = (index % icon_row_max) * icon_width
      icon_index = $data_states[state_id].icon_index
      draw_icon(icon_index, x + x_plus, y + y_plus)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_element_resists
  #--------------------------------------------------------------------------
  def draw_element_resists(item, x, y)
    change_color(normal_color)
    listed_elements.each_with_index do |element_id, index|
      y_plus = line_height * (index / col_max)
      x_plus = index % col_max * item_width
      icon_index = element_icon_id(element_id) ? element_icon_id(element_id) : 0
      draw_icon(icon_index, x + x_plus, y + y_plus)
      rect = Rect.new(x + x_plus, y + y_plus, contents.width / col_max - 4 - x, line_height)
      rate = item.element_rate(element_id) * 100 - 100
      change_color(param_change_color(-rate))
      text = sprintf("%+d%%", -rate)
      draw_text(rect, text, 2)  
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_usableitem_page
  #--------------------------------------------------------------------------
  def draw_usableitem_page(item, x, y)
    lh = line_height
    draw_hp_recovery(item, x, y + lh * 0)
    draw_mp_recovery(item, x, y + lh * 1)
    draw_tp_recovery(item, x, y + lh * 2)
    draw_label_text(:add_states, x, y  + lh * 4)
    draw_add_state_icons(item, x, y + lh * 5)
    draw_label_text(:remove_states, x, y + lh * 7)
    draw_remove_state_icons(item, x, y + lh * 8)
  end
  
  #--------------------------------------------------------------------------
  # draw_add_state_icons
  #--------------------------------------------------------------------------
  def draw_add_state_icons(item, x, y)
    icons = get_add_state_icons(item)
    draw_icon_columns(icons, x, y)
  end

  
  #--------------------------------------------------------------------------
  # draw_remove_state_icons
  #--------------------------------------------------------------------------
  def draw_remove_state_icons(item, x, y)
    icons = get_remove_state_icons(item)
    draw_icon_columns(icons, x, y)
  end

  #--------------------------------------------------------------------------
  # draw_learn_skill_page
  #--------------------------------------------------------------------------
  def draw_learn_skill_page(item, x, y)
    draw_label_text(:learn_skill, x, y)
    draw_learn_skills(item, x, y + line_height)
  end
  
  #--------------------------------------------------------------------------
  # draw_learn_skills
  #--------------------------------------------------------------------------
  def draw_learn_skills(item, x, y)
    w = contents_width - icon_width
    item.learn_skills.each_with_index do |skill_id, i|
      skill = $data_skills[skill_id]
      draw_item_name(skill, x, y + line_height * i, true, w)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_misc_page
  #--------------------------------------------------------------------------
  def draw_misc_page(item, x, y)
    lh = line_height
    draw_common_event_info(item, x, y)
    draw_common_event_name(item, x, y + lh)
    draw_animation_info(item, x, y + lh * 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_common_event_info
  #--------------------------------------------------------------------------
  def draw_common_event_info(item, x, y)
    draw_label_text(:common_event, x, y)
    rect = standard_rect(x, y)
    change_color(normal_color)
    text = item.common_event ? sprintf("%d", item.common_event) : "-"
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_common_event_name
  #--------------------------------------------------------------------------
  def draw_common_event_name(item, x, y)
    return unless item.common_event
    id = item.common_event
    rect = standard_rect(x, y)
    text = $data_common_events[id].name
    draw_text(rect, text)
  end
  
  #--------------------------------------------------------------------------
  # draw_animation_info
  #--------------------------------------------------------------------------
  def draw_animation_info(item, x, y)
    lh = line_height
    draw_label_text(:animation, x, y)
    draw_animation_id(item, x, y)
    draw_animation_name(item, x, y + lh)
  end
  
  #--------------------------------------------------------------------------
  # draw_animation_id
  #--------------------------------------------------------------------------
  def draw_animation_id(item, x, y)
    text = item.animation_id
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_animation_name
  #--------------------------------------------------------------------------
  def draw_animation_name(item, x, y)
    id = item.animation_id
    text = $data_animations[id] ? $data_animations[id].name : "None"
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text)
  end
  
  
  #--------------------------------------------------------------------------
  # draw_special_flag_page
  #--------------------------------------------------------------------------
  def draw_special_flag_page(item, x, y)
    draw_label_text(:special_flag, x, y)
    draw_special_flag_list(item, x, y + line_height)
  end
  
  #--------------------------------------------------------------------------
  # draw_special_flag_text
  #--------------------------------------------------------------------------
  def draw_special_flag_list(item, x, y)
    lh = line_height
    change_color(normal_color)
    item.get_feature_flags.each_with_index do |symbol, i|
      text = label_text(symbol)
      rect = standard_rect(x + 24, y + lh * i)
      draw_text(rect, text)
      draw_icon(special_flag_icon_id(symbol), x, y + lh * i)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_yes_equip_learn_page
  #--------------------------------------------------------------------------
  def draw_yes_equip_learn_page(item, x, y)
    draw_label_text(:yes_equip_learn, x, y)
    draw_yes_item_skills(item, x, y + line_height)
  end
  
  #--------------------------------------------------------------------------
  # draw_yes_item_skills
  #--------------------------------------------------------------------------
  def draw_yes_item_skills(item, x, y)
    lh = line_height
    vocab_ap = YES::EQUIPMENT_LEARNING::VOCAB
    vocab_size = text_size(vocab_ap).width
    item.el_skills.each_with_index do |skill_id, i|
      skill = $data_skills[skill_id]
      rect = standard_rect(x, y + lh * i)
      draw_item_name(skill, x, y + lh * i)
      change_color(system_color)
      draw_text(rect, vocab_ap, 2)
      change_color(normal_color)
      rect.width -= vocab_size
      draw_text(rect, skill.el_require, 2)
    end
  end
    
  #--------------------------------------------------------------------------
  # draw_icon_columns
  #--------------------------------------------------------------------------
  def draw_icon_columns(icons, x, y)
    icons.each_with_index do |n, i|
      icon_row_max = (contents.width - 4 - x) / icon_width
      y_plus = (i / icon_row_max) * line_height
      x_plus = (i % icon_row_max) * icon_width
      draw_icon(n, x + x_plus, y + y_plus)
    end
  end
  
  #--------------------------------------------------------------------------
  # get_add_state_icons
  #--------------------------------------------------------------------------
  def get_add_state_icons(item)
    icons = item.add_states.collect   { |id| $data_states[id].icon_index }
    icons += item.add_buffs.collect   { |param| buff_icon_index( 1, param) }
    icons += item.add_debuffs.collect { |param| buff_icon_index(-1, param) }
    icons.delete(0)
    icons
  end  
  
  #--------------------------------------------------------------------------
  # get_remove_state_icons
  #--------------------------------------------------------------------------
  def get_remove_state_icons(item)
    icons =  item.remove_states.collect  { |id| $data_states[id].icon_index }
    icons += item.remove_buffs.collect   { |param| buff_icon_index( 1, param) }
    icons += item.remove_debuffs.collect { |param| buff_icon_index(-1, param) }
    icons.delete(0)
    icons
  end
  
  #--------------------------------------------------------------------------
  # buff_icon_index           # Get Icon Number Corresponding to Buff/Debuff
  #--------------------------------------------------------------------------
  def buff_icon_index(buff_level, param_id)
    if buff_level > 0
      return ICON_BUFF_START + (buff_level - 1) * 8 + param_id
    elsif buff_level < 0
      return ICON_DEBUFF_START + (-buff_level - 1) * 8 + param_id 
    else
      return 0
    end
  end
    
  #--------------------------------------------------------------------------
  # draw_hp_recovery
  #--------------------------------------------------------------------------
  def draw_hp_recovery(item, x, y)
    value = item.hp_recovery
    draw_recovery_text(:hp_recovery, x, y, value)
  end
  
  #--------------------------------------------------------------------------
  # draw_mp_recovery
  #--------------------------------------------------------------------------
  def draw_mp_recovery(item, x, y)
    value = item.mp_recovery
    draw_recovery_text(:mp_recovery, x, y, value)
  end
  
  #--------------------------------------------------------------------------
  # draw_tp_recovery
  #--------------------------------------------------------------------------
  def draw_tp_recovery(item, x, y)
    # If you get an error on this line, it means you are using an old
    # version of "Reader Functions for Features/Effects". Get v1.2 or above.
    value = item.tp_recovery
    symbol = :tp_recovery
    draw_recovery_text(symbol, x, y, value)
  end
  
  #--------------------------------------------------------------------------
  # draw_recovery_text
  #--------------------------------------------------------------------------
  def draw_recovery_text(symbol, x, y, value)
    rect = standard_rect(x, y)
    draw_label_text(symbol, x, y)
    text = get_recovery_text(value)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # get_recovery_text
  #--------------------------------------------------------------------------
  def get_recovery_text(value, rate = 0)
    rate = rate * 100
    if value != 0 && rate != 0
      change_color(param_change_color(value))
      text = sprintf("%+d%%%+d", rate, value)
    elsif rate != 0
      change_color(param_change_color(rate))
      text = sprintf("%+d%%", rate)
    else
      change_color(param_change_color(value))
      text = sprintf("%+d", value)
    end
    return text
  end

  #--------------------------------------------------------------------------
  # draw_param_name
  #--------------------------------------------------------------------------
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    text = vocab_param(param_id)
    draw_text(x, y, contents.width - 4 - x, line_height, text)
  end
  
  #--------------------------------------------------------------------------
  # draw_xparam_name
  #--------------------------------------------------------------------------
  def draw_xparam_name(x, y, param_id)
    change_color(system_color)
    text = vocab_xparam(param_id)
    draw_text(x, y, contents.width - 4 - x, line_height, text)
  end
  
  #--------------------------------------------------------------------------
  # draw_sparam_name
  #--------------------------------------------------------------------------
  def draw_sparam_name(x, y, param_id)
    change_color(system_color)
    text = vocab_sparam(param_id)
    draw_text(x, y, contents.width - 4 - x, line_height, text)
  end
  
  #--------------------------------------------------------------------------
  # draw_param_value
  #--------------------------------------------------------------------------
  def draw_param_value(item, x, y, param_id)
    value = item.param(param_id)
    rate = item.param_rate(param_id)
    text = get_param_text(value, rate)
    draw_parameter_value(text, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_xparam_value
  #--------------------------------------------------------------------------
  def draw_xparam_value(item, x, y, param_id)
    value = item.xparam(param_id)
    text = get_xparam_text(value)
    draw_parameter_value(text, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_sparam_value
  #--------------------------------------------------------------------------
  def draw_sparam_value(item, x, y, param_id)
    value = item.sparam(param_id)
    text = get_sparam_text(value)
    draw_parameter_value(text, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_parameter_value
  #--------------------------------------------------------------------------
  def draw_parameter_value(text, x, y)
    rect = standard_rect(x, y)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # get_param_text
  #--------------------------------------------------------------------------
  def get_param_text(value, rate = 0)
    rate = (rate * 100).to_i - 100
    if value != 0 && rate != 0
      change_color(param_change_color(value))
      text = sprintf("%+d%%%+d", rate, value)
    elsif rate != 0
      change_color(param_change_color(rate))
      text = sprintf("%+d%%", rate)
    else
      change_color(param_change_color(value))
      text = sprintf("%+d", value)
    end
    return text
  end
  
  #--------------------------------------------------------------------------
  # get_xparam_text
  #--------------------------------------------------------------------------
  def get_xparam_text(value)
    value = (value * 100)
    change_color(param_change_color(value))
    text = sprintf("%+d%%", value)
    return text
  end

  #--------------------------------------------------------------------------
  # get_sparam_text
  #--------------------------------------------------------------------------
  def get_sparam_text(value)
    value = (value * 100).to_i - 100
    change_color(param_change_color(value))
    text = sprintf("%+d%%", value)
    return text
  end
  
  #--------------------------------------------------------------------------
  # draw_use_page
  #--------------------------------------------------------------------------
  def draw_use_page(item, x, y)
    lh = line_height
    draw_scope_info(item, x, y)
    draw_occasion_info(item, x, y + lh)
    draw_hit_type_info(item, x, y + lh * 2)
    draw_invocation_info(item, x, y + lh * 4)
  end
  
  #--------------------------------------------------------------------------
  # draw_scope_info
  #--------------------------------------------------------------------------
  def draw_scope_info(item, x, y)
    draw_label_text(:scope, x, y)
    draw_scope_text(item, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_scope_text
  #--------------------------------------------------------------------------
  def draw_scope_text(item, x, y)
    scope_id = item.scope
    text = scope_text(scope_id)
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_occasion_info
  #--------------------------------------------------------------------------
  def draw_occasion_info(item, x, y)
    draw_label_text(:occasion, x, y)
    draw_occasion_text(item, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_occasion_text
  #--------------------------------------------------------------------------
  def draw_occasion_text(item, x, y)
    case item.occasion
    when 0
      text = label_text(:always_use)
    when 1
      text = label_text(:battle_use)
    when 2
      text = label_text(:menu_use)
    when 3
      text = label_text(:never_use)
    end
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_hit_type_info
  #--------------------------------------------------------------------------
  def draw_hit_type_info(item, x, y)
    draw_label_text(:hit_type, x, y)
    draw_hit_type_text(item, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_hit_type_text
  #--------------------------------------------------------------------------
  def draw_hit_type_text(item, x, y)
    case item.hit_type
    when 0
      text = label_text(:certain_hit)
    when 1
      text = label_text(:physical_atk)
    when 2
      text = label_text(:magical_atk)
    end
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_invocation_info
  #--------------------------------------------------------------------------
  def draw_invocation_info(item, x, y)
    lh = line_height
    draw_success_info(item, x, y)
    draw_speed_info(item,   x, y + lh)
    draw_repeats_info(item, x, y + lh * 2)
    draw_tp_gain_info(item, x, y + lh * 3)
  end
  
  #--------------------------------------------------------------------------
  # draw_speed_info
  #--------------------------------------------------------------------------
  def draw_speed_info(item, x, y)
    draw_label_text(:speed, x, y)
    text = item.speed
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_success_info
  #--------------------------------------------------------------------------
  def draw_success_info(item, x, y)
    draw_label_text(:success_rate, x, y)
    text = sprintf("%d%%", item.success_rate) 
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_repeats_info
  #--------------------------------------------------------------------------
  def draw_repeats_info(item, x, y)
    draw_label_text(:repeats, x, y)
    text = item.repeats
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_tp_gain_info
  #--------------------------------------------------------------------------
  def draw_tp_gain_info(item, x, y)
    draw_label_text(:tp_gain, x, y)
    text = item.tp_gain
    rect = standard_rect(x, y)
    change_color(normal_color)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_added_skills_page
  #--------------------------------------------------------------------------
  def draw_added_skills_page(item, x, y)
    lh = line_height
    draw_label_text(:added_skills, x, y)
    draw_added_skills_info(item, x, y + lh)
  end
  
  #--------------------------------------------------------------------------
  # draw_added_skills_info
  #--------------------------------------------------------------------------
  def draw_added_skills_info(item, x, y)
    w = contents_width - icon_width
    item.added_skills.each_with_index do |skill_id, i|
      skill = $data_skills[skill_id]
      draw_item_name(skill, x, y + line_height * i, true, w)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_sealed_skills_page
  #--------------------------------------------------------------------------
  def draw_sealed_skills_page(item, x, y)
    lh = line_height
    draw_label_text(:sealed_skills, x, y)
    draw_sealed_skills_info(item, x, y + lh)
  end
  
  #--------------------------------------------------------------------------
  # draw_sealed_skills_info
  #--------------------------------------------------------------------------
  def draw_sealed_skills_info(item, x, y)
    w = contents_width - icon_width
    item.sealed_skills.each_with_index do |skill_id, i|
      skill = $data_skills[skill_id]
      draw_item_name(skill, x, y + line_height * i, true, w)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_added_skill_types_page
  #--------------------------------------------------------------------------
  def draw_added_skill_types_page(item, x, y)
    lh = line_height
    draw_label_text(:added_skill_types, x, y)
    draw_added_skill_types_info(item, x, y + lh)
  end
  
  #--------------------------------------------------------------------------
  # draw_added_skill_types_info
  #--------------------------------------------------------------------------
  def draw_added_skill_types_info(item, x, y)
    lh = line_height
    rect = standard_rect(x, y)
    change_color(normal_color)
    item.added_skill_types.each_with_index do |skill_type_id, i|
      text = $data_system.skill_types[skill_type_id]
      draw_text(rect, text)
      rect.y += lh
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_equip_wtypes_page
  #--------------------------------------------------------------------------
  def draw_equip_wtypes_page(item, x, y)
    lh = line_height
    draw_label_text(:equip_wtypes, x, y)
    draw_wtypes_info(item, x, y + lh)
  end

  #--------------------------------------------------------------------------
  # draw_wtypes_info
  #--------------------------------------------------------------------------
  def draw_wtypes_info(item, x, y)
    lh = line_height
    change_color(normal_color)
    item.equip_wtypes.each_with_index do |wtype_id, i|
      y_plus = lh * (i / col_max)
      x_plus = i % col_max * item_width
      rect = Rect.new(x + x_plus, y + y_plus, width, lh)
      text = $data_system.weapon_types[wtype_id]
      draw_text(rect, text)  
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_equip_atypes_page
  #--------------------------------------------------------------------------
  def draw_equip_atypes_page(item, x, y)
    lh = line_height
    draw_label_text(:equip_atypes, x, y)
    draw_atypes_info(item, x, y + lh)
  end
  
  #--------------------------------------------------------------------------
  # draw_atypes_info
  #--------------------------------------------------------------------------
  def draw_atypes_info(item, x, y)
    lh = line_height
    change_color(normal_color)
    width = contents.width / col_max - 4 - x
    item.equip_atypes.each_with_index do |atype_id, i|      
      y_plus = lh * (i / col_max)
      x_plus = i % col_max * item_width
      rect = Rect.new(x + x_plus, y + y_plus, width, lh)
      text = $data_system.armor_types[atype_id]
      draw_text(rect, text)  
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_equip_types_page
  #--------------------------------------------------------------------------
  def draw_equip_types_page(item, x, y)
    lh = line_height
    draw_label_text(:equip_wtypes, x, y)
    draw_wtypes_info(item, x, y + lh)
    draw_label_text(:equip_atypes, x, y + lh * 5)
    draw_atypes_info(item, x, y + lh * 6)
  end
  

  
  #--------------------------------------------------------------------------
  # draw_sealed_equips_info
  #--------------------------------------------------------------------------
  def draw_sealed_equips_info(item, x, y)
    lh = line_height
    rect = standard_rect(x, y)
    change_color(normal_color)
    item.sealed_equips.each_with_index do |etype_id, i|
      text = Vocab::etype(etype_id) #$$data_system.armor_types[atype_id]
      draw_text(rect, text)
      rect.y += lh
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_equip_slots_page
  #--------------------------------------------------------------------------
  def draw_equip_slots_page(item, x, y)
    lh = line_height
    draw_label_text(:fixed_equips, x, y)
    draw_sealed_equips_info(item, x, y + lh)
    draw_label_text(:sealed_equips, x, y + lh * 5)
    draw_sealed_equips_info(item, x, y + lh * 6)
  end
  
  #--------------------------------------------------------------------------
  # draw_sealed_equips_info
  #--------------------------------------------------------------------------
  def draw_sealed_equips_info(item, x, y)
    lh = line_height
    change_color(normal_color)
    width = contents.width / col_max - 4 - x
    item.fixed_equips.each_with_index do |etype_id, i|
      y_plus = lh * (i / col_max)
      x_plus = i % col_max * item_width
      rect = Rect.new(x + x_plus, y + y_plus, width, lh)
      text = Vocab::etype(etype_id)
      draw_text(rect, text)  
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_blocking_page
  #--------------------------------------------------------------------------
  def draw_bubs_blocking_page(item, x, y)
    lh = line_height
    draw_label_text(:blocking, x, y)
    draw_bubs_can_block_info(item, x, y)
    draw_label_text(:crit_blocking, x, y + lh)
    draw_bubs_can_crit_block_info(item, x, y + lh)
    draw_bubs_block_param_info(item, x, y + lh * 3)
    draw_label_text(:unblockable, x, y + lh * 8)
    draw_bubs_unblockable_info(item, x, y + lh * 8)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_can_block_info
  #--------------------------------------------------------------------------
  def draw_bubs_can_block_info(item, x, y)
    rect = standard_rect(x, y)
    change_color(normal_color)
    text = label_text(:blocking_no)
    text = label_text(:blocking_yes) if item.blocking
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_can_crit_block_info
  #--------------------------------------------------------------------------
  def draw_bubs_can_crit_block_info(item, x, y)
    rect = standard_rect(x, y)
    change_color(normal_color)
    text = label_text(:blocking_no)
    text = label_text(:blocking_yes) if item.critical_blocking
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_block_param_info
  #--------------------------------------------------------------------------
  def draw_bubs_block_param_info(item, x, y)
    lh = line_height
    draw_bubs_block_blc_info(item, x, y)
    draw_bubs_block_cbl_info(item, x, y + lh)
    draw_bubs_block_blr_info(item, x, y + lh * 2)
    draw_bubs_block_blv_info(item, x, y + lh * 3)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_block_blc
  #--------------------------------------------------------------------------
  def draw_bubs_block_blc_info(item, x, y)
    rect = standard_rect(x, y)
    change_color(system_color)
    text = use_full_param_names? ? Vocab::blc : Vocab::blc_a
    draw_text(rect, text)
    change_color(normal_color)
    text = sprintf("%+.1f%%", item.block_chance)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_block_cbl
  #--------------------------------------------------------------------------
  def draw_bubs_block_cbl_info(item, x, y)
    rect = standard_rect(x, y)
    change_color(system_color)
    text = use_full_param_names? ? Vocab::cbl : Vocab::cbl_a
    draw_text(rect, text)
    change_color(normal_color)
    text = sprintf("%+.1f%%", item.critical_block_chance)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_block_blr
  #--------------------------------------------------------------------------
  def draw_bubs_block_blr_info(item, x, y)
    rect = standard_rect(x, y)
    change_color(system_color)
    text = use_full_param_names? ? Vocab::blr : Vocab::blr_a
    draw_text(rect, text)
    change_color(normal_color)
    text = sprintf("%+.1f%%", item.block_reduction_rate)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_block_blv_info
  #--------------------------------------------------------------------------
  def draw_bubs_block_blv_info(item, x, y)
    rect = standard_rect(x, y)
    change_color(system_color)
    text = use_full_param_names? ? Vocab::blv : Vocab::blv_a
    draw_text(rect, text)
    change_color(normal_color)
    text = sprintf("%d", item.block_value)
    draw_text(rect, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_bubs_unblockable_info
  #--------------------------------------------------------------------------
  def draw_bubs_unblockable_info(item, x, y)
    rect = standard_rect(x, y)
    change_color(normal_color)
    text = label_text(:blocking_no)
    text = label_text(:blocking_yes) if item.unblockable
    draw_text(rect, text, 2)
  end
  
end # class Window_InfoPages
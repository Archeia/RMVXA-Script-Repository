#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Shoplifting
#  Author: Kread-EX
#  Version 1.02
#  Release date: 01/12/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 10/12/2012. Added class bonus and requirement. Couple bug fixes.
# # 02/12/2012. Added a variable to keep track of steal attempts.
#------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#------------------------------------------------------------------------------
# # You can steal from shops, making you a THIEF. You can customize the %
# # chance of being caught, and how much agility and luck influence
# # your chances.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # In the config module, set up the default % chance to succeed as well as
# # the ID of the switch being enabled if you happen to fail.
# # 
# # In the item/weapon/armor database tabs, you can use 3 notetags to
# # individualize the success chance:
# # <steal_chance: n%> # Base chance
# # <steal_agi: n%> # % of the leader's agi added to base chance
# # <steal_luk: n%> # % of the leader's luck added to base chance
# #
# # Class tab:
# # <steal_ok> # Class can steal
# # <steal_class: n%> # Class-based bonus.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # Works with the Ace Shop Options, Shop Clouts. Disabled for Synthesis Shop.
# # 
# # List of new classes:
# # 
# # Window_ShopSteal
# #
# # List of aliases and overwrites:
# # 
# # DataManager
# # load_database (alias)
# # load_shoplift_notetags (new method)
# # 
# # RPG::Item, RPG::EquipItem
# # load_shoplift_notetags (new method)
# # steal_chance (new attr method)
# # steal_agi (new attr method)
# # steal_luck (new attr method)
# # 
# # RPG::Class
# # load_shoplift_notetags (new method)
# # steal_ok (new attr method)
# # steal_class (new attr method)
# #
# # Window_ShopCommand
# # make_command_list (overwrite)
# # 
# # Scene_Shop
# # start (alias)
# # create_command_window (alias)
# # create_steal_window (new method)
# # activate_steal_window (new method)
# # command_steal (new method)
# # on_steal_ok (new method)
# # on_steal_cancel (new method)
# # do_steal (new method)
#------------------------------------------------------------------------------

$imported['KRX-Shoplifting'] = true if $imported != nil

puts 'Load: Shoplifting v1.02 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================

  BUSTED_SWITCH_ID = 2
  DEFAULT_STEAL_CHANCE = 100
  INFAMY_VARIABLE_ID = 4
  NEED_THIEF = true # Set this to false so everybody can steal
  
  module VOCAB
    SHOPLIFT_COMMAND = 'Steal'
  end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
  module REGEXP
    STEAL_CHANCE = /<steal_chance:[ ]*(\d+)%>/i
    STEAL_AGILITY = /<steal_agi:[ ]*(\d+)%>/i
    STEAL_LUCK = /<steal_luk:[ ]*(\d+)%>/i
    STEAL_OK = /<steal_ok>/i
    STEAL_CLASS = /<steal_class:[ ]*(\d+)%>/i
  end
  
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self; alias_method(:krx_shoplift_dm_ld, :load_database); end
	def self.load_database
		krx_shoplift_dm_ld
		load_shoplift_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_shoplift_notetags
		groups = [$data_items, $data_weapons, $data_armors, $data_classes]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_shoplift_notetags
			end
		end
		puts "Read: Shoplifting Notetags"
	end
end

#===========================================================================
# ■ RPG::Item, RPG::Weapon, RPG::Armor
#===========================================================================

module KRX
  module SHOPLIFT
    #--------------------------------------------------------------------------
    # ● Public instance variables
    #--------------------------------------------------------------------------
    attr_reader   :steal_chance
    attr_reader   :steal_agi
    attr_reader   :steal_luk
    #--------------------------------------------------------------------------
    # ● Loads the note tags
    #--------------------------------------------------------------------------
    def load_shoplift_notetags
      @note.split(/[\r\n]+/).each do |line|
        case line
        when KRX::REGEXP::STEAL_CHANCE
          @steal_chance = $1.to_i
        when KRX::REGEXP::STEAL_AGILITY
          @steal_agi = $1.to_i
        when KRX::REGEXP::STEAL_LUCK
          @steal_luk = $1.to_i
        end
      end
    end
  end
end

class RPG::Item < RPG::UsableItem; include KRX::SHOPLIFT; end
class RPG::EquipItem; include KRX::SHOPLIFT; end

class RPG::Class < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :steal_class
  attr_reader   :steal_ok
  #--------------------------------------------------------------------------
  # ● Loads the note tags
  #--------------------------------------------------------------------------
  def load_shoplift_notetags
    @note.split(/[\r\n]+/).each do |line|
      case line
      when KRX::REGEXP::STEAL_OK
        @steal_ok = true
      when KRX::REGEXP::STEAL_CLASS
        @steal_class = $1.to_i
      end
    end
  end
end

#==============================================================================
# ■ Window_ShopCommand
#==============================================================================

class Window_ShopCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● Create the list of commands
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopSell,   :sell,   !@purchase_only)
    # Make sure the scene isn't the synthesis shop
    if ($imported['KRX-SynthesisShop'] == false) ||
    !(SceneManager.scene.is_a?(Scene_SynthesisShop))
      add_command(KRX::VOCAB::SHOPLIFT_COMMAND, :steal, steal_ok?)
    end # End check
    add_command(Vocab::ShopCancel, :cancel)
  end
  #--------------------------------------------------------------------------
  # ● Determine if the class requirement is fullfilled
  #--------------------------------------------------------------------------
  def steal_ok?
    return true unless KRX::NEED_THIEF
    return $game_party.leader.class.steal_ok
  end
end

#==============================================================================
# ■ Window_ShopSteal
#==============================================================================

class Window_ShopSteal < Window_ShopBuy
  #--------------------------------------------------------------------------
  # ● Displays the item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    leader = $game_party.leader
    chance = item.steal_chance || KRX::DEFAULT_STEAL_CHANCE
    chance += (leader.agi * (item.steal_agi || 0) / 100.00)
    chance += (leader.luk * (item.steal_luk || 0) / 100.00)
    chance += (leader.class.steal_class || 0)
    chance = 100 if chance > 100
    chance = chance.round
    draw_text(rect, chance.to_s + '%', 2)
  end
  #--------------------------------------------------------------------------
  # ● Item is always enabled
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
end

#==============================================================================
# ■ Scene_Shop
#==============================================================================

class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● Start scene
  #--------------------------------------------------------------------------
  alias_method(:krx_shoplift_ss_start, :start)
  def start
    krx_shoplift_ss_start
    create_steal_window
  end
  #--------------------------------------------------------------------------
  # ● Create the command window
  #--------------------------------------------------------------------------
  alias_method(:krx_shoplift_ss_ccw, :create_command_window)
  def create_command_window
    krx_shoplift_ss_ccw
    @command_window.set_handler(:steal,  method(:command_steal))
  end
  #--------------------------------------------------------------------------
  # ● Create the steal window
  #--------------------------------------------------------------------------
  def create_steal_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @steal_window = Window_ShopSteal.new(0, wy, wh, @goods)
    @steal_window.viewport = @viewport
    @steal_window.help_window = @help_window
    @steal_window.status_window = @status_window
    @steal_window.hide
    @steal_window.set_handler(:ok,     method(:on_steal_ok))
    @steal_window.set_handler(:cancel, method(:on_steal_cancel))
  end
  #--------------------------------------------------------------------------
  # ● Show the steal window
  #--------------------------------------------------------------------------
  def command_steal
    @dummy_window.hide
    @buy_window.hide
    activate_steal_window
  end
  #--------------------------------------------------------------------------
  # ● Activate the steal window
  #--------------------------------------------------------------------------
  def activate_steal_window
    @steal_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● Validate steal command
  #--------------------------------------------------------------------------
  def on_steal_ok
    @item = @steal_window.item
    @steal_window.hide
    $game_variables[KRX::INFAMY_VARIABLE_ID] += 1
    leader = $game_party.leader
    chance = @item.steal_chance || KRX::DEFAULT_STEAL_CHANCE
    chance += (leader.agi * (@item.steal_agi || 0) / 100.00)
    chance += (leader.luk * (@item.steal_luk || 0) / 100.00)
    chance += (leader.class.steal_class || 0)
    if (rand(100) + 1) <= chance.round
      do_steal
    else
      $game_switches[KRX::BUSTED_SWITCH_ID] = true
      return_scene
    end
  end
  #--------------------------------------------------------------------------
  # ● Cancel steal command
  #--------------------------------------------------------------------------
  def on_steal_cancel
    @command_window.activate
    @dummy_window.show
    @steal_window.hide
    @status_window.hide
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● Steal the item
  #--------------------------------------------------------------------------
  def do_steal
    $game_party.gain_item(@item, 1)
    activate_steal_window
  end
end
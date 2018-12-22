#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Shop Clouts
#  Author: Kread-EX
#  Version 1.02
#  Release date: 07/01/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 02/03/2012. Compatibility fix with White Devil's Synthesis.
# # 13/02/2012. Fixed a bug allowing to buy even without the money.
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Allows the creation of shop clouts with independant client levels.
# # The shops will sell additional items as their associated client level goes
# # up.
# # Clout levels are gained by spending money at the shop.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # The clout membership is determined by the presence of a certain item in
# # the shop selection, called a token.
# # The token doesn't appear in the good list, he's just here to tag the shop.
# # Create a token by putting the following notetag in an item:
# # <shop_clout: string>
# # string is just an internal symbol, never displayed. However, the token name
# # will be the clout name and thus displayed.
# #
# # <clout_lv: x> will mark an item unvailable at the shop if the x clout level
# # is not attained.
# #
# # Go down the script config to find the EXP list for the clouts - the amount
# # of money that needs to be spent to gain levels. It is common to ALL clouts.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # The Synthesis Shop cannot be part of a clout. Works with YF's Ace Shop
# # Options.
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_sclout_notetags (new method)
# #
# # RPG::Item
# # load_sclout_notetags (new method)
# # clout_token (new attr method)
# # required_shop_lv (new attr method)
# #
# # RPG::EquipItem
# # required_shop_lv (new attr method)
# # load_sclout_notetags
# # 
# # Game_Party
# # shop_clouts (new attr method)
# # add_shop_clout (new method)
# #
# # Window_ShopBuy
# # enable? (alias)
# # draw_item (overwrite)
# # update_help (alias)
# # invalid_clout_lv? (new method)
# #
# # Window_ShopStatus
# # refresh (overwrite)
# #
# # Window_ShopData (only with Yanfly's Ace Shop Options)
# # pretty much every draw method is overwritten
# #
# # Window_ShopClout (new class)
# #
# # Scene_Shop
# # prepare (alias)
# # start (alias)
# # create_buy_window (overwrite)
# # create_clout_window (new method)
# # manage_clout_token (new method)
# # get_clout_info (new method)
# # do_buy (alias)

$imported = {} if $imported.nil?
$imported['KRX-ShopClouts'] = true

puts 'Load: Shop Clouts v1.02 by Kread-EX'

module KRX
  
  Shop_Levels_List = [
  
  500,
  3000,
  7000,
  12000,
  38000,
  80000,
  160000,
  300000,
  500000,
  1000000,
  2000000,
  5000000,
  
  ]
  
  module VOCAB
    SHOP_LEVEL = 'Lv.'
  end
  
  module REGEXP
    REQURED_SHOP_LV = /<clout_lv:[ ]*(\d+)>/i
    CLOUT_TOKEN = /<shop_clout:[ ]*(\w+)>/i
  end
  
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self
		alias_method(:krx_sclout_dm_load_database, :load_database)
	end
	def self.load_database
		krx_sclout_dm_load_database
		load_sclout_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_sclout_notetags
		groups = [$data_items, $data_weapons, $data_armors]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_sclout_notetags
			end
		end
		puts "Read: Shop Clouts Notetags"
	end
end

#==========================================================================
#  ■  RPG::Item
#==========================================================================

class RPG::Item < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :clout_token
  attr_reader     :required_shop_lv
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_sclout_notetags
    @required_shop_lv = 0
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::CLOUT_TOKEN
				@clout_token = $1.to_sym
			when KRX::REGEXP::REQURED_SHOP_LV
				@required_shop_lv = $1.to_i
			end
		end
	end
end

#==========================================================================
#  ■  RPG::EquipItem
#==========================================================================

class RPG::EquipItem < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :required_shop_lv
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_sclout_notetags
    @required_shop_lv = 0
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::REQURED_SHOP_LV
				@required_shop_lv = $1.to_i
			end
		end
	end
end

#===========================================================================
# ■ Game_Party
#===========================================================================

class Game_Party < Game_Unit
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :shop_clouts
	#--------------------------------------------------------------------------
	# ● Adds a new clout
	#--------------------------------------------------------------------------
  def add_shop_clout(sym)
    @shop_clouts = {} if @shop_clouts.nil?
    @shop_clouts[sym] = [1, 0] if @shop_clouts[sym].nil?
    @shop_clouts[sym]
  end
end

#===========================================================================
# ■ Window_ShopBuy
#===========================================================================

class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Determine if an item can be bought
  #--------------------------------------------------------------------------
  alias_method(:krx_sclout_wsb_enable?, :enable?)
  def enable?(item)
    return !invalid_clout_lv?(item) && krx_sclout_wsb_enable?(item)
  end
  #--------------------------------------------------------------------------
  # ● Displays the item to sale
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    return if item.nil?
    rect = item_rect(index)
    if invalid_clout_lv?(item)
      change_color(normal_color, false)
      draw_icon(item.icon_index, rect.x, rect.y, false)
      rect.x += 24
      draw_text(rect, '??????????')
      rect.x -= 24
    else
      if $imported["YEA-ShopOptions"]
        draw_item_name(item, rect.x, rect.y, enable?(item), rect.width-24)
      else
        draw_item_name(item, rect.x, rect.y, enable?(item))
      end
    end
    rect.width -= 4
    contents.font.size = YEA::LIMIT::SHOP_FONT if $imported["YEA-AdjustLimits"]
    if $imported["YEA-ShopOptions"]
      draw_text(rect, price(item).group, 2)
      reset_font_settings
    else
      draw_text(rect, price(item), 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● Determine if the clout level is too low for the transaction
  #--------------------------------------------------------------------------
  def invalid_clout_lv?(item)
    info = SceneManager.scene.get_clout_info
    return info[0] != nil && item.required_shop_lv > info[1]
  end
  #--------------------------------------------------------------------------
  # ● Updates the help windows
  #--------------------------------------------------------------------------
  alias_method(:krx_sclout_wsb_uh, :update_help)
  def update_help
    if !item.nil? && invalid_clout_lv?(item)
      @help_window.set_item(nil)
      return
    end
    krx_sclout_wsb_uh
  end
end

#===========================================================================
# ■ Window_ShopStatus
#===========================================================================

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● Refreshes the contents
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    # Compatibility with White Devil's Synthesis.
    unless defined?(Scene_ItemSynthesis) &&
      SceneManager.scene.is_a?(Scene_ItemSynthesis)
      info = SceneManager.scene.get_clout_info
      if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
        return
      end
    end # End of Compatibility with White Devil's Synthesis.
    draw_possession(4, 0)
    draw_equip_info(4, line_height * 2) if @item.is_a?(RPG::EquipItem)
  end
end

#==============================================================================
# ■ Window_ShopClout
#==============================================================================

class Window_ShopClout < Window_Base
  #--------------------------------------------------------------------------
  # ● Object Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, w, h)
    super
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Refreshes the contents
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    info = SceneManager.scene.get_clout_info
    return if info[0].nil?
    contents.draw_text(4, 0, 220, line_height, info[0])
    change_color(system_color)
    contents.draw_text(220, 0, 120, line_height, KRX::VOCAB::SHOP_LEVEL)
    change_color(normal_color)
    contents.draw_text(4, 0, width - 40, line_height, info[1], 2)
  end
end

## Yanfly's Ace Shop Options compatibility

if $imported["YEA-ShopOptions"]
  
#==============================================================================
# ■ Window_ShopData
#==============================================================================

class Window_ShopData < Window_Base
  #--------------------------------------------------------------------------
  # ● Displays the parameters
  #--------------------------------------------------------------------------
  def draw_equip_param(param_id, dx, dy, dw)
    draw_background_box(dx, dy, dw)
    change_color(system_color)   
    draw_text(dx+4, dy, dw-8, line_height, Vocab::param(param_id))
    info = SceneManager.scene.get_clout_info
    if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
      text = '???'
    else
      value = @item.params[param_id]
      change_color(param_change_color(value), value != 0)
      text = @item.params[param_id].group
      text = "+" + text if @item.params[param_id] > 0
    end
    draw_text(dx+4, dy, dw-8, line_height, text, 2)
  end
  #--------------------------------------------------------------------------
  # ● Displays the HP recovery value of usable items
  #--------------------------------------------------------------------------
  def draw_hp_recover(dx, dy, dw)
    draw_background_box(dx, dy, dw)
    change_color(system_color)
    draw_text(dx+4, dy, dw-8, line_height, Vocab::item_status(:hp_recover))
    info = SceneManager.scene.get_clout_info
    if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
      draw_text(dx+4, dy, dw-8, line_height, '???', 2)
      return
    end
    per = 0
    set = 0
    for effect in @item.effects
      next unless effect.code == 11
      per += (effect.value1 * 100).to_i
      set += effect.value2.to_i
    end
    if per != 0 && set != 0
      change_color(param_change_color(set))
      text = set > 0 ? sprintf("+%s", set.group) : set.group
      draw_text(dx+4, dy, dw-8, line_height, text, 2)
      dw -= text_size(text).width
      change_color(param_change_color(per))
      text = per > 0 ? sprintf("+%s%%", per.group) : sprintf("%s%%", per.group)
      draw_text(dx+4, dy, dw-8, line_height, text, 2)
      return
    elsif per != 0
      change_color(param_change_color(per))
      text = per > 0 ? sprintf("+%s%%", per.group) : sprintf("%s%%", per.group)
    elsif set != 0
      change_color(param_change_color(set))
      text = set > 0 ? sprintf("+%s", set.group) : set.group
    else
      change_color(normal_color, false)
      text = Vocab::item_status(:empty)
    end
    draw_text(dx+4, dy, dw-8, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_mp_recover
  #--------------------------------------------------------------------------
  def draw_mp_recover(dx, dy, dw)
    draw_background_box(dx, dy, dw)
    change_color(system_color)
    draw_text(dx+4, dy, dw-8, line_height, Vocab::item_status(:mp_recover))
    info = SceneManager.scene.get_clout_info
    if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
      draw_text(dx+4, dy, dw-8, line_height, '???', 2)
      return
    end
    per = 0
    set = 0
    for effect in @item.effects
      next unless effect.code == 12
      per += (effect.value1 * 100).to_i
      set += effect.value2.to_i
    end
    if per != 0 && set != 0
      change_color(param_change_color(set))
      text = set > 0 ? sprintf("+%s", set.group) : set.group
      draw_text(dx+4, dy, dw-8, line_height, text, 2)
      dw -= text_size(text).width
      change_color(param_change_color(per))
      text = per > 0 ? sprintf("+%s%%", per.group) : sprintf("%s%%", per.group)
      draw_text(dx+4, dy, dw-8, line_height, text, 2)
      return
    elsif per != 0
      change_color(param_change_color(per))
      text = per > 0 ? sprintf("+%s%%", per.group) : sprintf("%s%%", per.group)
    elsif set != 0
      change_color(param_change_color(set))
      text = set > 0 ? sprintf("+%s", set.group) : set.group
    else
      change_color(normal_color, false)
      text = Vocab::item_status(:empty)
    end
    draw_text(dx+4, dy, dw-8, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_tp_recover
  #--------------------------------------------------------------------------
  def draw_tp_recover(dx, dy, dw)
    draw_background_box(dx, dy, dw)
    change_color(system_color)
    draw_text(dx+4, dy, dw-8, line_height, Vocab::item_status(:tp_recover))
    info = SceneManager.scene.get_clout_info
    if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
      draw_text(dx+4, dy, dw-8, line_height, '???', 2)
      return
    end
    set = 0
    for effect in @item.effects
      next unless effect.code == 13
      set += effect.value1.to_i
    end
    if set != 0
      change_color(param_change_color(set))
      text = set > 0 ? sprintf("+%s", set.group) : set.group
    else
      change_color(normal_color, false)
      text = Vocab::item_status(:empty)
    end
    draw_text(dx+4, dy, dw-8, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_tp_gain
  #--------------------------------------------------------------------------
  def draw_tp_gain(dx, dy, dw)
    draw_background_box(dx, dy, dw)
    change_color(system_color)
    draw_text(dx+4, dy, dw-8, line_height, Vocab::item_status(:tp_gain))
    info = SceneManager.scene.get_clout_info
    if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
      draw_text(dx+4, dy, dw-8, line_height, '???', 2)
      return
    end
    set = @item.tp_gain
    if set != 0
      change_color(param_change_color(set))
      text = set > 0 ? sprintf("+%s", set.group) : set.group
    else
      change_color(normal_color, false)
      text = Vocab::item_status(:empty)
    end
    draw_text(dx+4, dy, dw-8, line_height, text, 2)
  end
  
  #--------------------------------------------------------------------------
  # draw_applies
  #--------------------------------------------------------------------------
  def draw_applies(dx, dy, dw)
    draw_background_box(dx, dy, dw)
    change_color(system_color)
    draw_text(dx+4, dy, dw-8, line_height, Vocab::item_status(:applies))
    info = SceneManager.scene.get_clout_info
    if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
      return
    end
    icons = []
    for effect in @item.effects
      case effect.code
      when 21
        next unless effect.value1 > 0
        next if $data_states[effect.value1].nil?
        icons.push($data_states[effect.data_id].icon_index)
      when 31
        icons.push($game_actors[1].buff_icon_index(1, effect.data_id))
      when 32
        icons.push($game_actors[1].buff_icon_index(-1, effect.data_id))
      end
      icons.delete(0)
      break if icons.size >= YEA::SHOP::MAX_ICONS_DRAWN
    end
    draw_icons(dx, dy, dw, icons)
  end
  
  #--------------------------------------------------------------------------
  # draw_removes
  #--------------------------------------------------------------------------
  def draw_removes(dx, dy, dw)
    draw_background_box(dx, dy, dw)
    change_color(system_color)
    draw_text(dx+4, dy, dw-8, line_height, Vocab::item_status(:removes))
    info = SceneManager.scene.get_clout_info
    if @item != nil && info[0] != nil && @item.required_shop_lv > info[1]
      return
    end
    icons = []
    for effect in @item.effects
      case effect.code
      when 22
        next unless effect.value1 > 0
        next if $data_states[effect.value1].nil?
        icons.push($data_states[effect.data_id].icon_index)
      when 33
        icons.push($game_actors[1].buff_icon_index(1, effect.data_id))
      when 34
        icons.push($game_actors[1].buff_icon_index(-1, effect.data_id))
      end
      icons.delete(0)
      break if icons.size >= YEA::SHOP::MAX_ICONS_DRAWN
    end
    draw_icons(dx, dy, dw, icons)
  end
end

end ## End of Yanfly's Ace Shop Options compatibility

#===========================================================================
# ■ Scene_Shop
#===========================================================================

class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● Setups the list of goods
  #--------------------------------------------------------------------------
  alias_method(:krx_sclout_ss_prep, :prepare)
  def prepare(goods, purchase_only)
    krx_sclout_ss_prep(goods, purchase_only)
    manage_clout_token
  end
  #--------------------------------------------------------------------------
  # ● Starts the scene
  #--------------------------------------------------------------------------
  alias_method(:krx_sclout_ss_start, :start)
  def start
    krx_sclout_ss_start
    create_clout_window
  end
  #--------------------------------------------------------------------------
  # ● Creates the window displaying the goods to buy
  #--------------------------------------------------------------------------
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height - 52
    @buy_window = Window_ShopBuy.new(0, wy, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  #--------------------------------------------------------------------------
  # ● Creates the window displaying the clout name and level
  #--------------------------------------------------------------------------
  def create_clout_window
    wy = @buy_window.y + @buy_window.height
    ww = @buy_window.width
    @clout_window = Window_ShopClout.new(0, wy, ww, 52)
  end
  #--------------------------------------------------------------------------
  # ● Determines if the shop belongs to a clout
  #--------------------------------------------------------------------------
  def manage_clout_token
    token = nil
    @goods.each do |good|
      if good[0] == 0 && $data_items[good[1]].clout_token
        item = $data_items[good[1]]
        @shop_clout = item.name
        @sym = item.clout_token.to_sym
        @shop_lv = $game_party.add_shop_clout(@sym)[0]
        token = good
        break
      end
    end
    @goods.delete(token)
    @goods.compact!
  end
  #--------------------------------------------------------------------------
  # ● Returns the clout name and level
  #--------------------------------------------------------------------------
  def get_clout_info
    [@shop_clout, @shop_lv]
  end
  #--------------------------------------------------------------------------
  # ● Proceeds with the shopping
  #--------------------------------------------------------------------------
  alias_method(:krx_sclout_ss_buy, :do_buy)
  def do_buy(number)
    krx_sclout_ss_buy(number)
    gold_spent = number * buying_price
    clout = $game_party.shop_clouts[@sym]
    clout[1] += gold_spent
    if (@shop_lv - 1) < KRX::Shop_Levels_List.size &&
    clout[1] >= KRX::Shop_Levels_List[@shop_lv-1]
      clout[0] += 1
      @shop_lv += 1
      @clout_window.refresh
    end
  end
end
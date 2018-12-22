#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Synthesis Shop
#  Author: Kread-EX
#  Version 1.07
#  Release date: 12/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 25/03/2012. Bugfixes and compat with the version 2 of Alchemic Synthesis.
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Add-on for the Alchemic Synthesis script, it enables the use of the Synthesis
# # Shop, a special shop which sells synthesized items.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Put the script blow the Alchemic Synthesis one.
# # Then, within the notebox of your synthesizable item, put a new tag:
# # <synth_shop: x>
# # X represents the number of copies available in the shop.
# #
# # To call the shop, use a Script event command:
# # SceneManager.call(Scene_SynthesisShop)
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # New classes: Scene_SynthesisShop Window_SynthShopBuy,
# # Window_SynthShopStatus, Window_SynthShopNumber
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_synthshop_notetags (new method)
# #
# # RPG::Item, RPG::EquipItem
# # synthesis_shop_nb (new attr method)
# # load_synthshop_notetags (new method)
# #
# # Game_Party
# # synthesis_stock (new attr method)
# # initialize (alias)
#-------------------------------------------------------------------------------------------------

# Quits if the synthesis system isn't found

if $imported.nil? || $imported['KRX-AlchemicSynthesis'].nil?
	
msgbox('You need the Alchemic Synthesis script in order to use the Synthesis
Shop. Loading aborted.')

else
	
$imported['KRX-SynthesisShop'] = true

puts 'Load: Synthesis Shop v1.07 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================
	module VOCAB
		SYNTHESIS_SHOP_STOCK = 'Shop Stock:'
	end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
	module REGEXP
		SYNTHESIS_SHOP = /<synth_shop:[ ]*(\d+)>/i
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
		alias_method(:krx_synthshop_dm_load_database, :load_database)
	end
	def self.load_database
		krx_synthshop_dm_load_database
		load_synthshop_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_synthshop_notetags
		groups = [$data_items, $data_weapons, $data_armors]
		classes = [RPG::Item, RPG::Weapon, RPG::Armor]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_synthshop_notetags if classes.include?(obj.class)
			end
		end
		puts "Read: Synthesis Shop Notetags"
	end
end

#==========================================================================
# ■ RPG::Item
#==========================================================================

class RPG::Item < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:synthesis_shop_nb
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_synthshop_notetags
		@synthesis_shop_nb = 0
		@note.split(/[\r\n]+/).each do |line|
			case line
			when  KRX::REGEXP::SYNTHESIS_SHOP
				@synthesis_shop_nb = $1.to_i
			end
		end
	end
end

#==========================================================================
# ■ RPG::EquipItem
#==========================================================================

class RPG::EquipItem < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:synthesis_shop_nb
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_synthshop_notetags
		@synthesis_shop_nb = 0
		@note.split(/[\r\n]+/).each do |line|
			case line
			when  KRX::REGEXP::SYNTHESIS_SHOP
				@synthesis_shop_nb = $1.to_i
			end
		end
	end
end

#==========================================================================
# ■ Game_Party
#==========================================================================

class Game_Party < Game_Unit
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_accessor	:synthesis_stock
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	alias_method(:krx_synthshop_gp_initialize, :initialize)
	def initialize
		krx_synthshop_gp_initialize
		@synthesis_stock = {}
	end
end

#==========================================================================
# ■ Window_SynthShopStatus
#==========================================================================

class Window_SynthShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● Object Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @page_index = 0
    refresh
  end
	#--------------------------------------------------------------------------
	# ● Refreshes the contents
	#--------------------------------------------------------------------------
	def refresh
		contents.clear
		draw_possession(4, 0)
		draw_vendor_stock(4, line_height)
		draw_item_traits
	end
  #--------------------------------------------------------------------------
  # ● Sets an item
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Displays the number of items currently possessed
  #--------------------------------------------------------------------------
  def draw_possession(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Vocab::Possession)
    change_color(normal_color)
    draw_text(rect, $game_party.item_number(@item), 2)
  end
	#--------------------------------------------------------------------------
	# ● Displays the number of items in stock for the vendor
	#--------------------------------------------------------------------------
	def draw_vendor_stock(x, y)
		rect = Rect.new(x, y, contents.width - 4 - x, line_height)
		change_color(system_color)
		draw_text(rect, KRX::VOCAB::SYNTHESIS_SHOP_STOCK)
		change_color(normal_color)
    return if @item.nil?
		draw_text(rect, $game_party.synthesis_stock[[@item.class, @item.id]].to_s, 2)
	end
	#--------------------------------------------------------------------------
	# ● Displays the item traits
	#--------------------------------------------------------------------------
	def draw_item_traits
		return if @item.nil?
    max = KRX::SYNTH_MAX_TRAITS
		draw_horz_line(line_height * 2)
		change_color(system_color)
		contents.draw_text(4, line_height * 3, width, line_height, KRX::VOCAB::TRAITS)
		change_color(normal_color)
		(1..max).each {|i| contents.draw_text(4, line_height * (i + 3), width,
    line_height, "#{i}.")}
    
    # Standard script
    if !$imported['KRX-AdvTraitManager']
		@item.traits.each_index do |i|
      break if i == max
      name = KRX::TraitsNamer.trait_name(@item.traits[i])
			contents.draw_text(28, line_height * (i+4), width - 24, line_height, name)
		end
    # Adv. trait manager
    else
    container = $game_party.synthesis_traits[[@item.class, @item.id]]
		container.each_index do |i|
      break if i == max
      name = container[i]
			contents.draw_text(28, line_height * (i+4), width - 24, line_height, name)
		end
    end
	end
	#--------------------------------------------------------------------------
	# ● Displays an horizontal line
	#--------------------------------------------------------------------------
	def draw_horz_line(y)
		line_y = y + line_height / 2 - 1
		contents.fill_rect(0, line_y, contents_width, 2, line_color)
	end
	#--------------------------------------------------------------------------
	# ● Returns the color used for horizontal lines
	#--------------------------------------------------------------------------
	def line_color
		color = normal_color
		color.alpha = 48
		return color
	end
end

#==========================================================================
# ■ Window_SynthShopBuy
#==========================================================================

class Window_SynthShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :status_window
  #--------------------------------------------------------------------------
  # ● Object Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height, shop_goods)
    super(x, y, window_width, height)
    @shop_goods = shop_goods
    @money = 0
    refresh
    select(0)
  end
  #--------------------------------------------------------------------------
  # ● Returns the window width
  #--------------------------------------------------------------------------
  def window_width
    return 304
  end
  #--------------------------------------------------------------------------
  # ● Returns the maximum number of items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● Returns the current item
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end
  #--------------------------------------------------------------------------
  # ● Refreshes the money display
  #--------------------------------------------------------------------------
  def money=(money)
    @money = money
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Refreshes the contents
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
	#--------------------------------------------------------------------------
	# ● Creates the list of items
	#--------------------------------------------------------------------------
	def make_item_list
		@data = []
		@price = {}
		@quantity = {}
		@shop_goods.each do |item|
			next if item.nil?
			@quantity[item] = $game_party.synthesis_stock[[item.class, item.id]]
			next if @quantity[item].nil? || @quantity[item] == 0
			@data.push(item)
			@price[item] = item.price
		end
	end
  #--------------------------------------------------------------------------
  # ● Displays the item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    draw_text(rect, price(item), 2)
  end
  #--------------------------------------------------------------------------
  # ● Determine if the current item is valid
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ● Returns the price of the item
  #--------------------------------------------------------------------------
  def price(item)
    @price[item]
  end
  #--------------------------------------------------------------------------
  # ● Assigns a status window
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● Updates the help windows
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @status_window.item = item if @status_window
  end
	#--------------------------------------------------------------------------
	# ● Determines if an item can be bought
	#--------------------------------------------------------------------------
	def enable?(item)
		item && price(item) <= @money && !$game_party.item_max?(item) &&
		$game_party.synthesis_stock[[item.class, item.id]] > 0
	end
end

#==========================================================================
# ■ Scene_SynthesisShop
#==========================================================================

class Scene_SynthesisShop < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize
		super
    @goods = []
    data = $game_party.synthesis_stock
		data.each_key do |arr|
      if arr[0] == RPG::Item
        container = $data_items
      elsif arr[0] == RPG::Weapon
        container = $data_weapons
      elsif arr[0] == RPG::Armor
        container = $data_armors
      end
      @goods.push(container[arr[1]])
    end
		@purchase_only = true
	end
  #--------------------------------------------------------------------------
  # ● Starts scene
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_gold_window
    create_command_window
    create_dummy_window
    create_number_window
    create_status_window
    create_buy_window
    create_category_window
  end
  #--------------------------------------------------------------------------
  # ● Constructs the gold window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● Constructs the command window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_ShopCommand.new(@gold_window.x, @purchase_only)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● Constructs a blank window
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● Constructs the window displaying the quantity to buy
  #--------------------------------------------------------------------------
  def create_number_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @number_window = Window_SynthShopNumber.new(0, wy, wh)
    @number_window.viewport = @viewport
    @number_window.hide
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
	#--------------------------------------------------------------------------
	# ● Constructs the window showing the actors' status
	#--------------------------------------------------------------------------
	def create_status_window
		wx = @number_window.width
		wy = @dummy_window.y
		ww = Graphics.width - wx
		wh = @dummy_window.height
		@status_window = Window_SynthShopStatus.new(wx, wy, ww, wh)
		@status_window.viewport = @viewport
		@status_window.hide
	end
	#--------------------------------------------------------------------------
	# ● Constructs the window showing the goods in sale
	#--------------------------------------------------------------------------
	def create_buy_window
		wy = @dummy_window.y
		wh = @dummy_window.height
		@buy_window = Window_SynthShopBuy.new(0, wy, wh, @goods)
		@buy_window.viewport = @viewport
		@buy_window.help_window = @help_window
		@buy_window.status_window = @status_window
		@buy_window.hide
		@buy_window.set_handler(:ok,     method(:on_buy_ok))
		@buy_window.set_handler(:cancel, method(:on_buy_cancel))
	end
  #--------------------------------------------------------------------------
  # ● Constructs the category window
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @dummy_window.y
    @category_window.hide.deactivate
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
  end
  #--------------------------------------------------------------------------
  # ● Enables item selection for the buy window
  #--------------------------------------------------------------------------
  def activate_buy_window
    @buy_window.money = money
    @buy_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ● Enables the buy confirmation
  #--------------------------------------------------------------------------
  def command_buy
    @dummy_window.hide
    activate_buy_window
  end
	#--------------------------------------------------------------------------
	# ● Confirms the item selection
	#--------------------------------------------------------------------------
	def on_buy_ok
		@item = @buy_window.item
		@buy_window.hide
		@number_window.set(@item, $game_party.synthesis_stock[[@item.class, @item.id]],
    buying_price, currency_unit)
		@number_window.show.activate
	end
  #--------------------------------------------------------------------------
  # ● Cancels transaction
  #--------------------------------------------------------------------------
  def on_buy_cancel
    @command_window.activate
    @dummy_window.show
    @buy_window.hide
    @status_window.hide
    @status_window.item = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # ● Confirms category selection
  #--------------------------------------------------------------------------
  def on_category_ok
    activate_sell_window
    @sell_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● Cancels category selection
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    @dummy_window.show
    @category_window.hide
    @sell_window.hide
  end
  #--------------------------------------------------------------------------
  # ● Confirms quantity selection
  #--------------------------------------------------------------------------
  def on_number_ok
    Sound.play_shop
    do_buy(@number_window.number)
    end_number_input
    @gold_window.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● Cancels quantity selection
  #--------------------------------------------------------------------------
  def on_number_cancel
    Sound.play_cancel
    end_number_input
  end
	#--------------------------------------------------------------------------
	# ● Performs the deal
	#--------------------------------------------------------------------------
	def do_buy(number)
    $game_party.lose_gold(number * buying_price)
    $game_party.gain_item(@item, number)
		$game_party.synthesis_stock[[@item.class, @item.id]] -= number
	end
  #--------------------------------------------------------------------------
  # ● Terminates the number selection
  #--------------------------------------------------------------------------
  def end_number_input
    @number_window.hide
    activate_buy_window
  end
  #--------------------------------------------------------------------------
  # ● Determine the maximum number that can be bought
  #--------------------------------------------------------------------------
  def max_buy
    max = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    buying_price == 0 ? max : [max, money / buying_price].min
  end
  #--------------------------------------------------------------------------
  # ● Returns the money held
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
  #--------------------------------------------------------------------------
  # ● Returns the currency name
  #--------------------------------------------------------------------------
  def currency_unit
    @gold_window.currency_unit
  end
  #--------------------------------------------------------------------------
  # ● Returns the price of an item
  #--------------------------------------------------------------------------
  def buying_price
    @buy_window.price(@item)
  end
end

#==========================================================================
# ■ Scene_Alchemy
#==========================================================================

class Scene_Alchemy < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Synthesis outcome
	#--------------------------------------------------------------------------
	alias_method(:krx_synthshop_outcome, :process_outcome)
	def process_outcome(failure = false)
		krx_synthshop_outcome(failure)
		unless failure
			itm = $game_party.last_item.object
			$game_party.synthesis_stock[[itm.class, itm.id]] = itm.synthesis_shop_nb
		end
	end
end

#==========================================================================
# ■ Window_SynthShopNumber
#--------------------------------------------------------------------------
# It's basically a clone of the default Window_ShopNumber
#==========================================================================

class Window_SynthShopNumber < Window_Selectable
  #--------------------------------------------------------------------------
  attr_reader   :number
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
    @currency_unit = Vocab::currency_unit
  end
  #--------------------------------------------------------------------------
  def window_width
    return 304
  end
  #--------------------------------------------------------------------------
  def set(item, max, price, currency_unit = nil)
    @item = item
    @max = max
    @price = price
    @currency_unit = currency_unit if currency_unit
    @number = 1
    refresh
  end
  #--------------------------------------------------------------------------
  def currency_unit=(currency_unit)
    @currency_unit = currency_unit
    refresh
  end
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_item_name(@item, 0, item_y)
    draw_number
    draw_total_price
  end
  #--------------------------------------------------------------------------
  def draw_number
    change_color(normal_color)
    draw_text(cursor_x - 28, item_y, 22, line_height, "×")
    draw_text(cursor_x, item_y, cursor_width - 4, line_height, @number, 2)
  end
  #--------------------------------------------------------------------------
  def draw_total_price
    width = contents_width - 8
    draw_currency_value(@price * @number, @currency_unit, 4, price_y, width)
  end
  #--------------------------------------------------------------------------
  def item_y
    contents_height / 2 - line_height * 3 / 2
  end
  #--------------------------------------------------------------------------
  def price_y
    contents_height / 2 + line_height / 2
  end
  #--------------------------------------------------------------------------
  def cursor_width
    figures * 10 + 12
  end
  #--------------------------------------------------------------------------
  def cursor_x
    contents_width - cursor_width - 4
  end
  #--------------------------------------------------------------------------
  def figures
    return 2
  end
  #--------------------------------------------------------------------------
  def update
    super
    if active
      last_number = @number
      update_number
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  def update_number
    change_number(1)   if Input.repeat?(:RIGHT)
    change_number(-1)  if Input.repeat?(:LEFT)
    change_number(10)  if Input.repeat?(:UP)
    change_number(-10) if Input.repeat?(:DOWN)
  end
  #--------------------------------------------------------------------------
  def change_number(amount)
    @number = [[@number + amount, @max].min, 1].max
  end
  #--------------------------------------------------------------------------
  def update_cursor
    cursor_rect.set(cursor_x, item_y, cursor_width, line_height)
  end
end

end # Parent script check
#===========================================================================
#    Author:   Calestian
#    Name:     Multiple Currencies
#    Created:  02-08-2015
#    Version:  1.1
#---------------------------------------------------------------------------
#                       VERSION HISTORY
#
#    v1.0 - Initial Release
#    v1.1 - Bug fix: gain_gold and lose_gold argument fix
#---------------------------------------------------------------------------
#                       DESCRIPTION
#    
#    User can set more than one different currencies.
#
#    There is a new Menu tab displaying all set currencies.
#
#    Shops can use only one currency.
#
#    Note: It is possible to set different shops to use different currencies.
#---------------------------------------------------------------------------
#                       LICENSE INFO
#
#    Free for commercial & non-commerical use as long as credit is given to
#    Calestian.
#---------------------------------------------------------------------------
#                       How to Use
#
#    - Change Currencies in the module below to enter the icons and
#      the starting value of each currency.
#
#    - To apply a currency to a shop, in the event window, before
#      Shop Processing, add a scripted command (Advanced Tab):
#      currency(Currency_ID)
#      Currency_ID is taken from the module.
#    
#      Note: If a currency isn't set in the event window, the default
#            currency is Currency_ID = 0
#
#    - To apply a currency gain or lose, in the event window, add
#      a scripted command (Advanced Tab):
#      add_currency(amount, Currency_ID) to apply a currency gain
#      add_currency(-amount, Currency_ID) to apply a currency loss
#  
#      Example: In the event window, after a Battle Processing event
#               add the scripted command: $game_party.gain_gold(100, 2)
#               This will give the player 100 of Currency #2 after the
#               Battle Processing event is finished.
#===========================================================================
 
#===========================================================================
# *** Editable Region
#===========================================================================
module Clstn_Currencies
 
  Currencies = {
     
    0  => [361, 0],
    1  => [362, 0],
    2  => [363, 0],
    3  => [364, 0],
    4  => [365, 0],
    5  => [366, 0],
    6  => [367, 0],
    7  => [368, 0],
    8  => [369, 0],
    9  => [370, 0],
    10 => [371, 0]
 
  }
 
end
 
#===========================================================================
# *** End of Editable Region
#===========================================================================
   
#===========================================================================
# *** Class Window_MenuCommand
#===========================================================================
class Window_MenuCommand < Window_Command
 
  #-------------------------------------------------------------------------
  # * Aliased Methods
  #-------------------------------------------------------------------------
  alias :clstn_add_main_commands_0003 add_main_commands
 
  #-------------------------------------------------------------------------
  # * Method: add_main_commands
  #-------------------------------------------------------------------------
  def add_main_commands
    clstn_add_main_commands_0003
    add_command("Currencies",  :currencies,   main_commands_enabled)
  end
 
end
 
#===========================================================================
# ** Class Scene_Menu
#===========================================================================
class Scene_Menu < Scene_MenuBase
 
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
    create_status_window
  end
 
  #-------------------------------------------------------------------------
  # * Aliased Methods
  #-------------------------------------------------------------------------
  alias :clstn_create_command_window_0004 :create_command_window
  alias :clstn_on_personal_ok_0008 :on_personal_ok
 
  #-------------------------------------------------------------------------
  # * Method: create_command_window
  #-------------------------------------------------------------------------
  def create_command_window
    clstn_create_command_window_0004
    @command_window.set_handler(:currencies, method(:command_currencies))
  end
 
   #-------------------------------------------------------------------------
   # * Method: on_personal_ok
   #-------------------------------------------------------------------------
   def on_personal_ok
    case @command_window.current_symbol
    when :currencies
      SceneManager.call(Scene_Currencies)
    end
    clstn_on_personal_ok_0008
   end
 
   #-------------------------------------------------------------------------
   # * Method: command_currencies
   #-------------------------------------------------------------------------
   def command_currencies
      SceneManager.call(Scene_Currencies)
   end
 
end
 
#===========================================================================
# ** Class Scene_Currencies
#===========================================================================
class Scene_Currencies < Scene_MenuBase
 
  #-------------------------------------------------------------------------
  # * Start
  #-------------------------------------------------------------------------
  def start
    super
    create_currencies_window
  end
 
  #-------------------------------------------------------------------------
  # * Method: create_currencies_window
  #-------------------------------------------------------------------------
  def create_currencies_window
    @currencies_window = Window_Currencies.new
    @currencies_window.viewport = @viewport
    @currencies_window.set_handler(:cancel, method(:return_scene))
    @currencies_window.activate
  end
 
end
 
#===========================================================================
# ** Class Window_Currencies
#===========================================================================
class Window_Currencies < Window_Selectable
 
  #-------------------------------------------------------------------------
  # * Initialize
  #-------------------------------------------------------------------------
  def initialize
    super(395, 0, 149, 416)
    refresh
  end
 
  #-------------------------------------------------------------------------
  # * Method: value
  #-------------------------------------------------------------------------
  def value(currency_index = $game_temp.currency_index)
    if currency_index == 0
      $game_party.gold
    else
      $game_party.currency[currency_index]
    end
  end
 
  #-------------------------------------------------------------------------
  # * Method: refresh
  #-------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(text_color(6))
    draw_text(23, -4, 100, 30,"Currencies")
    draw_horz_line(0, 6)
    draw_horz_line(3, 6)
    i = 0
    Clstn_Currencies::Currencies.each_value { |hash|
      icon_index = hash[0]
      draw_horz_line(37 + (32 * i), 0)
      currency_unit = draw_icon(icon_index, 100, 32 + (32 * i))
      draw_currency_value(value(i), currency_unit, -19, 33 + (32 * i), contents.width - 8)
      i += 1
    }
  end
 
  #-------------------------------------------------------------------------
  # * Method: draw_horz_line
  #-------------------------------------------------------------------------
  def draw_horz_line(dy, color)
    color = text_color(color)
    line_y = dy + line_height - 4
    contents.fill_rect(4, line_y, contents_width - 8, 3, Font.default_out_color)
    contents.fill_rect(5, line_y + 1, contents_width - 10, 1, color)
  end
 
end
#===========================================================================
# ** Class Window_Gold
#===========================================================================
class Window_Gold < Window_Base
 
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_currency_value(value($game_temp.currency_index), currency_unit($game_temp.currency_index), -10, 0, contents.width - 8)
  end
  #--------------------------------------------------------------------------
  # * Get Party Gold
  #--------------------------------------------------------------------------
  def value(currency_index = $game_temp.currency_index)
    if currency_index == 0
      $game_party.gold
    else
      $game_party.currency[currency_index]
    end
  end  
  #--------------------------------------------------------------------------
  # Get Currency Unit
  #--------------------------------------------------------------------------
  def currency_unit(currency_index = $game_temp.currency_index)
    icon_index = Clstn_Currencies::Currencies[currency_index][0]
    currency_unit = draw_icon(icon_index, 115, -1)
  end
 
end
 
#===========================================================================
# ** Class Game_Party
#===========================================================================
class Window_ShopNumber < Window_Selectable
 
  #-------------------------------------------------------------------------
  # * Method: draw_total_price
  #-------------------------------------------------------------------------
  def draw_total_price
    width = contents_width - 8
    icon_index = Clstn_Currencies::Currencies[$game_temp.currency_index][0]
    icon = draw_icon(icon_index, 255, 143)
    draw_currency_value(@price * @number, icon, -15, price_y, width)
  end
 
end
#===========================================================================
# ** Class Game_Party
#===========================================================================
class Game_Party < Game_Unit
  attr_accessor :currency
 
  #-------------------------------------------------------------------------
  # * Initialize
  #-------------------------------------------------------------------------
  def initialize
    @currency = []
    @gold = Clstn_Currencies::Currencies[0][1]
    11.times { |i|
      if i == 0
        @currency[i] = @gold
      else
        @currency[i] = Clstn_Currencies::Currencies[i][1]
      end
    }
    @steps = 0
    @last_item = Game_BaseItem.new
    @menu_actor_id = 0
    @target_actor_id = 0
    @actors = []
    init_all_items
  end
 
  #-------------------------------------------------------------------------
  # * Method: gain_gold
  #-------------------------------------------------------------------------
  def gain_gold(amount, currency_index = $game_temp.currency_index)
    if currency_index != 0
      @currency[currency_index] = [[@currency[currency_index] + amount, 0].max, max_gold].min
    else
      @gold = [[@gold + amount, 0].max, max_gold].min
    end
  end
 
  #-------------------------------------------------------------------------
  # * Method: lose_gold
  #-------------------------------------------------------------------------
  def lose_gold(amount, currency_index = $game_temp.currency_index)
      gain_gold(-amount, currency_index)
  end
 
end
 
#===========================================================================
# ** Class Game_Temp
#===========================================================================
class Game_Temp
  attr_accessor :currency_index
 
  #--------------------------------------------------------------------------
  # * Aliased Methods
  #--------------------------------------------------------------------------
  alias :clstn_initialize_0005 initialize
 
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize
    @currency_index = 0
    clstn_initialize_0005
  end
 
end
 
#===========================================================================
# ** Class Game_Temp
#===========================================================================
class Game_Interpreter
 
  #--------------------------------------------------------------------------
  # * Method: add_currency
  #--------------------------------------------------------------------------
  def add_currency(amount, currency_index)
    $game_party.gain_gold(amount, currency_index)
  end
 
  #--------------------------------------------------------------------------
  # * Method: currency
  #--------------------------------------------------------------------------
  def currency(currency_index)
    $game_temp.currency_index = currency_index
  end
 
end
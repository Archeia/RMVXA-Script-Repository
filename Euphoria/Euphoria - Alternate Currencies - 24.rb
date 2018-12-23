#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                          *Alternate Currencies*
#│                              Version: 1.1
#│                            Author: Euphoria
#│                            Date: 8/17/2014
#│                        Euphoria337.wordpress.com
#│                        
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: This script CAN overwrite methods in: Scene_Menu
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: 1.1) added compatibility for Euphoria - Alternate Currency Shops                         
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: This is my second time writing the instructions because I'm 
#│                stupid and canceled out of the editor when I finished.
#│                Anyways, edit the settings in the editable region to fit your
#│                needs. The NEW_GOLD_WINDOW will add a new window displaying up
#│                to seven new currencies, along with gold, to the menu. 
#│                SET_MENU_COMMAND will add the currency view option to the menu
#│                if you want currencies to be accessible from the menu, set it
#│                to true. SET_MENU_NAME will be the name of the menu option for
#│                the currency view scene. GOLD_WINDOW_ICONS will change the 
#│                currency symbol (ex: "$") to the currency icon, when true 
#│                (only in the new gold window). REGULAR_GOLD_ICON is the icon 
#│                id number to use for the default currency's icon, assuming you
#│                set GOLD_WINDOW_ICONS to true, if not, REGULAR_GOLD_ICON has
#│                no effect.
#│
#│                To edit/add currencies to your game you MUST follow the format
#│                used by the example currencies in the editable region, of 
#│                course, you could just edit those. But if you want to add more
#│                currencies than seven for some reason(I know it says DO NOT 
#│                ADD MORE, but that's for people who don't read the
#│                instructions(also note that only up to seven currencies can be 
#│                displayed in the NEW_GOLD_WINDOW)), the format is:
#│
#│                "Currency Name" => {      keep the currency's name in quotes
#│                :ENABLED => true or false, true will enable the currency
#│                :SYMBOL  => "Currency Symbol", keep the symbol in quotes
#│                :DESC    => "Short Description of Currency", keep the quotes
#│                :ICON    => Icon ID number you wish to use
#│                :MAX     => the maximum amount the party can have
#│                },            DO NOT FORGET THE BRACKET AND ADD COMMAS AFTER
#│                              EACH VARIABLE AS SEEN IN THE EXAMPLES
#│
#│                To actually use the currencies, you will have to use script 
#│                calls, the following are the script calls you will need to 
#│                know:
#│
#│                $ECurrency.set_currency("currency_name", amount)
#│
#│                $ECurrency.increase_currency("currency_name", amount)
#│
#│                $ECurrency.decrease_currency("currency_name", amount)
#│
#│                These will help you manage your currencies. set_currency will
#│                change whatever current value the currency has to the new
#│                amount. increase_currency will increase the named currency by
#│                the amount given. You can probably guess what 
#│                decrease_currency does.
#│
#│                There is a fourth call that will most likely only be used in
#│                conditional branch script calls, it is:
#│
#│                $ECurrency.amount("currency_name")
#│
#│                This call simply returns the party's current total of the 
#│                currency named. Here are some examples of how to use it in a
#│                conditional branch script call:
#│
#│                $ECurrency.amount("currency_name") == 50
#│                                   or
#│                $ECurrency.amount("currency_name") >= 50
#│                                   or
#│                $ECurrency.amount("currency_name") <= 50
#│
#│                With these you can check the parties currency amount to sell
#│                or buy special items, or whatever your imagination can come up
#│                with! Of course, after the check you would probably use one of 
#│                the previous calls to set, increase, or decrease the currency.
#│                 
#│                If you have any questions or suggestions feel free to ask at
#│                my website or wherever I post the script link. Enjoy!
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaAlternateCurrencies"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Currencies
    
    NEW_GOLD_WINDOW = true #If True, Creates A Window In Place Of Gold To
                           #Display All Currencies. WARNING: This Will Overwrite
                           #Parts Of Scene_Menu, If You Have A Custom Menu, Set
                           #It To false
                           
    GOLD_WINDOW_ICONS = false #If set to true the new gold window will display 
                              #currency icons instead of currency symbols (ex:
                              #"$") next to the currencies current amount
                              
    REGULAR_GOLD_ICON = 57 #ID Number to be used when GOLD_WINDOW_ICONS = true
                           #for gold, or the original default currency you made'
                           #in the database. This ONLY matters if 
                           #GOLD_WINDOW_ICONS = true
    
    SET_MENU_COMMAND = true #Add the currency view as a menu option, this is 
                             #the ugly way to add it, if you know how to add
                             #the command the pretty way, I recommend that.
                             
    SET_MENU_NAME = "Currencies" #The name of the menu option, only applies if
                                 #SET_MENU_COMMAND is set to true
                           
    CURR_HASH = { #DO NOT TOUCH!
    #DO NOT ADD MORE!
    
      "Currency1" => {
      :ENABLED => true,
      :SYMBOL  => "$",
      :DESC    => "Short Description",
      :ICON    => 30,
      :MAX     => 100,
      },
    
      "Currency2" => {
      :ENABLED => true,
      :SYMBOL  => "￠",
      :DESC    => "Short Description",
      :ICON    => 31,
      :MAX     => 9999999,
      },
    
      "Currency3" => {
      :ENABLED => true,
      :SYMBOL  => "＊",
      :DESC    => "Short Description",
      :ICON    => 32,
      :MAX     => 100,
      },
    
      "Currency4" => {
      :ENABLED => false,
      :SYMBOL  => "₩",
      :DESC    => "Short Description",
      :ICON    => 32,
      :MAX     => 100,
      },
      
      "Currency5" => {
      :ENABLED => false,
      :SYMBOL  => "Ω",
      :DESC    => "Short Description",
      :ICON    => 32,
      :MAX     => 100,
      },
      
      "Currency6" => {
      :ENABLED => false,
      :SYMBOL  => "※",
      :DESC    => "Short Description",
      :ICON    => 32,
      :MAX     => 100,
      },
      
      "Currency7" => {
      :ENABLED => false,
      :SYMBOL  => "₫",
      :DESC    => "Short Description",
      :ICON    => 32,
      :MAX     => 100,
      },
      
    #DO NOT ADD MORE!
    } #DO NOT TOUCH!
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ DataManager
#└──────────────────────────────────────────────────────────────────────────────
class << DataManager
  
  #ALIAS - CREATE_GAME_OBJECTS
  alias euphoria_multcurrency_datamanager_creategameobjects_24 create_game_objects
  def create_game_objects
    euphoria_multcurrency_datamanager_creategameobjects_24
    $ECurrency = ExtraCurrencies.new
  end
  
  #OVERWRITE - MAKE_SAVE_CONTENTS
  alias euphoria_multcurrency_datamanager_makesavecontents_24 make_save_contents
  def make_save_contents
    contents = euphoria_multcurrency_datamanager_makesavecontents_24
    contents[:ecurrency] = $ECurrency
    contents
  end
  
  #ALIAS - EXTRACT_SAVE_CONTENTS
  alias euphoria_multcurrency_datamanager_extractsavecontents_24 extract_save_contents
  def extract_save_contents(contents)
    euphoria_multcurrency_datamanager_extractsavecontents_24(contents)
    $ECurrency = contents[:ecurrency]
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ NewCurrency
#└──────────────────────────────────────────────────────────────────────────────
class NewCurrency
  attr_accessor :name
  attr_accessor :symbol
  attr_accessor :desc
  attr_accessor :icon
  attr_accessor :max
  attr_accessor :amount
  attr_accessor :enabled
  
  #NEW - INITIALIZE
  def initialize(name, symbol, desc, icon, max, amount, enabled)
    @name = name
    @symbol = symbol
    @desc = desc
    @icon = icon
    @max = max
    @amount = amount
    @enabled = enabled
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ ExtraCurrencies
#└──────────────────────────────────────────────────────────────────────────────
class ExtraCurrencies
  
  #NEW - INITIALIZE
  def initialize
    @ecurrencies = []
    add_currencies
  end
  
  #NEW - ADD_CURRENCIES
  def add_currencies
    Euphoria::Currencies::CURR_HASH.each {|name, val|
      currency = NewCurrency.new(name, val[:SYMBOL], val[:DESC],
          val[:ICON], val[:MAX], 0, val[:ENABLED])
      @ecurrencies.push(currency) if currency.enabled
    }
  end
  
  #NEW - ECURRENCIES_ARRAY
  def ecurrencies_array
    return @ecurrencies
  end
    
  #NEW - INCREASE_CURRENCY
  def increase_currency(curr_name, amt)
    currency = @ecurrencies.find {|cur| cur.name == curr_name }
    return false if currency.nil?
    currency.amount = [[currency.amount + amt, 0].max, currency.max].min
  end
  
  #NEW - DECREASE_CURRENCY
  def decrease_currency(curr_name, amt)
    currency = @ecurrencies.find {|cur| cur.name == curr_name }
    return false if currency.nil?
    currency.amount = [[currency.amount - amt, 0].max, currency.max].min
  end  
  
  #NEW - SET_CURRENCY
  def set_currency(curr_name, amt)
    currency = @ecurrencies.find {|cur| cur.name == curr_name }
    return false if currency.nil?
    currency.amount = [[amt, 0].max, currency.max].min
  end 

  #NEW - AMOUNT
  def amount(curr_name)
    currency = @ecurrencies.find {|cur| cur.name == curr_name }
    return false if currency.nil?
    return currency.amount
  end
  
  #NEW - SET_CURRENCY
  def set_currency(curr_name)
    currency = @ecurrencies.find {|cur| cur.name == curr_name }
    return false if currency.nil?
    return currency
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_Gold
#└──────────────────────────────────────────────────────────────────────────────  
class Window_ECurrencies < Window_Base
  
  #NEW - INITIALIZE
  def initialize
    case $ECurrency.ecurrencies_array.size
    when 7
      super(0, 0, window_width, 216)
    when 6
      super(0, 0, window_width, 192)
    when 5
      super(0, 0, window_width, 168)
    when 4
      super(0, 0, window_width, 144)
    when 3
      super(0, 0, window_width, 120)
    when 2
      super(0, 0, window_width, 96)
    when 1
      super(0, 0, window_width, 72)
    else
      super(0, 0, window_width, 48)
    end
    refresh
  end
  
  #NEW - WINDOW_WIDTH
  def window_width
    return 160
  end
  
  #NEW - DRAW_CURRENCY_VALUE_ICONS
  def draw_currency_value_icons(value, icon, x, y, width)
    cx = 24
    change_color(normal_color)
    draw_text(x, y, width - cx - 2, line_height, value, 2)
    change_color(system_color)
    new_x = x + 108
    draw_icon(icon, new_x, y, enabled = true)
  end
  
  #NEW - REFRESH
  def refresh
    contents.clear
    if Euphoria::Currencies::GOLD_WINDOW_ICONS == true
      draw_currency_value_icons(value, Euphoria::Currencies::REGULAR_GOLD_ICON, 4, 0, contents.width - 8)
      if $ECurrency.ecurrencies_array[0]
        draw_currency_value_icons(val_one, icon_one, 4, 24, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[1]
        draw_currency_value_icons(val_two, icon_two, 4, 48, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[2]
        draw_currency_value_icons(val_thr, icon_thr, 4, 72, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[3]
        draw_currency_value_icons(val_for, icon_for, 4, 96, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[4]
        draw_currency_value_icons(val_fiv, icon_fiv, 4, 120, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[5]
        draw_currency_value_icons(val_six, icon_six, 4, 144, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[6]
        draw_currency_value_icons(val_svn, icon_svn, 4, 168, contents.width - 8)
      end
    else 
      draw_currency_value(value, currency_unit, 4, 0, contents.width - 8)
      if $ECurrency.ecurrencies_array[0]
        draw_currency_value(val_one, unit_one, 4, 24, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[1]
        draw_currency_value(val_two, unit_two, 4, 48, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[2]
        draw_currency_value(val_thr, unit_thr, 4, 72, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[3]
        draw_currency_value(val_for, unit_for, 4, 96, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[4]
        draw_currency_value(val_fiv, unit_fiv, 4, 120, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[5]
        draw_currency_value(val_six, unit_six, 4, 144, contents.width - 8)
      end
      if $ECurrency.ecurrencies_array[6]
        draw_currency_value(val_svn, unit_svn, 4, 168, contents.width - 8)
      end
    end
  end

  #NEW - VALUE
  def value
    $game_party.gold
  end

  #NEW - CURRENCY_UNIT
  def currency_unit
    Vocab::currency_unit
  end
  
  #NEW - VAL_ONE
  def val_one
    return $ECurrency.ecurrencies_array[0].amount.to_i
  end
  
  #NEW - UNIT_ONE
  def unit_one
    return $ECurrency.ecurrencies_array[0].symbol.to_s
  end
  
  #NEW - VAL_TWO
  def val_two
    return $ECurrency.ecurrencies_array[1].amount.to_i
  end
  
  #NEW - UNIT_TWO
  def unit_two
    return $ECurrency.ecurrencies_array[1].symbol.to_s
  end
  
  #NEW - VAL_THR
  def val_thr
    return $ECurrency.ecurrencies_array[2].amount.to_i
  end
  
  #NEW - UNIT_THR
  def unit_thr
    return $ECurrency.ecurrencies_array[2].symbol.to_s
  end
  
  #NEW - VAL_FOR
  def val_for
    return $ECurrency.ecurrencies_array[3].amount.to_i
  end
  
  #NEW - UNIT_FOR
  def unit_for
    return $ECurrency.ecurrencies_array[3].symbol.to_s
  end
  
  #NEW - VAL_FIV
  def val_fiv
    return $ECurrency.ecurrencies_array[4].amount.to_i
  end
  
  #NEW - UNIT_FIV
  def unit_fiv
    return $ECurrency.ecurrencies_array[4].symbol.to_s
  end
  
  #NEW - VAL_SIX
  def val_six
    return $ECurrency.ecurrencies_array[5].amount.to_i
  end
  
  #NEW - UNIT_SIX
  def unit_six
    return $ECurrency.ecurrencies_array[5].symbol.to_s
  end
  
  #NEW - VAL_SVN
  def val_svn
    return $ECurrency.ecurrencies_array[6].amount.to_i
  end
  
  #NEW - UNIT_SVN
  def unit_svn
    return $ECurrency.ecurrencies_array[6].symbol.to_s
  end
  
  #NEW - ICON_ONE
  def icon_one
    return $ECurrency.ecurrencies_array[0].icon
  end
    
  #NEW - ICON_TWO
  def icon_two
    return $ECurrency.ecurrencies_array[1].icon
  end
    
  #NEW - ICON_THR
  def icon_thr
    return $ECurrency.ecurrencies_array[2].icon
  end
    
  #NEW - ICON_FOR
  def icon_for
    return $ECurrency.ecurrencies_array[3].icon
  end
    
  #NEW - ICON_FIV
  def icon_fiv
    return $ECurrency.ecurrencies_array[4].icon
  end
    
  #NEW - ICON_SIX
  def icon_six
    return $ECurrency.ecurrencies_array[5].icon
  end
    
  #NEW - ICON_SVN
  def icon_svn
    return $ECurrency.ecurrencies_array[6].icon
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_ECurrencyList
#└──────────────────────────────────────────────────────────────────────────────   
class Window_ECurrencyList < Window_Selectable
  
  #NEW - INITIALIZE
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @data = []
    activate
    select(0)
    refresh
  end

  #NEW - ITEM_MAX
  def item_max
    @data ? @data.size : 1
  end
  
  #NEW - REFRESH
  def refresh
    make_currency_list
    create_contents
    draw_all_items
  end
  
  #NEW - DRAW_ALL_ITEMS
  def draw_all_items
    item_max.times {|i| draw_currency(i) }
  end
  
  #NEW - DRAW_CURRENCY
  def draw_currency(index)
    currency = @data[index]
    if currency
      if currency.enabled
        rect = item_rect(index)
        draw_text(rect, currency.name, 1)
      end
    end
  end

  #NEW - CURRENCY
  def currency
    @data && index >= 0 ? @data[index] : nil
  end
  
  #NEW MAKE_CURRENCY_LIST
  def make_currency_list
    @data = $ECurrency.ecurrencies_array
  end
  
  #NEW - UPDATE_HELP
  def update_help
    data = @data[index]
    @help_window.set_currency(data)
  end
    
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_ECurrencyInfo
#└──────────────────────────────────────────────────────────────────────────────   
class Window_ECurrencyInfo < Window_Base
  
  #NEW - INITIALIZE
  def initialize(x, y, width, height)
    super(x, y, width, height)
  end
  
  #NEW - CURRENCY=
  def currency=(index)
    return if @currency == index
    @currency = index
    refresh
  end
  
  #NEW - REFRESH
  def refresh
    contents.clear
    draw_currency_info
    return if @currency
  end
  
  #NEW - SET_CURRENCY
  def set_currency(currency)
    @currency = currency
    refresh
  end
  
  #NEW - DRAW_CURRENCY_INFO
  def draw_currency_info
    draw_icon(@currency.icon, 185, 0)
    header = @currency.name
    make_font_bigger
    draw_text(0, 30, 394, 48, header, 1)
    make_font_smaller
    draw_icon(@currency.icon, 185, 80)
    owned = "Amount Owned:"
    ownednum = @currency.amount
    draw_text(0, 108, 394, line_height, owned, 1)
    draw_text(0, 132, 394, line_height, ownednum, 1)
    offsymbol = "Official Symbol: "
    realsymbol = @currency.symbol
    draw_text(0, 176, 394, line_height, offsymbol, 1)
    draw_text(0, 200, 394, line_height, realsymbol, 1)
    desc = @currency.desc
    draw_text(0, 248, 394, line_height, desc, 1)
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_ECurrencyHelp
#└──────────────────────────────────────────────────────────────────────────────
class Window_ECurrencyHelp < Window_Base
  
  #NEW - INITIALIZE
  def initialize(x, y, width, height)
    super(x, y, width, height)
    refresh
  end
  
  #NEW - REFRESH
  def refresh
    contents.clear
    draw_currency_help
  end
  
  #NEW - DRAW_CURRENCY_HELP
  def draw_currency_help
    text = "View Currency Information"
    make_font_bigger
    draw_text(0, 0, 544, 48, text, 1)
    make_font_smaller
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Scene_CurrencyView
#└────────────────────────────────────────────────────────────────────────────── 
class Scene_CurrencyView < Scene_MenuBase
  
  #NEW - START
  def start
    super
    create_cur_list
    create_cur_info
    create_cur_help
  end
  
  #NEW - CREATE_CUR_LIST
  def create_cur_list
    @cur_list = Window_ECurrencyList.new(0, 72, 150, 344)
    @cur_list.viewport = @viewport
    @cur_list.set_handler(:cancel, method(:return_scene))
  end
  
  #NEW - CREATE_CUR_INFO
  def create_cur_info
    @cur_info = Window_ECurrencyInfo.new(150, 72, 394, 344)
    @cur_info.viewport = @viewport
    @cur_list.help_window = @cur_info
  end
  
  #NEW - CREATE_CUR_HELP
  def create_cur_help
    @help_window = Window_ECurrencyHelp.new(0, 0, 544, 72)
    @help_window.viewport = @viewport
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Scene_Menu
#└──────────────────────────────────────────────────────────────────────────────
if Euphoria::Currencies::NEW_GOLD_WINDOW == true
class Scene_Menu < Scene_MenuBase
  
  #OVERWRITE 
  def start
    super
    create_command_window
    create_new_gold_window
    create_status_window
  end
 
  #NEW - CREATE_NEW_GOLD_WINDOW
  def create_new_gold_window
    @gold_window = Window_ECurrencies.new
    @gold_window.x = 0
    @gold_window.y = Graphics.height - @gold_window.height
  end

end  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_MenuCommand
#└──────────────────────────────────────────────────────────────────────────────
class Window_MenuCommand < Window_Command
  
  #ALIAS - ADD_MAIN_COMMANDS
  alias euphoria_multcurrency_windowmenucommand_addmaincommands_24 add_main_commands
  def add_main_commands
    euphoria_multcurrency_windowmenucommand_addmaincommands_24
    if Euphoria::Currencies::SET_MENU_COMMAND == true
      add_command(Euphoria::Currencies::SET_MENU_NAME, :currency)
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Scene_Menu
#└──────────────────────────────────────────────────────────────────────────────
class Scene_Menu < Scene_MenuBase
  
  #ALIAS - CREATE_COMMAND_WINDOW
  alias euphoria_multcurrency_scenemenu_createcommandwindow_24 create_command_window
  def create_command_window
    euphoria_multcurrency_scenemenu_createcommandwindow_24
    if Euphoria::Currencies::SET_MENU_COMMAND == true
      @command_window.set_handler(:currency, method(:command_currency))
    end
  end
  
  #NEW - COMMAND_CURRENCY
  def command_currency
    SceneManager.call(Scene_CurrencyView)
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────
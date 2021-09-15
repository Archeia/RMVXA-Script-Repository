#encoding:UTF-8
# Window_ShopCommand
#==============================================================================
# ** Window_ShopCommand
#------------------------------------------------------------------------------
#  This window is for selecting buy/sell on the shop screen.
#==============================================================================

class Window_ShopCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(window_width, purchase_only)
    @window_width = window_width
    @purchase_only = purchase_only
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopSell,   :sell,   !@purchase_only)
    add_command(Vocab::ShopCancel, :cancel)
  end
end

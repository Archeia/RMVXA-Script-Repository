#encoding:UTF-8
# Game_Temp
#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
# The instance of this class is referenced by $game_temp.
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :next_scene               # screen for switch (String)
  attr_accessor :map_bgm                  # map screen BGM (for battle memory)
  attr_accessor :map_bgs                  # map screen BGS (for battle memory)
  attr_accessor :common_event_id          # common event ID
  attr_accessor :in_battle                # in-battle flag
  attr_accessor :battle_proc              # battle callback (Proc)
  attr_accessor :shop_goods               # list of shop goods
  attr_accessor :shop_purchase_only       # shop purchase only flag
  attr_accessor :name_actor_id            # name input: actor ID
  attr_accessor :name_max_char            # name input: number of characters
  attr_accessor :menu_beep                # menu: play SE flag
  attr_accessor :last_file_index          # last save file no.
  attr_accessor :debug_top_row            # debug screen: for saving conditions
  attr_accessor :debug_index              # debug screen: for saving conditions
  attr_accessor :background_bitmap        # background bitmap
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @next_scene = nil
    @map_bgm = nil
    @map_bgs = nil
    @common_event_id = 0
    @in_battle = false
    @battle_proc = nil
    @shop_goods = nil
    @shop_purchase_only = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_beep = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
    @background_bitmap = Bitmap.new(1, 1)
  end
end

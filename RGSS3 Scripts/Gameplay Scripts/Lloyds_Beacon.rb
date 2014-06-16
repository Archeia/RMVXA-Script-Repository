#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Lloyd's Beacon
#  Author: Kread-EX
#  Version 1.0
#  Release date: 07/01/2013
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

=begin

IMPORTANT

Please credit Cremno (https://gist.github.com/cremno) because I used his
GDI+ interface to know how to use a C pointer to Ruby bitmaps.

=end

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
# # Mimics the eponymous spell from Might and Magic VI. Allows you to set
# # teleport points with skills.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # You need to use skill notetags:
# #
# # <beacon>
# # Mark the skill as a beacon
# # 
# # <beacon_max: x>
# # Maximum number of beacons available with this skill.
# #
# # Further customization can be found in the config module (commented).
# #
# # Note: beacons are saved globally, not per skill. If you have multiple
# # beacon skills with different beacon_max values, the only difference will
# # be the number of slots available.
# # 
# # Also, there is a hardcoded 9 beacons limit.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # List of new classes:
# # 
# # Window_BeaconMode
# # Window_Beacon
# # Scene_Beacon
# #
# # List of aliases and overwrites:
# # 
# # Bitmap
# # get_dib (new method)
# # to_s (new method)
# # swap_dib (new method)
# # 
# # DataManager
# # load_database (alias)
# # load_beacon_notetags (new method)
# # 
# # RPG::Skill
# # is_beacon (new attr method)
# # beacon_max (new attr method)
# # load_beacon_notetags (new method)
# # 
# # Game_BattlerBase
# # skill_conditions_met? (alias)
# # 
# # Game_Party
# # beacons (new attr method)
# # save_beacon (new method)
# # 
# # Scene_Skill
# # check_common_event (alias)
#------------------------------------------------------------------------------

($imported ||= {})['KRX-LloydBeacon'] = true

puts 'Load: Lloyd\'s Beacon v1.0 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================
  # Switch ID for disabling beacon skills.
  LB_SWITCH_DISABLE = 5
  
  # Font name used for the thumbnails. If nil, the default font will be used.
  LB_FONT_NAME = ['Tahoma', 'UmePlus Gothic']
  # Font size used for the thumbnails. If nil, the default size will be used.
  LB_FONT_SIZE = 12
  
  # Animation ID to be displayed after a beacon is SET.
  LB_SET_ANIM = 107
  # Animation ID to be displayed after a beacon is teleported to.
  LB_GOTO_ANIM = 107
  
  module VOCAB
    # Text displayed for setting and returning to a beacon.
    LB_PUT_BEACON = 'Set beacon'
    LB_TELEPORT = 'Go to beacon'
  end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
  module REGEXP
    LB_BEACON = /<beacon>/i
    LB_BEACON_MAX = /<beacon_max:[ ]*(\d+)>/i
  end
  LB_Structure = Struct.new(:map_id, :map_x, :map_y, :thumbnail)
end

#===========================================================================
# ■ Bitmap
#===========================================================================

class Bitmap
	#--------------------------------------------------------------------------
	# ● Return the dib
	#--------------------------------------------------------------------------
  def get_dib
    ((DL::CPtr.new((object_id << 1) + 16).ptr + 8).ptr + 16).ptr
  end
	#--------------------------------------------------------------------------
	# ● Return a string version of the dib
	#--------------------------------------------------------------------------
  def to_s
    get_dib.to_s(width * height * 4)
  end
	#--------------------------------------------------------------------------
	# ● Swap the current dib stored in memory with another one
	#--------------------------------------------------------------------------
  def swap_dib(dib = nil)
    get_dib[0, width * height * 4] = dib
  end
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self; alias_method(:krx_beacon_dm_ld, :load_database); end
	def self.load_database
		krx_beacon_dm_ld
		load_beacon_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_beacon_notetags
    for obj in $data_skills
      next if obj.nil?
      obj.load_beacon_notetags
    end
		puts "Read: Lloyd's Beacon Notetags"
	end
end

#==========================================================================
# ■ RPG::Skill
#==========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :is_beacon
  attr_reader   :beacon_max
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_beacon_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
      when KRX::REGEXP::LB_BEACON
        @is_beacon = true
      when KRX::REGEXP::LB_BEACON_MAX
        @beacon_max = $1.to_i
			end
		end
  end
end

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Determine if the skill usage conditions are met
  #--------------------------------------------------------------------------
  alias_method(:krx_beacon_gbb_scm?, :skill_conditions_met?)
  def skill_conditions_met?(skill)
    return false if skill.is_beacon && $game_switches[KRX::LB_SWITCH_DISABLE]
    return krx_beacon_gbb_scm?(skill)
  end
end

#==============================================================================
# ■ Game_Party
#==============================================================================

class Game_Party < Game_Unit
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :beacons
	#--------------------------------------------------------------------------
	# ● Save a beacon
	#--------------------------------------------------------------------------
  def save_beacon(bitmap, index)
    mid = $game_map.map_id
    mx, my = $game_player.x, $game_player.y
    mt = Zlib::Deflate.deflate(bitmap.to_s, Zlib::BEST_COMPRESSION)
    @beacons ||= {}
    @beacons[index] = KRX::LB_Structure.new(mid, mx, my, mt)
  end
end

#==========================================================================
# ■ Window_BeaconMode
#==========================================================================

class Window_BeaconMode < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● Get window width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● Get number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● Make command list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(KRX::VOCAB::LB_PUT_BEACON, :set)
    add_command(KRX::VOCAB::LB_TELEPORT, :goto)
  end
end

#==========================================================================
# ■ Window_Beacon
#==========================================================================

class Window_Beacon < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :mode_window
  #--------------------------------------------------------------------------
  # ● Object initialization
  #--------------------------------------------------------------------------
  def initialize(y)
    super(0, y, window_width, Graphics.height - y)
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● Get window width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● Get number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # ● Get line height
  #--------------------------------------------------------------------------
  def line_height
    return (height - standard_padding * 2) / 3
  end
  #--------------------------------------------------------------------------
  # ● Get indexed item
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end
  #--------------------------------------------------------------------------
  # ● Get item max
  #--------------------------------------------------------------------------
  def item_max
    return 9 if @mode_window.nil?
    return @data ? @data.size : 9
  end
  #--------------------------------------------------------------------------
  # ● Get availability
  #--------------------------------------------------------------------------
  def enable?(item)
    return true if @mode_window && @mode_window.current_symbol == :set
    !item.nil?
  end
  #--------------------------------------------------------------------------
  # ● Get current availability
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ● Make item list
  #--------------------------------------------------------------------------
  def make_item_list
    sk = $game_party.menu_actor.last_skill.object
    size = [sk.beacon_max || 9, 9].min
    @data = Array.new(size)
    size.times do |i|
      if ($game_party.beacons || {})[i]
        @data[i] = $game_party.beacons[i]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Display indexed item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    rect.x += 1
    rect.y += 1
    rect.width -= 2
    rect.height -= 2
    if item
      dib = Zlib::Inflate.inflate(item.thumbnail)
      th = Bitmap.new(rect.width, rect.height)
      th.swap_dib(dib)
      contents.blt(rect.x, rect.y, th, th.rect)
    else
      contents.fill_rect(rect, Color.new(0, 0, 0, translucent_alpha / 2))
    end
  end
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● Resize the snapshot into a usable thumbnail
  #--------------------------------------------------------------------------
  def resize_thumbnail(snap)
    rect = item_rect(index)
    rect.x = 0
    rect.y = 0
    rect.width -= 2
    rect.height -= 2
    bmp = Bitmap.new(rect.width, rect.height)
    bmp.stretch_blt(rect, snap, snap.rect)
    rect.height = 24
    name = Bitmap.new(rect.width, rect.height)
    name.fill_rect(rect, Color.new(0, 0, 0, 160))
    rect.y = bmp.rect.height - 24
    bmp.blt(rect.x, rect.y, name, name.rect)
    bmp.font.name = KRX::LB_FONT_NAME ? KRX::LB_FONT_NAME : Font.default_name
    bmp.font.size = KRX::LB_FONT_SIZE ? KRX::LB_FONT_SIZE : Font.default_size
    bmp.draw_text(rect, $game_map.display_name, 1)
    return bmp
  end
end

#==========================================================================
# ■ Scene_Skill
#==========================================================================

class Scene_Skill < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● Check common event
  #--------------------------------------------------------------------------
  alias_method(:krx_beacon_ss_cce, :check_common_event)
  def check_common_event
    krx_beacon_ss_cce
    SceneManager.goto(Scene_Beacon) if item.is_beacon
  end
end

#==========================================================================
# ■ Scene_Beacon
#==========================================================================

class Scene_Beacon < Scene_Base
  #--------------------------------------------------------------------------
  # ● Start
  #--------------------------------------------------------------------------
  def start
    super
    @command_window = Window_BeaconMode.new(0, 0)
    @command_window.set_handler(:ok,     method(:on_mode_ok))
    @command_window.set_handler(:cancel, method(:return_scene))
    @beacon_window = Window_Beacon.new(@command_window.height)
    @beacon_window.mode_window = @command_window
    @beacon_window.refresh
    @beacon_window.set_handler(:ok,      method(:on_beacon_ok))
    @beacon_window.set_handler(:cancel,  method(:on_beacon_cancel))
  end
  #--------------------------------------------------------------------------
  # ● Validate mode selection
  #--------------------------------------------------------------------------
  def on_mode_ok
    @beacon_window.activate.select(0)
  end
  #--------------------------------------------------------------------------
  # ● Validate beacon selection
  #--------------------------------------------------------------------------
  def on_beacon_ok
    set_beacon if @command_window.current_symbol == :set
    goto_beacon if @command_window.current_symbol == :goto
  end
  #--------------------------------------------------------------------------
  # ● Cancel beacon selection
  #--------------------------------------------------------------------------
  def on_beacon_cancel
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● Set a beacon
  #--------------------------------------------------------------------------
  def set_beacon
    th = @beacon_window.resize_thumbnail(SceneManager.background_bitmap)
    aid = KRX::LB_SET_ANIM.is_a?(Numeric) ? KRX::LB_SET_ANIM : 0
    $game_party.save_beacon(th, @beacon_window.index)
    $game_player.animation_id = aid
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● Teleport to the selected beacon
  #--------------------------------------------------------------------------
  def goto_beacon
    if @beacon_window.current_item_enabled?
      mid = @beacon_window.item.map_id
      mx = @beacon_window.item.map_x
      my = @beacon_window.item.map_y
      md = $game_player.direction
      aid = KRX::LB_GOTO_ANIM.is_a?(Numeric) ? KRX::LB_GOTO_ANIM : 0
      $game_player.animation_id = aid
      $game_player.reserve_transfer(mid, mx, my, md)
      SceneManager.goto(Scene_Map)
    else
      Sound.play_buzzer
      @beacon_window.activate
    end
  end
end
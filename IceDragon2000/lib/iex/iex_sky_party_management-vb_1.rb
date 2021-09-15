#===========================================================================
#
# Sky Script Revolution : Party Manager (SSR)
# Version 1.0
# January 20, 2011 Started
# January 22, 2011 Completed
#
#===========================================================================
#
# What is Sky Script Revolution (SSR)?
#	It is a revamp of Sky's previous scripts.
# Is that all?
#	No, that is only the beginning. Look for
#	New Scripts as well. Also look forward to
#	the reopenning of script request hall soon.
# What kind of scripts are you planning?
#	I am starting to get into battle system
#	scripting so look for edits.
# Are you supporting old scripts?
#	Some scripts don't need revamping as they
#	work beautifully, so I will update those
#	scripts.
#
#===========================================================================
#
# Features :
#	Version 1.0 - January 22, 2011
#	   - Swapping of members available
#	   - Searching for party members
#		  * Name
#		  * Level
#		  * Class
#	   - Shows Primary Stats and equips
# 
#===========================================================================
#
# Credit
# Sky00Valentine :creator and editor
#		 Yanfly :Game_Party Class to add extra members & switch members.
#				 (I could try changing it but its basically the same so
#				  Yanfly thanks) Also for Input Script
#  OriginalWij : For Input Script
#
#===========================================================================
#
# Terms of Use
# ------------
#
#	 Crediting Rpgmakervx.net is the only thing I ask.
#	 However feel free to credit Sky00Valentine if you
#	 see fit.
#
#===========================================================================
#
# Future improvement
# ------------------
#   
#	- Unknown
#  
#===========================================================================
#
# Instructions & Installation
# ---------------------------
# - Edit modules
# 
# - Get my SAATW edit
#
# - Get Yanfly and OriginalWij's Keyboard Input Script 
#   and place it before this script
#
# - Edit Game_Party's MAX_MEMBERS to be 2, 3, or 4.
#
# - Script commands:
#	(Goes to Party Menu.)
#	 -------------------
#	  $scene = Scene_Party.new 
#
#	(Locks actor into battle party or reserve even before they party.)
#	 ---------------------------------------------------------------
#	  $game_actors[id].lock = true 
#	  $game_party.all_members[a].lock = true
#	  (locks party member in posistion a to where they are
#				 party or reserve.)
#								 
#
# - You can search through your reserves by typing on the keyboard
#   when the reserve is active.
#   (This is setup for the default Input so let me know if you)
#
# - During your search the TAB key can change sorting method.
#
# - Have Fun
#
#===========================================================================
$imported = {} if $imported == nil
$imported["SSR-PartyManagement"] = true

#==============================================================================
# ** Sky::Party
#------------------------------------------------------------------------------
#==============================================================================
module Sky
  module Party
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#============================================================================== 
    ICONS = { # Currently serves no purpose!
      :weapon    => 2 ,
      :shield    => 52,
      :helmet    => 32,
      :armor     => 44,
      :accessory => 56,
    }
                
    MAX_MEMBERS   = 3
    TOTAL_MEMBERS = 99
    
    SUPPORT_OLD_LOCK = false
    
    SPRITE_RECT = Rect.new(0, 0, 32, 32)
#==============================================================================
#                           End Primary Customization
#------------------------------------------------------------------------------
#==============================================================================                 
  end
end

#==============================================================================
# ** Sky::Sprite
#------------------------------------------------------------------------------
#==============================================================================
module Sky
  module Sprite
    
    def self.get_actor_sprite_size(actor)
     	bitmap = Cache.character(actor.character_name)
	    sign = actor.character_name[/^[\!\$]./]
	    if sign != nil and sign.include?('$')
	      ch = bitmap.height / 4
	      cw = bitmap.width / 3
	    else
	      ch = bitmap.height / 8
	      cw = bitmap.width / 12
    	end
      bitmap.dispose
      return Rect.new(0, 0, cw, ch)
    end
    
  end  
end  
#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
# credit to Yanfly for almost everything following
#==============================================================================
class Game_Party < Game_Unit 
  
  #--------------------------------------------------------------------------
  # constants
  #--------------------------------------------------------------------------
  TOTAL_MEMBERS = Sky::Party::TOTAL_MEMBERS
  MAX_MEMBERS   = Sky::Party::MAX_MEMBERS
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :actors
  attr_accessor :battlers
  
  #--------------------------------------------------------------------------
  # alias method: members
  #--------------------------------------------------------------------------
  alias members_pss members unless $@
  def members ; return battle_members end
	
  #--------------------------------------------------------------------------
  # new method: battle_members
  #--------------------------------------------------------------------------
  def battle_members
	  if @battlers == nil
	    @battlers = Array.new(MAX_MEMBERS).map! { |ele| ele = 0}
	    for i in 0..([@actors.size, MAX_MEMBERS].min - 1)
    		@battlers[i] = @actors[i]
	    end
  	end  
	  result = []
	  for id in @battlers 
	    result.push($game_actors[id]) unless $game_actors[id] == nil
	  end
	  return result
  end
  
  def all_battle_members
    battle_members if @battlers == nil
    result = []
    for id in @battlers
      result.push($game_actors[id]) 
    end  
    return result
  end  
  #--------------------------------------------------------------------------
  # new method: party_members
  #--------------------------------------------------------------------------
  def party_members
  	result = []
  	for member in battle_members
  	  result.push(member)
  	end
  	for member in all_members
  	  result.push(member) unless result.include?(member) 
	  end
	  return result
  end
  
  #--------------------------------------------------------------------------
  # new method: all_members
  #--------------------------------------------------------------------------
  def all_members
    result = []
    @actors.each { |aid| result << $game_actors[aid] if aid > 0}
    return result
  end
  
  def battle_party_size ; return MAX_MEMBERS end
  
  def add_actor(actor_id)
	  if @actors.size < TOTAL_MEMBERS and !@actors.include?(actor_id)
	    @actors.push(actor_id)
	    $game_player.refresh
	  end
  end
  
  #--------------------------------------------------------------------------
  # new method: set_battlers
  #--------------------------------------------------------------------------
  def set_battlers(*args)
  	battle_members if @battlers == nil
    old_bats = @battlers.clone
    @battlers.clear
    bats = *args
    for i in 0...battle_party_size
      bat = old_bats[i]
      @battlers[i] = 0
      @battlers[i] = old_bats[bat] if @actors.include?(bat)
    end  
  	$game_player.refresh
  end
  
  def change_battler_at(index, aid)
    battle_members if @battlers == nil
    @battlers[index] = aid
  end  
  
  def get_empty_index
    for i in 0...battle_party_size
      return i if @battlers[i] == 0
    end  
    return nil
  end  
  #--------------------------------------------------------------------------
  # alias method: add_actor
  #--------------------------------------------------------------------------
  alias add_actor_pss add_actor unless $@
  def add_actor(actor_id)
    last_size = @actors.size
    add_actor_pss(actor_id)
	  if last_size < @actors.size
	    battle_members if @battlers == nil
	    for i in 0..(@battlers.size-1)
	    	if @battlers[i] == 0
	    	  @battlers[i] = actor_id unless battle_members.size == battle_party_size
		      break
		    end
	    end
	  end
  end
  
  #--------------------------------------------------------------------------
  # alias method: remove_actor
  #--------------------------------------------------------------------------
  alias remove_actor_pss remove_actor unless $@
  def remove_actor(actor_id)
  	battle_members if @battlers == nil
  	@battlers[@battlers.index(actor_id)] = 0 if @battlers.include?(actor_id)
  	remove_actor_pss(actor_id)
  end
  
  def battle_members_full?
    return battle_members.compact.size >= battle_party_size
  end
  
end # Game_Party

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#==============================================================================
class Game_Actor
  
  attr_accessor :party_lock
  
  alias setup_ssr setup unless $@
  def setup(actor_id)
	  @party_lock = false
  	setup_ssr(actor_id)
  end
  
  if Sky::Party::SUPPORT_OLD_LOCK
    def lock ; return @party_lock end
    def lock=(val) ; @party_lock = val end
  end    
    
end # Game_Actor

#==============================================================================
# ** Window_Party
#------------------------------------------------------------------------------
#==============================================================================
class Window_Party < Window_Selectable
  
  include Sky::Party
  
  attr_accessor :character_rect
  attr_accessor :fwrect
  
  def initialize(px, py)
    if SPRITE_RECT.nil?
   	  wrect = Sky::Sprite.get_actor_sprite_size($game_party.members[0]).dup
    else
      wrect = SPRITE_RECT.dup
    end  
    @character_rect = wrect.dup
    wrect.x = px ; wrect.y = py 
    wrect.width = (wrect.width * 2)+64 ; wrect.height = wrect.height + 10
    bparty_size = $game_party.battle_party_size
	  super(wrect.x, wrect.y, wrect.width, wrect.height * bparty_size + 56)
    @fwrect = wrect
    @actors = $game_party.battle_members
  	@item_max = bparty_size 
    self.index = 0
    @smindex = nil
  	refresh if init_refresh?
  end
  
  def init_refresh? ; return true end
  
  def current_actor ; return @actors[self.index] end
  
  def refresh
	  self.contents.clear
	  @actors = $game_party.all_battle_members 
	  @item_max = $game_party.battle_party_size
    create_contents
	  for i in 0...@item_max
	    draw_item(i)
	  end
  end
  
  def item_rect(index)
  	rect = Rect.new(0, 0, 0, 0)
  	rect.width = self.contents.width
  	rect.height = @character_rect.height + 10
  	rect.x = 0
  	rect.y = (rect.height + 4) * index
  	return rect
  end
  
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
	  actor = @actors[index]
    unless actor.nil?
	    aname  = actor.name
	    aclass = actor.class.name
	    alevel = actor.level
      ash = (rect.height-@character_rect.height)/2
      draw_actor_graphic(actor, rect.x+16, rect.y+@character_rect.height+ash)
      self.contents.font.size = 12 # 16
      self.contents.draw_text(rect.x,rect.y + 2 ,rect.width-4,14,aname,2)
      self.contents.draw_text(rect.x,rect.y + 14,rect.width-4,14,aclass,2)
      self.contents.draw_text(rect.x,rect.y + 26,rect.width-4,14,"LV" + alevel.to_s,2)
    end
  end

  #--------------------------------------------------------------------------
  # * Draw Actor Walking Graphic
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y, enabled=true)
    draw_character(actor.character_name, actor.character_index, x, y, enabled)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Character Graphic
  #     character_name  : Character graphic filename
  #     character_index : Character graphic index
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y, enabled=true)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect, enabled ? 255 : 128)
  end
  
end

#==============================================================================
# ** Window_MemberShift
#------------------------------------------------------------------------------
#==============================================================================
class Window_MemberShift < Window_Party
  
  def init_refresh? ; return false end
    
  def shift_member_index ; return @smindex end  
  def shift_member_index=(val) ; @smindex = val end
  
  def refresh
    self.height = @character_rect.height + 48
	  self.contents.clear
    @item_max = 1 ; create_contents
    rect = item_rect(0) ; self.contents.font.size = 24 # 16
    self.contents.draw_text(rect.x,rect.y+6,rect.width,28,"Empty",1)
    return if @smindex.nil?
	  @actors = [$game_party.all_battle_members[@smindex]] 
	  for i in 0...@item_max
	    draw_item(i)
	  end
  end
  
  def draw_item(*args)
    super(*args)
  end
  
end  

#==============================================================================
# ** Window_PartyReserve
#------------------------------------------------------------------------------
#==============================================================================
class Window_PartyReserve < Window_Party
  
  HEIGHT_PUSH = 72 #24
  def initialize(x, y)
	  super(x, y)
    self.height = @character_rect.height + HEIGHT_PUSH 
    @key = ""
  	@sort = "NAME"
  	@actors = []
	  @column_max = [@item_max,1].max
  end
  
  def init_refresh? ; return false end
    
  def refresh
	  self.contents.clear
	  @actors = []
    all_mems = $game_party.all_members
    bat_mems = $game_party.battle_members
	  unless @key.empty?
	    for i in 0...all_mems.size
        mem = all_mems[i]
        next if mem.nil?
	    	next if bat_mems.include?(mem)
        cond = ""
        case @sort.to_s.upcase
        when "NAME"
          cond = mem.name[0,@key.size].to_s.upcase
        when "CLASS"  
          cond = mem.class.name[0,@key.size].to_s.upcase
        when "LEVEL"  
          cond = mem.level.to_s[0,@key.size].to_s.upcase
        end  
        @actors.push(mem) if cond == @key.upcase
		  end
      @actors.push(nil)
	  else
      for i in 0...all_mems.size
        @actors.push(all_mems[i]) unless bat_mems.include?(all_mems[i])
      end
      @actors.push(nil)
    end
    @item_max = @actors.size
    @column_max = [@item_max,1].max
    create_contents
	  for i in 0...@item_max
  	  draw_item(i)
  	end
  end
  
  def key ; return @key end
  def key=(string) ; @key = string end
    
  def sort ; return @sort end
  def sort=(string) ; @sort = string end
  
  def get_actor_at(index) ; return @actors[index] end
  
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
	  actor = @actors[index]
    unless actor.nil?
	    aname  = actor.name
	    aclass = actor.class.name
	    alevel = actor.level
      ash = (rect.height-@character_rect.height)/2
	    locked = actor.party_lock 
      ch = @character_rect.height
      draw_actor_graphic(actor, rect.x+16, rect.y+@character_rect.height+ash+4, !locked)
	    self.contents.font.color.alpha = locked ? 128 : 255
	    self.contents.font.size = 12
	    self.contents.draw_text(rect.x+3,rect.y - 4,rect.width,24,aname)
	    self.contents.draw_text(rect.x,rect.y+18,rect.width-2,24,"Lv.",2)
	    self.contents.draw_text(rect.x,rect.y+28,rect.width-2,24,alevel,2)
	    self.contents.draw_text(rect.x,rect.y+17+ch,rect.width-3,24,aclass,2)
	  end
  end
  
  def item_rect(index)
  	rect = Rect.new(0, 0, 0, 0)
  	rect.width = @character_rect.width + 32
  	rect.height = @character_rect.height + (HEIGHT_PUSH-32)
  	rect.x = index * (rect.width + 10)
  	rect.y = 0
  	return rect
  end
  
end

#==============================================================================
# ** Window_ActorStat
#------------------------------------------------------------------------------
#==============================================================================
class Window_ActorStat < Window_Base
  
  include Sky::Party
  
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @actor = nil
    refresh
  end
  
  def change_actor(new_actor)
    if @actor != new_actor
      @actor = new_actor 
      refresh
    end  
  end
  
  def refresh
    self.contents.clear
    create_contents
    return if @actor == nil
    stats = ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi']
    stats2 =['eva', 'cri']
    stats2.unshift('res') if $imported["RES Stat"]
    stats2.unshift('dex') if $imported["DEX Stat"]
    def_size = self.contents.font.size
    self.contents.font.size = 18
    self.contents.draw_text(0, 0, self.contents.width, 24, @actor.name, 2)
    self.contents.font.size = def_size 
    draw_stats(0, 24, (self.contents.width/2)-32, stats)
    draw_stats(self.contents.width/2, 24, (self.contents.width/2)-32, stats2)
    draw_equipment(0, 24*8, 0)
  end
  
  def draw_stats(x, y, width, stats)
    for i in 0...stats.size
      rect = Rect.new(x, y, width, 24)
      rect.y += (i*24)
      st = stats[i]
      vst = stats[i]
      vst = "hp_a" if stats[i] == 'maxhp'
      vst = "mp_a" if stats[i] == 'maxmp'
      if $imported["IconModuleLibrary"]
        case st.to_sym
        when :hp, :maxhp
          draw_icon(YEM::ICON[:basic_stats][:hp], rect.x, rect.y)
        when :mp, :maxmp
          draw_icon(YEM::ICON[:basic_stats][:mp], rect.x, rect.y)
        else  
          draw_icon(YEM::ICON[:basic_stats][st.to_sym], rect.x, rect.y)
        end  
        rect.x += 24
        rect.width -= 24
      end
          
      def_size = self.contents.font.size
      
      self.contents.font.color = system_color
      self.contents.font.size = 18
      self.contents.draw_text(rect.x, rect.y, rect.width, rect.height-2, 
        eval("Vocab.#{vst}"))
        
      self.contents.font.color = normal_color
      self.contents.font.size = 16
      self.contents.draw_text(rect.x, rect.y, rect.width, rect.height-4, 
        eval("@actor.#{st}"), 2)
      self.contents.font.size = def_size 
    end
  end
  
  def draw_equipment(x, y, mode)
    case mode
    when 0
      coun = 0
      for eq in @actor.equips
        def_size = self.contents.font.size
        self.contents.font.size = 18
        draw_item_name(eq, x, y+(24*coun))
        coun += 1
        self.contents.font.size = def_size
      end  
    when 1
      linelimit = (self.contents.width-4)/24
      coun = 0
      for eq in @actor.equips
        rect = Rect.new(x, y, 0, 0)
        rect.x += 24*(coun % linelimit)
        rect.y += 24*(coun/linelimit)
        coun += 1
        next if eq == nil
        draw_icon(eq.icon_index, rect.x, rect.y)
      end  
    end  
  end
  
end

#==============================================================================
# ** Scene_Party
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Party < Scene_Base
  
  def initialize
    super()
  end
  
  def start
    super()
    create_menu_background
    @windows = {}
    # ------------------------------------------------------------------------ #
  	@windows["Reserve"] = Window_PartyReserve.new(0, 0)
    @windows["Reserve"].width = Graphics.width
    @windows["Reserve"].refresh
    # ------------------------------------------------------------------------ #
    @windows["Party"]   = Window_Party.new(0, @windows["Reserve"].height)
    # ------------------------------------------------------------------------ #
  	@windows["Stats1"]  = Window_ActorStat.new(
       @windows["Party"].width,  @windows["Reserve"].height, 
      (Graphics.width - @windows["Party"].width) / 2,
      Graphics.height - @windows["Reserve"].height)
    # ------------------------------------------------------------------------ #  
  	@windows["Stats2"]  = Window_ActorStat.new(
      @windows["Stats1"].x+@windows["Stats1"].width, @windows["Reserve"].height,
      @windows["Stats1"].width, @windows["Stats1"].height)
    # ------------------------------------------------------------------------ #  
    @windows["Question"] = Window_Base.new(
      @windows["Party"].width,  @windows["Reserve"].height,
      340, 56)
    # ------------------------------------------------------------------------ #   
    @windows["Command"] = Window_Command.new(128, ["Switch", "Add", "Remove", "Shift"])
    @windows["Command"].x = @windows["Party"].width
    @windows["Command"].y = @windows["Reserve"].height+@windows["Question"].height
    
    # ------------------------------------------------------------------------ #
    @windows["Shift"]   = Window_MemberShift.new(0,0)#(@windows["Party"].width, 
      #@windows["Reserve"].height)
    @windows["Shift"].refresh
    # ------------------------------------------------------------------------ #
    @windows["Party"].active    = true
    @windows["Reserve"].active  = false 
    @windows["Stats1"].active   = false
    @windows["Stats2"].active   = false
    @windows["Question"].active = false
    @windows["Command"].active  = false
    @windows["Shift"].active    = false
    # ------------------------------------------------------------------------ #
    @windows["Question"].width  = 0
    @windows["Command"].height  = 0
    @windows["Shift"].width     = 0
    # ------------------------------------------------------------------------ #
    @shift_mode = false
    @shifting = false
  end
  
  def terminate
    super()
	  for win in @windows.values
      win.dispose unless win.nil?
    end  
    dispose_menu_background
  end  
  
  def return_scene
    $scene = Scene_Map.new
  end
  
  def update
    super()
	  for win in @windows.values
      next if win.nil?
      next unless win.active
      win.update 
    end
    @windows["Stats1"].change_actor(@windows["Party"].current_actor)
    @windows["Stats2"].change_actor(@windows["Reserve"].current_actor)
    update_user_input
  end
  
  def update_party_accept
    if @shift_mode
      if @shifting
        @party_op = "SHIFT"
        perform_operation
        @windows["Shift"].shift_member_index=nil
        @windows["Shift"].refresh
        @party_op = ""
        @shifting = false
      else  
        @windows["Shift"].shift_member_index=@windows["Party"].index
        @windows["Shift"].refresh
        @shifting = true
        Sound.play_equip
      end  
    else  
      Sound.play_decision
      @windows["Party"].active    = false
      @windows["Command"].active  = true
      open_addswi_window
    end 
  end
  
  def update_command_accept
    cant_go = true
    @party_op = ""
    case @windows["Command"].index
    when 0
      cant_go = @windows["Reserve"].current_actor.nil?
      @party_op = "SWITCH"
    when 1
      cant_go = ($game_party.battle_members_full? or @windows["Reserve"].current_actor.nil?)
      @party_op = "ADD"
    when 2
      cant_go = $game_party.battle_members.compact.size <= 1
      @party_op = "REMOVE"
    when 3
      @shift_mode = true
      Sound.play_decision
      @windows["Party"].active    = true
      @windows["Command"].active  = false
      @windows["Shift"].shift_member_index=nil
      close_addswi_window
      push_over_reserve(@windows["Shift"].fwrect.width)
      @windows["Reserve"].x = @windows["Shift"].fwrect.width
      open_shift_win
      @windows["Shift"].refresh
      @party_op = "PRESHIFT"
      cant_go = false
    end  
    unless cant_go
      if @party_op == "REMOVE"
        Sound.play_decision
        perform_operation
      elsif @party_op == "PRESHIFT"  
      else  
        Sound.play_decision
        @windows["Command"].active = false
        @windows["Reserve"].active = true
        close_addswi_window
      end  
    else
      Sound.play_buzzer
    end 
  end
  
  def update_user_input
    if Input.trigger?(Input::C)
      if @windows["Party"].active
        update_party_accept 
      elsif @windows["Command"].active
        update_command_accept 
      elsif @windows["Reserve"].active  
        Sound.play_decision
        perform_operation
      end  
    elsif Input.trigger?(Input::B)  
      if @windows["Party"].active
        if @shift_mode
          Sound.play_cancel
          @shift_mode = false
          @shifting = false
          @windows["Party"].active    = false
          @windows["Command"].active  = true
          @windows["Shift"].shift_member_index=nil
          @windows["Shift"].refresh
          close_shift_win
          push_over_reserve(-@windows["Shift"].fwrect.width)
          @windows["Reserve"].x = 0
          open_addswi_window
          refresh_commands
          return
        else  
          Sound.play_cancel
          return_scene 
        end  
      elsif @windows["Command"].active
        Sound.play_cancel
        @windows["Command"].active  = false
        @windows["Party"].active    = true
        close_addswi_window
      elsif @windows["Reserve"].active  
        Sound.play_cancel
        @windows["Reserve"].active  = false
        @windows["Command"].active  = true
        open_addswi_window
      end
    end  
  end
  
  def can_add_new_actor?
    return !($game_party.battle_members_full? or @windows["Reserve"].current_actor.nil?)
  end
  
  def can_switch_actor?
    return !(@windows["Reserve"].current_actor.nil? && $game_party.battle_members.compact.size <= 1)
  end
  
  def can_remove_actor?
    return !($game_party.battle_members.compact.size <= 1 or @windows["Party"].current_actor.nil?)
  end
  
  def perform_operation
    pindex = @windows["Party"].index
    rindex = @windows["Reserve"].index
    sindex = @windows["Shift"].shift_member_index
    raid = @windows["Reserve"].current_actor
    paid = @windows["Party"].current_actor
    said = @windows["Shift"].current_actor
    raid = raid.nil? ? 0 : raid.id
    paid = paid.nil? ? 0 : paid.id
    said = said.nil? ? 0 : said.id
    case @party_op.to_s.upcase 
    when "SWITCH" 
      if can_switch_actor?
        Sound.play_evasion
        $game_party.change_battler_at(pindex, raid)
      else  
        Sound.play_buzzer
        return  
      end  
    when "ADD"
      if can_add_new_actor?
        Sound.play_equip
        emindex = $game_party.get_empty_index
        $game_party.change_battler_at(emindex, raid)
      else 
        Sound.play_buzzer
        return
      end  
    when "REMOVE"
      unless $game_party.battle_members.compact.size <= 1
        Sound.play_actor_collapse
        $game_party.change_battler_at(pindex, 0)
      else  
        Sound.play_buzzer
        return   
      end 
    when "SHIFT"  
      unless sindex.nil?   
        Sound.play_evasion
        $game_party.change_battler_at(sindex, paid)
        $game_party.change_battler_at(pindex, said)
      else
        Sound.play_buzzer
        return 
      end  
    else ; return
    end  
    @windows["Reserve"].refresh
    @windows["Party"].refresh
    refresh_commands
    $game_player.refresh
  end
  
  def push_over_reserve(amt)
    loop do 
      Graphics.update
      @windows["Reserve"].x += amt/10
      if amt > 0
        break if @windows["Reserve"].x >= amt
      else
        break if @windows["Reserve"].x <= 0
      end  
    end  
  end
  
  def open_shift_win
    loop do 
      Graphics.update
      @windows["Shift"].width += @windows["Shift"].fwrect.width / 10
      break if @windows["Shift"].width >= @windows["Shift"].fwrect.width
    end  
    @windows["Shift"].width = @windows["Shift"].fwrect.width
  end
  
  def close_shift_win
    loop do 
      Graphics.update
      @windows["Shift"].width -= @windows["Shift"].fwrect.width / 10
      break if @windows["Shift"].width <= 0
    end  
    @windows["Shift"].width = 0
  end
  
  def open_addswi_window
    loop do
      Graphics.update
      unless @windows["Question"].width >= 340
        @windows["Question"].width  += 340/10 
      end 
      if @windows["Question"].width >= 340/2
        @windows["Command"].height += ((@windows["Command"].commands.size*24)+32)/5
      end  
      break if @windows["Question"].width >= 340
    end  
    @windows["Command"].height = ((@windows["Command"].commands.size*24)+32).to_i
    refresh_commands
    @windows["Question"].width = 340
    @windows["Question"].contents.clear
    @windows["Question"].contents.draw_text(0, 0, 340-32, 24, "What to do?")
  end
  
  def close_addswi_window
    loop do
      Graphics.update
      unless @windows["Question"].width == 0
        @windows["Question"].width  -= 340/10 
      end 
      if @windows["Question"].width <= 340/2 and @windows["Question"].width > 0
        @windows["Command"].height -= ((@windows["Command"].commands.size*24)+32)/5
      end  
      break if @windows["Question"].width <= 0
    end 
    @windows["Question"].width = 0
    @windows["Command"].height = 0
  end
  
  def refresh_commands
    @windows["Command"].refresh
    @windows["Command"].draw_item(0,false) unless can_switch_actor?
    @windows["Command"].draw_item(1,false) unless can_add_new_actor?
    @windows["Command"].draw_item(2,false) unless can_remove_actor?
  end
  
end


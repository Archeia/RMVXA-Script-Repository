$imported = {} if $imported.nil?
$imported["EST SUIKODEN FORMATION"] = true
=begin
 ** EST - SUIKODEN FORMATION v 1.1 
 author : estriole
 licences:
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
 
 version history
 v 1.1 -> add patch if not using yanfly ace menu engine script.
 v 1.0 -> initial release

 basicly this script change the yanfly formation to party (since it's set
 the party members in battle). set the max battle members to 6. then disable
 the variable that can change the max battle members ingame.
 then create new command in menu named formation which is the real formation
 the real formation will set the placement of the party members in battle
  
 requirement :
 have the script in this following order for the best result:
  yanfly party system 1.08
  victor basic module 1.17
  victor animated battle 1.04
  victor actor battler 1.05

  yanfly ace battle engine 1.22
  yanfly enemy hp bar 1.10
  yanfly ace menu engine 1.07
  yanfly attack replace 1.01
  yea compatibility patch 1.0
  EST- Victor Battle Patch 1.0 (or higher)
  ve - custom action (optional)
  
  EST - ENEMY POSITION 1.7 (or higher)
  EST - PERMANENT STATE 1.0 (or higher)
  EST - BATTLESTART ADD STATE 1.0 (or higher)
  this script (EST - SUIKODEN FORMATION 1.1)
 

=end
module YEA
  module PARTY
    MAX_BATTLE_MEMBERS   = 6      # set Maximum party member to 6
    MAX_MEMBERS_VARIABLE = 0      # disable variable to change max members
  end
end

module ESTRIOLE
  #--------------------------------------------------------------------------
  #   YEA Ace Menu Engine - Custom Menu Command Setting
  #--------------------------------------------------------------------------
  # This setting only takes effect when YEA - Ace Menu Engine is installed
  # in the same project.
  #
  # To add the Formation scene to Ace Menu Engine, look for a 
  # configuration setting called "- Main Menu Settings -". There is a
  # variable called COMMANDS that has an array of orange symbols. Add
  # the symbol :est_formation to the COMMANDS array to add the crafting
  # command to your menu. not needed anymore. will auto added to below party command
  # (old formation command)
  #
  # The setting here working exactly the same as the CUSTOM_COMMAND
  # setting in Ace Menu Engine. For more information, please refer to
  # the Ace Menu Engine script.
  EST_FORMATION_CUSTOM_COMMAND = {
  #             ["Display Name", EnableSwitch, ShowSwitch,      Handler Method],
    :est_formation => [  "Formation",           0,          0, :command_est_formation],
  } # <- Do not delete.
  ###############################################################################
end

if $imported["YEA-AceMenuEngine"]
YEA::MENU::CUSTOM_COMMANDS.merge!(ESTRIOLE::EST_FORMATION_CUSTOM_COMMAND)
index, target = nil
for i in 0..YEA::MENU::COMMANDS.size-1
 index = i if YEA::MENU::COMMANDS[i] == :formation
end
target = index - YEA::MENU::COMMANDS.size if index !=nil
YEA::MENU::COMMANDS.insert(target,:est_formation) if target!=nil
YEA::MENU::COMMANDS.insert(-1,:est_formation)if target==nil

#==============================================================================
# ++ Scene_Menu
#==============================================================================

end # if $imported["YEA-AceMenuEngine"]

class Window_MenuCommand < Window_Command
  def add_formation_command
    add_command("Party", :formation, formation_enabled)
    return unless !$imported["YEA-AceMenuEngine"]
    add_command("Formation", :est_formation, formation_enabled)
  end
end

class Scene_Menu < Scene_MenuBase
  alias est_formation_changer_create_command_window create_command_window
  def create_command_window
    est_formation_changer_create_command_window
    return unless !$imported["YEA-AceMenuEngine"]
    @command_window.set_handler(:est_formation, method(:command_est_formation))
  end
  def command_est_formation
    SceneManager.call(Scene_Formation)
  end
end

class Game_Party < Game_Unit
  def swap_form (index1, index2)
  temp = @battle_members_array[index1]  
  @battle_members_array[index1] = @battle_members_array[index2]  
  @battle_members_array[index2] = temp
  end  
  def rearrange_form(array)
    for i in 0..array.size-1
    @actors[i] = array[i]
    end
    $game_player.refresh
  end
end

class Scene_Formation < Scene_MenuBase
  def start
    super
    create_status_window
  end
  def create_status_window
    @status_window = Window_Formation.new(100, 0)
    @status_window.select_last
    @status_window.activate
    @status_window.set_handler(:ok,     method(:on_formation_ok))
    @status_window.set_handler(:cancel, method(:on_formation_cancel))
  end
  
  def on_formation_ok
    if @status_window.pending_index >= 0
      $game_party.swap_form(@status_window.index,
                             @status_window.pending_index)
      formlist = $game_party.battle_members_array - [0]                      
      $game_party.rearrange_form(formlist)
      #$game_party.swap_order(@status_window.index,
      #                       @status_window.pending_index)
      @status_window.pending_index = -1
      @status_window.redraw_item(@status_window.index)
    else
      @status_window.pending_index = @status_window.index
    end
    @status_window.activate
  end
  def on_formation_cancel
    if @status_window.pending_index >= 0
      @status_window.pending_index = -1
      @status_window.activate
    else
      @status_window.unselect
      SceneManager.return
    end
  end
end

class Window_Formation < Window_Selectable
  attr_reader   :pending_index            # 保留位置（並び替え用）
  def initialize(x, y)
    super(x - ((col_max-3)*100/2), y, col_max * 100 + 11 + (col_max*11), 190*2+30)
    @pending_index = -1
    refresh
    @actor = nil
  end
    
  def col_max
  return 3
  end
  
  def item_max
    return 6#$game_party.battle_members.size
  end
  def spacing
    return 10
  end
  
  def item_width
  return 100
  end
  #--------------------------------------------------------------------------
  # ● 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
  return 190
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def getrange(actor)
    attack_skill = $data_skills[actor.attack_skill_id]
    attack_range = attack_skill.scope
    case attack_range
    when 81; return 'B' #back row > ???
    when 82; return 'F' #front row > ???
    when 83; return '★B' #front row > ???
    when 84; return '★F' #front row > ???
    when 85; return 'Z' #flying row > ???
    when 86; return '★Z' #allflying row > ???
    when 87; return 'W' #underwater row > ???
    when 88; return '★W' #allunderwater row > ???
    when 89; return 'G' #underground row > ???
    when 90; return '★G' #allunderground row > ???
    when 91; return 'E' #either row > spears
    when 92; return '★E' #either row > spears
    when 97; return 'S' #short range > knuckles
    when 98; return 'M' #mid range > swords
    when 99; return 'L' #long range > guns
    when 100; return '★S' #short range > knuckles
    when 101; return '★M' #mid range > swords
    when 102; return '★L' #long range > guns
    when 1; return 'A' #all target > magic
    when 2; return '★A' #all target > magic
    else
    return '?' #all pos
    end
  end
  
  def draw_item(index)
    actor = $game_actors[$game_party.battle_members_array[index]]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index) if actor != nil
    draw_actor_face(actor, rect.x + 1, rect.y + 1, enabled) if actor != nil
#    draw_actor_simple_status(actor, rect.x + 108, rect.y + line_height / 2)
    if actor != nil
    statx = rect.x + 1
    staty = rect.y + 83 + line_height / 2
    draw_actor_name(actor, statx, staty)  
    
    contents.font.size = 22 if $imported["YEA-AdjustLimits"] == true
    draw_actor_level(actor, statx +43, staty + line_height * 1 + 2)
    reset_font_settings if $imported["YEA-AdjustLimits"] == true
    
    draw_icon(116, statx + 1, staty + line_height * 1, enabled)
    range = getrange(actor)
    draw_text(statx + 24, staty + line_height * 1, 20, line_height, range)    
    draw_current_and_max_values(statx, staty + line_height * 2, rect.width-4, actor.hp, actor.mhp,
                                    hp_color(actor), normal_color)   
    draw_current_and_max_values(statx, staty + line_height * 3 , rect.width-4, actor.mp, actor.mmp,
                                    mp_color(actor), normal_color)   
    end
  end
  def draw_actor_name(actor, x, y, width = 100)
    change_color(hp_color(actor))
    draw_text(x, y, width, line_height, actor.name)
  end  
  #--------------------------------------------------------------------------
  # ● 項目の背景を描画
  #--------------------------------------------------------------------------
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    super
    $game_party.menu_actor = $game_party.battle_members[index] if $game_party.battle_members[index] != nil
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select($game_party.menu_actor.index || 0)
  end
  #--------------------------------------------------------------------------
  # ● 保留位置（並び替え用）の設定
  #--------------------------------------------------------------------------
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
end
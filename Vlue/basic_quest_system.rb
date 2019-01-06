#Basic Quest System v1.3f
#----------#
#Features: Quests! What more can you say.
#
#Usage:   Set up your quests and away you go!
#        Script calls:
#         accept_quest(:questid)     - force quest accept
#         ask_accept(:questid)       - open quest acceptance window
#         abandon_quest(:questid)    - force quest abandon
#         turnin_quest(:questid)     - force quest turnin
#         fail_quest(:questid)       - force abandon with ME
#         ask_turnin(:questid)       - open quest complete window
#
#       adv_obj(:questid, :objectiveid, value)   - changes obj by value
#       set_obj(:questid, :objectiveid, value)   - sets obj to value
#       obj(:questid, :objectiveid)              - gets obj value
#       hide_obj(:questid, :objectiveid)         - hides objective
#       show_obj(:questid, :objectiveid)         - shows objective
#
#     $game_quests[:questid].accepted?     - true if quest is accepted
#     $game_quests[:questid].completed?    - true if quest is completed
#     $game_quests[:questid].turned_in?     - true if quest is turned in
#
# Examples:
#  The obj function can be used in conditional branches to check progress
#   of certain objectives. Example.
#    #Checking if :obj3 of :quest89 is greater than 3:
#     obj(:quest89, :obj3) > 3
#
#~ #----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#Visibility of quest log on map
$questlogvisibility = true
#Maximum # of quests displayed on the quest log overlay
$questlogmaxdisplay = 5
#Quest log position, 1 - top-left, 2 - top-right
QUEST_LOG_POSITION = 2
#Quest log offsets
QUEST_LOG_OFFSET_X = 0
QUEST_LOG_OFFSET_Y = 0
 
# Quest Format and set up!
 
# DETAILS[:quest_id] = {
#   :name => "quest name"     #Quest name
#   :level => value           #Arbitrary value (Optional)
#   :difficulty => "string"   #Arbitrary string (Optional)
#   :auto_complete => true    #Recieve rewards on the spot (Optional)
#   :abandonable => false     #Set's whether quest can be abandoned (Optional)
#   :force_accept => true     #ask_accept only allows accepting (Optional)
#   :force_turnin => true     #ask_turnin only allows completing (Optional)
#  }
# DESCRIPTIONS[:quest_id] = {
#   :qgiver_name => "string"  #Quest giver name (shows in log) (Optional)
#   :location => "string"     #Quest giver location (shows in log) (Optional)
#   :desc => "string"         #Description of quest displayed in log (Optional)
#  }
# OBJECTIVES[:quest_id] = {   #Quest objectives, "string" is name, id is max value
#                             #   boolean is hidden objective (true for hidden)
#   :obj_id1 => ["string", id]
#   :obj_id2 => ["string", id, boolean],
#   etc...
#  }
# REWARDS[:quest_id] = {
#   :gold => value            #Gold recieved from quest (Optional)
#   :exp => value             #Exp recieved from quest (Optional)
#         #Items recieved from quest, :type is :item, :weapon, or :armor
#   :scale_exp => value       #Percent value to scale exp based on level vs party
#   :items => [[:type,id,value], ...]],    (Optional)
#  }
 
module QUEST
  DETAILS= {}
  DESCRIPTIONS = {}
  OBJECTIVES = {}
  REWARDS = {}
 
  #Main Quest 1
  DETAILS[:questid001] = {
    :name => "I need water!",
    :level => 1,
    :force_accept => true,
    :force_turnin => true,}
  DESCRIPTIONS[:questid001] = {
    :qgiver_name => "This Lady",
    :location => "This Place",
    :desc => " I'm thirsty, can you get me some water from the merchant?" }
  OBJECTIVES[:questid001] = {
    :obj1 => ["Get a canteen of water",1],
    :obj2 => ["Get another canteen of water",1,true]}
  REWARDS[:questid001] = {
#    :gold => 5,
#    :exp => 10,
    :scale_exp => 5,
    :items => [[:item,1,2]], }  
   
  #Main Quest 2
  DETAILS[:questid002] = {
    :name => "First Steps: Arkineer",
    :level => 2,}
  DESCRIPTIONS[:questid002] = {
    :qgiver_name => "Marshal Avalan",
    :location => "Class Town",
    :desc => " An Arkineer's job is to construct
as much as it is to fight. To do
that, requires materials though.
Head to the Forest Encampment and
see what the situation is." }
  OBJECTIVES[:questid002] = {
    :obj1 => ["Head to the Forest Camp",1] }
  REWARDS[:questid002] = {}
  
    #Main Quest 2
  DETAILS[:questid003] = {
    :name => "First Steps: Arkineer",
    :level => 2,}
  DESCRIPTIONS[:questid003] = {
    :qgiver_name => "Marshal Avalan",
    :location => "Class Town",
    :desc => " An Arkineer's job is to construct
as much as it is to fight. To do
that, requires materials though.
Head to the Forest Encampment and
see what the situation is." }
  OBJECTIVES[:questid003] = {
    :obj1 => ["Head to the Forest Camp",1] }
  REWARDS[:questid003] = {}
 
  #Side Quest
  DETAILS[:sidequest001] = {
    :name => "Fibers for M'Lana",
    :level => 3,}
  DESCRIPTIONS[:sidequest001] = {
    :qgiver_name => "M'Lana Lee",
    :location => "Class Town",
    :desc => " You're not sure what M'Lana
wants with the plant fibres, but at
least she's isn't telling you to
leave anymore. Better do as she
says and collect them from beasts
around the Forest Camp." }
  OBJECTIVES[:sidequest001] = {
    :obj1 => ["Collect 10 plant fibres",10] }
  REWARDS[:sidequest001] = {
    :gold => 20,
    :exp => 25,
    :items => [[:armor,89,1]], }
 
end
 
class Game_Quests
  attr_accessor :reset_hash
  def initialize
    @quests = {}
    QUEST::DETAILS.each do |id, quest|
      @quests[id] = Quest.new(id,quest)
    end
    @reset_hash = {}
    @quests.each_value do |quest|
      @reset_hash[quest.id] = {}
      @reset_hash[quest.id][:accepted] = false
      @reset_hash[quest.id][:turnedin] = false
      quest.objectives.each do |id, obj|
        @reset_hash[quest.id][id] = obj
      end
    end
  end
  def check_quests
    @quests.each do |id, quest|
      if !$game_party.quests[id]
        $game_party.quests[id] = {}
        quest.reset
      end
    end
  end
  def [](quest_id)
    return msgbox("No Quest with id " + quest_id.to_s) if @quests[quest_id].nil?
    @quests[quest_id]
  end
  def []=(quest_id, val)
    @quests[quest_id] = val
  end
  def quests
    @quests
  end
  def no_quests?
    @quests.each do |id, quest|
      return false if quest.accepted? && !quest.turned_in
    end
    return true
  end
  def tracking?
    $game_party.tracking
  end
  def track_quest(id)
    return if $game_party.tracking.include?(id)
    $game_party.tracking.push(id)
    if $game_party.tracking.size > $questlogmaxdisplay = 5
      $game_party.tracking.reverse!.pop
      $game_party.tracking.reverse!
    end
  end
  def untrack_quest(id)
    return unless $game_party.tracking.include?(id)
    $game_party.tracking.delete(id)
    $game_party.tracking.compact!
  end
end
 
class Quest
  attr_accessor :name
  attr_accessor :level
  attr_accessor :id
  attr_accessor :desc
  attr_accessor :objectives
  attr_accessor :turned_in
  attr_accessor :difficulty
  attr_accessor :qgiver_name
  attr_accessor :location
  attr_accessor :auto_complete
  attr_accessor :abandonable
  attr_accessor :force_accept
  attr_accessor :force_turnin
  def initialize(id,quest_hash)
    @id = id
    @level = 0
    @difficulty = 0
    @name = "No Quest Name"
    @desc = ""
    @qgiver_name = 0
    @location = 0
    @auto_complete = false
    @abandonable = true
    @need_popup = false
    @force_turnin = false
    @force_accept = false
    @name = quest_hash[:name] if quest_hash[:name]
    @level = quest_hash[:level] if quest_hash[:level]
    @force_accept = quest_hash[:force_accept] if quest_hash[:force_accept]
    @force_turnin = quest_hash[:force_turnin] if quest_hash[:force_turnin]
    @difficulty = quest_hash[:difficulty] if quest_hash[:difficulty]
    @auto_complete = quest_hash[:auto_complete] if quest_hash[:auto_complete]
    @abandonable = quest_hash[:abandonable] if !quest_hash[:abandonable].nil?
    @desc = QUEST::DESCRIPTIONS[id][:desc] if QUEST::DESCRIPTIONS[id][:desc]
    @qgiver_name = QUEST::DESCRIPTIONS[id][:qgiver_name] if QUEST::DESCRIPTIONS[id][:qgiver_name]
    @location = QUEST::DESCRIPTIONS[id][:location] if QUEST::DESCRIPTIONS[id][:location]
    @objectives = {}
    if QUEST::OBJECTIVES[id]
      QUEST::OBJECTIVES[id].each do |id, obj|
        @objectives[id] = Objective.new(id, obj)
      end
    else
      msgbox("Quest " + id.to_s + " has no objectives.")
    end
    @reward_gold = 0
    @reward_exp = 0
    @scale_exp = 0
    @reward_items = []
    begin
      if QUEST::REWARDS[id][:gold]
        @reward_gold = QUEST::REWARDS[id][:gold]
      end
      if QUEST::REWARDS[id][:exp]
        @reward_exp = QUEST::REWARDS[id][:exp]
        @scale_exp = QUEST::REWARDS[id][:scale_exp] if QUEST::REWARDS[id][:scale_exp]
      end
      if QUEST::REWARDS[id][:items]
        @reward_items = QUEST::REWARDS[id][:items]
      end
    rescue
      msgbox(id.to_s + " has no defined REWARDS. This is not optional.")
    end
  end
  def accept
    reset
    $game_party.quests[id][:accepted] = true
    track_quest
    $game_map.need_refresh = true
    Audio.se_play("Audio/SE/Book2")
  end
  def abandon
    reset
    $game_party.quests[id][:accepted] = false
  end
  def fail
    Audio.me_play("Audio/ME/Gag")
    abandon
  end
  def accepted?
    $game_party.quests[id][:accepted]
  end
  def accepted
    accepted?
  end
  def completed?
    @objectives.each do |id, obj|
      return false if !$game_party.quests[@id][id].completed?
    end
    return true
  end
  def force_done
    $game_party.quests[id][:accepted] = true
    @objectives.each do |id, obj|
      $game_party.quests[@id][id].current = obj.max
    end
    turnin
  end
  def reset
    $game_party.quests[id][:accepted] = false
    @objectives.each do |id, obj|
      $game_party.quests[@id][id] = obj
      $game_party.quests[@id][id].current = 0
    end
    $game_party.quests[id][:turnedin] = false
  end
  def objective(id)
    return Objective.new(id, ["No Objective Found",0]) if @objectives[id].nil?
    $game_party.quests[@id][id]
  end
  def set_obj(id, value)
    objective(id).current = value
    @need_popup = false if !completed?
    popup if completed? && !@need_popup
    turnin if completed? && @auto_complete
    $game_map.need_refresh = true
  end
  def adv_obj(id, value)
    objective(id).current += value
    @need_popup = false if !completed?
    popup if completed? && !@need_popup
    turnin if completed? && @auto_complete
    $game_map.need_refresh = true
  end
  def reward_gold
    @reward_gold
  end
  def reward_exp
    get_mod_exp.to_i
  end
  def reward_items
    @reward_items
  end
  def turnin
    $game_party.quests[id][:turnedin] = true
    untrack_quest
    $game_map.need_refresh = true
    $game_party.gain_gold(@reward_gold)
    $game_party.members.each do |actor|
      actor.gain_exp(@reward_exp)
    end
    @reward_items.each do |array|
      item = $data_items[array[1]] if array[0] == :item
      item = $data_weapons[array[1]] if array[0] == :weapon
      item = $data_armors[array[1]] if array[0] == :armor
      $game_party.gain_item(item, array[2])
    end
  end
  def track_quest
    $game_quests.track_quest(@id)
  end
  def untrack_quest
    $game_quests.untrack_quest(@id)
  end
  def can_abandon?
    @abandonable
  end
  def popup
    @need_popup = true
    Audio.me_play("Audio/ME/Item")
    if Module.const_defined?(:Popup)
      Popup.add([@name + ' complete!'])
    end
  end
  def turned_in?
    $game_party.quests[id][:turnedin]
  end
  def turned_in
    turned_in?
  end
  def active?
    accepted? && !completed?
  end
  def get_mod_exp
    pval = @scale_exp * (@level - $game_party.highest_level).to_f / 100 + 1
    @reward_exp * pval
  end
end
 
class Objective
  attr_accessor :id
  attr_accessor :name
  attr_accessor :current
  attr_accessor :max
  attr_accessor :hidden
  def initialize(id, obj)
    @name = obj[0]
    @current = 0
    @max = obj[1]
    @hidden = obj[2] ? obj[2] : false
  end
  def completed?
    @current >= @max
  end
end
 
module DataManager
  class << self
    alias quest_cgo load_database
    alias quest_sng setup_new_game
  end
  def self.load_database
    quest_cgo
    $game_quests = Game_Quests.new
  end
  def self.setup_new_game
    $game_quests = Game_Quests.new
    quest_sng
  end
end
 
class Scene_Quest < Scene_MenuBase
  def start
    super
    @help_window = Window_Help.new(1)
    @help_window.set_text("Quest Log")
    @list_window = Window_SceneList.new
    @list_window.set_handler(:cancel, method(:list_cancel))
    @list_window.set_handler(:ok, method(:list_ok))
    @list_window.refresh
    @list_window.activate
    @list_window.select(0)
    @detail_window = Window_SceneDetail.new
    @command_window = Window_QuestTrack.new
    @command_window.x = Graphics.width / 2 - @command_window.width / 2
    @command_window.y = Graphics.height / 2 - @command_window.height / 2
    @command_window.set_handler(:track, method(:track))
    @command_window.set_handler(:untrack, method(:untrack))
    @command_window.set_handler(:abandon, method(:abandon))
    @command_window.set_handler(:cancel, method(:command_cancel))
  end
  def update
    super
    @detail_window.quest = @list_window.current_item
  end
  def list_cancel
    SceneManager.return
  end
  def list_ok
    @command_window.quest(@list_window.current_item)
    @command_window.refresh
    @command_window.select(0)
    @command_window.activate
    @command_window.open
  end
  def track
    $game_quests.track_quest(@list_window.current_item.id)
    command_cancel
  end
  def untrack
    $game_quests.untrack_quest(@list_window.current_item.id)
    command_cancel
  end
  def abandon
    @list_window.current_item.abandon
    command_cancel
  end
  def command_cancel
    @command_window.close
    @list_window.refresh
    @list_window.activate
    list_cancel if $game_quests.no_quests?
  end
end
 
class Window_SceneList < Window_Selectable
  def initialize
    super(0,48,Graphics.width/5*2,Graphics.height-48)
    refresh
  end
  def make_item_list
    @data = []
    $game_quests.quests.each do |id, quest|
      @data.push(quest) if quest.accepted? && !quest.turned_in?
    end
    @data.push(nil) if @data.empty?
  end
  def draw_item(index)
    contents.font.size = 18
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      if $game_quests.tracking?.include?(item.id)
        text = "*" + item.name
      else
        text = item.name
      end
      draw_text(rect, text)
      draw_text(rect, "Lv" + item.level.to_s,2) if item.level > 0
    end
  end
  def col_max; 1; end
  def current_item
    @data[@index]
  end
  def current_item_enabled?
    true
  end
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  def item_max
    @data ? @data.size : 0
  end
end
 
class Window_SceneDetail < Window_Base
  def initialize
    super(Graphics.width/5*2,48,Graphics.width-Graphics.width/5*2,Graphics.height-48)
  end
  def quest=(quest)
    return if @quest == quest
    @quest = quest
    refresh
  end
  def refresh
    contents.clear
    return unless @quest
    contents.font.size = 18
    change_color(system_color)
    draw_text(0,0,contents.width,line_height,@quest.qgiver_name) if @quest.qgiver_name != 0
    draw_text(0,0,contents.width,line_height,@quest.location,2) if @quest.location != 0
    change_color(normal_color)
    @quest.qgiver_name != 0 || @quest.location != 0 ? yy = line_height : yy = 0
    draw_text_ex(0,yy,@quest.desc)
    change_color(system_color)
    draw_text(0,line_height*7,contents.width,24,"Objectives:")
    change_color(normal_color)
    yy = line_height * 8
    @quest.objectives.each do |id, obj|
      next if obj.hidden
      draw_objective(yy, obj)
      yy += 24
    end
    change_color(system_color)
    draw_text(0,yy,contents.width,line_height,"Rewards:")
    yy += line_height
    if @quest.reward_exp > 0
      draw_text(6,yy,contents.width/2,line_height,"XP: ")
      change_color(normal_color)
      draw_text(36,yy,contents.width/2,line_height,@quest.reward_exp)
      yy += line_height
    end
    if @quest.reward_gold > 0
      change_color(normal_color)
      draw_text(6,yy,contents.width/2,line_height,@quest.reward_gold.to_s)
      cx = text_size(@quest.reward_gold).width
      change_color(system_color)
      draw_text(6+cx,yy,contents.width/2,line_height,Vocab::currency_unit)
    end
    yy += line_height
    change_color(normal_color)
    @quest.reward_items.each do |array|
      item = $data_items[array[1]] if array[0] == :item
      item = $data_weapons[array[1]] if array[0] == :weapon
      item = $data_armors[array[1]] if array[0] == :armor
      draw_item_name(item, 6, yy, true, contents.width)
      if array[2] > 1
        draw_text(6+text_size(item.name).width+36,yy,48,24,"x"+array[2].to_s)
      end
      yy += line_height
    end
    if @quest.difficulty != 0
      text = "Difficulty: " + @quest.difficulty
      draw_text(0,contents.height-line_height,contents.width,line_height,text,2)
    end
  end
  def draw_objective(yy, obj)
    draw_text(6,yy,contents.width,24,obj.name)
    draw_text(0,yy,contents.width,24,obj.current.to_s+"/"+obj.max.to_s,2)
  end
  def reset_font_settings
    change_color(normal_color)
    contents.font.bold = Font.default_bold
    contents.font.italic = Font.default_italic
  end
end
 
class Window_QuestTrack < Window_Command
  def initialize
    super(0,0)
    self.openness = 0
  end
  def quest(quest)
    @quest = quest
  end
  def make_command_list
    return unless @quest
    if !$game_quests.tracking?.include?(@quest.id)
      add_command("Track Quest", :track)
    else
      add_command("Untrack Quest", :untrack)
    end
    add_command("Abandon Quest", :abandon, @quest.can_abandon?)
  end
  def window_height
    fitting_height(2)
  end
end
 
class Window_MenuCommand
  alias quest_aoc add_original_commands
  def add_original_commands
    quest_aoc
    add_command("Quest Log", :quest, !$game_quests.no_quests?)
  end
end
 
class Scene_Menu
  alias quest_ccw create_command_window
  def create_command_window
    quest_ccw
    @command_window.set_handler(:quest,    method(:scene_quest))
  end
  def scene_quest
    SceneManager.call(Scene_Quest)
  end
end
 
class Scene_Map
  alias quest_start start
  alias quest_update update
  def start
    quest_start
    @quest_log = Window_QuestLog.new
    @quest_confirm = Window_QuestConfirm.new
    @quest_confirm.set_handler(:accept, method(:confirm_accept))
    @quest_confirm.set_handler(:decline, method(:confirm_cancel))
    @quest_confirm.set_handler(:cancel, method(:confirm_cancel))
    @quest_turnin = Window_QuestTurnin.new
    @quest_turnin.set_handler(:accept, method(:turnin_accept))
    @quest_turnin.set_handler(:decline, method(:confirm_cancel))
    @quest_turnin.set_handler(:cancel, method(:confirm_cancel))
    @quest_apply = Window_QuestApply.new(@quest_confirm,@quest_turnin)
  end
  def update(*args)
    @quest_log = Window_QuestLog.new if @quest_log.disposed?
    quest_update(*args)
  end
  def show_quest(id, turnin = false)
    @quest_apply.show($game_quests[id],turnin)
  end
  def accepting?
    @quest_confirm.active || @quest_turnin.active
  end
  def confirm_accept
    @quest_apply.accept
    @quest_apply.hide
  end
  def confirm_cancel
    @quest_apply.hide
  end
  def turnin_accept
    @quest_apply.turnin
    @quest_apply.hide
  end
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running? || accepting?
      @menu_calling = false
    else
      @menu_calling ||= Input.trigger?(:B)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
end
 
class Scene_Base
  def accepting?
    false
  end
end
 
class Window_QuestLog < Window_Base
  def initialize
    super(Graphics.width/5*3,0,Graphics.width/5*2,Graphics.height)
    self.x = 0 if QUEST_LOG_POSITION == 1
    self.x += QUEST_LOG_OFFSET_X
    self.y += QUEST_LOG_OFFSET_Y
    self.opacity = 0
    self.contents.font.size = 18
  end
  def update
    super
    return unless Graphics.frame_count % 20 == 0
    self.visible = $questlogvisibility
    return unless self.visible
    self.visible = !$game_quests.no_quests?
    self.visible = $game_quests.tracking?.size > 0
    return unless self.visible
    contents.clear
    change_color(crisis_color)
    draw_text(0,0,contents.width,18,"Quest Log:",1)
    yy = 18;iter = 0
    $game_quests.tracking?.each do |id|
      quest = $game_quests[id]
      next unless quest.accepted? && !quest.turned_in
      change_color(system_color)
      draw_text(6,yy,contents.width-6,18,quest.name)
      change_color(normal_color)
      yy += 18
      quest.objectives.each do |obj_id, obj|
        next if obj.hidden
        draw_objective(yy, $game_party.quests[id][obj_id])
        yy += 18
      end
      iter += 1
    end
  end
  def draw_objective(yy, obj)
    draw_text(0,yy,contents.width-24,18,obj.name)
    draw_text(0,yy,contents.width,18,obj.current.to_s+"/"+obj.max.to_s,2)
  end
end
   
class Window_QuestApply < Window_Base
  def initialize(confirm_window, turnin_window)
    super(Graphics.width/8,Graphics.width/8,Graphics.width/5*3,Graphics.height-Graphics.width/8*2)
    self.openness = 0
    @confirm_window = confirm_window
    @turnin_window = turnin_window
    self.contents.font.size = 18
  end
  def refresh
    return unless @quest
    contents.clear
    change_color(system_color)
    yy = 0
    if @quest.qgiver_name != 0
      draw_text(0,0,contents.width/2,line_height,@quest.qgiver_name)
      yy = line_height
    end
    if @quest.location != 0
      draw_text(contents.width/2,0,contents.width/2,line_height,@quest.location,2)
      yy = line_height
    end
    change_color(crisis_color)
    draw_text(0,yy,contents.width,line_height,"Lvl: " + @quest.level.to_s) if @quest.level > 0
    draw_text(0,yy,contents.width,line_height,@quest.name,1)
    draw_text(0,yy,contents.width,line_height,@quest.difficulty,2) if @quest.difficulty != 0
    change_color(normal_color)
    draw_text_ex(0,line_height+yy,@quest.desc)
    change_color(system_color)
    draw_text(0,line_height*8,contents.width,line_height,"Objectives:")
    change_color(normal_color)
    yy = line_height * 9
    @quest.objectives.each do |obj_id, obj|
      next if obj.hidden
      draw_objective(yy, $game_party.quests[@quest.id][obj_id])
      yy += line_height
    end
    change_color(system_color)
    draw_text(0,yy,contents.width,line_height,"Rewards:")
    yy += line_height
    if @quest.reward_exp > 0
      draw_text(6,yy,contents.width/2,line_height,"XP: ")
      change_color(normal_color)
      draw_text(36,yy,contents.width/2,line_height,@quest.reward_exp)
      yy += line_height
    end
    if @quest.reward_gold > 0
      change_color(normal_color)
      draw_text(6,yy,contents.width/2,line_height,@quest.reward_gold.to_s)
      cx = text_size(@quest.reward_gold).width
      change_color(system_color)
      draw_text(6+cx,yy,contents.width/2,line_height,Vocab::currency_unit)
    end
    yy += line_height
    change_color(normal_color)
    @quest.reward_items.each do |array|
      item = $data_items[array[1]] if array[0] == :item
      item = $data_weapons[array[1]] if array[0] == :weapon
      item = $data_armors[array[1]] if array[0] == :armor
      draw_item_name(item, 6, yy, true, contents.width)
      if array[2] > 1
        draw_text(6+text_size(item.name).width+36,yy,48,24,"x"+array[2].to_s)
      end
      yy += line_height
    end
  end
  def reset_font_settings
    change_color(normal_color)
    contents.font.bold = Font.default_bold
    contents.font.italic = Font.default_italic
  end
  def line_height
    18
  end
  def draw_objective(yy, obj)
    draw_text(6,yy,contents.width,24,obj.name)
    draw_text(0,yy,contents.width,24,obj.current.to_s+"/"+obj.max.to_s,2)
  end
  def show(quest,turnin)
    @quest = quest
    return if @quest.turned_in
    refresh
    open
    @confirm_window.quest(@quest)
    @confirm_window.open if !turnin
    if turnin
      @turnin_window.quest(@quest)
      @turnin_window.open
    end
  end
  def hide
    close
    @confirm_window.close
    @turnin_window.close
  end
  def accept
    @quest.accept
  end
  def turnin
    @quest.turnin
  end
end
 
class Window_QuestConfirm < Window_HorzCommand
  def initialize
    super(Graphics.width/8,Graphics.width/8+Graphics.height-Graphics.width/8*2)
    self.openness = 0
    self.active = false
    @enabled = true
    refresh
  end
  def window_width
    Graphics.width/5*2
  end
  def window_height
    48
  end
  def make_command_list
    add_command("Accept",:accept)
    add_command("Decline",:decline, @enabled)
  end
  def item_width
    width / 2 - padding * 2
  end
  def open
    super
    activate
    select(0)
  end
  def quest(quest)
    @quest = quest
    @enabled = !@quest.force_accept
    refresh
  end
  def cancel_enabled?
    super && @enabled
  end
end
 
class Window_QuestTurnin < Window_QuestConfirm
  def quest(quest)
    @quest = quest
    @enabled = true
    @enabled = !@quest.completed? if @quest.force_turnin
    refresh
  end
  def make_command_list
    return unless @quest
    add_command("Complete",:accept,@quest.completed? && !@quest.turned_in)
    add_command("Cancel",:decline, @enabled)
  end
end
 
class Game_Party
  attr_accessor :quests
  attr_accessor :tracking
  alias quests_init initialize
  def initialize(*args)
    quests_init(*args)
    @quests = $game_quests.reset_hash unless $game_quests.nil?
    @tracking = []
  end
end
 
class Game_Player
  alias quest_update update
  def update
    return if SceneManager.scene.accepting?
    quest_update
  end
end
 
class Game_Event
  def obj(quest, objective)
    $game_quests[quest].objective(objective).current
  end
end
 
class Game_Interpreter
  def accept_quest(quest)
    $game_quests[quest].accept
  end
  def ask_accept(quest)
    return unless SceneManager.scene.is_a?(Scene_Map)
    SceneManager.scene.show_quest(quest)
    Fiber.yield while SceneManager.scene.accepting?
  end
  def abandon_quest(quest)
    $game_quests[quest].abandon
  end
  def fail_quest(quest)
    $game_quests[quest].fail
  end
  def turnin_quest(quest)
    $game_quests[quest].turnin
  end
  def ask_turnin(quest)
    return unless SceneManager.scene.is_a?(Scene_Map)
    SceneManager.scene.show_quest(quest,true)
    Fiber.yield while SceneManager.scene.accepting?
  end
  def adv_obj(quest, objective, value)
    $game_quests[quest].adv_obj(objective, value)
  end
  def set_obj(quest, objective, value)
    $game_quests[quest].set_obj(objective, value)
  end
  def obj(quest, objective)
    $game_quests[quest].objective(objective).current
  end
  def hide_obj(quest, objective)
    $game_quests[quest].objective(objective).hidden = true
  end
  def show_obj(quest, objective)
    $game_quests[quest].objective(objective).hidden = false
  end
end

module DataManager
  class << self
    alias quest_load_game load_game
  end
  def self.load_game(index)
    quest_load_game(index)
    $game_quests.check_quests
  end
end
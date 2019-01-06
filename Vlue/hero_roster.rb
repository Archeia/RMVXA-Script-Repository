#--# Hero Roster v 1.2a
#
# Just a simple scene that lets you see a list of all the actors in the game.
#  Works based on whether they've been in your party or not, as well as
#  manually through script calls.
#
# Usage: Plug and play.
#    Script calls:
#     SceneManager.call(Scene_Roster)          - calls the scene
#     $game_actors[id].discovered = true/false - discovers or undiscovers
#     $game_actors[actor_id].in_roster = true/false
#
#    Notetags:
#     <NO ROSTER> - keeps an actor out of the roster
#     <ROSTER ##> - Used to manually sort actors
#
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
#--Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
module ROSTER
  #Face to be displayed for unknown actors. Set to false to disable.
  UNDISCOVERED_FACE = ["Monster1",7]
  #Description text to be displayed for unknown actors
  UNDISCOVERED_DESC = "You have not met this hero yet."
  #Use basic status: (For compatibility with scripts that change status display)
  USE_BASIC = false
  #Shows empty slots in equipment array
  SHOW_EMPTY_SLOTS = true
  EMPTY_SLOT_ICON = 0
  EMPTY_SLOT_TEXT = "--Empty--"
end
 
class Scene_Roster < Scene_Base
  def initialize
    super
    @list_window = Window_ActorList.new
    @list_window.set_handler(:cancel, method(:close_scene))
    @status_window = Window_RosterStatus.new(@list_window.current_actor)
    @status_window.x = @list_window.width
    @help_window = Window_Help.new
  end
  def update
    super
    @status_window.actor = @list_window.current_actor
    if @list_window.current_actor.discovered
      @help_window.set_text(@list_window.current_actor.description)
    else
      @help_window.set_text(ROSTER::UNDISCOVERED_DESC)
    end
  end
  def close_scene
    SceneManager.return
  end
end
 
class Window_ActorList < Window_Selectable
  def initialize
    super(0,72,176,Graphics.height-72)
    activate
    select(0)
    refresh
  end
  def make_item_list
    @data = $data_actors.select {|actor| actor.nil? ? false : $game_actors[actor.id].in_roster?}
    @data.sort! {|a,b| a.roster_number - b.roster_number }
  end
  def draw_item(index)
    actor = @data[index]
    if actor
      rect = item_rect(index)
      rect.x += 4
      if $game_actors[actor.id].discovered
        change_color(normal_color)
        draw_text(rect, actor.name)
      else
        change_color(normal_color, false)
        draw_text(rect, "?????")
      end
    end
  end
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  def item_max
    @data ? @data.size : 0
  end
  def current_actor
    $game_actors[@data[@index].id]
  end
end
 
class Game_Actor
  attr_accessor  :discovered
  attr_accessor  :in_roster
  def in_roster?
    @in_roster = !actor.in_roster? if @in_roster.nil?
    @in_roster
  end
end
 
class RPG::Actor
  def in_roster?
    self.note =~ /<NO ROSTER>/
  end
  def roster_number
    self.note =~ /<ROSTER (\d+)>/ ? $1.to_i : 999
  end
end
 
class Game_Party
  def setup_starting_members
    @actors = $data_system.party_members.clone
    @actors.each do |actor|
      $game_actors[actor].discovered = true
    end
  end
  def add_actor(actor_id)
    @actors.push(actor_id) unless @actors.include?(actor_id)
    $game_actors[actor_id].discovered = true
    $game_player.refresh
    $game_map.need_refresh = true
  end
end
 
class Window_RosterStatus < Window_Selectable
  def initialize(actor)
    super(0, 72, 368, Graphics.height-72)
    @actor = actor
    refresh
  end
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  def refresh
    contents.clear
    reset_font_settings
    contents.font.size -= 4
    if ROSTER::USE_BASIC
      if @actor.discovered
        draw_actor_face(@actor, 0, 0)
      elsif ROSTER::UNDISCOVERED_FACE
        face = ROSTER::UNDISCOVERED_FACE
        draw_face(face[0], face[1], 0, 0, false)
      end
      draw_actor_simple_status(@actor, 96, line_height * 0)
    else
      draw_block1   (line_height * 0)
      draw_horz_line(line_height * 1)
      draw_block2   (line_height * 2)
    end
    draw_horz_line(line_height * 6)
    draw_block3   (line_height * 7)
    draw_horz_line(line_height * 13)
    draw_block4   (line_height * 14)
  end
  def draw_block1(y)
    draw_actor_name(@actor, 4, y)
    draw_actor_class(@actor, contents.width / 3, y)
    draw_actor_nickname(@actor, contents.width / 3 * 2, y)
  end
  def draw_block2(y)
    if @actor.discovered
      draw_actor_face(@actor, 8, y)
    elsif ROSTER::UNDISCOVERED_FACE
      face = ROSTER::UNDISCOVERED_FACE
      draw_face(face[0], face[1], 8, y, false)
    end
    draw_basic_info(136, y)
  end
  def draw_block3(y)
    draw_parameters(8, y)
    draw_equipments(contents.width / 3, y) if @actor.discovered
  end
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    if @actor.discovered
      draw_text(x + 40, y, 36, line_height, actor.param(param_id), 2)
    else
      draw_text(x + 40, y, 36, line_height, "??", 2)
    end
  end
  def draw_block4(y)
  end
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + line_height * 0)
    draw_actor_hp(@actor, x, y + line_height * 2)
    draw_actor_mp(@actor, x, y + line_height * 3)
  end
  def draw_parameters(x, y)
    6.times {|i| draw_actor_param(@actor, x, y + line_height * i, i + 2) }
  end
  def draw_equipments(x, y)
    iter = 0
    @actor.equips.each do |item|
      change_color(normal_color,!item.nil?)
      if item.nil? && ROSTER::SHOW_EMPTY_SLOTS
        draw_icon(ROSTER::EMPTY_SLOT_ICON, x, y + line_height * iter,false)
        draw_text(x+24,y+line_height*iter,172,24,ROSTER::EMPTY_SLOT_TEXT)
      else
        draw_item_name(item, x, y + line_height * iter) unless item.nil?
      end
      iter += 1
    end
  end
  def draw_description(x, y)
    draw_text_ex(x, y, @actor.description) if @actor.discovered
  end
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  alias ros_draw_actor_name draw_actor_name
  def draw_actor_name(a, x, y)
    return ros_draw_actor_name(a,x,y) if @actor.discovered
    draw_text(x,y,contents.width,line_height,"?????")
  end
  alias ros_draw_actor_class draw_actor_class
  def draw_actor_class(a, x, y)
    return ros_draw_actor_class(a,x,y) if @actor.discovered
    draw_text(x,y,contents.width,line_height,"?????")
  end
  alias ros_draw_actor_nickname draw_actor_nickname
  def draw_actor_nickname(a, x, y)
    return ros_draw_actor_nickname(a,x,y) if @actor.discovered
    draw_text(x,y,contents.width,line_height,"?????")
  end
  def draw_actor_level(actor, x, y)
    change_color(system_color)
    draw_text(x, y, 32, line_height, Vocab::level_a)
    change_color(normal_color)
    if @actor.discovered
      draw_text(x + 32, y, 24, line_height, actor.level, 2)
    else
      draw_text(x + 32, y, 24, line_height, "??", 2)
    end
  end
  def draw_actor_hp(actor, x, y, width = 124)
    draw_gauge(x, y, width, 1, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.mhp, actor.mhp,
      hp_color(actor), normal_color)
  end
  def draw_actor_mp(actor, x, y, width = 124)
    draw_gauge(x, y, width, 1, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    draw_current_and_max_values(x, y, width, actor.mmp, actor.mmp,
      mp_color(actor), normal_color)
  end
  def draw_current_and_max_values(x, y, width, current, max, color1, color2)
    change_color(color1)
    xr = x + width
    if @actor.discovered
      draw_text(xr - 92, y, 42, line_height, current, 2)
      change_color(color2)
      draw_text(xr - 52, y, 12, line_height, "/", 2)
      draw_text(xr - 42, y, 42, line_height, max, 2)
    else
      draw_text(xr - 92, y, 42, line_height, "??", 2)
      change_color(color2)
      draw_text(xr - 52, y, 12, line_height, "/", 2)
      draw_text(xr - 42, y, 42, line_height, "??", 2)
    end
  end
end
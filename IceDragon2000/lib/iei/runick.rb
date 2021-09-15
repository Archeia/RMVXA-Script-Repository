#-define SKPVERSION 0x0800C
#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Runick"
#-define HDR_GDC :dc=>"24/06/2012"
#-define HDR_GDM :dm=>"12/07/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"SKPVERSION"
#-inject gen_script_header_wotail HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
#-inject gen_spacer
#-skip:
=begin
#-end:
#-inject gen_script_des 'Requirements'
  This script is standalone.

#-inject gen_script_des 'Introduction'
  Welcome to IEI - Runick.
  This script replaces your regular attack command with a
  Rune/Skill matches. Actually that makes no sense..
  1 + 2 = 3
  You merge multiple skills together to use another.
  However these merged skills will use the skill cost of
  all the runes together.
  So you use Fire (5MP) and Slash (2MP) to use
  Fire Slash, in all this costs (7MP).

#-inject gen_script_des 'Instruction Manual'
  In order for rune skills to show in the Rune Skill Window
  you need to put aside a Skill type ID, default this is 3.

#-inject gen_script_des 'Reference Manual'
  -Script Calls-
    $game.party.rune_limit = new_limit
      Changes the global rune limit

  -Notetags-
    Skill
      <rune: n>
        Sets the skill as n rune
        NOTE: rune names are case sensitive.
          fire is not the same as Fire or FIRE
      <rune recipe: n,n,n>
        Using skills that have the <rune: n> tag
        this skill will be used when all the runes
        are present.

      EG:
        Skill 2 (Fire)
          <rune: fire>
        Skill 22 (Fire III)
          <rune: fire>
        Skill 12 (Slash)
          <rune: slash>
        Skill 32 (Slash III)
          <rune: slash>
        Skill 42 (Fire Slash)
          <rune recipe: fire,slash>

        Skill 2 + Skill 12
          Skill 42 (Fire Slash)
        Skill 22 + Skill 12
          Skill 42 (Fire Slash)
        Skill 22 + Skill 42
          Skill 42 (Fire Slash)

#-inject gen_script_header_tail
#-skip:
=end
#-end:
$simport.r 'iei/runick', '0.8.0', 'IEI Runick'
#-inject gen_module_header 'IEI::Runick'
module IEI
  module Runick
#-inject gen_function_des 'Start Customization'
    RUNE_STYPE_ID       = 3     # // Rune Skill Type ID
    UNKNOWN_RUNE        = '???' # // Text used for unknown runes
    FAIL_RUNE           = '---' # // Fail
    DEFAULT_RUNE_NUMBER = 2     # // default number of 'same' runes
    DEFAULT_RUNE_LIMIT  = 2     # // default max number of runes
    DEFAULT_RUNE_ICON   = 184   # // Default icon index for runes
#-inject gen_function_des 'End Customization'
  end
end
#-inject gen_module_header 'IEI::Runick'
module IEI
  module Runick
    def self.recipe_list
      @recipe_list
    end
    def self.skills2recipe(*skills)
      runes = skills.map(&:rune)
    end
    def self.sort_recipe(array)
      array.sort
    end
    def self.mk_recipe_list!(items)
      @recipe_list = mk_recipe_list_abs items unless @recipe_list
    end
    def self.mk_recipe_list_abs(items)
      recipe_list = {}
      pc = item = nil # // Forward Dec.
      items.each do |item|
        item.rune_recipes.each do |r|
          recipe_list[sort_recipe(r)] = IEI.item2sym_a(item)
        end
      end
      return recipe_list
    end # // mk_recipe_list
    def self.get_skill recipe
      IEI.sym_a2item @recipe_list[recipe]
    end
    #add_recipe sort_recipe(recipe), skills
  end
  #-include ASMxROOT . "/src/core-item-syms.rb"
end
#-inject gen_module_header 'DataManager'
class << DataManager
  alias iei_rune_load_database load_database
  def load_database *args,&block
    iei_rune_load_database *args,&block
    IEI::Runick.mk_recipe_list! ($data_skills+$data_items).compact
    #puts IEI::Runick.recipe_list
  end
end
#-inject gen_class_header 'RPG::UsableItem'
class RPG::UsableItem < RPG::BaseItem
  def rune?
    !rune.empty?
  end
  def need_rune?
    !rune_recipes.empty?
  end
  def rune_ceil
    @rune_ceil ||= (@note.match(/<rune[_ ]?(?:number|ceil):\s*(\d+)>/i)||[nil,IEI::Runick::DEFAULT_RUNE_NUMBER])[1].to_i
  end
  def rune
    @runes ||= (@note.match(/<rune:\s*(\w+)>/i)||[nil,''])[1]
  end
  def rune_recipes
    unless @rune_recipes
      @rune_recipes = []
      @note.scan(/<rune[_ ]?recipe:\s*(\w+(?:\s*,\s*\w+)*)>/i).each do |s|
        @rune_recipes << s[0].scan(/\w+/)
      end
    end
    @rune_recipes
  end
end

#-inject gen_class_header 'Game::Action'
class Game::Action

  attr_accessor :runes

  alias rune_clear clear
  def clear
    rune_clear
    @runes = []
  end

  def rune?
    !@runes.empty?
  end

  def rune_skill_stack?
    @runes.size > 1 and !rune_skill
  end

  def rune_skill
    return @runes.first if @runes.size == 1
    recipe = IEI::Runick.skills2recipe *@runes
    IEI::Runick.get_skill IEI::Runick.sort_recipe(recipe)
  end

end

#-inject gen_class_header 'Game::Battler'
class Game::Battler

  alias org_use_item use_item
  def use_item item
    org_use_item item
    act = current_action
    if act.rune?
      runes = act.runes
      pay_rune_cost runes
      set_known_rune! runes,2
    end if act
  end

  alias org_usable? usable?
  def usable? item
    res  = org_usable? item
    act  = current_action
    res&&= rune_usable? act.runes if act.rune? if act
    res
  end

  def mk_cost_stack objs
    costs = objs.map do |i|
      {hp: 0, mp: skill_mp_cost(i), tp: skill_tp_cost(i)}
    end
    costs.inject({hp: 0, mp: 0, tp: 0}) do |main_hash,costs|
      main_hash[:hp] += costs[:hp]
      main_hash[:mp] += costs[:mp]
      main_hash[:tp] += costs[:tp]
      main_hash
    end
  end
  def can_pay_cost_stack? hash
    return false if hash[:hp] > hp
    return false if hash[:mp] > mp
    return false if hash[:tp] > tp
    return true
  end
  def pay_rune_cost objs
    objs.each do |i| org_use_item i end
  end
  def rune_usable? objs
    return false unless can_pay_cost_stack? mk_cost_stack(objs)
    objs.all? do |i| org_usable? i end
  end
  def runes_known
    $game.party.runes_known
  end
  def rune_ceil skill
    skill ? skill.rune_ceil : 0
  end
  #def rune_limit
  #  $game.party.rune_limit
  #end
  def rune_limit
    @rune_limit ||= IEI::Runick::DEFAULT_RUNE_LIMIT
  end
  attr_writer :rune_limit
  def rune_limit_reached?
    act = current_action
    return false unless act
    current_action.runes.size >= rune_limit
  end
  def rune_queue_usable? item
    runes = current_action.runes
    rune_usable? runes + [item]
  end
  def rune_known? runes
    return false unless runes
    set_known_rune runes,2 if runes.size == 1
    #runes_known.push item.id unless runes_known.include? item.id
    (sym_a = runes.map do |r| IEI.item2sym_a r end).sort!
    runes_known[sym_a]
  end
  def set_known_rune runes,n
    (sym_a = runes.map do |r| IEI.item2sym_a r end).sort!
    set_known_rune! runes,n unless runes_known[sym_a]
  end
  def set_known_rune! runes,n
    (sym_a = runes.map do |r| IEI.item2sym_a r end).sort!
    runes_known[sym_a] = n
  end
end
#-inject gen_class_header 'Game::Actor'
class Game::Actor
  def prior_command
    return false if @action_input_index <= 0
    current_action.clear if current_action
    @action_input_index -= 1
    return true
  end
end
#-inject gen_class_header 'Game::Party'
class Game::Party
  attr_writer :rune_limit, :runes_known
  def runes_known
    @runes_known ||= {}
  end
  def rune_limit
    @rune_limit ||= IEI::Runick::DEFAULT_RUNE_LIMIT
  end
end
#-inject gen_class_header 'Window::SkillRune'
class Window::Runes < Window::SkillList
  attr_reader :actor
  NULL_SKILL = RPG::Skill.new
  NULL_SKILL.id = -1
  NULL_SKILL.icon_index = 187
  NULL_SKILL.name = '-DONE-'
  def done_skill_index
    @data.index NULL_SKILL
  end
  def make_item_list
    super
    @data.unshift NULL_SKILL
    #@data.push NULL_SKILL
  end
  def refresh
    unless @actor
      self.contents.clear
    else
      super
    end
    self
  end
  def include? skill
    skill and skill.rune? and super skill
  end
  def enable? item
    return false unless @actor
    if item and item.id == -1
      return true if @actor.current_action.rune_skill_stack?
      return true if @actor.current_action.rune? and rune_skill
      return false
    end
    return false unless @actor.rune_queue_usable? item
    return false if @actor.rune_limit_reached?
    return false if @actor.current_action.runes.count(item) >= @actor.rune_ceil(item)
    super item
  end
  def rune_skill
    return nil unless @actor
    act = @actor.current_action
    #return nil unless act
    act.rune_skill
  end
  def select_done!
    select done_skill_index
  end
end
#-inject gen_class_header 'Window::RuneStack'
class Window::RuneStack < Window::Selectable

  attr_reader :rune_window

  def initialize x,y,w,h
    @runes = []
    super
  end

  def contents_height
    self.height - (self.padding * 2)
  end

  def update_padding_bottom
  end

  def rune_window= win
    @rune_window = win
    refresh
    self
  end

  def col_max
    item_max
  end

  def spacing
    2
  end

  def item_max
    [$game.party.rune_limit,1].max
  end

  def item_width
    24
  end

  def item_height
    24
  end

  def actor
    @rune_window.actor
  end

  def skill
    @rune_window.rune_skill
  end

  def draw_fraction(x, y, width, height, num, den, align=1)
    h = height / 2.0
    size = contents.font.size
    contents.font.size = [h,16].max
    contents.fill_rect x,y+h,width,1,contents.font.color
    draw_text x,y,width,h,num,align
    draw_text x,y+h,width,h,den,align
    contents.font.size = size
  end

  def draw_rune_name(item, x, y, enabled=true)
    change_color normal_color
    case @rune_window.actor.rune_known? @rune_window.actor.current_action.runes
    when 0,nil # // none
      change_color normal_color,enabled
      draw_text x+24,y,196,line_height,IEI::Runick::UNKNOWN_RUNE
    when 1 # // failed
      change_color normal_color#,enabled
      draw_text x+24,y,196,line_height,IEI::Runick::FAIL_RUNE
    when 2 # // sucess
      draw_item_name item,x,y,enabled
    end
    change_color normal_color
  end
  def refresh
    unless actor
      self.contents.clear
      return
    end
    @runes = actor.current_action.runes.dup
    super
    skl = skill
    wd = 196
    h = contents.height
    en = actor.org_usable?(skl)||!skl
    draw_rune_name skl,self.width-wd,(h-line_height)/2,en
    cost_stack = actor.mk_cost_stack @runes
    wd += 32 + spacing
    draw_fraction self.width-wd,0,32,h,cost_stack[:tp],(actor.tp_rate * 100).to_i # // Tp
    wd += 34 + spacing
    draw_fraction self.width-wd,0,32,h,cost_stack[:mp],actor.mp # // Mp
  end
  def item_rect index
    rect = super
    rect.x += (contents.width-266-item_max*rect.width) / 2
    rect
  end
  def draw_item index
    rect = item_rect index
    rect.y += (contents.height - rect.height) / 2.0
    item = @runes[index]
    icon_index = item ? item.icon_index : IEI::Runick::DEFAULT_RUNE_ICON
    draw_icon icon_index,rect.x,rect.y
  end
  def update
    super
    if @rune_window.actor
      if n = @rune_window.actor.current_action
        refresh if @runes != n.runes
      end
    end
  end
end

#-inject gen_class_header 'Scene_Battle'
class Scene_Battle

  alias iei_caw_rune create_all_windows
  def create_all_windows
    iei_caw_rune
    create_rune_window
  end

  def create_rune_window
    y = @help_window.y + @help_window.height
    rsw_h = 64
    h = Graphics.height - @help_window.height - @actor_window.height - rsw_h
    @rune_window = Window::Runes.new @help_window.x, y, @help_window.width, h
    @rune_window.set_handler :ok    , method(:on_rune_ok)
    @rune_window.set_handler :cancel, method(:on_rune_cancel)
    @rune_window.help_window = @help_window
    @rune_window.stype_id    = IEI::Runick::RUNE_STYPE_ID
    @rune_window.select 0
    y = @rune_window.y + @rune_window.height
    @rune_stack_window = Window::RuneStack.new @rune_window.x,y,@rune_window.width,rsw_h
    @rune_stack_window.rune_window = @rune_window
    @rune_window.deactivate.hide
    @rune_stack_window.deactivate.hide
  end

  alias iei_cacw_rune create_actor_command_window
  def create_actor_command_window
    iei_cacw_rune
    @actor_command_window.set_handler :attack, method(:command_rune)
  end

  alias iei_rune_prior_command prior_command
  def prior_command
    iei_rune_prior_command
    act = BattleManager.actor
    act.current_action.clear if act && act.current_action
  end

  def command_rune
    start_rune_entry
  end

  def start_rune_entry
    @rune_window.actor = BattleManager.actor
    @help_window.show
    @rune_window.refresh.show.activate
    @rune_stack_window.refresh
    @rune_stack_window.show
  end

  def on_rune_ok
    item  = @rune_window.item
    actor = BattleManager.actor
    act   = actor.current_action
    if item.id == -1
      runes = act.runes
      if act.rune_skill_stack?
        actor.clear_actions
        runes[0...runes.size].each do |skill|
          nact = Game::Action.new actor
          nact.set_skill skill.id
          actor.actions.push nact
        end
        until actor.next_command ; end
      else
        skill = @rune_window.rune_skill
        actor.clear_actions
        nact = Game::Action.new actor
        nact.set_skill skill.id
        nact.runes = runes if runes.size > 1
        actor.actions.push nact
      end
      end_rune_selection
      @skill = actor.current_action.item
      skill_target_selection
      actor.actions.each do |a| a.target_index = actor.current_action.target_index end
      actor.set_known_rune runes, 1
      #end
      #next_command
    else
      BattleManager.actor.current_action.runes << item
      @rune_window.select_done! if actor.rune_limit_reached?
      @rune_window.refresh
      @rune_window.activate
    end
  end

  def skill_target_selection
    BattleManager.actor.last_skill.object = @skill
    if !@skill.need_selection?
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end

  def on_rune_cancel
    runes = BattleManager.actor.current_action.runes
    if runes.empty?
      end_rune_selection
      @actor_command_window.show.activate
    else
      runes.clear
      @rune_window.refresh
      @rune_window.activate
    end
  end

  #alias iei_rune_on_skill_cancel on_skill_cancel
  #def on_skill_cancel
  #  iei_rune_on_skill_cancel
  #  BattleManager.actor.current_action.runes.clear
  #end

  def end_rune_selection
    @rune_stack_window.hide
    @rune_window.hide
    #@rune_stack_window = nil
    #@rune_window.help_window = nil
    #@rune_window.dispose
    #@rune_window = nil
    @help_window.hide
  end

  def on_actor_cancel
    @actor_window.hide
    case @actor_command_window.current_symbol
    when :attack
      start_rune_entry
    when :skill
      @skill_window.activate
    when :item
      @item_window.activate
    end
  end

  def on_enemy_cancel
    @enemy_window.hide
    case @actor_command_window.current_symbol
    when :attack
      start_rune_entry
    when :skill
      @skill_window.activate
    when :item
      @item_window.activate
    end
  end

end
#-inject gen_script_footer

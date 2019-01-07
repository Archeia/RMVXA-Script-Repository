###--------------------------------------------------------------------------###
#  CP Enemy Scan script                                                        #
#  Version 1.2a                                                                #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neon Black                                                #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.2a - 12.19.2013
#   Quick fix for 2 issues
#  V1.2 - 11.12.2012                                                           #
#   Added libra effect                                                         #
#   Recoded how discovered elements are stored/called                          #
#   Added new options and visuals                                              #
#  V1.1 - 11.11.2012                                                           #
#   Fixed a bug related to adding weak states                                  #
#   Added pop-ups when used with battleview 1                                  #
#  V1.0 - 11.6.2012-11.9.2012                                                  #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Game_System: initialize                                       #
#                Game_Battler: item_apply, item_effect_add_state_attack,       #
#                              item_effect_add_state_normal                    #
#                Scene_Battle: create_all_windows, create_enemy_window,        #
#                              next_command, update, invoke_item               #
#                Window_BattleEnemy: update                                    #
#  New Methods - Game_System: scan_known_elements, scan_known_states,          #
#                             add_known_element, add_known_state               #
#                Game_Battler: scan_check_rate, cp_scan_enemy,                 #
#                              scan_element_affinities, scan_state_affinities, #
#                              scan_weak_elements, scan_weak_states,           #
#                              scan_strong_elements, scan_strong_states        #
#                Scene_Battle: create_scan_windows, open_enemy_scan,           #
#                              close_enemy_scan, next_enemy, last_enemy        #
#                              scan_windows, open_scan_window,                 #
#                              close_scan_window, close_from_selection         #
#                Window_ScanEnemy: initialize, refresh, enemy, draw_enemy_hp,  #
#                                  draw_enemy_mp, draw_enemy_tp,               #
#                                  process_pageup, process_pagedown,           #
#                                  update_cursor
#                Window_ScanElements: initialize, window_width, refresh,       #
#                                     disc_element_type, draw_all_weak,        #
#                                     draw_all_resist, xicon, col2,            #
#                                     weaknesses, resistances,                 #
#                                     all_element_type, draw_all_elements,     #
#                                     draw_all_states, line_offset, text_pos,  #
#                                     font_size, row_height, state_color,      #
#                                     enemy, update_cursor                     #
#                Window_ScanBio: initialize, refresh, bio, enemy,              #
#                                contents_height, update_cursor                #
#                RPG::Enemy: bio, hidden_stats, set_bio_info,                  #
#                            set_hidden_stats                                  #
#                RPG::UsableItem: scan_types, libra?, set_scan_type            #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script adds a scan scene to battles that allows the player to view     #
#  info on enemies by pressing a designated key.  There are multiple tags      #
#  that may be used in enemies, skills, and items to allow different types of  #
#  scan functions to be used.                                                  #
###-----                                                                -----###
#      Enemy Tags:                                                             #
#  <bio>  -and-  </bio>                                                        #
#    Sets the text between these tags to the bio description for the enemy.    #
#    This automatically formats allowing you to type the entire bio in a       #
#    single line in the notebox and then showing it over the required lines    #
#    on the scan screen.                                                       #
#  USAGE:                                                                      #
#    <bio>                                                                     #
#    Enemy bio goes here.  You can type it all on one line.                    #
#    Or you can use more than one line.                                        #
#    </bio>                                                                    #
#  hide hp  -and/or-  hide mp  -and/or-  hide tp                               #
#    Hides the designated stat in the info box.  You can use one or each tag   #
#    to hide several options at once.                                          #
###-----                                                                -----###
#      Skill/Item Tags:                                                        #
#  scan[libra]                                                                 #
#    The skill gains a libra effect opening a scan window on the enemy the     #
#    skill is used on.                                                         #
#  scan[all]                                                                   #
#    When the skill use used on a foe, it reveals all info about an enemy.     #
#    This does not count hidden stats such as HP and MP.  Also, this tag will  #
#    have no effect unless DISCOVER_TYPE is set to true.                       #
#  scan[weak elements]  -or-  scan[strong states]  -or-  scan[weak]  -etc-     #
#    Scans only specific parts of the attributes sections.  You can use the    #
#    words "strong" or "weak" and/or "elements" or "states" to reveal          #
#    whichever attributes you want revealed.  Note that if you use two words,  #
#    strong/weak must come before elements/states.  Several similar tags can   #
#    be present in a single skill or item.                                     #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP   # Do not touch                                                     #
module SCAN #  these two lines.                                                #
###-----                                                                -----###
# These are the high and low values of STATES.  A state with an chance higher  #
# than "TOP" is considered weak.  A state with a chance lower than "BOT" is    #
# considered strong.  1.0 = 100% chance.                                       #
STATE_NORM_TOP = 1.0 # Default = 1.0                                           #
STATE_NORM_BOT = 1.0 # Default = 1.0                                           #
#                                                                              #
# Sets the button that can be used to open the scan menu.  This can be set to  #
# nil to disable normal opening of the scan menu.                              #
BUTTON_SCAN = :A # Default = :A                                                #
#                                                                              #
# Choose to use the percentage based scan screen (all elements and states      #
# shown) or the icon based scan screen.                                        #
PERCENTAGE_BASED = false # Default = false                                     #
#                                                                              #
# Choose if stats and states must be discovered or if they are all shown by    #
# default.                                                                     #
DISCOVER_TYPE = true # Default = true                                          #
#                                                                              #
# This is the text that displays on undiscovered affinities in the percentage  #
# based screen.                                                                #
HIDDEN_STAT = "--%" # Default = "--%"                                          #
#                                                                              #
# Determine if an info window is used to tell the player what button to press, #
# the text of this window, and the X and Y position of the window.             #
INFO_WINDOW = true # Default = true                                            #
INFO_X = 264 # Default = 304                                                   #
INFO_Y = 248 # Default = 248                                                   #
INFO_TEXT = "Press shift for enemy info"                                       #
#                                                                              #
# This is the text that displays in the discovery type scan screen that above  #
# the icons.                                                                   #
WEAK_TEXT = "Weaknesses" # Default = "Weaknesses"                              #
RESIST_TEXT = "Resistances" # Default = "Resistances"                          #
#                                                                              #
# This is the text that displays when HP, MP, or TP is hidden.                 #
HIDDEN_TEXT = "? ? ?" # Default = "? ? ?"                                      #
#                                                                              #
# This hash contains all the elements that can be displayed in the scan screen #
# and the icon to go with them.  You may have as many or as few as you want.   #
# The ID relates to the element's ID in the "Terms" page of the database.      #
ELEMENTS ={                                                                    #
# ID => Icon,                                                                  #
  1  => 116,
  2  => 114,
  3  => 96,
  4  => 97,
  5  => 98,
  6  => 99,
  7  => 100,
  8  => 101,
  9  => 102,
  10 => 103,
}                                                                              #
#                                                                              #
# This hash contains all the states that can be displayed in the scan screen   #
# and the icon to go with them.  If you want to use the same icon from the     #
# database, set the icon number to nil.                                        #
STATES ={                                                                      #
# ID => Icon,                                                                  #
  1 => 1,
  2 => 2,
  3 => 3,
  4 => 4,
  5 => 5,
  6 => 6,
  7 => 7,
  8 => 8,
}                                                                              #
#                                                                              #
# These are the different things to be shown in each row of the namebox.  You  #
# can set up as many or as few as you want in each one.  You may also remove   #
# any lines of this hash as you want.  The valid tags for terms are :name,     #
# :states, :hp, :mp, and :tp.  If you want a blank to be included, use an      #
# empty array for that line.  Also note that the height of the name and        #
# element windows are dependant on the number of rows you set here with a max  #
# of 4 rows and a minimum of 2 rows.                                           #
NAMEBOX ={                                                                     #
  0 => [:name, :states],
  1 => [:hp],
  2 => [:mp, :tp],
  #3 => [],
}                                                                              #
#                                                                              #
###-----                                                                -----###
#  The following options can only be used if CP Pop-ups version 1.2 or higher  #
#  is also present in the game.                                                #
#                                                                              #
# The text to display for skills that a battler is strong or weak to.          #
WEAK_POP = "Weakness" # Default = "Weakness"                                   #
STRONG_POP = "Resist" # Default = "Resist"                                     #
#                                                                              #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end
end

$imported = {} if $imported.nil?
$imported["CP_SCAN_SCENE"] = 1.2

class Game_System
  alias cp_scan_init initialize
  def initialize  ## Adds the new hashes to store known affinities.
    cp_scan_init
    @known_elements = {}
    @known_states = {}
  end
  
  def scan_known_elements(mob)
    mob = mob.enemy.id  ## Checks known elements/states based on arguments.
    @known_elements = {} if @known_elements.nil?
    @known_elements[mob] = [] unless @known_elements.include?(mob)
    return @known_elements[mob]
  end
  
  def scan_known_states(mob)
    mob = mob.enemy.id
    @known_states = {} if @known_states.nil?
    @known_states[mob] = [] unless @known_states.include?(mob)
    return @known_states[mob]
  end
  
  def add_known_element(mob, element)
    mob = mob.id  ## Adds a new id to the affinity array.
    return unless CP::SCAN::ELEMENTS.include?(element)
    @known_elements = {} if @known_elements.nil?
    @known_elements[mob] = [] unless @known_elements.include?(mob)
    return if @known_elements[mob].include?(element)
    @known_elements[mob].push(element)
  end
  
  def add_known_state(mob, state)
    mob = mob.id
    return unless CP::SCAN::STATES.include?(state)
    @known_states = {} if @known_states.nil?
    @known_states[mob] = [] unless @known_states.include?(mob)
    return if @known_states[mob].include?(state)
    @known_states[mob].push(state)
  end
end

class Game_Battler
  alias cp_scan_item_apply item_apply
  def item_apply(user, item)
    cp_scan_item_apply(user, item)
    cp_scan_enemy(item) unless item.scan_types.empty?
    return if !@result.hit?  ## Adds an element to the affinity array.
    if item.damage.element_id < 0
      return if user.atk_elements.empty?
      max_id_val = elements_max_rate(user.atk_elements)
      do_weak_res_pop(max_id_val)
      return if actor?
      user.atk_elements.each do |id|
        next unless element_rate(id) == max_id_val
        $game_system.add_known_element(enemy, id)
      end
    else
      rate = element_rate(item.damage.element_id)
      do_weak_res_pop(rate)
      return if actor?
      $game_system.add_known_element(enemy, item.damage.element_id)
    end
  end
  
  def do_weak_res_pop(rate)
    return unless $imported["CP_BATTLEVIEW"] && $imported["CP_BATTLEVIEW"] >= 1.2
    do_weak_pop if rate > 1.0
    do_strong_pop if rate < 1.0
  end
  
  def do_weak_pop
    pop = CP::BATTLEVIEW::POP_STYLE[:weak_pop]
    create_pop(CP::SCAN::WEAK_POP, :weak_pop, pop)
  end
  
  def do_strong_pop
    pop = CP::BATTLEVIEW::POP_STYLE[:strong_pop]
    create_pop(CP::SCAN::STRONG_POP, :strong_pop, pop)
  end
  
  alias cp_scan_state_attack item_effect_add_state_attack
  def item_effect_add_state_attack(user, item, effect)
    cp_scan_state_attack(user, item, effect)
    user.atk_states.each do |id|
      scan_check_rate(id)
    end
  end  ## Check the states used by the skill and adds them to the array.
  
  alias cp_scan_state_normal item_effect_add_state_normal
  def item_effect_add_state_normal(user, item, effect)
    cp_scan_state_normal(user, item, effect)
    scan_check_rate(effect.data_id)
  end
  
  def scan_check_rate(id)  ## Common function that determines array args.
    return if actor?
    $game_system.add_known_state(enemy, id)
  end
  
  def cp_scan_enemy(item)  ## Gets the basic types of scans on a skill.
    return if actor?
    item.scan_types.each do |type|
      case type
      when :we
        scan_weak_elements
      when :se
        scan_strong_elements
      when :ws
        scan_weak_states
      when :ss
        scan_strong_states
      when :e
        scan_element_affinities
      when :s
        scan_state_affinities
      end
    end
  end
  
  def scan_element_affinities
    CP::SCAN::ELEMENTS.each do |id, icon|
      $game_system.add_known_element(enemy, id)
    end
  end
  
  def scan_state_affinities
    CP::SCAN::STATES.each do |id, icon|
      $game_system.add_known_state(enemy, id)
    end
  end
  
  def scan_weak_elements  ## Performs the designated scan.
    CP::SCAN::ELEMENTS.each do |id, icon|
      rate = element_rate(id)
      next if rate <= 1.0
      $game_system.add_known_element(enemy, id)
    end
  end
  
  def scan_weak_states
    CP::SCAN::STATES.each do |id, icon|
      rate = state_rate(id)
      next if rate <= CP::SCAN::STATE_NORM_TOP
      $game_system.add_known_state(enemy, id)
    end
  end
  
  def scan_strong_elements
    CP::SCAN::ELEMENTS.each do |id, icon|
      rate = element_rate(id)
      next if rate >= 1.0
      $game_system.add_known_element(enemy, id)
    end
  end
  
  def scan_strong_states
    CP::SCAN::STATES.each do |id, icon|
      rate = state_rate(id)
      next if rate >= CP::SCAN::STATE_NORM_BOT
      $game_system.add_known_state(enemy, id)
    end
  end
end

class Scene_Battle < Scene_Base
  alias cp_scan_create_all_windows create_all_windows
  def create_all_windows  ## Adds the new scan window stuff.
    cp_scan_create_all_windows
    create_scan_windows
  end
  
  alias cp_create_enemy_window create_enemy_window
  def create_enemy_window  ## Adds a new enemy window method.
    cp_create_enemy_window
    @enemy_window.set_handler(:scan, method(:open_enemy_scan))
  end
  
  def create_scan_windows  ## Creates all required graphics for scanning.
    @scan_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @scan_viewport.z = 400
    @scan_viewport.visible = false
    @scan_enemy = Window_ScanEnemy.new
    @scan_bio = Window_ScanBio.new
    @scan_elements = Window_ScanElements.new
    @scan_info = Window_ScanInfo.new
    @scan_info.z = 400
    @scan_info.visible = false
    scan_windows.each do |wind|
      wind.viewport = @scan_viewport
    end
    @scan_enemy.set_handler(:ok,       method(:close_enemy_scan))
    @scan_enemy.set_handler(:cancel,   method(:close_enemy_scan))
    @scan_enemy.set_handler(:pagedown, method(:next_enemy))
    @scan_enemy.set_handler(:pageup,   method(:last_enemy))
  end
  
  def open_enemy_scan
    @from_selection = true
    open_scan_window
    @scan_enemy.lock_foe = false
    @enemy_window.deactivate
    @scan_enemy.activate
  end  ## Open and close the enemy scan.
  
  def close_enemy_scan
    close_scan_window
    close_from_selection if @from_selection
    @from_selection = false
  end
  
  def next_enemy
    scan_windows.each do |wind|
      wind.index += 1
      next unless wind.index == $game_troop.alive_members.size
      wind.index = 0
    end
    scan_windows.each {|wind| wind.refresh}
    @scan_enemy.activate
  end  ## Next and last enemies....
  
  def last_enemy
    scan_windows.each do |wind|
      wind.index -= 1
      next unless wind.index == -1
      wind.index = $game_troop.alive_members.size - 1
    end
    scan_windows.each {|wind| wind.refresh}
    @scan_enemy.activate
  end
  
  def scan_windows  ## Quickly returns each scan window.
    return [@scan_enemy, @scan_bio, @scan_elements]
  end
  
  alias cp_scan_next_command next_command
  def next_command
    @scan_info.visible = false
    cp_scan_next_command
  end
  
  alias cp_scan_update update
  def update
    cp_scan_update
    return unless @scan_info && @enemy_window
    @scan_info.visible = @enemy_window.active
  end
  
  def open_scan_window(target = nil)
    @window_tot_vis = {}
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      next unless ivar.is_a?(Window)
      next if ivar.viewport == @scan_viewport
      @window_tot_vis[varname] = ivar.visible
      ivar.visible = false
    end
    if target
      target = $game_troop.alive_members.index(target)
    end
    enemy = target || @enemy_window.index
    scan_windows.each {|wind| wind.index = enemy; wind.refresh}
    @scan_viewport.visible = true
    @scan_enemy.lock_foe = true
    @scan_enemy.activate
  end
  
  def close_scan_window
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      next unless ivar.is_a?(Window)
      next if ivar.viewport == @scan_viewport
      ivar.visible = @window_tot_vis[varname]
    end
    scan_windows.each do |wind|
      wind.index = @enemy_window.index
    end
    @scan_viewport.visible = false
  end
  
  def close_from_selection
    @enemy_window.activate
    @scan_enemy.deactivate
  end
  
  alias cp_scan_action invoke_item
  def invoke_item(target, item)
    scan_windows.each {|w| w.index = $game_troop.alive_members.index(target)}
    target.cp_scan_enemy(item) if item.libra?
    open_scan_window(target) if item.libra?
    update_for_wait while @scan_viewport.visible
    cp_scan_action(target, item)
  end
end

##-----
## The new windows are located below.
##-----
class Window_ScanEnemy < Window_Selectable
  attr_accessor :lock_foe
  
  def initialize
    w = !CP::SCAN::PERCENTAGE_BASED ? 208 : 200
    h = fitting_height([[CP::SCAN::NAMEBOX.size, 2].max, 4].min)
    super(0, 0, w, h)
    @index = 0
    @lock_foe
    refresh
  end
  
  def refresh
    contents.clear
    CP::SCAN::NAMEBOX.each do |id, array|
      next unless [0, 1, 2, 3].include?(id)
      next if (array.nil? || !array.is_a?(Array) || array.empty?)
      wd = contents.width / array.size
      array.each_with_index do |key, i|
        case key
        when :name
          draw_text(wd * i + 2, id * line_height, wd, line_height, enemy.name)
        when :states
          draw_actor_icons(enemy, wd * i, id * line_height, wd)
        when :hp
          draw_enemy_hp(enemy, wd * i + 2, id * line_height, wd - 4)
        when :mp
          draw_enemy_mp(enemy, wd * i + 2, id * line_height, wd - 4)
        when :tp
          draw_enemy_tp(enemy, wd * i + 2, id * line_height, wd - 4)
        end
      end
    end
  end
  
  def enemy
    $game_troop.alive_members[@index]
  end
  
  def draw_enemy_hp(battler, x, y, width = 124)
    unless battler.enemy.hidden_stats.include?(:hp)
      draw_gauge(x, y, width, battler.hp_rate, hp_gauge_color1, hp_gauge_color2)
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::hp_a)
      change_color(hp_color(battler))
      draw_text(x + 32, y, width - 32, line_height, battler.hp.to_i, 2)
    else
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::hp_a)
      change_color(normal_color)
      draw_text(x + 32, y, width - 32, line_height, CP::SCAN::HIDDEN_TEXT, 2)
    end
  end
    
  def draw_enemy_mp(battler, x, y, width = 124)
    unless battler.enemy.hidden_stats.include?(:mp)
      draw_gauge(x, y, width, battler.mp_rate, mp_gauge_color1, mp_gauge_color2)
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::mp_a)
      change_color(mp_color(battler))
      draw_text(x + 32, y, width - 32, line_height, battler.mp.to_i, 2)
    else
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::mp_a)
      change_color(normal_color)
      draw_text(x + 32, y, width - 32, line_height, CP::SCAN::HIDDEN_TEXT, 2)
    end
  end
    
  def draw_enemy_tp(battler, x, y, width = 124)
    unless battler.enemy.hidden_stats.include?(:tp)
      draw_gauge(x, y, width, battler.tp_rate, tp_gauge_color1, tp_gauge_color2)
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::tp_a)
      change_color(tp_color(battler))
      draw_text(x + 32, y, width - 32, line_height, battler.tp.to_i, 2)
    else
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::tp_a)
      change_color(normal_color)
      draw_text(x + 32, y, width - 32, line_height, CP::SCAN::HIDDEN_TEXT, 2)
    end
  end
  
  def process_pageup
    return if @lock_foe
    super
  end
  
  def process_pagedown
    return if @lock_foe
    super
  end
  
  def update_cursor
  end
end

class Window_ScanElements < Window_Selectable
  def initialize
    w = window_width
    h = fitting_height([[CP::SCAN::NAMEBOX.size, 2].max, 4].min)
    super(Graphics.width - w, 0, w, h)
    @index = 0
    refresh
  end
  
  def window_width
    if !CP::SCAN::PERCENTAGE_BASED
      return Graphics.width - 208
    else
      icons = [CP::SCAN::ELEMENTS.size, CP::SCAN::STATES.size].max + 24
      return [icons * 32, Graphics.width - 200].min
    end
  end
  
  def refresh
    contents.clear
    !CP::SCAN::PERCENTAGE_BASED ? disc_element_type : all_element_type
  end
  
  def disc_element_type
    draw_all_weak
    draw_all_resist
  end
  
  def draw_all_weak
    draw_text(2, 0, 144, line_height, CP::SCAN::WEAK_TEXT, 1)
    weaknesses.each_with_index do |id, i|
      draw_icon(id, 24 * (i % xicon), line_height + 24 * (i / xicon))
    end
  end
  
  def draw_all_resist
    draw_text(col2 + 2, 0, 144, line_height, CP::SCAN::RESIST_TEXT, 1)
    resistances.each_with_index do |id, i|
      draw_icon(id, col2 + 24 * (i % xicon), line_height + 24 * (i / xicon))
    end
  end
  
  def xicon
    (contents.width / 2) / 24
  end
  
  def col2
    contents.width - xicon * 24
  end
  
  def weaknesses
    result = []
    CP::SCAN::ELEMENTS.each do |id, icon|
      next unless enemy.element_rate(id) > 1.0
      if CP::SCAN::DISCOVER_TYPE
        next unless $game_system.scan_known_elements(enemy).include?(id)
      end
      result.push(icon)
    end
    CP::SCAN::STATES.each do |id, icon|
      next unless enemy.state_rate(id) > CP::SCAN::STATE_NORM_TOP
      next if enemy.state_resist?(id)
      if CP::SCAN::DISCOVER_TYPE
        next unless $game_system.scan_known_states(enemy).include?(id)
      end
      result.push(icon ? icon : $data_states[id].icon_index)
    end
    return result
  end
  
  def resistances
    result = []
    CP::SCAN::ELEMENTS.each do |id, icon|
      next unless enemy.element_rate(id) < 1.0
      if CP::SCAN::DISCOVER_TYPE
        next unless $game_system.scan_known_elements(enemy).include?(id)
      end
      result.push(icon)
    end
    CP::SCAN::STATES.each do |id, icon|
      next unless (enemy.state_rate(id) < CP::SCAN::STATE_NORM_BOT ||
                   enemy.state_resist?(id))
      if CP::SCAN::DISCOVER_TYPE
        next unless $game_system.scan_known_states(enemy).include?(id)
      end
      result.push(icon ? icon : $data_states[id].icon_index)
    end
    return result
  end
  
  def all_element_type
    draw_all_elements
    draw_all_states
  end
  
  def draw_all_elements
    i = 0
    contents.font.size = font_size
    CP::SCAN::ELEMENTS.each do |id, icon|
      known = $game_system.scan_known_elements(enemy).include?(id)
      if known
        rate = sprintf("%d%", enemy.element_rate(id) * 100)
        state_color(enemy.element_rate(id))
      else
        rate = CP::SCAN::HIDDEN_STAT
        contents.font.color.set(normal_color)
      end
      draw_icon(icon, 32 * i + 4, line_offset)
      draw_text(32 * i, text_pos, 32, font_size, rate, 1)
      i += 1
    end
  end
  
  def draw_all_states
    i = 0
    contents.font.size = font_size
    CP::SCAN::STATES.each do |id, icon|
      known = $game_system.scan_known_states(enemy).include?(id)
      if known
        perc = enemy.state_resist?(id) ? 0 : enemy.state_rate(id)
        rate = sprintf("%d%", perc * 100)
        state_color(perc, true)
      else
        rate = CP::SCAN::HIDDEN_STAT
        contents.font.color.set(normal_color)
      end
      iconid = icon ? icon : $data_states[id].icon_index
      draw_icon(iconid, 32 * i + 4, row_height + line_offset)
      draw_text(32 * i, row_height + text_pos, 32, font_size, rate, 1)
      i += 1
    end
  end
  
  def line_offset
    return 0 if CP::SCAN::NAMEBOX.size != 4
    return (row_height - line_height) / 2
  end
  
  def text_pos
    row_height - font_size
  end
  
  def font_size
    (line_height * 0.75).to_i
  end
  
  def row_height
    contents.height / 2
  end
  
  def state_color(rate, state = false)
    hrate = state ? CP::SCAN::STATE_NORM_TOP : 1.0
    lrate = state ? CP::SCAN::STATE_NORM_BOT : 1.0
    if rate > hrate
      contents.font.color.set(power_up_color)
    elsif rate < lrate
      contents.font.color.set(power_down_color)
    else
      contents.font.color.set(normal_color)
    end
  end
  
  def enemy
    $game_troop.alive_members[@index]
  end
  
  def update_cursor
  end
end

class Window_ScanBio < Window_Selectable
  def initialize
    w = Graphics.width
    h = fitting_height(4)
    super(0, Graphics.height - h, w, h)
    refresh
  end
  
  def refresh
    contents.clear
    draw_text_ex(0, 0, bio)
  end
  
  def bio
    temp = enemy.bio
    result = ""; line = ""
    temp.split(/ /).each do |word|
      sz = contents.text_size(line).width + contents.text_size("#{word}").width
      if sz > contents.width - 2
        if line.empty?
          word2 = ""
          word.chars do |c|
            s2 = contents.text_size(line).width + contents.text_size("#{c}").width
            if s2 <= contents.width - 2
              line += c
            else
              word2 += c
            end
          end
          word = word2
        end
        result += "#{line}\n"
        line = "#{word} "
        next
      else
        line += "#{word} "
      end
      nl = (line =~ /\\n/i)
      if line.length - 2 == nl
        result += "#{line}\n"
        line = word
      end
    end
    result += "#{line}"
    return result
  end
  
  def enemy
    $game_troop.alive_members[@index].enemy
  end
  
  def contents_height
    height - standard_padding * 2
  end
  
  def update_cursor
  end
end

class Window_BattleEnemy < Window_Selectable
  alias cp_scan_update update
  def update
    cp_scan_update
    return unless active
    call_handler(:scan) if Input.trigger?(CP::SCAN::BUTTON_SCAN)
  end
end

class RPG::Enemy < RPG::BaseItem
  def bio
    set_bio_info if @bio.nil?
    return @bio
  end
  
  def hidden_stats
    set_hidden_stats if @hidden_stats.nil?
    return @hidden_stats
  end
  
  def set_bio_info
    @bio = ""
    get_bio = false
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /<bio>/i
        get_bio = true
        next
      when /<\/bio>/i
        return
      end
      next unless get_bio
      @bio += "#{line}\n"
    end
  end
  
  def set_hidden_stats
    @hidden_stats = []
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /hide hp/i
        @hidden_stats.push(:hp)
      when /hide mp/i
        @hidden_stats.push(:mp)
      when /hide tp/i
        @hidden_stats.push(:tp)
      end
    end
    @hidden_stats.uniq!
  end
end

class RPG::UsableItem < RPG::BaseItem
  def scan_types
    set_scan_type if @scan_types.nil?
    return @scan_types
  end
  
  def libra?
    set_scan_type if @libra_skill.nil?
    return @libra_skill
  end
  
  def set_scan_type
    @scan_types = []
    @libra_skill = false
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /scan\[libra\]/i
        @libra_skill = true
      when /scan\[all\]/i
        @scan_types = [:e, :s]
      when /scan\[(strong|weak)?\s*(elements|states)?\]/i
        affinity = $1.to_s.downcase; type = $2.to_s.downcase
        if affinity == ""
          @scan_types += [:e] if type == "elements"
          @scan_types += [:s] if type == "states"
        elsif type == ""
          @scan_types += [:se, :ss] if affinity == "strong"
          @scan_types += [:we, :ws] if affinity == "weak"
        elsif affinity == "strong"
          if type == "elements"
            @scan_types.push(:se)
          elsif type == "states"
            @scan_types.push(:ss)
          end
        elsif affinity == "weak"
          if type == "elements"
            @scan_types.push(:we)
          elsif type == "states"
            @scan_types.push(:ws)
          end
        end
      end
    end
    @scan_types.uniq!
  end
end

class Window_ScanInfo < Window_Base
  def initialize
    super(CP::SCAN::INFO_X, CP::SCAN::INFO_Y, 280, fitting_height(1))
    self.back_opacity = 255
    refresh
  end
  
  def refresh
    contents.clear
    draw_text(2, 0, contents.width - 4, line_height, CP::SCAN::INFO_TEXT, 1)
    self.opacity = 0 if !CP::SCAN::INFO_WINDOW
    self.contents_opacity = 0 if !CP::SCAN::INFO_WINDOW
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###
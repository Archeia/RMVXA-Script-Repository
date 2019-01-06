# Skill Trees or Something v1.0a
#----------#
#Features: Basic skill trees! Earn skill points, spend skill points,
#           get abilities! Enjoy.
#
#Usage:   Set up your skill trees, knock yourself out.
#          Script calls:
#           SceneManager.call(Scene_SkillTree)
#           $game_actors[actor_id].add_skill_tree(tree_id)
#
#          Notetags (Actors):
#       <SP_PER #>  - sets the amount of sp earned per gain (overrides default)
#       <SP_LEVEL #> - Overrides how many levels between each sp gain
#       <SKILL_TREE #> - Sets the actors default skill tree
#
#          Notetags (Classes):
#       <SKILL_TREES [#,#..]> - An array of trees for a class
#         Example: <SKILL_TREES [0,1,24]>
#
#          Notetags (Items):
#       <SKILL_BOOK> - Will add value of grow feature in skill points instead.
#      Example: Set an item with the feature grow MHP 5 and gain 5 skill points.
#
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
 
#Default SP earned every gain
DEFAULT_POINTS_GAINED = 5
#Default levels between each SP gain (2 means every two levels, 3 means 3, etc.)
DEFAULT_LEVEL_MOD = 2
#The Skill Trees!
# id# => { :name => "Tree name",
#   :desc => "Description of tree",
#   :icon => id,
#   :background => "image_name",
#   :skills => {
#     :skillname => { :name => "Skill Name",
#       :skillids => [skill1,skill2,...],
#       :replace => true/false
#       :spcost => #,
#       :splock => #, :prevlock => [:skill1,:skill2,...],
#       :row => #, :col => #
#     },
#   },
#  },
#
# Look at how confusing that can be! I either hate you all or this is the easiest
#  setup for me! I'll let you decide later. Anywho, on to the explanation:
# id# is the the number of the skill tree, just a number
# :name is just the name of the skill tree
# :skills is where you set up each branch of the tree
#   :skillname is just a simple identifier, can be anything
#   :name is the name of the branch that appears in the menu
#   :icon is the id of the icon to be displayed in the tree selection
#   :background is the image to be displayed behind the tree (Graphics/System)
###   :background can also be set to :simple for a simple rowed background
#   :skillids is the list of skills learned, more skills = more ranks
#   :replace - skill from next rank will replace skill from previous rank
#   :spcost is the cost in SP it takes to learn one rank of a branch
#   :splock means you have to have spent that much SP to learn that branch
#   :prevlock is a list of :skillnames that have to be learnt to learn that branch
#   :row is the vertical position of the branch (it's # * 24)
#   :col is the horizontal position of the branch (also # * 24)
#
# I'll have to explain this better at some point, but I can't get around it right
#  now. The example below should be able to provide a lot of answers!
 
SKILL_TREES = {
 
  0 => {
    :name => "Paladin",
    :desc => "The mighty Paladin, master of sword and holy magic.",
    :icon => 15,
    :background => "GameOver",
    :skills => {
      :hpboost => { :name => "HP Boost [Passive]",
        :skillids => [76,77,78],
        :replace => true,
        :row => 0, :col => 3
      },
      :combostrike => { :name => "Combo Strike [Ability]",
        :skillids => [80], :spcost => 2,
        :row => 0, :col => 6
      },
      :cover => { :name => "Cover [Ability]",
        :skillids => [90], :spcost => 2,
        :splock => 3, :statlock => [[:hp,750],[:def, 25]],
        :row => 2, :col => 2
      },
      :cure1 => { :name => "Minor Cure [Spell]",
        :skillids => [31], :spcost => 3,
        :splock => 3, :statlock => [[:int, 25]],
        :row => 2, :col => 5
      },
      :cleave => { :name => "Cleave [Ability]",
        :skillids => [81], :spcost => 2,
        :splock => 3, :lvllock => 10,
        :row => 2, :col => 8
      },
      :provoke => { :name => "Provoke [Ability]",
        :skillids => [91], :spcost => 2,
        :splock => 10, :prevlock => [:cover,:cleave],
        :row => 4, :col => 3
      },
      :defup => { :name => "Def Boost [Passive]",
        :skillids => [72,73,74],
        :splock => 10, :lvllock => 15,
        :row => 4, :col => 6
      },
      :cure2 => { :name => "Super Cure [Spell]",
        :skillids => [32], :spcost => 4,
        :splock => 17, :prevlock => [:cure1],
        :row => 6, :col => 5
      }
    },
  },
 
}
 
class Game_Actor
  attr_accessor :active_skill_tree
  attr_accessor :skill_points
  attr_accessor :spent_skill_points
  alias sktree_init initialize
  def initialize(*args)
    sktree_init(*args)
    @active_skill_tree = {}
    @skill_points = 0
    @spent_skill_points = {}
    $data_classes[@class_id].skill_trees.each do |id|
      add_skill_tree(id)
    end
    add_skill_tree(actor.skill_tree) if actor.skill_tree
  end
  def add_skill_tree(id)
    skill_tree = SKILL_TREES[id].clone
    skill_tree[:skills].each do |key,hash|
      hash[:rank] = 0
    end
    @active_skill_tree[id] = skill_tree
    @spent_skill_points[id] = 0
  end
  def remove_skill_tree(id)
    reset_skill_tree(id)
    @active_skill_tree.delete(id)
    @spent_skill_points.delete(id)
  end
  def skill_upgrade_valid?(tree_id, skill_id)
    if skill_id.is_a?(Integer)
      skill_id = @active_skill_tree[tree_id][:skills].keys[skill_id]
    end
    sktree = @active_skill_tree[tree_id][:skills][skill_id]
    return false if @skill_points < (sktree[:spcost] ? sktree[:spcost] : 1)
    return false if sktree[:rank] >= sktree[:skillids].size
    if sktree[:lvllock]
      return false if @level < sktree[:lvllock]
    end
    if sktree[:statlock]
      id = [:hp,:mp,:atk,:def,:int,:wis,:agi,:luk]
      sktree[:statlock].each do |array|
        return false if param(id.index(array[0])) < array[1]
      end
    end
    if sktree[:splock]
      return false if @spent_skill_points[tree_id] < sktree[:splock]
    end
    if sktree[:prevlock]
      sktree[:prevlock].each do |key|
        nextskill = @active_skill_tree[tree_id][:skills][key]
        return false if nextskill[:rank] < nextskill[:skillids].size
      end
    end
    return true
  end
  def increase_rank(tree_id, skill_id)
    if skill_id.is_a?(Integer)
      skill_id = @active_skill_tree[tree_id][:skills].keys[skill_id]
    end
    sktree = @active_skill_tree[tree_id][:skills][skill_id]
    if sktree[:replace] && sktree[:rank] > 0
      forget_skill(sktree[:skillids][sktree[:rank]-1])
    end
    learn_skill(sktree[:skillids][sktree[:rank]])
    sktree[:rank] += 1
    @skill_points -= (sktree[:spcost] ? sktree[:spcost] : 1)
    @spent_skill_points[tree_id] += (sktree[:spcost] ? sktree[:spcost] : 1)
  end
  def reset_skill_tree(id)
    @active_skill_tree[id][:skills].keys.each do |key|
      sktree = @active_skill_tree[id][:skills][key]
      while sktree[:rank] > 0
        sktree[:rank] -= 1
        forget_skill(sktree[:skillids][sktree[:rank]])
        @skill_points += (sktree[:spcost] ? sktree[:spcost] : 1)
        @spent_skill_points[id] -= (sktree[:spcost] ? sktree[:spcost] : 1)
      end
    end
  end
  def increase_skill_points(amount)
    @skill_points += amount
  end
  alias sktree_level_up level_up
  def level_up
    sktree_level_up
    if @level % actor.spoint_level == 0
      increase_skill_points(actor.spoint_gain)
    end
  end
  alias skill_change_class change_class
  def change_class(class_id, keep_exp = false)
    old_trees = $data_classes[@class_id].skill_trees
    new_trees = $data_classes[class_id].skill_trees
    old_level = @level
    skill_change_class(class_id, keep_exp)
    (new_trees - old_trees).each do |id|
      add_skill_tree(id)
    end
    (old_trees - new_trees).each do |id|
      remove_skill_tree(id)
    end
    if old_level < @level
      (@level - old_level).times do |i|
        if (old_level + i) % actor.spoint_level == 0
          increase_skill_points(-actor.spoint_gain)
        end
      end
    end
  end
  def item_effect_grow(user, item, effect)
    if item.skill_book
      increase_skill_points(effect.value1.to_i)
    else
      add_param(effect.data_id, effect.value1.to_i)
    end
    @result.success = true
  end
end
 
class RPG::Item
  def skill_book
    self.note =~ /<SKILL_BOOK>/ ? true : false
  end
end
 
class RPG::Class
  def skill_trees
    self.note =~ /<SKILL_TREES (.+)>/ ? eval($1) : []
  end
end
 
 
class RPG::Actor
  def spoint_gain
    self.note =~ /<SP_PER (\d+)>/ ? $1.to_i : DEFAULT_POINTS_GAINED
  end
  def spoint_level
    self.note =~ /<SP_LEVEL (\d+)>/ ? $1.to_i : DEFAULT_LEVEL_MOD
  end
  def skill_tree
    self.note =~ /<SKILL_TREE (\d+)>/ ? $1.to_i : false
  end
end
 
class Scene_SkillTree < Scene_MenuBase
  def start
    super
    @actor = $game_party.menu_actor
    @help_window = Window_Help.new(1)
    @category_window = Window_STCat.new
    @category_window.set_handler(:ok, method(:cat_ok))
    @category_window.set_handler(:cancel, method(:cat_cancel))
    @tree_window = Window_STTree.new(cur_item)
    @tree_window.set_handler(:ok, method(:on_tree_ok))
    @tree_window.set_handler(:cancel, method(:on_tree_cancel))
    @actor_window = Window_STActor.new
    @skill_window = Window_STSkill.new(cur_item)
    @text = ""
  end
  def cat_ok
    @tree_window.activate
    @tree_window.select(0)
  end
  def on_tree_ok
    @tree_window.activate
    return Sound.play_buzzer unless @actor.skill_upgrade_valid?(cur_item,@tree_window.index)
    @actor.increase_rank(cur_item,@tree_window.index)
    Sound.play_ok
    @tree_window.refresh
    @skill_window.refresh
    @actor_window.refresh
    Sound.play_buzzer
  end
  def cur_item
    @category_window.cur_item
  end
  def cat_cancel
    SceneManager.return
  end
  def on_tree_cancel
    @category_window.activate
    @tree_window.select(-1)
  end
  def update
    super
    if @tree_window.current_tree != cur_item
      @tree_window.current_tree = cur_item
      @skill_window.current_tree = cur_item
      @tree_window.refresh
      @skill_window.refresh
    end
    @skill_window.set_skill(@tree_window.current_item)
    return unless @actor.active_skill_tree[cur_item]
    sym = @actor.active_skill_tree[cur_item][:skills].keys[@tree_window.index]
    if @actor.active_skill_tree[cur_item][:desc]
      text = @actor.active_skill_tree[cur_item][:desc]
    else
      text = ""
    end
    if @text != text
      @text = text
      @help_window.set_text(@text)
    end
  end
  def terminate
    super
  end
end
 
class Window_STCat < Window_HorzCommand
  def initialize
    super(0,48) #,Graphics.width/2,48)
    @actor = $game_party.menu_actor
    @index = 0
    activate
    refresh
  end
  def col_max; 3; end
  def ensure_cursor_visible2
    self.top_col = index - 1 if index < top_col
    self.bottom_col = index + 1 if index > bottom_col
  end
  def window_width; Graphics.width/2; end
  def window_height; 48; end
  def item_max
    @actor ? @actor.active_skill_tree.keys.size : 0
  end
  def current_item
    @actor.active_skill_tree[cur_item][:name]
  end
  def cur_item
    @actor.active_skill_tree.keys[index]
  end
  def item(id)
    @actor.active_skill_tree[@actor.active_skill_tree.keys[id]]
  end
  def spacing; 12; end
  def draw_item(index)
    rect = item_rect(index)
    item = item(index)
    draw_icon(item[:icon],rect.x,rect.y) if item[:icon]
    rect.x += 24;rect.width -= 24
    draw_text(rect,item[:name])
  end
  def current_item_enabled?
    !cur_item.nil?
  end
end
 
class Window_STTree < Window_Selectable
  attr_accessor :current_tree
  def initialize(tree)
    super(0,48*2,Graphics.width/2,Graphics.height-48*2)
    @actor = $game_party.menu_actor
    @index = -1
    @current_tree = tree
    refresh
  end
  def ensure_cursor_visible
  end
  def item_width; 48; end
  def item_height; 24; end
  def item_rect(index)
    Rect.new(current_item[:col]*24,current_item[:row]*24,48,24)
  end
  def item_max
    return 0 unless @actor
    @actor.active_skill_tree[@current_tree][:skills].values.size
  end
  def current_item
    return nil unless @actor
    return nil if @index == -1
    @actor.active_skill_tree[@current_tree][:skills].values[@index]
  end
  def refresh
    contents.clear
    return unless @actor
    skilltree = @actor.active_skill_tree[@current_tree]
    return unless skilltree
    if skilltree[:background]
      if skilltree[:background] == :simple
        (contents.height/24).times do |i|
          i % 2 == 0 ? color = Color.new(150,150,150,75) : color = Color.new(150,150,150,30)
          contents.fill_rect(0,24*i,contents.width,24,color)
        end
      else
        bitmap = Cache.system(skilltree[:background])
        contents.blt(0,0,bitmap,bitmap.rect,175)
      end
    end
    skilltree[:skills].each do |key, skillhash|
      change_color(normal_color, @actor.skill_upgrade_valid?(@current_tree,key))
      skill = $data_skills[skillhash[:skillids][0]]
      x, y = skillhash[:col] * 24, skillhash[:row] * 24
      draw_icon(skill.icon_index,x,y,@actor.skill_upgrade_valid?(@current_tree,key))
      draw_text(x+24,y,24,24,skillhash[:rank].to_s + "/" + skillhash[:skillids].size.to_s)
    end
    contents.font.size = 20
    change_color(system_color)
    draw_text(0,contents.height-20,contents.width,20,"SP Spent: ")
    change_color(normal_color)
    draw_text(0,contents.height-20,contents.width/2,20,@actor.spent_skill_points[@current_tree],2)
    reset_font_settings
  end
  def process_ok
    if current_item_enabled?
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  def cursor_up(wrap = false)
    next_skill = nil
    next_key = nil
    tree = @actor.active_skill_tree[@current_tree][:skills]
    curr_skill = tree[@actor.active_skill_tree[@current_tree][:skills].keys[@index]]
    tree.each do |key, hash|
      next if hash[:row] >= curr_skill[:row]
      if next_skill == nil
        next_skill = tree[key]
        next_key = key
        next
      else
        if next_skill[:row] == hash[:row]
          if (curr_skill[:col] - hash[:col]).abs < (curr_skill[:col] - next_skill[:col]).abs
            next_skill = tree[key]
            next_key = key
          end
        end
        if hash[:row] > next_skill[:row] && hash[:row] < curr_skill[:row]
          next_skill = tree[key]
          next_key = key
        end
        next
      end
    end
    if next_key
      select(@actor.active_skill_tree[@current_tree][:skills].keys.index(next_key))
    end
  end
  def cursor_down(wrap = false)
    next_skill = nil
    next_key = nil
    tree = @actor.active_skill_tree[@current_tree][:skills]
    curr_skill = tree[@actor.active_skill_tree[@current_tree][:skills].keys[@index]]
    tree.each do |key, hash|
      next if hash[:row] <= curr_skill[:row]
      if next_skill == nil
        next_skill = tree[key]
        next_key = key
        next
      else
        if next_skill[:row] == hash[:row]
          if (curr_skill[:col] - hash[:col]).abs < (curr_skill[:col] - next_skill[:col]).abs
            next_skill = tree[key]
            next_key = key
          end
        end
        if hash[:row] < next_skill[:row] && hash[:row] > curr_skill[:row]
          next_skill = tree[key]
          next_key = key
        end
        next
      end
    end
    if next_key
      select(@actor.active_skill_tree[@current_tree][:skills].keys.index(next_key))
    end
  end
  def cursor_left(wrap = false)
    next_skill = nil
    next_key = nil
    tree = @actor.active_skill_tree[@current_tree][:skills]
    curr_skill = tree[@actor.active_skill_tree[@current_tree][:skills].keys[@index]]
    tree.each do |key, hash|
      next if hash[:col] >= curr_skill[:col]
      next if hash[:row] != curr_skill[:row]
      if next_skill == nil
        next_skill = tree[key]
        next_key = key
        next
      else
        if hash[:col] > next_skill[:col]
          next_skill = tree[key]
          next_key = key
        end
        next
      end
    end
    if next_key
      select(@actor.active_skill_tree[@current_tree][:skills].keys.index(next_key))
    end
  end
  def cursor_right(wrap = false)
    next_skill = nil
    next_key = nil
    tree = @actor.active_skill_tree[@current_tree][:skills]
    curr_skill = tree[@actor.active_skill_tree[@current_tree][:skills].keys[@index]]
    tree.each do |key, hash|
      next if hash[:col] <= curr_skill[:col]
      next if hash[:row] != curr_skill[:row]
      if next_skill == nil
        next_skill = tree[key]
        next_key = key
        next
      else
        if hash[:col] < next_skill[:col]
          next_skill = tree[key]
          next_key = key
        end
        next
      end
    end
    if next_key
      select(@actor.active_skill_tree[@current_tree][:skills].keys.index(next_key))
    end
  end
end
 
class Window_STActor < Window_Base
  def initialize
    super(Graphics.width/2,48,Graphics.width/2,96+24)
    @actor = $game_party.menu_actor
    refresh
  end
  def set_actor(actor)
    return if actor == @actor
    @actor = actor
    refresh
  end
  def refresh
    contents.clear
    return unless @actor
    draw_actor_face(@actor,0,0)
    draw_actor_name(@actor,96+12,0)
    draw_actor_level(@actor,96+12,24)
    draw_text(96+12,24*2,contents.width,24,"SP: " + @actor.skill_points.to_s)
  end
end
 
class Window_STSkill < Window_Base
  attr_accessor :current_tree
  def initialize(tree)
    super(Graphics.width/2,48+96+24,Graphics.width/2,Graphics.height-48-96-24)
    @skill = nil
    @current_tree = tree
    @actor = $game_party.menu_actor
    contents.font.size = line_height
    refresh
  end
  def set_actor(actor)
    return if actor == @actor
    @actor = actor
  end
  def set_skill(skill)
    return if @skill == skill
    @skill = skill
    refresh
  end
  def line_height
    20
  end
  def refresh
    contents.clear
    return unless @skill
    change_color(system_color)
    draw_text(0,0,contents.width,24,"SP Cost:")
    draw_text(0,line_height,contents.width,line_height,"Current:")
    draw_text(0,line_height*4,contents.width,line_height,"Next:")
    draw_text(0,line_height*7,contents.width,line_height,"Requirements:")
    change_color(normal_color)
    draw_text(0,0,contents.width,line_height,(@skill[:spcost] ? @skill[:spcost] : 1).to_s,2)
    if @skill[:rank] > 0
      skill = $data_skills[@skill[:skillids][@skill[:rank]-1]]
      draw_icon(skill.icon_index,contents.width-text_size(skill.name).width-24,line_height)
      draw_text(0,line_height,contents.width,line_height,skill.name,2)
      draw_text_ex(0,line_height*2,skill.description)
    else
      draw_text_ex(0,line_height*2,"   -----")
    end
    if @skill[:rank] < @skill[:skillids].size
      skill = $data_skills[@skill[:skillids][@skill[:rank]]]
      draw_icon(skill.icon_index,contents.width-text_size(skill.name).width-24,line_height*4)
      draw_text(0,line_height*4,contents.width,line_height,skill.name,2)
      draw_text_ex(0,line_height*5,skill.description)
    else
      draw_text_ex(0,line_height*5,"   -----")
    end
    if @skill[:splock] || @skill[:prevlock] || @skill[:lvllock] || @skill[:statlock]
      yy = line_height * 8
      if @skill[:splock]
        change_color(normal_color, @actor.spent_skill_points[@current_tree] >= @skill[:splock])
        draw_text(12,yy,contents.width-12,line_height,"SP Spent: " + @skill[:splock].to_s)
        yy += line_height
      end
      if @skill[:lvllock]
        change_color(normal_color, @actor.level >= @skill[:lvllock])
        draw_text(12,yy,contents.width-12,line_height,"Level: " + @skill[:lvllock].to_s)
        yy += line_height
      end
      if @skill[:statlock]
        xx = 12
        id = [:hp,:mp,:atk,:def,:int,:wis,:agi,:luk]
        @skill[:statlock].each do |array|
          param_id = id.index(array[0])
          change_color(normal_color,@actor.param(param_id) >= array[1])
          text = Vocab::param(param_id) + ":" + array[1].to_s
          width = text_size(text).width
          if xx + width > contents.width
            xx = 12; yy += line_height
          end
          draw_text(xx,yy,contents.width,line_height,text)
          xx += width + 6
        end
      end
      if @skill[:prevlock]
        xx = 12
        @skill[:prevlock].each do |sym|
          olskill = @actor.active_skill_tree[@current_tree][:skills][sym]
          text = "["+olskill[:name]+"]"
          width = text_size(text).width
          if xx + width > contents.width
            xx = 12
            yy += line_height
          end
          change_color(normal_color, olskill[:rank] >= olskill[:skillids].size)
          draw_text(xx,yy,contents.width,line_height,text)
          xx += width
        end
      end
    else
      draw_text(0,line_height*8,contents.width,line_height,"None")
    end
  end
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
end
 
class Window_MenuCommand < Window_Command
  alias sktree_aoc add_original_commands
  def add_original_commands
    sktree_aoc
    add_command("Skill Tree", :skilltree)
  end
end
 
class Scene_Menu
  alias sktree_ccw create_command_window
  def create_command_window
    sktree_ccw
    @command_window.set_handler(:skilltree,    method(:command_personal))
  end
  alias sktree_opo on_personal_ok
  def on_personal_ok
    sktree_opo
    SceneManager.call(Scene_SkillTree) if @command_window.current_symbol == :skilltree
  end
end
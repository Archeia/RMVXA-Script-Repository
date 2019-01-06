#Advanced Recipe Crafting v1.2
#----------#
#Features: Advanced Recipe crafting! Hold on tight!
#
#Usage:    Set up your recipes, learn recipes, make items! Yay!
#       $crafting_category = :craft         - call before Scene, craft is category
#       SceneManager.call(Scene_Crafting)   - opens the Crafting menu
#       SceneManager.call(Scene_CraftingAll)- opens the category Crafting menu
#       learn_recipe(id)                    - teaches that recipe
#       forget_recipe(id)                   - forgets that recipe
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
 
module ADV_RECIPE
#Whether or not crafted items use Weapon/Armor Randomization
  USE_WA_RANDOMIZATION = false
#The names of the categories for All Crafting Menu, use :All for all recipes
  CATEGORIES = [:Alchemy,:Blacksmith,:Tailor,:Armorer,:Carpenter,:Builder,:Etceterer]
  DESCRIPTIONS = {
    :Alchemy => "This skill allows you to mix this and that. Potion!",
    :Tailor => "The ability to sew numerous things together to make another thing.",
    :Carpenter => "Everything's made out of wood."
  }
#The icons for categories, same order as above
  CATEGORY_ICONS = [10,199,284,332,0,0,0]
#The icon for player level
  LEVEL_ICON = 117
#Xp needed for crafting level, lvl is used for current level
  XP_NEEDED_EQUATION = "100 * lvl"
#Allow the crafting of multiple items
  CRAFT_MULTIPLE = true
#Allow or disallow menu access to the crafting scene
  ENABLE_MENU_ACCESS = true
#Disable crafting from menu (turning it into a recipe viewer)
  DISABLE_MENU_CRAFT = false
#Font Size of Detail window, smaller font size creates more room for materials
  DETAIL_FONT_SIZE = 18
  
 
#The following options disable the display of certain features. They still work
# however if declared in recipes, so edit recipes accordingly.
#Removes Gold Cost
  DISABLE_GOLD_COST = false
#Removes success rate
  DISABLE_SUCCESS = false
#Removes player level requirement
  DISABLE_PLAYER_LEVEL = false
#Removes crafting level requirement and gauge
  DISABLE_CRAFT_LEVEL = false
#Auto-learn all skills (can use forget_recipe to forget certain ones for later)
  AUTO_LEARN_RECIPES = true
 
 
#The fun (read: complicated) part!
#Recipe symbols:
#
#The crafted item, type is 0 for item, 1 for weapon, 2 for armor
# :result => [type,id,amount]
#
#The materials required, same style as result.
# :materials => [ [type,id,amount,consumed?],[type,id,amount] ... ],
#
#  All the following are optional:
# :gold_cost => amount          - amount of gold to craft, can be 0
# :success => percent           - base percent chance of successful craft
# :success_gain => percent      - percent gain on success per crafting level
# :level => value               - Hero level required to craft
# :craft_level => value         - Crafting level required to craft
# :category => :category        - Crafting category (:Alchemy, :Tailor, etc)
# :multiple => false            - disallows multiple crafts
# :xp => amount                 - base Crafting xp gained per craft
# :xp_deprac => amount          - Xp lost per crafting level
# :pxp => amount                - Player xp gainer per craft
 
# Formula for xp gained is as follows and is never negative:
#  xp gain = xp - (current_level - recipe_level) * xp_deprac
 
  RECIPES = {
  0 => { :result => [0,1,1],
         :materials => [[0,4,2]],
         :gold_cost => 10,
         :success => 95,
         :success_gain => 1,
         :level => 5,
         :craft_level => 1,
         :category => :Alchemy,
         :xp => 50,
         :xp_deprac => 15,},
         
  1 => { :result => [0,2,1],
         :materials => [[1,4,1],[0,5,2,false]],
         :gold_cost => 50,
         :success => 90,
         :success_gain => 2,
         :level => 15,
         :craft_level => 1,
         :category => :Alchemy,
         :xp => 150,
         :xp_deprac => 20,},
         
  2 => { :result => [0,3,1],
         :materials => [[0,4,1],[0,5,1],[0,6,2],[0,7,1],[0,8,1],[0,9,2]],
         :gold_cost => 150,
         :success => 85,
         :success_gain => 3,
         :level => 25,
         :craft_level => 1,
         :category => :Alchemy,
         :xp => 250,
         :xp_deprac => 25,},
         
  }
 
end
 
$crafting_category = :All
class Recipe
  attr_accessor :result
  attr_accessor :materials
  attr_accessor :known
  attr_accessor :id
  attr_accessor :gold_cost
  attr_accessor :level
  attr_accessor :category
  attr_accessor :xp
  def initialize(id,recipe_hash)
    @id = id
    @result = Material.new(recipe_hash[:result])
    @materials = []
    for item in recipe_hash[:materials]
      @materials.push(Material.new(item))
    end
    @known = false
    recipe_hash[:gold_cost] ? @gold_cost = recipe_hash[:gold_cost] : @gold_cost = 0
    recipe_hash[:success] ? @rate = recipe_hash[:success] : @rate = 100
    recipe_hash[:success_gain] ? @rated = recipe_hash[:success_gain] : @rated = 0
    recipe_hash[:level] ? @level = recipe_hash[:level] : @level = 1
    recipe_hash[:category] ? @category = recipe_hash[:category] : @category = CATEGORIES[0]
    recipe_hash[:xp] ? @xp = recipe_hash[:xp] : @xp = 0
    recipe_hash[:xp_deprac] ? @xpd = recipe_hash[:xp_deprac] : @xpd = 0
    recipe_hash[:craft_level] ? @clevel = recipe_hash[:craft_level] : @clevel = 0
    recipe_hash[:pxp] ? @pxp = recipe_hash[:pxp] : @pxp = 0
    !recipe_hash[:multiple].nil? ? @mult = recipe_hash[:multiple] : @mult = true
    @known = ADV_RECIPE::AUTO_LEARN_RECIPES
  end
  def name
    return @result.item.name
  end
  def multiple?
    @mult
  end
  def has_materials?
    for item in @materials
      return false unless $game_party.item_number(item.item) >= item.amount
    end
    return true
  end
  def has_gold?
    $game_party.gold >= @gold_cost
  end
  def has_craft_level?
    craft_level <= $game_party.craft_level_sym(@category)
  end
  def has_level?
    @level <= $game_party.highest_level && has_craft_level?
  end
  def craftable?
    has_gold? && has_materials? && has_level?
  end
  def craft_level
    @clevel
  end
  def amount_craftable?
    mat_amount = []
    for item in @materials
      mat_amount.push($game_party.item_number(item.item) / item.amount)
    end
    if @gold_cost > 0
      return [$game_party.gold / @gold_cost,mat_amount.min].min
    else
      return mat_amount.min
    end
  end
  def craft(fail = 0)
    remove_materials
    if fail < success_rate
      return add_result
    else
      return nil
    end
  end
  def remove_materials
    for item in @materials
      next unless item.consumed?
      $game_party.gain_item(item.item,-item.amount)
    end
    $game_party.gain_gold(-@gold_cost)
  end
  def add_result
    if ADV_RECIPE::USE_WA_RANDOMIZATION
      item = $game_party.add_weapon(@result.item.id,@result.amount) if @result.item.is_a?(RPG::Weapon)
      item = $game_party.add_armor(@result.item.id,@result.amount) if @result.item.is_a?(RPG::Armor)
      item = $game_party.add_item(@result.item.id,@result.amount) if @result.item.is_a?(RPG::Item)
    else
      $game_party.gain_item(@result.item,@result.amount)
      item = @result.item
    end
    $game_party.gain_craft_exp(category_id, xp_gain)
    $game_party.members.each do |actor|
      actor.gain_exp(@pxp)
    end
    item
  end
  def category_id
    ADV_RECIPE::CATEGORIES.index(@category)
  end
  def xp_gain
    level_diff = $game_party.craft_level(category_id) - @clevel
    [@xp - @xpd * level_diff,0].max
  end
  def success_rate
    level_diff = $game_party.craft_level(category_id) - @clevel
    [@rate + @rated * level_diff,100].min
  end
end
 
class Material
  attr_accessor :item
  attr_accessor :amount
  def initialize(mat)
    @item = $data_items[mat[1]] if mat[0] == 0
    @item = $data_weapons[mat[1]] if mat[0] == 1
    @item = $data_armors[mat[1]] if mat[0] == 2
    @amount = mat[2]
    @consumed = mat[3].nil? ? true : mat[3]
  end
  def consumed?
    @consumed
  end
end
 
class Game_Party
  alias recipe_init initialize
  def initialize
    recipe_init
    @crafting_level = [1]*ADV_RECIPE::CATEGORIES.size
    @craft_exp = [0]*ADV_RECIPE::CATEGORIES.size
  end
  def craft_level(id)
    @crafting_level[id]
  end
  def craft_level_sym(sym)
    @crafting_level[ADV_RECIPE::CATEGORIES.index(sym)]
  end
  def craft_exp(id)
    @craft_exp[id]
  end
  def craft_exp_next(id)
    lvl = craft_level(id)
    return eval(ADV_RECIPE::XP_NEEDED_EQUATION)
  end
  def gain_craft_exp(id, val)
    @craft_exp[id] += val
    while craft_exp(id) >= craft_exp_next(id)
      @craft_exp[id] -= craft_exp_next(id)
      @crafting_level[id] += 1
    end
  end
end
 
module DataManager
  class << self
    alias rec_cgo create_game_objects
    alias rec_msc make_save_contents
    alias rec_esc extract_save_contents
  end
  def self.create_game_objects
    rec_cgo
    $game_recipes = create_recipes
  end
  def self.make_save_contents
    contents = rec_msc
    contents[:recipe] = $game_recipes
    contents
  end
  def self.extract_save_contents(contents)
    rec_esc(contents)
    $game_recipes = contents[:recipe]
  end
  def self.create_recipes
    recipes = {}
    ADV_RECIPE::RECIPES.each_pair do |key, val|
      recipes[key] = Recipe.new(key,val)
    end
    recipes
  end
end
 
class Game_Interpreter
  def learn_recipe(id)
    return if $game_recipes[id].nil?
    $game_recipes[id].known = true
  end
  def forget_recipe(id)
    return if $game_recipes[id].nil?
    $game_recipes[id].known = false
  end
end
 
class Window_RecipeList < Window_Selectable
  def initialize(x,y,w,h)
    super
    @data = $game_recipes.values.select {|recipe| include?(recipe)}
    refresh
  end
  def item_max
    @data ? @data.size : 1
  end
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  def current_item_enabled?
    enable?(@data[index])
  end
  def include?(item)
    return false unless item.has_craft_level?
    return false unless item.known
    return true if @category == :All
    return @category == item.category
  end
  def set_category(cat)
    return if cat == @category
    @category = cat
    @data = $game_recipes.values.select {|recipe| include?(recipe)}
    refresh
  end
  def enable?(item)
    return false if item.nil?
    return false if $temp_disable_crafting
    item.craftable?
  end
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      enabled = $temp_disable_crafting ? true : enable?(item)
      draw_item_name(item.result.item, rect.x, rect.y, enabled)
      if item.amount_craftable? > 0
        draw_text(rect.x,rect.y,contents.width,24,"x"+item.amount_craftable?.to_s,2)
      end
    end
  end
  def current_item
    index >= 0 ? @data[index] : nil
  end
  def process_ok
    if current_item_enabled?
      Sound.play_ok
      Input.update
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  def refresh
    create_contents
    super
  end
  def content_heights
    item_max * 24
  end
end
 
class Window_RecipeDetail < Window_Base
  def initialize(x,y,w,h)
    super
    @recipe = nil
  end
  def set_recipe(recipe)
    @recipe = recipe
    refresh
  end
  def refresh
    contents.clear
    contents.font.size = ADV_RECIPE::DETAIL_FONT_SIZE
    return if @recipe.nil?
    draw_craft_level unless ADV_RECIPE::DISABLE_PLAYER_LEVEL && ADV_RECIPE::DISABLE_CRAFT_LEVEL
    draw_materials
    draw_success_rate unless ADV_RECIPE::DISABLE_SUCCESS
    draw_gold_cost unless ADV_RECIPE::DISABLE_GOLD_COST
  end
  def draw_craft_level
    change_color(system_color, @recipe.has_level?)
    draw_text(0,0,contents.width,contents.font.size,"Craft Level:")
    change_color(normal_color, @recipe.has_level?)
    xx = 0
    if !ADV_RECIPE::DISABLE_PLAYER_LEVEL
      draw_text(0,0,contents.width,contents.font.size,@recipe.level,2)
      draw_icon(ADV_RECIPE::LEVEL_ICON,contents.width - 48,0)
      xx += 48
      text = @recipe.craft_level.to_s + "/"
    else
      text = @recipe.craft_level.to_s
    end
    if !ADV_RECIPE::DISABLE_CRAFT_LEVEL
      draw_text(0,0,contents.width - xx,contents.font.size,text,2)
      draw_icon(ADV_RECIPE::CATEGORY_ICONS[ADV_RECIPE::CATEGORIES.index(@recipe.category)],contents.width - 56 - xx,0)
    end
  end
  def draw_materials
    if ADV_RECIPE::DISABLE_CRAFT_LEVEL && ADV_RECIPE::DISABLE_PLAYER_LEVEL
      yy = 0
    else
      yy = contents.font.size
    end
    change_color(system_color, @recipe.craftable?)
    draw_text(0,yy,self.width,contents.font.size,"Required:")
    yy += contents.font.size
    for item in @recipe.materials
      change_color(normal_color, $game_party.item_number(item.item) >= item.amount)
      draw_icon(item.item.icon_index,0,yy)
      draw_text(24,yy,self.width,contents.font.size,item.item.name)
      string = $game_party.item_number(item.item).to_s + "/" + item.amount.to_s
      draw_text(0,yy,self.contents.width,contents.font.size,string,2)
      yy += contents.font.size
    end
  end
  def draw_success_rate
    change_color(system_color, @recipe.craftable?)
    draw_text(0,contents.height-contents.font.size,contents.width,contents.font.size,"Success Rate:")
    change_color(normal_color, @recipe.craftable?)
    draw_text(0,contents.height-contents.font.size,contents.width,contents.font.size,@recipe.success_rate.to_s + "%",2)
  end
  def draw_gold_cost
    if @recipe.gold_cost > 0
      change_color(system_color, @recipe.has_gold?)
      draw_text(0,contents.height-contents.font.size*2,contents.width,contents.font.size,"Crafting Cost:")
      change_color(normal_color, @recipe.has_gold?)
      draw_currency_value(@recipe.gold_cost,Vocab::currency_unit,0,contents.height-contents.font.size*2,contents.width)
    end  
  end
  def draw_currency_value(value, unit, x, y, width)
    cx = text_size(unit).width
    change_color(normal_color,$game_party.gold >= value)
    draw_text(x, y, width - cx - 2, contents.font.size, value, 2)
    change_color(system_color)
    draw_text(x, y, width, contents.font.size, unit, 2)
  end
end
 
class Window_RecipeConfirm < Window_Selectable
  attr_accessor :amount
  def initialize(x,y,w,h)
    super
    @amount = 1
    refresh
  end
  def item_max; 1; end;
  def enable?(item); true; end;
  def refresh
    super
    draw_text(0,0,self.contents.width,line_height,"Craft",1)
    return unless @recipe && @recipe.craftable?
    draw_text(0,0,contents.width,line_height,"x"+@amount.to_s,2)
  end
  def activate
    super
    select(0)
  end
  def deactivate
    super
    select(-1)
  end
  def set_recipe(rec)
    return if rec == @recipe
    @recipe = rec
    @amount = 1
    refresh
  end
  def cursor_movable?
    active && open? && ADV_RECIPE::CRAFT_MULTIPLE && @recipe.multiple?
  end
  def cursor_down(wrap = false)
    change_amount(-10)
  end
  def cursor_up(wrap = false)
    change_amount(10)
  end
  def cursor_right(wrap = false)
    change_amount(1)
  end
  def cursor_left(wrap = false)
    change_amount(-1)
  end
  def change_amount(val)
    Sound.play_cursor
    @amount += val
    @amount = [[@amount,1].max,@recipe.amount_craftable?].min
    refresh
  end
end
 
class Scene_CraftingAll < Scene_Base
  def start
    super
    @help_window = Window_Help.new
    width = Graphics.width / 2
    height = Graphics.height - @help_window.height - 48
    @list_window = Window_RecipeList.new(0,@help_window.height+48,width,height-48)
    @list_window.set_handler(:ok, method(:list_success))
    @list_window.set_handler(:cancel, method(:cancel))
    @list_window.height += 48 if ADV_RECIPE::DISABLE_CRAFT_LEVEL
    @list_window.create_contents
    @detail_window = Window_RecipeDetail.new(width,@list_window.y,width,height-48*2)
    @detail_window.height += 48 if ADV_RECIPE::DISABLE_GOLD_COST
    @detail_window.create_contents
    height = @detail_window.y + @detail_window.height
    @confirm_window = Window_RecipeConfirm.new(width,height,width,48)
    @confirm_window.set_handler(:ok, method(:craft_success))
    @confirm_window.set_handler(:cancel, method(:confirm_cancel))
    if !ADV_RECIPE::DISABLE_GOLD_COST
      @gold_window = Window_Gold.new
      @gold_window.width = width
      @gold_window.y = Graphics.height - 48
      @gold_window.x = width
    end
    @popup_window = Window_RecPopup.new
    @popup_window.set_handler(:ok, method(:popup_ok))
    @popup_window.set_handler(:cancel, method(:popup_ok))
    @command_window = Window_RecCategory.new
    @command_window.set_handler(:ok, method(:command_ok))
    @command_window.set_handler(:cancel, method(:command_cancel))
    @gauge_window = Window_RecGauge.new unless ADV_RECIPE::DISABLE_CRAFT_LEVEL
  end
  def popup_ok
    @popup_window.deactivate
    @popup_window.close
    @list_window.activate
  end
  def update
    super
    @help_window.set_text(@list_window.current_item.result.item.description) if !@list_window.current_item.nil?
    if @command_window.active
      category = ADV_RECIPE::CATEGORIES[@command_window.index]
      @help_window.set_text(ADV_RECIPE::DESCRIPTIONS[category])
    end
    @detail_window.set_recipe(@list_window.current_item)
    @confirm_window.set_recipe(@list_window.current_item)
    @list_window.set_category(ADV_RECIPE::CATEGORIES[@command_window.index])
    @gauge_window.set_category(ADV_RECIPE::CATEGORIES[@command_window.index]) unless ADV_RECIPE::DISABLE_CRAFT_LEVEL
    return unless @list_window.current_item
    if @list_window.current_item.craftable?
      @confirm_window.opacity = 255
      @confirm_window.contents_opacity = 255
    else
      @confirm_window.opacity = 75
      @confirm_window.contents_opacity = 75
    end
  end
  def list_success
    @list_window.deactivate
    @confirm_window.activate
  end
  def craft_success
    amount = 0
    item = nil
    @confirm_window.amount.times do
      item2 = @list_window.current_item.craft(rand(100))
      if item2
        amount += 1
        item = item2
      end
    end
    if item
      @popup_window.set_text(item, amount)
    else
      @popup_window.set_text_fail
    end
    @confirm_window.change_amount(-1000)
    @gold_window.refresh unless ADV_RECIPE::DISABLE_GOLD_COST
    @list_window.refresh
    @gauge_window.refresh unless ADV_RECIPE::DISABLE_CRAFT_LEVEL
    @popup_window.activate
  end
  def confirm_cancel
    @confirm_window.deactivate
    @list_window.activate
  end
  def command_cancel
    $temp_disable_crafting = false
    SceneManager.return
  end
  def cancel
    @list_window.select(-1)
    @help_window.set_text("")
    @command_window.activate
  end
  def command_ok
    @list_window.select(0)
    @list_window.activate
  end
end
 
class Scene_Crafting < Scene_CraftingAll
  def start
    super
    @command_window.index = ADV_RECIPE::CATEGORIES.index($crafting_category)
    @command_window.deactivate
    @command_window.visible = false
    @list_window.height += 48
    @list_window.y -= 48
    @detail_window.height += 48
    @detail_window.y -= 48
    @list_window.create_contents
    @detail_window.create_contents
    @list_window.select(0)
    @list_window.activate
  end
  def cancel
    SceneManager.return
  end
end
 
class Window_RecCategory < Window_HorzCommand
  def initialize
    super(0,72)
  end
  def window_width; Graphics.width; end
  def window_height; 48; end
  def make_command_list
    ADV_RECIPE::CATEGORIES.each do |command|
      add_command(command.to_s,command)
    end
  end
  def item_width
    120
  end
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    rect = item_rect_for_text(index)
    draw_text(rect, command_name(index))
    draw_icon(ADV_RECIPE::CATEGORY_ICONS[index],rect.x-24,rect.y)
  end
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 28
    rect.width -= 28
    rect
  end
end
 
class Window_RecPopup < Window_Selectable
  def initialize
    super(Graphics.width/2-window_width/2,Graphics.height/2-window_height/2,120,48)
    self.openness = 0
    deactivate
  end
  def window_width; 120; end
  def window_height; 48; end
  def set_text(item, amount)
    contents.clear
    text = amount.to_s + "x " + item.name + " crafted!"
    width = contents.text_size(text).width
    self.width = width + padding*2
    self.x = Graphics.width/2-width/2
    create_contents
    draw_text(24,0,contents.width,line_height,text)
    draw_icon(item.icon_index,0,0)
    open
  end
  def set_text_fail
    contents.clear
    text = "Crafting failed!"
    width = contents.text_size(text).width
    self.width = width + padding*2
    self.x = Graphics.width/2-width/2
    create_contents
    draw_text(12,0,contents.width,line_height,text)
    open
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
end
 
class Window_RecGauge < Window_Base
  def initialize
    super(0,Graphics.height-48,Graphics.width/2,48)
    @category = :All
  end
  def refresh
    contents.clear
    return if @category == :All
    draw_icon(ADV_RECIPE::CATEGORY_ICONS[cat_index],0,0)
    draw_text(24,0,contents.width,24,$game_party.craft_level(cat_index))
    rate = $game_party.craft_exp(cat_index).to_f / $game_party.craft_exp_next(cat_index)
    draw_gauge(48, -3, contents.width-48, rate, tp_gauge_color1, tp_gauge_color2)
    if Module.const_defined?(:SPECIAL_GAUGES)
      @gauges[[48,-3]].set_extra("XP",$game_party.craft_exp(cat_index),$game_party.craft_exp_next(cat_index))
    else
      text = $game_party.craft_exp(cat_index).to_s+"/"+$game_party.craft_exp_next(cat_index).to_s
      draw_text(0,0,contents.width,24,text,2)
    end
  end
  def set_category(cat)
    return if cat == @category
    @category = cat
    refresh
  end
  def cat_index
    ADV_RECIPE::CATEGORIES.index(@category)
  end
end
 
class Window_MenuCommand < Window_Command
  alias recipe_aoc add_original_commands
  def add_original_commands
    recipe_aoc
    add_command("Crafting", :recipe) if ADV_RECIPE::ENABLE_MENU_ACCESS
  end
end
 
class Scene_Menu < Scene_MenuBase
  alias recipe_create_command_window create_command_window
  def create_command_window
    recipe_create_command_window
    @command_window.set_handler(:recipe,   method(:command_recipe))
  end
  def command_recipe
    $temp_disable_crafting = ADV_RECIPE::DISABLE_MENU_CRAFT
    SceneManager.call(Scene_CraftingAll)
  end
end
#Basic Recipe Crafting v1.1a
#----------#
#Features: Recipe crafting! Yeesh.
#
#Usage:    Set up your recipes, learn recipes, make items! Yay!
#       SceneManager.call(Scene_Crafting)   - opens the Crafting meny
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
 
#How the recipes work:
#   ID = > [ result , [ materials ] ],
#  Result = one item set up like... [item_type,item_id,amount]
#  Materials are set up the same way but in an array to account for multiples:
#   [item_type,item_id,amount],[item_type,item_id,amount],etc...
#  Item_type is 0 for items, 1 for weapons, 2 for armors
#
# Example for making 1 Weapon 3 using 2 Item 2's, 1 Weapon 1, and 1 Armor 1:
# 30 => [[1,3,1],[[0,2,2],[1,1,1],[2,1,1]]],
 
USE_WA_RANDOMIZATION = false
 
RECIPES = {
  0 => [ [0,1,1] , [ [0,17,2] ] ],
  1 => [ [0,2,1] , [ [0,17,1],[0,18,2] ] ],
  2 => [ [0,3,1] , [ [0,17,1],[0,18,1],[0,19,2] ] ],
  3 => [ [0,1,1] , [ [0,17,2] ] ],
  4 => [ [0,2,1] , [ [0,17,1],[0,18,2] ] ],
  5 => [ [0,3,1] , [ [0,17,1],[0,18,1],[0,19,2] ] ],
  6 => [ [0,1,1] , [ [0,17,2] ] ],
  7 => [ [0,2,1] , [ [0,17,1],[0,18,2] ] ],
  8 => [ [0,3,1] , [ [0,17,1],[0,18,1],[0,19,2] ] ],
  9 => [ [0,1,1] , [ [0,17,2] ] ],
  10 => [ [0,2,1] , [ [0,17,1],[0,18,2] ] ],
  11 => [ [0,3,1] , [ [0,17,1],[0,18,1],[0,19,2] ] ],
  12 => [ [0,1,1] , [ [0,17,2] ] ],
  13 => [ [0,2,1] , [ [0,17,1],[0,18,2] ] ],
  14 => [ [0,3,1] , [ [0,17,1],[0,18,1],[0,19,2] ] ],
  
 
  }
 
 
class Recipe
  attr_accessor :result
  attr_accessor :materials
  attr_accessor :known
  attr_accessor :id
  def initialize(id,res,mat)
    @id = id
    @result = Material.new(res[0],res[1],res[2])
    @materials = []
    for item in mat
      @materials.push(Material.new(item[0],item[1],item[2]))
    end
    @known = false
  end
  def name
    return @result.item.name
  end
  def has_materials?
    for item in @materials
      return false unless $game_party.item_number(item.item) >= item.amount
    end
    return true
  end
  def craft
    remove_materials
    add_result
  end
  def remove_materials
    for item in @materials
      $game_party.gain_item(item.item,-item.amount)
    end
  end
  def add_result
    if USE_WA_RANDOMIZATION
      $game_party.add_weapon(@result.item.id,@result.amount) if @result.item.is_a?(RPG::Weapon)
      $game_party.add_armor(@result.item.id,@result.amount) if @result.item.is_a?(RPG::Armor)
      $game_party.add_item(@result.item.id,@result.amount) if @result.item.is_a?(RPG::Item)
    else
      $game_party.gain_item(@result.item,@result.amount)
    end
  end
end
 
class Material
  attr_accessor :item
  attr_accessor :amount
  def initialize(type, id, amount)
    @item = $data_items[id] if type == 0
    @item = $data_weapons[id] if type == 1
    @item = $data_armors[id] if type == 2
    @amount = amount
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
    RECIPES.each_pair do |key, val|
      recipes[key] = Recipe.new(key,val[0],val[1])
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
    self.contents = Bitmap.new(self.contents.width,@data.size*24)
    select(0)
    activate
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
    item.known
  end
  def enable?(item)
    return false if item.nil?
    item.has_materials?
  end
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item.result.item, rect.x, rect.y, enable?(item))
    end
  end
  def current_item
    @data[index]
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
    return if @recipe.nil?
    change_color(normal_color)
    draw_text(0,0,self.width,line_height,"Required:")
    yy = line_height
    for item in @recipe.materials
      change_color(normal_color, $game_party.item_number(item.item) >= item.amount)
      draw_icon(item.item.icon_index,0,yy)
      draw_text(24,yy,self.width,line_height,item.item.name)
      string = $game_party.item_number(item.item).to_s + "/" + item.amount.to_s
      draw_text(0,yy,self.contents.width,line_height,string,2)
      yy += line_height
    end
  end
end
 
class Window_RecipeConfirm < Window_Selectable
  def initialize(x,y,w,h)
    super
    self.opacity = 0
    refresh
  end
  def item_max; 1; end;
  def enable?(item); true; end;
  def refresh
    super
    draw_text(0,0,self.contents.width,line_height,"Craft",1)
  end
  def activate
    super
    select(0)
  end
  def deactivate
    super
    select(-1)
  end
end
 
class Scene_Crafting < Scene_Base
  def start
    super
    @top_help_window = Window_Help.new(1)
    @top_help_window.set_text("Select recipe to craft:")
    @bottom_help_window = Window_Help.new
    @bottom_help_window.y = Graphics.height - @bottom_help_window.height
    width = Graphics.width / 2
    height = Graphics.height - @top_help_window.height - @bottom_help_window.height
    @list_window = Window_RecipeList.new(0,@top_help_window.height,width,height)
    @list_window.set_handler(:ok, method(:list_success))
    @list_window.set_handler(:cancel, method(:cancel))
    @detail_window = Window_RecipeDetail.new(width,@list_window.y,width,height)
    height = @list_window.y + @list_window.height - @top_help_window.height
    @confirm_window = Window_RecipeConfirm.new(width,height,width,@top_help_window.height)
    @confirm_window.set_handler(:ok, method(:craft_success))
    @confirm_window.set_handler(:cancel, method(:confirm_cancel))
  end
  def update
    super
    @bottom_help_window.set_text(@list_window.current_item.result.item.description) if !@list_window.current_item.nil?
    @detail_window.set_recipe(@list_window.current_item)
  end
  def list_success
    @list_window.deactivate
    @confirm_window.activate
  end
  def craft_success
    @list_window.current_item.craft
    @list_window.refresh
    @list_window.activate
  end
  def confirm_cancel
    @confirm_window.deactivate
    @list_window.activate
  end
  def cancel
    SceneManager.return
  end
end
 
class Window_MenuCommand < Window_Command
  alias recipe_aoc add_original_commands
  def add_original_commands
    recipe_aoc
    rec = $game_recipes.values.select {|recipe| recipe.known}
    add_command("Crafting", :recipe, rec.size > 0)
  end
end
 
class Scene_Menu < Scene_MenuBase
  alias recipe_create_command_window create_command_window
  def create_command_window
    recipe_create_command_window
    @command_window.set_handler(:recipe,   method(:command_recipe))
  end
  def command_recipe
    SceneManager.call(Scene_Crafting)
  end
end
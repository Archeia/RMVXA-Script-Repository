=begin
#===============================================================================
 Title: Learn Skill Shop
 Author: Hime
 Date: May 23, 2013
--------------------------------------------------------------------------------
 ** Change log
 May 23, 2013
   - regex updated to make underscores optional
 Mar 1, 2013
   - updated to support shop options
 Feb 26, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Required
 
 -Shop Manager
 (http://himeworks.com/2013/02/22/shop-manager/)
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to learn skills from shops directly

--------------------------------------------------------------------------------
 ** Usage
 
 -- Set up class buyable skills --
 
 In order to be abke to buy a skill from a shop, your class must be
 able to learn AND buy the skill
 
 In the Classes tab, create some Learning objects and tag them with
   
   <buyable>
   
 You can set the level requirement as well if you want the skill to only
 be buyable when the actor's class has reached a certain level.
 
 -- Set up shop goods --
 
 In the Items tab in your database, create some items that you will display
 in your skill shop. Tag them with the following notetag
 
   <buy_skill: x>
   
 For some skill ID x. This determines what skill to teach.
 
 -- Setting up the shop --
 
 In the interpreter, before the "Shop Processing" command, make a script call
 
    @shop_type = "LearnSkillShop"
    
 The list of items in the shop processing editor contain a list of items
 that you can sell to the shop. The price you input will be the price that
 it will be sold at, or the default price you set in the Items tab.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_LearnSkillShop"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Learn_Skill_Shop
    
    Buyable_Regex = /<buyable>/i
    Buy_Skill_Regex = /<buy[ _]skill: (\d+)>/i
  end
end

module Vocab
  
  #Text to display depending on whether an actor can buy a skill or not
  LearnSkillShop_AlreadyLearned = "Already learned"
  LearnSkillShop_CannotLearn    = "Unable to learn"
  LearnSkillShop_CanLearn       = "Can learn"
end
#===============================================================================
# ** Rest of the Script
#===============================================================================
module RPG
  class Item
    
    def skill_shop_learn_id
      return @skill_shop_learn_id unless @skill_shop_learn_id.nil?
      res = TH::Learn_Skill_Shop::Buy_Skill_Regex.match(self.note)
      return @skill_shop_learn_id = res ? res[1].to_i : 0
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Separate buyable skills from learnable skills
  #-----------------------------------------------------------------------------
  class Class
    alias :th_learn_skill_shop_learnings :learnings
    def learnings
      split_buyables unless @buyable_checked      
      th_learn_skill_shop_learnings
    end
    
    def buyable_skills
      return @buyable_skills unless @buyable_skills.nil?
      split_buyables
      return @buyable_skills
    end
    
    def split_buyables
      @buyable_skills = @learnings.select {|learn| learn.note =~ TH::Learn_Skill_Shop::Buyable_Regex }
      @learnings -= @buyable_skills
      @buyable_checked = true
    end
  end
end

class Game_Actor < Game_Battler
  
  #-----------------------------------------------------------------------------
  # Skill can be learned through purchase if actor's "buyable skills" list 
  # contains it AND the required level is met.
  #-----------------------------------------------------------------------------
  def skill_buyable?(skill_id)
    learning = self.class.buyable_skills.detect{|learn| learn.skill_id == skill_id}
    return false if learning.nil?
    return learning.level <= self.level
  end
end

class Game_LearnSkillShop < Game_Shop
end

class Window_LearnSkillShopCommand < Window_ShopCommand
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopCancel, :cancel)
  end
end

class Window_LearnSkillShopStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @data = []
    @page_index = 0
    refresh
  end
  
  def actor
    return @data[index]
  end
  
  def skill
    $data_skills[@item.skill_shop_learn_id]
  end
  
  def item=(item)
    @item = item
    refresh
  end
  
  def make_item_list
    @data = $game_party.battle_members
  end
  
  def item_max
    $game_party.battle_members.size
  end
  
  def item_height
    (height - standard_padding * 2) / 4
  end
  
  def enable?(actor)
    return false if actor.skill_learn?(skill)
    return false unless actor.skill_buyable?(skill.id)
    return true
  end

  def draw_item(index)
    return unless @item
    rect = item_rect(index)
    actor = @data[index]
    change_color(normal_color, enable?(actor))
    draw_text(rect.x + 36, rect.y + 4, 112, line_height, actor.name)
    draw_character(actor.character_name, actor.character_index, rect.x + 16, rect.y + line_height + 16)
    
    if actor.skill_learn?(skill)
      draw_text(rect.x+36, rect.y + line_height, 160, line_height, Vocab::LearnSkillShop_AlreadyLearned)
    elsif !actor.skill_buyable?(skill.id)
      draw_text(rect.x+36, rect.y + line_height, 160, line_height, Vocab::LearnSkillShop_CannotLearn)
    else
      draw_text(rect.x+36, rect.y + line_height, 160, line_height, Vocab::LearnSkillShop_CanLearn)
    end
  end
  
  def select_last
    select(0)
  end
  
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  
  def process_ok
    unless enable?(actor)
      Sound.play_buzzer
    else
      super
    end
  end
end

class Window_LearnSkillShopBuy < Window_ShopBuy

  alias :th_learn_skill_shop_enable? :enable?
  def enable?(item)
    return false unless item && price(item) <= @money
    th_learn_skill_shop_enable?(item)
  end

  alias :th_learn_skill_shop_include? :include?
  def include?(shopGood)
    return false unless shopGood.item.skill_shop_learn_id > 0
    th_learn_skill_shop_include?(shopGood)
  end
  
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end

class Scene_LearnSkillShop < Scene_Shop
  
  def create_status_window
    wx = @number_window.width
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @status_window = Window_LearnSkillShopStatus.new(wx, wy, ww, wh)
    @status_window.viewport = @viewport
    @status_window.hide
    @status_window.set_handler(:ok, method(:learn_ok))
    @status_window.set_handler(:cancel, method(:learn_cancel))
  end
  
  def create_command_window
    @command_window = Window_LearnSkillShopCommand.new(@gold_window.x, @purchase_only)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @buy_window = Window_LearnSkillShopBuy.new(0, wy, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  
  def on_buy_ok
    @item = @buy_window.item
    @status_window.select_last
    @status_window.activate
  end
  
  def learn_ok
    actor = @status_window.actor
    skill = @status_window.skill
    actor.learn_skill(skill.id)
    $game_party.lose_gold(buying_price)
    Sound.play_ok
    @buy_window.money = money
    @gold_window.refresh
    @status_window.refresh
    if money < buying_price
      @status_window.unselect
      @buy_window.activate
    else
      @status_window.activate
    end
  end
  
  def learn_cancel
    @status_window.unselect
    @buy_window.activate
  end
end
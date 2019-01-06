#--# Appraisal Shop v 1.1a
#
# Allows you to create unidentified items that can be appraised for a cost
#  in a special shop, or an option to appraise them at no cost from the
#  inventory. Includes support for W/A Randomization.
#
# Usage: Plug and play, customize and set up note tags as needed.
#
#   SceneManager.call(Scene_Appraise) - calls the appraisal shop
#
#   Notetags determine what an unidentified item identifies into:
#     <APPRAISE COST ##> where ## is the cost to appraise the item
#     <APPRAISE id rarity> where id is the item id, and rarity is the chance
#    Items identify into items, weapons into weapons, etc.
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

$imported = {} if $imported.nil?
$imported[:Vlue_Appraisal] = true
 
#SE to be played upon appraisal
APPRAISAL_SE = "Chime2"
#Whether or not appraisal can be done in the menu
APPRAISE_IN_MENU = true
#Hide ingredient names? (set to :discover to reaveal names on identify)
HIDE_INGREDIENT_NAMES = :discover
#Whether or not to hide ingredient chance
HIDE_INGREDIENT_NUMBERS = :discover
 
class RPG::BaseItem
  def appraisal_list
    appraise = {}
    list = self.note.clone
    while list =~ /<APPRAISE (\d+) (\d+)>/
      appraise[$1.to_i] = $2.to_i
      list[list.index("<APPRAISE")] = "N"
    end
    appraise
  end
  def appraise_cost
    note =~ /<APPRAISE COST (\d+)>/
    return 0 if !$~
    return $1.to_i
  end
end
 
class Scene_Appraise < Scene_Base
  def start
    super
    @random = Module.const_defined?(:AFFIXES)
    @help_window = Window_Help.new
    @gold_window = Window_Gold.new
    @gold_window.width = Graphics.width/2
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = Graphics.height - @gold_window.height
    @window_command = Window_AppCommand.new
    @window_command.set_handler(:on_ok, method(:command_ok))
    @window_command.set_handler(:on_cancel, method(:command_cancel))
    @window_command.set_handler(:cancel, method(:command_cancel))
    @window_list = Window_AppList.new
    @window_list.set_handler(:ok, method(:list_ok))
    @window_list.set_handler(:cancel, method(:list_cancel))
    @window_detail = Window_AppDetail.new
    @window_popup = Window_AppPopup.new
    @window_popup.set_handler(:ok, method(:popup_ok))
    @window_popup.set_handler(:cancel, method(:popup_ok))
    @window_confirm = Window_AppConfirm.new
    @window_confirm.set_handler(:on_ok, method(:confirm_ok))
    @window_confirm.set_handler(:on_cancel, method(:confirm_cancel))
    @window_confirm.set_handler(:cancel, method(:confirm_cancel))
    @window_command.activate
  end
  def update
    super
    if @window_list.active && !@window_list.current_item.nil?
      @window_detail.item = @window_list.current_item
      @help_window.set_text(@window_list.current_item.description)
    end
  end
  def command_ok
    @window_list.select(0)
    @window_list.activate
  end
  def command_cancel
    SceneManager.return
  end
  def list_ok
    @window_confirm.activate
  end
  def list_cancel
    @window_command.activate
    @window_list.select(-1)
    @window_detail.contents.clear
  end
  def confirm_ok
    Audio.se_play("/Audio/SE/"+APPRAISAL_SE,100,100)
    item = @window_list.current_item
    $game_party.lose_gold(item.appraise_cost)
    $game_party.lose_item(item,1)
    random_pick = []
    item.appraisal_list.each do |id, value|
      value.times do |i|
        random_pick.push(id)
      end
    end
    if item.is_a?(RPG::Item)
      nitem = $data_items[random_pick[rand(random_pick.size)]]
      nitem = $game_party.add_item(nitem.id,1) if @random
    elsif item.is_a?(RPG::Weapon)
      nitem = $data_weapons[random_pick[rand(random_pick.size)]]
      nitem = $game_party.add_weapon(nitem.id,1) if @random
    elsif item.is_a?(RPG::Armor)
      nitem = $data_armors[random_pick[rand(random_pick.size)]]
      nitem = $game_party.add_armor(nitem.id,1) if @random
    end
    $game_party.gain_item(nitem,1) if !@random
    @window_popup.set_text(nitem)
    @gold_window.refresh
    @window_list.refresh
    @window_popup.activate
  end
  def confirm_cancel
    @window_list.activate
  end
  def popup_ok
    @window_popup.deactivate
    @window_popup.close
    @window_list.select(0)
    @window_list.activate
  end
end
 
class Window_AppCommand < Window_HorzCommand
  def initialize
    super(0,72)
  end
  def item_width
    width / 2 - padding * 2
  end
  def window_width
    Graphics.width
  end
  def window_height
    48
  end
  def make_command_list
    add_command("Appraise",:on_ok)
    add_command("Cancel",:on_cancel)
  end
end
 
class Window_AppList < Window_ItemList
  def initialize
    super(0,120,Graphics.width/2,Graphics.height-120)
    @category = :item
    refresh
  end
  def include?(item)
    item && !item.appraisal_list.empty?
  end
  def current_item
    @data[index]
  end
  def enable?(item)
    return false if item.nil?
    !item.appraisal_list.empty? && item.appraise_cost <= $game_party.gold
  end
  def col_max; 1; end
end
 
class Window_AppDetail < Window_Base
  def initialize
    super(Graphics.width/2,120,Graphics.width/2,Graphics.height-168)
  end
  def item=(item)
    @item = item
    refresh
  end
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(0,0,contents.width,24,"Appraisal Cost:")
    draw_text(0,line_height*2,contents.width,24,"Outcome:")
    return unless @item
    !@item.appraisal_list.empty? ? self.contents_opacity = 255 : self.contents_opacity = 150
    draw_currency_value(@item.appraise_cost,Vocab::currency_unit,0,line_height,contents.width)
    max = 0;yy = line_height*3
    @item.appraisal_list.values.each do |i|
      max += i
    end
    change_color(normal_color)
    @item.appraisal_list.each do |id, value|
      item = $data_items[id] if @item.is_a?(RPG::Item)
      item = $data_weapons[id] if @item.is_a?(RPG::Weapon)
      item = $data_armors[id] if @item.is_a?(RPG::Armor)
      name = item.name
      name = "????" if HIDE_INGREDIENT_NAMES == true
      if HIDE_INGREDIENT_NAMES == :discover && !$game_party.item_discovered?(item)
        name = "????"
      end
      draw_text(0,yy,contents.width,24,name)
      val = (value/max.to_f*100).to_i.to_s
      val = "??" if HIDE_INGREDIENT_NUMBERS == true
      if HIDE_INGREDIENT_NUMBERS == :discover && !$game_party.item_discovered?(item)
        val = "??"
      end
      draw_text(0,yy,contents.width,24,val+"%",2)
      yy += line_height
    end
  end
end
 
class Window_AppConfirm < Window_Command
  def initialize
    super(Graphics.width/2-window_width/2,Graphics.height/2-window_height/2)
    self.openness = 0
    deactivate
  end
  def window_width
    120
  end
  def window_height
    72
  end
  def make_command_list
    add_command("Appraise",:on_ok)
    add_command("Cancel",:on_cancel)
  end
  def activate
    open
    super
  end
  def deactivate
    close
    super
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
 
class Window_AppPopup < Window_Selectable
  def initialize
    super(Graphics.width/2-window_width/2,Graphics.height/2-window_height/2,120,48)
    self.openness = 0
    deactivate
  end
  def window_width; 120; end
  def window_height; 49; end
  def refresh; end;
  def set_text(item)
    contents.clear
    text1, text2 = item.name, " identified!"
    width = contents.text_size(text1 + text2).width
    self.width = width + padding*2
    self.x = Graphics.width/2-width/2
    create_contents
    $imported[:Vlue_WARandom] ? color = item.color : color = normal_color
    change_color(color)
    draw_text(24,1,contents.width,24,text1)
    change_color(normal_color)
    draw_text(24+contents.text_size(text1).width,1,contents.width,24,text2)
    draw_icon(item.icon_index,0,0)
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
 
class Scene_ItemBase
  alias app_start start
  def start
    app_start
    @random = Module.const_defined?(:AFFIXES)
    @window_popup = Window_AppPopup.new
    @window_popup.set_handler(:ok, method(:popup_ok))
    @window_popup.set_handler(:cancel, method(:popup_ok))
    @window_confirm = Window_AppConfirm.new
    @window_confirm.set_handler(:on_ok, method(:confirm_ok))
    @window_confirm.set_handler(:on_cancel, method(:confirm_cancel))
    @window_confirm.set_handler(:cancel, method(:confirm_cancel))
    @window_popup.z = @window_confirm.z = 201
  end
  def popup_ok
    @window_popup.deactivate
    @window_popup.close
    activate_item_window
  end
  def confirm_ok
    identify_item
  end
  def confirm_cancel
    activate_item_window
  end
  def determine_item
    if item.for_friend?
      show_sub_window(@actor_window)
      @actor_window.select_for_item(item)
    else
      if !item.appraisal_list.empty? && APPRAISE_IN_MENU
        @window_confirm.activate
      else
        use_item
        activate_item_window
      end
    end
  end
  def identify_item
    Audio.se_play("/Audio/SE/"+APPRAISAL_SE,100,100)
    $game_party.lose_item(item,1)
    random_pick = []
    item.appraisal_list.each do |id, value|
      value.times do |i|
        random_pick.push(id)
      end
    end
    if item.is_a?(RPG::Item)
      sitem = $data_items[random_pick[rand(random_pick.size)]]
      sitem = $game_party.add_item(sitem.id,1) if @random
    elsif item.is_a?(RPG::Weapon)
      sitem = $data_weapons[random_pick[rand(random_pick.size)]]
      sitem = $game_party.add_weapon(sitem.id,1) if @random
    elsif item.is_a?(RPG::Armor)
      sitem = $data_armors[random_pick[rand(random_pick.size)]]
      sitem = $game_party.add_armor(sitem.id,1) if @random
    end
    $game_party.gain_item(sitem,1) if !@random
    @window_popup.set_text(sitem)
    @window_popup.activate
  end
  def item_usable?
    if APPRAISE_IN_MENU
      if item.appraisal_list.empty?
        return user.usable?(item) && item_effects_valid?
      else
        return true
      end
    else
      return user.usable?(item) && item_effects_valid?
    end
  end
end
 
class Game_Party
  attr_accessor :appraise_discovery
  alias app_init initialize
  alias app_gain_item gain_item
  def initialize
    app_init
    @app_disc_item = {}
    @app_disc_weapon = {}
    @app_disc_armor = {}
  end
  def item_discovered?(item)
    array = @app_disc_item if item.is_a?(RPG::Item)
    array = @app_disc_weapon if item.is_a?(RPG::Weapon)
    array = @app_disc_armor if item.is_a?(RPG::Armor)
    array[item.id] ? true : false
  end
  def gain_item(item, amount, *args)
    app_gain_item(item, amount, *args)
    return unless item
    $imported[:Vlue_WARandom] ? id = item.original_id : id = item.id
    @app_disc_item[id] = true if amount > 0 && item.is_a?(RPG::Item)
    @app_disc_weapon[id] = true if amount > 0 && item.is_a?(RPG::Weapon)
    @app_disc_armor[id] = true if amount > 0 && item.is_a?(RPG::Armor)
  end
  def usable?(item)
    return false if item.nil?
    return true if !item.appraisal_list.empty? && APPRAISE_IN_MENU
    members.any? {|actor| actor.usable?(item) }
  end
end
 
class RPG::BaseItem
  def for_friend?
  end
end
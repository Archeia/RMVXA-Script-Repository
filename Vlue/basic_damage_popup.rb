#Basic Damage Popup v1.3b
#----------#
#Features: What the title says, very simple damage popup
#
#Usage:    Plug and play, customize as needed
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

$imported = {} if $imported.nil?
$imported[:BasicDamagePopup] = true
 
class Damage_Popup < Sprite_Base
 
  #Font Details:
  FONT_NAME = "Arial"
  FONT_BOLD = false
  FONT_SHADOW = false
  FONT_BASE_SIZE = 24
  #If you want to use a bitmap of numbers instead:
  #Bitmap is to be named Numbers.png and placed in Graphics/System
  USE_BITMAP = false
  #Adjust the spacing between bitmap numbers
  PADDING = 10
  #Whether to change the size of the font based on weakness/resistance
  CHANGE_SIZE = true
  FONT_SIZE_CHANGE = 6
  #Whether the popup should move along the x or y axis respectively
  POPUP_MOVE = true
  POPUP_BOUNCE = true
  #Different colours for the popups
  USE_ELEMENT_COLORS = true
  NORMAL_COLOR = Color.new(255,255,255)
  HEAL_COLOR = Color.new(0,255,0)
  MISS_COLOR = Color.new(255,255,255)
  STATE_COLOR = Color.new(255,100,255)
 
  #Set the colors for each element, it goes: element_id => Color.new(r,g,b),
  ELEMENT_COLOR = {
    3 => Color.new(255,0,0),
    4 => Color.new(100,100,255),
    5 => Color.new(255,255,0),
    6 => Color.new(0,0,175),
    7 => Color.new(255,175,50),
    8 => Color.new(175,255,175),
    9 => Color.new(255,255,255),
   10 => Color.new(150,10,150),
   }
 
  def initialize(viewport = nil)
    super(viewport)
    @damage = 0
    @timer = 60
    @x_speed = 0
    @y_speed = 0
    @element_id = 0
  end
  def setup_damage(target,item,subject)
    @damage = target.result.hp_damage
    @damage = "Failed" if !target.result.success
    @damage = "Missed" if target.result.missed
    @damage = "Evaded" if target.result.evaded
    @damage = " " if @damage == 0
    @element_id = item.damage.element_id
    setup_position(target,item,subject)
  end
  def setup_position(target,item,subject)
    font_size = FONT_BASE_SIZE
    if @damage.is_a?(Integer)
      val = @damage
      val *= item_element_rate(subject, item, target)
      if CHANGE_SIZE
        font_size += FONT_SIZE_CHANGE
        font_size += FONT_SIZE_CHANGE if val > @damage
        font_size -= FONT_SIZE_CHANGE if val < @damage
        font_size += FONT_SIZE_CHANGE if target.result.critical
      end
    end
    fake_bitmap = Cache.battler(target.battler_name, target.battler_hue)
    if $imported[:VlueAnimatedBattlers] && target.get_anim("Idle")
      fake_bitmap = Cache.battler(target.get_anim("Idle")[0],0)
      width = Animation::ANIMATION_FILES[target.get_anim("Idle")[0]][0]
      width = fake_bitmap.width / width
      height = Animation::ANIMATION_FILES[target.get_anim("Idle")[0]][1]
      height = fake_bitmap.height / height
      fake_bitmap = Bitmap.new(width,height)
    end
    fake_bitmap.font.size = font_size
    self.bitmap = Bitmap.new(fake_bitmap.text_size(@damage).width*3+24,48*2)
    self.bitmap.font.name = FONT_NAME
    self.bitmap.font.size = font_size
    self.bitmap.font.bold = FONT_BOLD
    self.bitmap.font.shadow = FONT_SHADOW
    self.x = target.screen_x - self.width / 2 - 24
    self.y = target.screen_y - fake_bitmap.height
    @x_speed = rand(3) - 1 if POPUP_MOVE
    @y_speed = 2 if POPUP_BOUNCE
  end
  def setup_state(target, state)
    self.visible = false if state.id == 1
    @damage = state.name
    @icon = state.icon_index
    setup_position(target,nil,nil)
  end
  def update
    update_regular if !USE_BITMAP
    update_bitmap if USE_BITMAP
  end
  def update_color
    bitmap.font.color = NORMAL_COLOR
    bitmap.font.color = get_element_color if USE_ELEMENT_COLORS
    bitmap.font.color = HEAL_COLOR if @damage.is_a?(Integer) && @damage < 0
    bitmap.font.color = MISS_COLOR if @damage == "Missed"
    bitmap.font.color = STATE_COLOR if @icon
  end
  def update_bounce
    self.y -= @y_speed if @timer % 2 == 0 && POPUP_BOUNCE
    @y_speed -= 0.1
    @timer -= 1
    self.x += @x_speed if @timer % 2 == 0
    self.opacity -= 6 if @timer < 30
  end
  def update_regular
    bitmap.clear
    update_color
    text = @damage.abs if @damage.is_a?(Integer)
    text = @damage if @damage.is_a?(String)
    draw_icon(@icon,self.width/4,self.height/2-12) if @icon
    bitmap.draw_text(24,0,self.width,self.height,text,1)
    update_bounce
  end
  def update_bitmap
    bitmap.clear
    update_color
    text = @damage.abs if @damage.is_a?(Integer)
    return update_regular unless text
    self.color = bitmap.font.color
    self.color.alpha = 75
    text = text.to_s;xx = 0
    dmg_bmp = SceneManager.scene.dam_bmps
    rect = Rect.new(0,0,dmg_bmp[0].width,dmg_bmp[0].height)
    text.length.times do |i|
      bitmap.blt(bitmap.width / 2 + xx,bitmap.height/2,dmg_bmp[text[i].to_i],rect)
      xx+=PADDING
    end
    update_bounce
  end
  def get_element_color
    ELEMENT_COLOR[@element_id].nil? ? NORMAL_COLOR : ELEMENT_COLOR[@element_id]
  end
  def done
    @timer < 0
  end
  def item_element_rate(user, item, subject)
    if item.damage.element_id < 0
      user.atk_elements.empty? ? 1.0 : subject.elements_max_rate(user.atk_elements)
    else
      subject.element_rate(item.damage.element_id)
    end
  end
  def draw_icon(icon_index, x, y, enabled = true)
    temp_bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(x, y, temp_bitmap, rect)
  end
end
 
class Scene_Battle
  alias dam_pop_init start
  alias dam_pop_update update_basic
  def start(*args)
    dam_pop_init(*args)
    @damage_popups = []
    return unless Damage_Popup::USE_BITMAP
    @damage_number_bitmaps = [0]
    bitmap = Cache.system("Numbers")
    x = 0;y = 0;w = bitmap.width / 5;h = bitmap.height / 2
    10.times do
      rect = Rect.new(x,y,w,h)
      bmp = Bitmap.new(w,h)
      bmp.blt(0,0,bitmap,rect)
      @damage_number_bitmaps.push(bmp)
      @damage_number_bitmaps[0] = bmp
      x += w
      if x == w*5
        x = 0;y += h
      end
    end
  end
  def dam_bmps
    @damage_number_bitmaps
  end
  def add_damage_popup(target,item,subject)
    @damage_popups.push(Damage_Popup.new(nil))
    @damage_popups[-1].setup_damage(target,item,subject)
  end
  def add_state_popup(target, state)
    @damage_popups.push(Damage_Popup.new(nil))
    @damage_popups[-1].setup_state(target, state)
  end
  def update_basic(*args)
    dam_pop_update(*args)
    @damage_popups.each do |popup| popup.update end
    @damage_popups.each_index do |index|
      if @damage_popups[index].done
        @damage_popups[index].bitmap.clear
        @damage_popups[index] = nil
      end
    end
    @damage_popups.compact!
  end
  def apply_item_effects(target, item)
    target.item_apply(@subject, item)
    refresh_status
    if $imported[:VlueAnimatedBattlers]
      add_damage_popup(target, item, @subject) if target.result.ignore.nil?
    else
      add_damage_popup(target, item, @subject)
    end
    target.result.added_state_objects.each do |state|
      add_state_popup(target, state)
    end
    @log_window.display_action_results(target, item)
  end
end
 
class Game_Actor
  def screen_x
    return -50
  end
  def screen_y
    return -50
  end
end
#==============================================================================
#
# • Dhoom Text to Icon v.1.0a
#   drd-workshop.blogspot.com
# -- Last Updated: 26.07.2015
# -- Requires: None
#
#==============================================================================
# Convert any specified text into icon. You can set conditions for specific
# icon to be displayed. Works with every script that use draw_text method in
# window.
#==============================================================================
# • CHANGELOG
# - 27.07.2015 v1.0a
#   - Adding ways to disable text to icon convertion
#==============================================================================
  $imported ||= {}
  $imported[:dhoom_text_to_icon] = true
#==============================================================================
module Dhoom
  module TextToIcon
#==============================================================================
# • CONFIGURATION
#==============================================================================
    Icons = {} #<-- Don't Remove!
#------------------------------------------------------------------------------
#   Icons[Text] = Icon Index or Array
#     If array, the format is 
#     [
#       [Icon Index, Script Condition],
#       ...
#       [Icon Index, Script Condition],
#     ]
#     Script condition must be converted into string. 
#     actor => will return the last actor that used to draw anything 
#              in Window_Base.
#------------------------------------------------------------------------------
    Icons['HP'] = [
                   [123, 'actor.hp_rate <= 0.5'], 
                   [122, 'actor.hp_rate == 1.0'],
                   [124, 'true'],
                  ]
    Icons['MP'] = 125
    Icons['Eric'] = 1
    Icons['Potion'] = 9
    Icons['ATK'] = 34
    Icons['DEF'] = 35
    Icons['AGI'] = 38
    
#------------------------------------------------------------------------------
#   SceneExlude = [Scene Class, Scene Class, ...]
#   Disable text to icon convertion if current scene is included in this array
#------------------------------------------------------------------------------
    SceneExclude = [Scene_Status, Scene_Battle]
    
#------------------------------------------------------------------------------
#   WindowExlude = [Window Class, Window Class, ...]
#   Disable text to icon convertion in window that are included in this array
#------------------------------------------------------------------------------
    WindowExclude = [Window_ItemList, Window_EquipItem]
    
#------------------------------------------------------------------------------
#   DisableSwitch = Switch ID
#   Disable text to icon convertion when switch is ON
#------------------------------------------------------------------------------
    DisableSwitch = 1
    
#==============================================================================
# • END OF CONFIGURATION
#==============================================================================
  end
end

class Window_Base < Window
  alias :dhoom_txttoic_wndbase_draw_text :draw_text
  def draw_text(*args)
    if Dhoom::TextToIcon::WindowExclude.include?(self.class) ||
       Dhoom::TextToIcon::SceneExclude.include?(SceneManager.scene.class) ||
       $game_switches[Dhoom::TextToIcon::DisableSwitch]
      return dhoom_txttoic_wndbase_draw_text(*args)
    end
    text = args.size > 3 ? args[4] : args[1]
    if Dhoom::TextToIcon::Icons[text]
      data = Dhoom::TextToIcon::Icons[text]
      icon = nil
      if data.is_a?(Array)
        actor = @last_actor
        data.each do |cond|
          begin; icon = cond[0] if eval(cond[1]); rescue; next; end
          break if icon
        end
      else
        icon = data
      end      
      unless icon
        dhoom_txttoic_wndbase_draw_text(*args)
        return
      end
      rect = args.size > 3 ? Rect.new(args[0], args[1], args[2], args[3]) : args[0]
      y = rect.y + (rect.height - 24) / 2
      align = args.size > 3 ? args[5] : [3]
      case align
      when 1
        x = rect.x + rect.width / 2 - 12
      when 2
        x = rect.x + rect.width - 24
      else
        x = rect.x
      end
      draw_icon(icon, x, y)
    else
      dhoom_txttoic_wndbase_draw_text(*args)
    end
  end
  
  alias :dhoom_txttoic_wndbase_hp_color :hp_color
  def hp_color(actor)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_hp_color(actor)
  end
  
  alias :dhoom_txttoic_wndbase_mp_color :mp_color
  def mp_color(actor)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_mp_color(actor)
  end
  
  alias :dhoom_txttoic_wndbase_tp_color :tp_color
  def tp_color(actor)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_tp_color(actor)
  end
  
  alias :dhoom_txttoic_wndbase_draw_actor_hp :draw_actor_hp
  def draw_actor_hp(actor, x, y, width = 124)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_hp(actor, x, y, width)
  end  
  
  alias :dhoom_txttoic_wndbase_draw_actor_graphic :draw_actor_graphic
  def draw_actor_graphic(actor, x, y)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_graphic(actor, x, y)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_face :draw_actor_face
  def draw_actor_face(actor, x, y, enabled = true)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_face(actor, x, y, enabled)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_name :draw_actor_name
  def draw_actor_name(actor, x, y, width = 112)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_name(actor, x, y, width)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_class :draw_actor_class
  def draw_actor_class(actor, x, y, width = 112)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_class(actor, x, y, width)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_nickname :draw_actor_nickname
  def draw_actor_nickname(actor, x, y, width = 180)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_nickname(actor, x, y, width)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_level :draw_actor_level
  def draw_actor_level(actor, x, y)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_level(actor, x, y)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_icons :draw_actor_icons
  def draw_actor_icons(actor, x, y, width = 96)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_icons(actor, x, y, width)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_mp :draw_actor_mp
  def draw_actor_mp(actor, x, y, width = 124)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_mp(actor, x, y, width)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_tp :draw_actor_tp
  def draw_actor_tp(actor, x, y, width = 124)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_tp(actor, x, y, width)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_simple_status :draw_actor_simple_status
  def draw_actor_simple_status(actor, x, y)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_simple_status(actor, x, y)
  end

  alias :dhoom_txttoic_wndbase_draw_actor_param :draw_actor_param
  def draw_actor_param(actor, x, y, param_id)
    set_last_actor(actor)
    dhoom_txttoic_wndbase_draw_actor_param(actor, x, y, param_id)
  end
  
  def set_last_actor(actor)
    @last_actor = actor
  end
end
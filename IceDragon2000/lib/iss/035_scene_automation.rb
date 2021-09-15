#encoding:UTF-8
# ISS035 - Scene Automation
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS ; end
#==============================================================================#
# ** ISS::Scene_Automation
#==============================================================================#
class ISS::Scene_Automation

  def self.auto_array(name, *parameters)
    return [name, parameters]
  end

  def self.create_fading_text(text, align, time)
    return [
      ["MESSAGE1", ["CLEAR"]],                   # // Clear Message Strip
      ["MESSAGE1", ["EFFECT", "set_opacity", 0]],# // Set Message Strip Opacity to 0
      ["MESSAGE1", ["TEXT", text, align]],
      ["MESSAGE1", ["EFFECT", "fadein", 0, 255, time]],
      ["SLEEP", [time]],                         # // Sleep for time
     ]
  end

  AUTOMATIONS = {}

end

#==============================================================================#
# ** ISS::Scene_Automation
#==============================================================================#
class ISS::Scene_Automation
#==============================================================================#
# ** Message_Strip
#==============================================================================#
  class Message_Strip

    attr_reader :x, :y, :z
    attr_reader :visible
    attr_reader :opacity

    def initialize()
      @disposed = false
      @active_effect = "none"
      @effect_parameters = []
      @back_sprite = Sprite.new()
      @back_sprite.bitmap = Bitmap.new(Graphics.width, 24)
      @back_sprite.bitmap.fill_rect(0, 0, Graphics.width, 24, Color.new(0,0,0))
      @text_sprite = Sprite.new()
      @text_sprite.bitmap = Bitmap.new(Graphics.width, 24)
      @text_sprite.z = 1
      @x, @y, @z = 0, 0, 0
      @opacity = 255
      @visible = true
    end

    def x=(new_x)
      @x = new_x
      @back_sprite.x = @text_sprite.x = @x
    end

    def y=(new_y)
      @y = new_y
      @back_sprite.y = @text_sprite.y = @y
    end

    def z=(new_z)
      @z = new_z
      @text_sprite.z = 1 + @back_sprite.z = @z
    end

    def disposed?() ; return @disposed ; end

    def dispose()
      @text_sprite.bitmap.dispose() ; @text_sprite.dispose() ; @text_sprite = nil
      @back_sprite.bitmap.dispose() ; @back_sprite.dispose() ; @back_sprite = nil
      @disposed = true
    end

    def update()
      case @active_effect.downcase
      when "fadein_text"
        @opacity = [[@opacity + 255/@effect_parameters[2].to_f,
         @effect_parameters[1].to_i].min, @effect_parameters[0].to_i].max
        @text_sprite.opacity = @opacity
        @active_effect = "none" if @opacity == @effect_parameters[1].to_i
      when "fadeout_text"
        @opacity = [[@opacity - 255/@effect_parameters[2].to_f,
         @effect_parameters[1].to_i].min, @effect_parameters[0].to_i].max
        @text_sprite.opacity = @opacity
        @active_effect = "none" if @opacity == @effect_parameters[0].to_i
      when "set_text_opacity"
        @opacity = @effect_parameters[0].to_i
        @text_sprite.opacity = @opacity
        @active_effect = "none"
      when "fadein_back"
        @opacity = [[@opacity + 255/@effect_parameters[2].to_f,
         @effect_parameters[1].to_i].min, @effect_parameters[0].to_i].max
        @back_sprite.opacity = @opacity
        @active_effect = "none" if @opacity == @effect_parameters[1].to_i
      when "fadeout_back"
        @opacity = [[@opacity - 255/@effect_parameters[2].to_f,
         @effect_parameters[1].to_i].min, @effect_parameters[0].to_i].max
        @back_sprite.opacity = @opacity
        @active_effect = "none" if @opacity == @effect_parameters[0].to_i
      when "set_back_opacity"
        @opacity = @effect_parameters[0].to_i
        @back_sprite.opacity = @opacity
        @active_effect = "none"
      when "fadein"
        @opacity = [[@opacity + 255/@effect_parameters[2].to_f,
         @effect_parameters[1]].min, @effect_parameters[0]].max
        @text_sprite.opacity = @opacity
        @back_sprite.opacity = @opacity
        @active_effect = "none" if @opacity == @effect_parameters[1].to_i
      when "fadeout"
        @opacity = [[@opacity - 255/@effect_parameters[2].to_f,
         @effect_parameters[1].to_i].min, @effect_parameters[0].to_i].max
        @text_sprite.opacity = @opacity
        @back_sprite.opacity = @opacity
        @active_effect = "none" if @opacity == @effect_parameters[0].to_i
      when "set_opacity"
        @opacity = @effect_parameters[0].to_i
        @text_sprite.opacity = @opacity
        @back_sprite.opacity = @opacity
        @active_effect = "none"
      end
    end

    def clear()
      @text_sprite.bitmap.clear()
    end

    def set_text(text, align)
      case align
      when 1
        @text_sprite.bitmap.draw_text(-32, 0, @text_sprite.bitmap.width+64, 24, text.to_s, align.to_i)
      else
        @text_sprite.bitmap.draw_text(0, 0, @text_sprite.bitmap.width, 24, text.to_s, align.to_i)
      end
    end

    def set_effect(effect, *parameters)
      @active_effect = effect
      @effect_parameters = parameters
      update()
    end

    def set_font(*parameters)
      case parameters[0].upcase
      when "SIZE"
        @text_sprite.bitmap.font.size = parameters[1].to_i
      when "NAME"
        @text_sprite.bitmap.font.name = [parameters[1].to_s]
      end
    end

  end

  Automation = Struct.new(
    :initialize_auto, :start_auto, :post_start_auto, :update_auto,
    :pre_terminate_auto, :terminate_auto
  )

  def initialize(automation)
    set_automation(automation)
  end

  def automation_complete?()
    return @auto_index >= @current_auto.size
  end

  def set_automation(automation)
    @automation = Automation.new(
      automation[:initialize], automation[:start], automation[:post_start], automation[:update],
      automation[:pre_terminate], automation[:terminate]
    )
    @current_auto = []
  end

  def automatable?()
    return @automation != nil
  end

  def clear_automation()
    @automation = nil
    @current_auto = []
  end

  def update()
    @message_window.update() unless @message_window.nil?()
    @message_strip.update() unless @message_strip.nil?()
  end

  def terminate()
    @message_window.dispose() unless @message_window.nil?() ; @message_window = nil
    @message_strip.dispose() unless @message_strip.nil?() ; @message_strip = nil
  end

  def setup_new_automation(new_automation)
    @auto_index = 0
    @current_auto.clear()

    @sleep_count = 0
    @wait_count  = 0

    return if new_automation.nil?()
    @current_auto += new_automation
  end

  def on_initialize()
    return unless automatable?()
    setup_new_automation(@automation.initialize_auto)
    update_automation() until automation_complete?()
  end

  def on_start()
    return unless automatable?()
    setup_new_automation(@automation.start_auto)
    update_automation() until automation_complete?()
  end

  def on_post_start()
    return unless automatable?()
    setup_new_automation(@automation.post_start_auto)
    update_automation() until automation_complete?()
  end

  def setup_update_automation()
    return unless automatable?()
    setup_new_automation(@automation.update_auto)
  end

  def on_update()
    @sleep_count = [@sleep_count - 1, 0].max
    return unless @sleep_count == 0
    return unless automatable?()
    update_automation()
  end

  def on_pre_terminate()
    return unless automatable?()
    setup_new_automation(@automation.pre_terminate_auto)
    update_automation() until automation_complete?()
  end

  def on_terminate()
    return unless automatable?()
    setup_new_automation(@automation.terminate_auto)
    update_automation() until automation_complete?()
  end

  def update_automation()
    while !automation_complete?()
      action, parameters = @current_auto[@auto_index]
      puts "Automating: #{action} [#{parameters}]"
      case action.upcase
      when "CLEAR"
        clear_automation()
      when "DISABLE_INPUT", "DISABLE INPUT", "DISABLEINPUT"
        $scene.input_disabled = true
      when "ENABLE_INPUT", "ENABLE INPUT", "ENABLEINPUT"
        $scene.input_disabled = false
      when "MESSAGE1"
        case parameters[0].upcase
        when "CREATE"
          @message_strip = Message_Strip.new()
        when "DISPOSE"
          @message_strip.dispose() unless @message_strip.nil?()
          @message_strip = nil
        when "EFFECT"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.set_effect(parameters[1], *(parameters.slice(2, parameters.size)))
        when "FONT"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.set_font(*(parameters.slice(1, parameters.size)))
        when "CLEAR"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.clear()
        when "TEXT"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.set_text(parameters[1], parameters[2])
        when "SET_X", "SET X", "SETX"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.x = parameters[1].to_i
        when "SET_Y", "SET Y", "SETY"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.y = parameters[1].to_i
        when "SET_Z", "SET Z", "SETZ"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.z = parameters[1].to_i
        when "MOVETO"
          raise "Message strip was not created" if @message_strip.nil?()
          @message_strip.x = parameters[1].to_i
          @message_strip.y = parameters[2].to_i
        end
      when "SCENE_SEND", "SCENE SEND", "SCENESEND"
        case parameters[0].upcase
        when "SEND"
          $scene.send(parameters[1].to_s)
        when "ASSIGN1I"
          $scene.send(parameters[1].to_s, parameters[2].to_i)
        when "ASSIGN1S"
          $scene.send(parameters[1].to_s, parameters[2].to_s)
        when "ASSIGN1SYM"
          $scene.send(parameters[1].to_s, parameters[2].to_s.to_sym)
        end
      when "SCRIPT"
        eval(parameters[0].to_s)
      when "SLEEP"
        @sleep_count = parameters[0].to_i
      when "WAIT"
        @wait_count = parameters[0].to_i
      end
      Graphics.wait(@wait_count) if @wait_count > 0
      @auto_index += 1
      break if @sleep_count > 0
    end
  end

end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  def setup_automation(name)
    terminate_automation()
    $scene_automation = ISS::Scene_Automation.new(ISS::Scene_Automation::AUTOMATIONS[name])
  end

  def set_automation(name)
    $scene_automation.set_automation(ISS::Scene_Automation::AUTOMATIONS[name])
  end

  def clear_automation()
    $scene_automation.clear_automation()
  end

  def terminate_automation()
    $scene_automation.terminate() unless $scene_automation.nil?()
    $scene_automation = nil
  end

end

#==============================================================================#
# ** Scene_Base
#==============================================================================#
class Scene_Base

  def main
    start                         # Start processing
    perform_transition            # Perform transition
    post_start                    # Post-start processing
    Input.update                  # Update input information
    $scene_automation.setup_update_automation() unless $scene_automation.nil?()
    loop do
      Graphics.update             # Update game screen
      Input.update                # Update input information
      update                      # Update frame
      break if $scene != self     # When screen is switched, interrupt loop
    end
    Graphics.update
    pre_terminate                 # Pre-termination processing
    Graphics.freeze               # Prepare transition
    terminate                     # Termination processing
  end #if rgss2?()

  alias :iss035_scnbs_initialize :initialize unless $@
  def initialize(*args, &block)
    iss035_scnbs_initialize(*args, &block)
    $scene_automation.on_initialize() unless $scene_automation.nil?()
  end

  alias :iss035_scnbs_start :start unless $@
  def start(*args, &block)
    iss035_scnbs_start(*args, &block)
    $scene_automation.on_start() unless $scene_automation.nil?()
  end

  alias :iss035_scnbs_post_start :post_start unless $@
  def post_start(*args, &block)
    iss035_scnbs_post_start(*args, &block)
    $scene_automation.on_post_start() unless $scene_automation.nil?()
  end

  alias :iss035_scnbs_update :update unless $@
  def update(*args, &block)
    iss035_scnbs_update(*args, &block)
    unless $scene_automation.nil?()
      $scene_automation.update()
      $scene_automation.on_update()
    end
  end

  alias :iss035_scnbs_pre_terminate :pre_terminate unless $@
  def pre_terminate(*args, &block)
    iss035_scnbs_pre_terminate(*args, &block)
    $scene_automation.on_pre_terminate() unless $scene_automation.nil?()
  end

  alias :iss035_scnbs_terminate :terminate unless $@
  def terminate(*args, &block)
    iss035_scnbs_terminate(*args, &block)
    $scene_automation.on_terminate() unless $scene_automation.nil?()
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

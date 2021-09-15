#==============================================================================#
# ** IEX(Icy Engine Xelion) - TP - Text Pop
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Events and Player)
# ** Script Type   : Text Pop
# ** Date Created  : 08/29/2010
# ** Date Modified : 12/09/2010
# ** Version       : 1.0a
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES + HOW TO USE
#------------------------------------------------------------------------------#
# ~Quick Ref
# stack_text_pop("text", color, size)
# text is pretty straight forward..
#
# color is a color class type
# Being Color.new(255, 255, 255, 255) R,G,B, alpha respectively
#
# size is an integer, and represents the pops font size
#
# ~Long Explanation
# Just a simple text popping script.
# How does this work?
# You will do all these in a Move Route Call (Sorry its just easier that way)
# This works a little different from the IXTP version
# You do the script call stack_text_pop("text", color, size) This will immediately
# pop the selected text.
# You can call this as many times as you like. It will simply add to the existing
# pops
# Color is optional (The deafult color will be used if not defined)
# Size is the font size and is also optional
#
# Credit goes to Xideworg (Did I spell it right?) for his Pop Engine (XRXS Scripts)
#
# To use text substitution.
# <var[id]> for variables
# <name[id]> for actor name
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
# Non at the moment.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# 09/01/2010 1.0  Edited IXTP and shipped over to IEX
# 12/09/2010 1.0a Bug Fix, if the default font was changed from an array,
#                 the script would throw an error
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Text_Pop"] = true

class XRXS_POP_ENGINE # Taken form XRXS
    attr_accessor :finished
    attr_accessor :sprite
    attr_accessor :stop_update

    GRAVITY = 0.58
    TRANCEPARENT_START = 40
    TRANCEPARENT_X_SLIDE = 0

    def initialize(sprite, x, y, ox)
      @finished = false
      @ref_character = Game_Character.new
      @ref_character.moveto(x, y)
      @ref_character.update
      @spr_ox = ox
      @working_sprite = sprite
      @stop_update = false
      prep_pop
    end

    def work_sprite
      return @working_sprite
    end

    def damage_x_init_velocity
      return 0.4 * (rand(8))  # 0.2 * (rand(5) - 2)
    end

    def damage_y_init_velocity
      return 1.5 * (rand(4) + 4)
    end

    def prep_pop
      @now_x_speed = damage_x_init_velocity
      @now_y_speed = damage_y_init_velocity
      @potential_x_energy = 0.0
      @potential_y_energy = 0.0
      @speed_off_x = rand(10)
      @pop_duration = 80
    end

    def pop_update
      sprite = work_sprite
      return if sprite == nil
      return if @finished
      return if @stop_update
      if @pop_duration <= TRANCEPARENT_START
        sprite.opacity -= (256 / TRANCEPARENT_START)
        sprite.x += TRANCEPARENT_X_SLIDE if @speed_off_x < 6
        sprite.x -= TRANCEPARENT_X_SLIDE if @speed_off_x >= 6
      end
      sprite.x = @ref_character.screen_x + (@spr_ox - (sprite.bitmap.width) / 2)
      sprite.y = @ref_character.screen_y
      return if sprite == nil
      n = sprite.oy + @now_y_speed
      if n <= 0
        @now_y_speed *= -1
        @now_y_speed /=  2
        @now_x_speed /=  2
      end
      sprite.oy = [n, 0].max
      @potential_y_energy += GRAVITY
      speed = @potential_y_energy.floor
      @now_y_speed        -= speed
      @potential_y_energy -= speed
      @potential_x_energy += @now_x_speed
      speed = @potential_x_energy.floor
      sprite.ox  += speed if @speed_off_x < 6
      sprite.ox  -= speed if @speed_off_x >= 6
      @potential_x_energy -= speed
      @pop_duration -= 1
      if @pop_duration == 0
        @finished = true
      end
    end

end

class Sprite_Character < Sprite_Base

  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias iex_text_pop_spc_initialize initialize unless $@
  def initialize(*args)
    iex_text_pop_spc_initialize(*args)
    if @character != nil
      @character.iex_sprite_back_ref = self
    end
  end

  alias iex_text_pop_spc_dispose dispose unless $@
  def dispose(*args)
    iex_text_pop_spc_dispose(*args)
    if @character != nil
      @character.iex_sprite_back_ref = nil
    end
  end

end

class Game_Character

  attr_accessor :texts_to_pop
  attr_accessor :texts_ready
  attr_accessor :iex_sprite_back_ref
  attr_accessor :iex_waiting_text

  alias ixtp_gc_text_pop_initialize initialize unless $@
  def initialize(*args)
    ixtp_gc_text_pop_initialize(*args)
    @texts_to_pop = []
    @texts_ready = false
    @ptext = ''
    @iex_sprite_back_ref = nil
    @iex_waiting_text = []
    @pop_delay = 0
    @iex_can_pop = true
  end

  def prep_text_stack
    if @texts_to_pop != nil
       @texts_to_pop.clear
    end
    @texts_to_pop = []
  end


  def stack_text_pop(text = nil, color = Color.new(255, 255, 255), size = 21, properties = [], more_fonts = [])
    @iex_waiting_text.push([text, color, size, properties, more_fonts])
  end

  alias ixtp_gc_text_pop_update update unless $@
  def update(*args)
    ixtp_gc_text_pop_update(*args)
    if @iex_can_pop
      @pop_delay -= 1 unless @pop_delay == 0
      if @pop_delay == 0 and !@iex_waiting_text.empty?
        pop_dat = @iex_waiting_text.shift
        execute_text_pop(pop_dat[0], pop_dat[1], pop_dat[2], pop_dat[3], pop_dat[4])
        @pop_delay = 5
      end
    end
  end

  def execute_text_pop(text = nil, color = Color.new(255, 255, 255), size = 21, properties = [], more_fonts = [])
    return if text == nil
    text = text.to_s
    size = size.to_i
    text = text.gsub(/<(?:var|v)\[(\d+)\]>/i) { $game_variables[$1.to_i] }
    text = text.gsub(/<(?:name|n)\[(\d+)\]>/i) { $game_actors[$1.to_i].name }
    textsize = text.size * 24
    textsize += 32 if textsize < 32
    text_height = size + 2
    text_data = []
    text_data[0] = Sprite.new
    text_data[0].bitmap = Bitmap.new(textsize, text_height)
    font_names = []
    font_names += more_fonts
    for prop in properties
      case prop.to_s
      when /(?:BOLD|B)/i
        text_data[0].bitmap.font.bold = true
      when /(?:ITALIC|I)s?/i
        text_data[0].bitmap.font.italic = true
      when /(?:SHADOW|SH)/i
        text_data[0].bitmap.font.shadow = true
      when /(?:NO_SHADOW|no shadow|NSH)/i
        text_data[0].bitmap.font.shadow = false
      when /(?:NO_BOLD|no bold|NB)/i
        text_data[0].bitmap.font.bold = false
      when /(?:NO_ITALIC|no italic|NI)s?/i
        text_data[0].bitmap.font.italic = false
      end
    end
    font_names += Font.default_name if Font.default_name.is_a?(Array)
    font_names.push(Font.default_name) if Font.default_name.is_a?(String)
    text_data[0].bitmap.font.name = font_names
    text_data[0].bitmap.font.size = size
    text_data[0].bitmap.font.color = color
    text_data[0].bitmap.draw_text(0, 0, textsize, text_height, text, 1)
    if @iex_sprite_back_ref != nil
      spr_ox = @iex_sprite_back_ref.ox
      spr_x  = @iex_sprite_back_ref.x
      spr_y  = @iex_sprite_back_ref.y
      spr_height = @iex_sprite_back_ref.height
    else
      spr_ox = 0
      spr_x  = screen_x
      spr_y  = screen_y
      spr_height = 32
    end
    text_data[0].x = spr_x + (spr_ox - (text_data[0].bitmap.width) / 2)
    text_data[0].y = (spr_y - spr_height) + 16
    text_data[0].z = 280
    text_data[1] = XRXS_POP_ENGINE.new(text_data[0], self.x, self.y, spr_ox)
    @texts_to_pop.push(text_data)
  end

end

class Sprite_Character < Sprite_Base

  alias ixtp_scm_text_pop_initialize initialize unless $@
  def initialize(*args)
    @ixtp_text_pop = []
    ixtp_scm_text_pop_initialize(*args)
  end

  alias ixtp_update_text_pop_update update unless $@
  def update
    ixtp_update_text_pop_update
    unless @character.texts_to_pop.empty?
      @ixtp_text_pop = @ixtp_text_pop + @character.texts_to_pop
      @character.texts_to_pop.clear
    end
    ixtp_update_text_pop
  end

  def ixtp_update_text_pop
    return if @ixtp_text_pop.empty?
    for i in 0..@ixtp_text_pop.size
      spri = @ixtp_text_pop[i]
      next if spri == nil
      if spri[1] == nil or spri[0] == nil
        #@ixtp_text_pop.compact!
        next
      end
      if spri[1].finished
        ixtp_dispose_text_pop(spri)
        @ixtp_text_pop.delete(i)
        spri[0] = nil
        spri[1] = nil
        #@ixtp_text_pop.compact!
      else
        spri[1].pop_update
      end
    end
  end

  def ixtp_dispose_text_pop(spri)
    return if spri.nil? || spri[0].nil?
    spri[1].stop_update = true
    spri[0].bitmap.dispose
    spri[0].dispose
  end

  def ixtp_dispose_all_text_pop
    for spri in @ixtp_text_pop
      ixtp_dispose_text_pop(spri)
    end
      @ixtp_text_pop.clear
      @ixtp_text_pop = []
  end

  alias ixtp_scm_text_pop_dispose dispose unless $@
  def dispose
    ixtp_scm_text_pop_dispose
    ixtp_dispose_all_text_pop
    @character.iex_sprite_back_ref = nil
  end

end

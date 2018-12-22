#==============================================================================
# P A R T I C L E    E N G I N E    VXAce Port
#------------------------------------------------------------------------------
#  Author: Andrew McKellar (Anaryu) (anmckell@gmail.com)
#  Ported by: Dr. Yami
#
#  Version: 1.2
#
#  1.2: Added animation support to Partile Engine.
#
#  This script is built to work with the default systems but can be adapated
#  to work with most, epsecially event-driven systems.
#
#  All particles should be loaded into the Pictures folder.
#
#  Please credit if used, not licensed for commercial use without consent.
#==============================================================================

#==============================================================================
# ** Particle Setting
#------------------------------------------------------------------------------
#  Instance of the settings for a particle
#==============================================================================

class Particle_Setting
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  # [Speed] is how many frames to wait before
  # making [Power] amount of the parctile
  # So [Power] of 2 and [Speed] of 3 means 2 particles every 3 frames
  attr_accessor       :power          # Power of the particle
  attr_accessor       :speed          # Speed of the particle generation
  # [Intensity] is the starting opacity 1-255 and
  # [burnout] is how how much the opacity changes a particle 
  # is considered "done" when opacity is more than 255 or less than 1
  attr_accessor       :intensity
  attr_accessor       :burnout
  # H and V scatter are how much of a random value the starting location
  # can have, so a [h_scatter] of 10 and a [v_scatter] of 0 means it will
  # generate all particles at the same y location, but with a random
  # difference of 10 pixels (in either direction) of it's x starting location
  attr_accessor       :h_scatter
  attr_accessor       :v_scatter
  # [Velocity] is how fast it changes in each direction [down, left, right, up]
  # [acceleration] is how much the [velocity] changes each frame
  # in each of the same directions [down, left, right, up]
  attr_accessor       :velocity
  attr_accessor       :acceleration
  # [Angle_change] is how much the angle should change each frame and
  # [achange_delta] is how much that angle change will chance each frame
  attr_accessor       :angle_change
  attr_accessor       :achange_delta
  # [zoom_start] is the start value of the zoom for the sprite [x,y]
  # [zoom_starts] is when the zoom transition starts (frame) [x,y]
  # [zoom_change] is the amount to change it [x,y]
  attr_accessor       :zoom_start
  attr_accessor       :zoom_starts
  attr_accessor       :zoom_change
  # [Move_type] decides the move type of the particle
  # 0: Standard Linear Movement
  # 1: Circular movement offset [x,y] used to define x and y radius
  # 2: Explode/collapse based on velocity being + or -
  # 3: Circular in X, linear in Y
  # 4: Circular in Y, linear in X
  attr_accessor       :move_type
  # [Lock] decides if the particle is locked on it's target or will
  # remain where it started
  attr_accessor       :lock
  # [wAmp] and [wLength] and [wSpeed] and [wPhase] are the default values
  # for the wave attributes (read VX documentation under "Sprite" for details)
  attr_accessor       :wamp
  attr_accessor       :wlength
  attr_accessor       :wspeed
  attr_accessor       :wphase
  # [Animation_Frames] if set will create an animated particle instead,
  # which will loop through an image assuming it's width / [animation_frames]
  # will produce the correct number of frames and will loops through
  # these with [Animation_Speed] pause between each frame.
  attr_accessor       :animation_frames
  attr_accessor       :animation_speed
  # The starting frame for the particle, if set to -1 it will be random
  # if set past the pattern limitation it will be the first
  attr_accessor       :animation_start_frame
end

#==============================================================================
# ** Particle
#------------------------------------------------------------------------------
#  A Particle is the actual particle itself.
#==============================================================================

class Combat_Effect_Setting
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor   :particle
  attr_accessor   :blend
  attr_accessor   :setting
  attr_accessor   :duration
  attr_accessor   :offset
end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass of the
# Game_Player and Game_Event classes.
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Get X for Particle Engine System
  #--------------------------------------------------------------------------
  def get_pe_x
    return @real_x * 256
  end
  #--------------------------------------------------------------------------
  # * Get Y for Particle Engine System
  #--------------------------------------------------------------------------
  def get_pe_y
    return @real_y * 256
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader     :particles
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     map_id : map ID
  #     event  : event (RPG::Event)
  #--------------------------------------------------------------------------
  alias :pre_pe_initialize  :initialize
  def initialize(map_id, event)
    # Generate particle variables
    @particles = []
    @particles_created = false
    # Normal init
    pre_pe_initialize(map_id, event)
  end
  #--------------------------------------------------------------------------
  # * Create Particles
  #--------------------------------------------------------------------------
  def create_particles
    # Check to see if we have particles
    if @event.name.include?("PART") and not @particles_created
      # Add effects found in the event codes
      if self.list != nil
        for item in self.list
          if item.code == 108 and item.parameters[0].include?("PARTICLE=")
            id = item.parameters[0].split('=')
            particle_settings = id[1].to_s
            ps = particle_settings.split(',')
            if ps.size == 3
              particle = SceneManager.scene.ap(ps[0].to_s, self, ps[1].to_i, -1, ps[2].to_s)
              @particles.push(particle)
            elsif ps.size == 5
              particle = SceneManager.scene.ap(ps[0].to_s, self, ps[1].to_i, -1, ps[2].to_s, [ps[3].to_i, ps[4].to_i])
              @particles.push(particle)
            end
          end
        end
      end
    end
    @particles_created = true
  end
  #--------------------------------------------------------------------------
  # * Clear Starting Flag
  #--------------------------------------------------------------------------
  alias :pre_pe_clear_starting  :clear_starting_flag
  def clear_starting_flag
    pre_pe_clear_starting
    # Also clear particle flags and clear all particles
    for i in 0...@particles.size
      @particles[i].dispose
      @particles[i] = nil
    end
    @particles.delete(nil)
    @particles_created = false
  end
  #--------------------------------------------------------------------------
  # * Clear Starting Flag
  #--------------------------------------------------------------------------
  def clear_particles
    @particles = [] if @particles == nil
    # Also clear particle flags and clear all particles
    for i in 0...@particles.size
      @particles[i].dispose
      @particles[i] = nil
    end
    @particles.delete(nil)
    @particles_created = false
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles maps. It includes event starting determinants and map
# scrolling functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Execute Player Transfer
  #--------------------------------------------------------------------------
  alias :pre_pe_perform_transfer  :perform_transfer
  def perform_transfer
    # Perform normal transfer
    pre_pe_perform_transfer
    # If we're staying on the same map, remake the particles
    if $game_map.map_id == @new_map_id
      for event in $game_map.events.values
        event.clear_particles
      end
    end
  end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles data surrounding the system. Backround music, etc.
#  is managed here as well. Refer to "$game_system" for the instance of 
#  this class.
#==============================================================================

class Game_System
  attr_accessor   :particle_level
  attr_accessor   :particle_settings
  attr_accessor   :combat_settings
  alias :pre_pe_initialize  :initialize
  def initialize
    # Run original initialize
    pre_pe_initialize
    # Set new values
    @particle_level = 100
    @particle_settings = {}
    @combat_settings = {}
    battle_effect_settings
  end
end

#==============================================================================
# ** Interpreter
#------------------------------------------------------------------------------
#  This interpreter runs event commands. This class is used within the
#  Game_System class and the Game_Event class.
#==============================================================================

class Game_Interpreter
  attr_accessor   :effects
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias :pre_pe_initialize  :initialize
  def initialize(depth = 0)
    @effects = []
    pre_pe_initialize(depth)
  end
  #--------------------------------------------------------------------------
  # * Add Effect
  #--------------------------------------------------------------------------
  def add_effect(id, particle)
    # Initialize @effects if it's not initialized yet to cope
    # with late particle system integration
    @effects = [] if @effects == nil
    # Dispose of effect at given id if possible
    if @effects[id] == nil
      @effects[id] = particle
    else
      @effects[id].disposed = true
      @effects[id] = particle
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose Effect
  #--------------------------------------------------------------------------
  def dispose_effect(id = 0)
    # Initialize @effects if it's not initialized yet to cope
    # with late particle system integration
    @effects = [] if @effects == nil
    # Dispose of effect at given id if possible
    if @effects[id] != nil
      @effects[id].disposed = true
    end
  end
end

#==============================================================================
# ** Particle_Effect
#------------------------------------------------------------------------------
#  A Particle_Effect will generate particles based on it's settings.
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # * Execute Screen Switch
  #--------------------------------------------------------------------------
  alias  :pre_pe_update_scene_change    :update_scene
  def update_scene
    # Run normal function
    pre_pe_update_scene_change
    # Clear particles as the scene has changed
    if scene_changing?
      for event in $game_map.events.values
        event.clear_particles
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Add Particle Effect
  #--------------------------------------------------------------------------
  def ap(name, target, blend, duration, setting, offset = [0,0])
    s = $game_system.particle_settings[setting]
    if target?(target)
      return @spriteset.ap(name, target, blend, duration, s, offset.clone)
    else
      return @spriteset.ap(name, target.clone, blend, duration, s, offset.clone)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias :pre_pe_update  :update
  def update
    # Run normal update
    pre_pe_update
    # Update particles
    if SceneManager.scene_is?(Scene_Map)
      for event in $game_map.events.values
        event.create_particles
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def add_particle(target, name, blend, setting, offset, v = nil, a = nil)
    @spriteset.add_particle(target, name, blend, setting, offset, v, a)
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def target?(t)
    return true if t.is_a?(Game_Character)
    return true if t.is_a?(Sprite_Battler)
    return false
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  alias :pre_pe_start   :start
  def start
    # Generate battle effect settings
    $game_system.battle_effect_settings
    # Run normal start
    pre_pe_start
  end
  #--------------------------------------------------------------------------
  # * Add Particle Effect
  #--------------------------------------------------------------------------
  def ap(name, target, blend, duration, setting, offset = [0,0])
    s = $game_system.particle_settings[setting]
    if target?(target)
      return @spriteset.ap(name, target, blend, duration, s, offset.clone)
    else
      return @spriteset.ap(name, target.clone, blend, duration, s, offset.clone)
    end
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def add_particle(target, name, blend, setting, offset, v = nil, a = nil)
    @spriteset.add_particle(target, name, blend, setting, offset, v, a)
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def target?(t)
    return true if t.is_a?(Game_Character)
    return true if t.is_a?(Sprite_Battler)
    return false
  end
end

#==============================================================================
# ** Sprite_Base
#------------------------------------------------------------------------------
#  A sprite class with animation display processing added.
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * SE and Flash Timing Processing
  #     timing : timing data (RPG::Animation::Timing)
  #--------------------------------------------------------------------------
  alias   :pre_pe_animation_process_timing  :animation_process_timing
  def animation_process_timing(timing)
    c = timing.flash_color
    if c.alpha == 0 and c.red == 1
      e = $game_system.combat_settings[timing.flash_duration]
      if SceneManager.scene_is?(Scene_Battle)
        offset = [e.offset[0], e.offset[1]]
        offset[0] += c.green
        offset[1] += c.blue
        SceneManager.scene.ap(e.particle, self, e.blend, e.duration, e.setting, offset)
      end
    else
      pre_pe_animation_process_timing(timing)
    end
  end
  #--------------------------------------------------------------------------
  # * Get X for Particle Engine System
  #--------------------------------------------------------------------------
  def get_pe_x
    return (@battler.screen_x * 8)
  end
  #--------------------------------------------------------------------------
  # * Get Y for Particle Engine System
  #--------------------------------------------------------------------------
  def get_pe_y
    return ((@battler.screen_y * 8) - (@height * 4))
  end
end

#==============================================================================
# ** Spriteset
#------------------------------------------------------------------------------
#  A Particle_Effect will generate particles based on it's settings.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader     :particles
  attr_reader     :effects
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  alias :pre_pe_initialize  :initialize
  def initialize
    @frame = 0
    @particles = []
    @effects = []
    $game_system.particle_settings = {} if $game_system.particle_settings == nil
    $game_system.create_particle_settings
    pre_pe_initialize
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias :pre_pe_dispose :dispose
  def dispose
    for particle in @particles
      particle.dispose
    end
    pre_pe_dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias :pre_pe_update :update
  def update    
    # Set the particle level if it's nil to 100 (full amount)
    $game_system.particle_level = 100 if $game_system.particle_level == nil
    # Go through and update effects
    for i in 0...@effects.size
      # Update only if on_screen (or close)
      @effects[i].update if on_screen(@effects[i])
      # Nil it if it's time to dispose it
      @effects[i] = nil if @effects[i].dispose?
    end
    # Delete those disposed effects
    @effects.delete(nil)
    # Updated particles
    for i in 0...@particles.size
      # Update
      @particles[i].update
      # Check if disposed
      dispose = @particles[i].dispose?
      # If disposed dispose and nil it
      @particles[i].dispose if dispose
      @particles[i] = nil if dispose
    end
    # Delete disposed particles
    @particles.delete(nil)
    # Run standard update
    pre_pe_update
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def ap(name, target, blend, duration, setting, offset = [0,0])
    s = $game_system.particle_settings[setting]
    t = target
    t = target.clone if not target?(target)
    effect = Particle_Effect.new(name, target, blend, duration, setting, offset.clone)
    @effects.push(effect)
    return effect
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def add_particle(target, name, blend, setting, offset, v = nil, a = nil)
    particle = Particle.new(@viewport1, target, name, blend, setting, offset, v, a)
    @particles.push(particle)
  end
  #--------------------------------------------------------------------------
  # * On Screen
  #--------------------------------------------------------------------------
  def on_screen(effect)
    x = effect.origin[0]
    y = effect.origin[1]
    x_range = ((x <= ($game_map.display_x + 4352)) and (x >= ($game_map.display_x - 512)))
    y_range = ((y <= ($game_map.display_y + 3072)) and (y >= ($game_map.display_y - 512)))
    if x_range and y_range
      return true
    end
    return true if effect.target.is_a?(Game_Player)
    return false
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def target?(t)
    return true if t.is_a?(Game_Character)
    return true if t.is_a?(Sprite_Battler)
    return false
  end
end

#==============================================================================
# ** Spriteset
#------------------------------------------------------------------------------
#  A Particle_Effect will generate particles based on it's settings.
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader     :particles
  attr_reader     :effects
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  alias :pre_pe_initialize  :initialize
  def initialize
    @particles = []
    @effects = []
    $game_system.particle_settings = {} if $game_system.particle_settings == nil
    $game_system.create_particle_settings
    pre_pe_initialize
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias :pre_pe_dispose :dispose
  def dispose
    for particle in @particles
      particle.dispose
    end
    pre_pe_dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias :pre_pe_update :update
  def update
    # Set the particle level if it's nil to 100 (full amount)
    $game_system.particle_level = 100 if $game_system.particle_level == nil
    # Go through and update effects
    for i in 0...@effects.size
      # Update only if on_screen (or close)
      @effects[i].update
      # Nil it if it's time to dispose it
      @effects[i] = nil if @effects[i].dispose?
    end
    # Delete those disposed effects
    @effects.delete(nil)
    # Updated particles
    for i in 0...@particles.size
      # Update
      @particles[i].update
      # Check if disposed
      dispose = @particles[i].dispose?
      # If disposed dispose and nil it
      @particles[i].dispose if dispose
      @particles[i] = nil if dispose
    end
    # Delete disposed particles
    @particles.delete(nil)
    # Run standard update
    pre_pe_update
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def ap(name, target, blend, duration, setting, offset = [0,0])
    s = $game_system.particle_settings[setting]
    t = target
    t = target.clone if not target?(target)
    effect = Particle_Effect.new(name, target, blend, duration, setting, offset.clone)
    @effects.push(effect)
    return effect
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def add_particle(target, name, blend, setting, offset, v = nil, a = nil)
    particle = Particle.new(@viewport1, target, name, blend, setting, offset, v, a)
    @particles.push(particle)
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def target?(t)
    return true if t.is_a?(Game_Character)
    return true if t.is_a?(Sprite_Battler)
    return false
  end
end

#==============================================================================
# ** Particle_Effect
#------------------------------------------------------------------------------
#  A Particle_Effect will generate particles based on it's settings.
#==============================================================================

class Particle_Effect
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor   :origin       # starting location in realx/realy location
  attr_accessor   :target       # game character or starting [x,y] origin
  attr_reader     :power        # higher power means more particles per tick
  attr_reader     :speed        # higher speed means faster particle generation
  attr_reader     :blend        # blend type 0 = normal, 1 = add, 2 = subtract
  attr_reader     :velocity     # initial speed [x,y]
  attr_reader     :acceleration # amount to change speed [x,y]
  attr_reader     :duration     # length of frames to produce particles
  attr_reader     :h_scatter    # magnitude of random horizontal offsets
  attr_reader     :v_scatter    # magnitude of random vertical offsets
  attr_reader     :particle     # name of the picture file to use
  attr_reader     :lock         # locked on target or not?
  attr_reader     :offset       # [x,y] offset
  attr_accessor   :disposed     # should this be disposed of now?
  attr_reader     :frame        # frames, starts at zero and increases over time
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(name, target, blend, duration, setting, offset)
    # Assign starting values
    if target?(target)
      @origin = [target.get_pe_x, target.get_pe_y]
      @target = target
    else
      @origin = [target[0], target[1]]
      @target = target.clone
    end
    @name = name
    @setting = setting
    @blend = blend
    @duration = duration
    @particle = name
    @offset = offset
    @frames = 0
    @powered = 0
    @disposed = false
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Add new particles if necessary
    gen_frame = (@frames % @setting.speed == 0)
    powed = (@powered[1] == 0 or (@powered[0] > 0 and @frames % @powered[1] == 0))
    # Check if the level of particles set will allow us to generate or not
    rand = $game_system.particle_level > rand(100)
    # Use the checks to determine if we should generate a particle right now
    if (gen_frame or powed) and rand
      # If we're going to generate more than one per tick, do it!
      @setting.power[1] == 0 ? @repeat = @setting.power[0] : @repeat = 1
      for i in 0...@repeat
        # Set the powered value 
        @powered = @setting.power.clone if @powered[0] <= 0
        # Generate scattered start points
        x_rand = rand(@setting.h_scatter+1)
        y_rand = rand(@setting.v_scatter+1)
        # Scatter in all directions, not just one
        neg1 = rand(2)
        x_rand *= -1 if neg1 == 1
        neg2 = rand(2)
        y_rand *= -1 if neg2 == 1
        # Apply the scatter values
        offset = [@offset[0] + x_rand, @offset[1] + y_rand]
        # Set the particles starting conditions based on move_type
        case @setting.move_type
        when 0, 1, 3, 4
          # Create the particles with the offset
          offset = [@offset[0] + x_rand, @offset[1] + y_rand]
          SceneManager.scene.add_particle(@target, @name, @blend, @setting, offset)
        when 2
          # Get a scatter value
          x_mod = x_rand.abs * 1.0 / (@setting.h_scatter + 1)
          y_mod = y_rand.abs * 1.0 / (@setting.v_scatter + 1)
          # Clone our velocity and accelerate to accomodate random start place
          # but identical ending location
          v = [@setting.velocity[0] * x_mod, @setting.velocity[1] * y_mod]
          a = [@setting.acceleration[0] * x_mod, @setting.acceleration[1] * y_mod]
          # Invert values if necessary
          if neg1 == 1
            v = [v[0] * -1.0, v[1]]
            a = [a[0] * -1.0, a[1]]
          end
          if neg2 == 1
            v = [v[0], v[1] * -1.0]
            a = [a[0], a[1] * -1.0]
          end
          # Fix origin to accomodate moving characters
          if target?(target)
            @origin = [target.get_pe_x, target.get_pe_y]
          end
          # Add the particle
          SceneManager.scene.add_particle(@target, @name, @blend, @setting, offset, v, a)
        end
        # Reduced our powered value
        @powered[0] -= 1
      end
    end
    # Increase frame
    @frames += 1
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def dispose?
    # Return true if we're set to be disposed
    return true if @disposed
    # Return false immediately if our duration is 01
    return false if @duration == -1
    # Return true if our frames are at or past duration
    if @frames > @duration
      return true
    end
    # Default false
    return false
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def dispose
    @disposed = true
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def target?(t)
    return true if t.is_a?(Game_Character)
    return true if t.is_a?(Sprite_Battler)
    return false
  end
end


#==============================================================================
# ** Particle
#------------------------------------------------------------------------------
#  A Particle is the actual particle itself.
#==============================================================================

class Particle < Sprite
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader     :target       # game character or starting [x,y] origin
  attr_reader     :velocity     # initial speed [x,y]
  attr_reader     :acceleration # amount to change speed [x,y]
  attr_reader     :duration     # length of frames to produce particles
  attr_reader     :particle     # name of the picture file to use
  attr_reader     :offset       # [x,y] offset
  attr_reader     :opacity      # current opacity
  attr_reader     :achange      # angle change
  attr_reader     :opacity      # current opacity
  attr_reader     :setting      # the particle settings to use
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport, target, name, blend, setting, offset = [0,0], v = nil, a = nil)
    super(viewport)
    self.bitmap = Cache.picture(name)
    # Set the setting variable
    @s = setting
    # Set x/y based on target
    @target = target
    @offset = offset.clone
    # Set wave and angle defaults
    self.wave_amp = @s.wamp if @s.wamp != nil
    self.wave_length = @s.wlength if @s.wlength != nil
    self.wave_speed = @s.wspeed if @s.wspeed != nil
    self.wave_phase = @s.wphase if @s.wphase != nil
    @angle = self.angle
    # Set the angle values
    @achange = @s.angle_change
    # Set starting point based on target type (character vs. array)
    if target?(@target)
      self.x = (@target.get_pe_x / 8) + @offset[0]
      self.y = (@target.get_pe_y / 8) + @offset[1]
      @origin = [(@target.get_pe_x / 8) + @offset[0], (@target.get_pe_y / 8) + @offset[1]]
    else
      self.x = @target[0] + @offset[0]
      self.y = @target[1] + @offset[1]
      @origin = [@target[0] + @offset[0], @target[1] + @offset[1]]
    end
    # Set zoome values if they're there
    if @s.zoom_start != nil
      @zoom = [(@s.zoom_start[0] / 100.0), (@s.zoom_start[1] / 100.0)]
      self.zoom_x = @zoom[0]
      self.zoom_y = @zoom[1]
    end
    # Set width and height for animation
    @width = self.bitmap.width
    @width = self.bitmap.width / @s.animation_frames if animated?
    @height = self.bitmap.height
    # Offset x/y based on our sprite size
    self.ox = (@width / 2)
    self.oy = (@height / 2)
    # Set default extra x/y for tile offset
    @x_extra = 0
    @y_extra = 0
    # Set the extra offset if we're a special case type
    set_extra_offset
    # Set blend type and other values
    self.blend_type = blend
    @opacity = @s.intensity
    @velocity = @s.velocity.clone
    @acceleration = @s.acceleration.clone
    @velocity = v if v != nil
    @acceleration = a if a != nil
    # Set internal variables
    @delta = [0,0]
    @frame = 0
    # Set pattern and animation variables
    if @s.animation_start_frame != nil
      if @s.animation_start_frame == -1
        @pattern = rand((@s.animation_frames+1))
      else
        if @s.animation_start_frame > @s.animation_frames
          @pattern = 0
        else
          @pattern = @s.animation_start_frame
        end
      end
    end
    # Run first frame
    update
    update_pattern
  end
  #--------------------------------------------------------------------------
  # * Should I be disposed?
  #--------------------------------------------------------------------------
  def dispose?
    # We're dead if our opacity is zero
    return ((@opacity <= 0) or (@opacity > 255))
  end
  #--------------------------------------------------------------------------
  # * Should I be disposed?
  #--------------------------------------------------------------------------
  def animated?
    # We're dead if our opacity is zero
    return (@s.animation_frames != nil and @s.animation_frames > 0)
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  def update_pattern
    if animated?
      sx = @pattern * @width
      sy = 0
      self.src_rect.set(sx, sy, @width, @height)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Change angle
    @achange = @achange + @s.achange_delta
    @angle = @angle + @achange
    self.angle = @angle
    # Decay opacity
    @opacity -= @s.burnout
    self.opacity = @opacity
    # Update animation
    # working
    if animated?
      if @s.animation_speed > 0 and @frame % @s.animation_speed == 0
        @pattern = ((@pattern + 1) % @s.animation_frames)
        update_pattern
      end
    end
    # Change velocity
    @velocity[0] += @acceleration[0]
    @velocity[1] += @acceleration[1]
    @delta[0] += @velocity[0]
    @delta[1] += @velocity[1]
    # Check zoom changes
    if @s.zoom_starts != nil
      # Check each zoom starts frame to see if we start on that axis yet
      if @s.zoom_starts[0] <= @frame
        @zoom[0] += (@s.zoom_change[0] / 100.0)
      end
      if @s.zoom_starts[1] <= @frame
        @zoom[1] += (@s.zoom_change[1] / 100.0)
      end
      # Reset zoom values
      self.zoom_x = @zoom[0]
      self.zoom_y = @zoom[1]
    end
    # Set Z value
    if @target.is_a?(Game_Character)
      if @target.priority_type != nil and @target.priority_type == 2
        self.z = @target.screen_z + 1000
      else
        if self.y > (@target.screen_y - 64)
          self.z = @target.screen_z + 32 + @delta[1]
        else
          self.z = @target.screen_z - 16 + @delta[1]
        end
      end
    elsif @target.is_a?(Sprite_Base)
      self.z = @target.z + 100
    elsif $game_player != nil
      if self.y > ($game_player.screen_y - 16)
        self.z = $game_player.screen_z + 32 + @delta[1]
      else
        self.z = $game_player.screen_z - 16 + @delta[1]
      end
    end
    # Set Screen offsets
    x_screen = 0
    y_screen = 0
    if $game_map != nil
      x_screen = $game_map.display_x * 32
      y_screen = $game_map.display_y * 32
    end
    # Set x/y location
    case @s.move_type
    # Standard acceleration based vector movement
    when 0, 2
      if target?(@target)
        if @s.lock
          self.x = (@target.get_pe_x / 8) + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = (@target.get_pe_y / 8) + @offset[1] + @delta[1] + @y_extra - y_screen
        else
          self.x = @origin[0] + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = @origin[1] + @offset[1] + @delta[1] + @y_extra - y_screen
        end
      else
        if @s.lock
          self.x = @target[0] + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = @target[1] + @offset[1] + @delta[1] + @y_extra - y_screen
        else
          self.x = @origin[0] + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = @origin[1] + @offset[1] + @delta[1] + @y_extra - y_screen
        end
      end
    # Circles around the target
    when 1
      if target?(@target)
        if @s.lock
          self.x = ((@target.get_pe_x / 8) + @x_extra) + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = ((@target.get_pe_y / 8) + @y_extra) + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        else
          self.x = @origin[0] + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = @origin[1] + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        end
      else
        if @s.lock
          self.x = (@target[0] + @x_extra) + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = (@target[1] + @y_extra) + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        else
          self.x = @origin[0] + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = @origin[1] + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        end
      end
    # Circles around the X moves in Y
    when 3
      if target?(@target)
        if @s.lock
          self.x = ((@target.get_pe_x / 8) + @x_extra) + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = (@target.get_pe_y / 8) + @offset[1] + @delta[1] + @y_extra - y_screen
        else
          self.x = @origin[0] + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = @origin[1] + @offset[1] + @delta[1] + @y_extra - y_screen
        end
      else
        if @s.lock
          self.x = (@target[0] + @x_extra) + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = @target[1] + @offset[1] + @delta[1] + @y_extra - y_screen
        else
          self.x = @origin[0] + @offset[0] * Math.cos(@velocity[0]*@frame) - x_screen
          self.y = @origin[1] + @offset[1] + @delta[1] + @y_extra - y_screen
        end
      end
    # Circles around the Y and moves in X
    when 4
      if target?(@target)
        if @s.lock
          self.x = (@target.get_pe_x / 8) + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = ((@target.get_pe_y / 8) + @y_extra) + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        else
          self.x = @origin[0] + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = @origin[1] + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        end
      else
        if @s.lock
          self.x = @target[0] + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = (@target[1] + @y_extra) + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        else
          self.x = @origin[0] + @offset[0] + @delta[0] + @x_extra - x_screen
          self.y = @origin[1] + @offset[1] * Math.sin(@velocity[1]*@frame) - y_screen
        end
      end
    end
    # Increase frame count
    @frame += 1
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def target?(t)
    return true if t.is_a?(Game_Character)
    return true if t.is_a?(Sprite_Battler)
    return false
  end
  #--------------------------------------------------------------------------
  # * Add Particle
  #--------------------------------------------------------------------------
  def set_extra_offset
    if @target.is_a?(Game_Character)
      @x_extra = 16
      @y_extra = 16
    end
  end
end
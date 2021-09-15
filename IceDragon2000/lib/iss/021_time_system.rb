#encoding:UTF-8
# ISS021 - Time System 1.1
#==============================================================================#
# ** ISS - Time System
#==============================================================================#
# ** Date Created  : 08/13/2011
# ** Date Modified : 08/13/2011
# ** Created By    : IceDragon
# ** ID            : 021
# ** Version       : 1.1
# ** Requires      : ISS000 - Core(2.1 or above)
#==============================================================================#
# // Few Warnings and such
#==============================================================================#
# // 1.0
# // This time system uses a new technique I created for dynamic tone changing.
# // This works, but is a time consuming and heavy process.
# // To reduce the load, I created a Tone Cache, which is stored in your projects
# // Data folder.
# // This cache is recreated everytime you make changes to:
# // FPS, SPM, MPH, HPD, PHASES, PHASE_ORDER
# // Try not to do it too often.
# //
# // 1.1
# // Use tone mode 1, it does real time calculations, so the cache isn't needed.
# //
#==============================================================================#
($imported ||= {})["ISS-TimeSystem"] = true
#==============================================================================#
# ** ISS::TIMESYS
#==============================================================================#
module ISS
  install_script(21, :system)
  module TIMESYS
# oo========================================================================oo #
# // Start Customization // Basic
# oo========================================================================oo #
    # // 0 - Continous Time (Changes to the variables will not affect the actual time) this is actually useless D:
    # // 1 - Controlled Time (Reccommended)
    # // 2 - Real Time (Takes the time from the players computer)
    # // 3 - Step Time (Frame Per Step)
    TIME_MODE = 1

    # // This section only pretains to TIME_MODE 0 and 1
    # // Time Frame per Game Frame
    FRAME_RATE = 60

    # // Changing these will cause the Tone Cache to be remade on startup
    FPS = 1  # // Frames per Second, try not to change this, use FRAME_RATE to have accelerated time
    SPM = 60 # // Seconds per Minute
    MPH = 60 # // Minutes per Hour
    HPD = 24 # // Hours per Day

    START_TIME = [  7, 30,  0] # // Hour, Minute, Second

  #//oo=====================================oo//#
  # // Variables                             // #
  #//oo=====================================oo//#
    SECONDS_VAR = 41 # // Seconds
    MINUTES_VAR = 42 # // Minutes
    MHOURS_VAR  = 43 # // Military Hours
    HOURS_VAR   = 44 # // Standard 12 hours, any changes made to this will not affect the time

    TIME_OFFSET = 5 # // Hours to offset by, used to correct tones

  #//oo=====================================oo//#
  # // Phase setup                           // #
  #//oo=====================================oo//#
    PHASES = {}
    PHASES[:dawn] = [ 0..6   , Tone.new(17, -51, -102, 0)    ]
    PHASES[:day]  = [ 6..12  , Tone.new(0, 0, 0, 0)          ]
    PHASES[:dusk] = [ 12..18 , Tone.new(17, -51, -102, 0)    ]
    PHASES[:night]= [ 18..24 , Tone.new(-187, -119, -17, 68) ]

    PHASE_ORDER = [ :dawn, :day, :dusk, :night ]

  #//oo=====================================oo//#
  # // Switches                              // #
  #//oo=====================================oo//#
    # // Both are set to ON a startup
    TIME_SWITCH = 41 # // While off, time will not progress
    TONE_SWITCH = 42 # // While off, tones will not change

    # // These switches are automatically set based on the hour
    # // NOTE if the TIME_SWITCH is off these switches will not update
    # // In that case call $game_time.update_phase in a script command
    PHASE_SWITCH = {}
    PHASE_SWITCH[:dawn]  = 43
    PHASE_SWITCH[:day]   = 44
    PHASE_SWITCH[:dusk]  = 45
    PHASE_SWITCH[:night] = 46

    # // Controls when the map should be refreshed
    # // :frame   (every frame)  # // CAN LAG REAL BAD
    # // :second  (every second) # // CAN LAG BAD
    # // :minutes (every minute) # // CAN LAG
    # // :hour    (every hour)   # // Reccomended
    REFRESH_MAP = :hour
  #//oo====================================================================oo//#
    # // Set this to true if you have an encrypted game
    # // The tones cache will not be created if it doesn't exist if this is false
    NO_CHECKS = false

    NO_TONE = Tone.new(0, 0, 0, 0)

    # // 0 - Cache Mode, 1 - Real Time
    TONE_MODE = 1
# oo========================================================================oo #
# \\ End Customization \\ Basic
# oo========================================================================oo #
  end
#==============================================================================#
# ** ISS::TIMESYS
#==============================================================================#
  module TIMESYS

    DEBUG = ISS::DEBUG_MODE

    PHASE_BY_HOUR   = []
    FRAMES_BY_PHASE = {}
    FRAMES_BY_HOUR   = []

    PHASES.keys.each { |key|
      ph = PHASES[key] ;
      ph[0].to_a.each { |i| PHASE_BY_HOUR[i] = key }
      FRAMES_BY_PHASE[key] = ph[0].to_a[-1] - ph[0].to_a[0]
      FRAMES_BY_PHASE[key] *= MPH
      FRAMES_BY_PHASE[key] *= SPM
      FRAMES_BY_PHASE[key] *= FPS
    }
    (HPD+1).times { |i| FRAMES_BY_HOUR[i] = (i+1) * MPH * SPM * FPS }
    FPH = MPH * SPM * FPS # // Frames Per Hour

    SysConstruct = Struct.new(:phases, :phase_order, :time_rates, :tones)

    class SysConstruct
      def force_rebuild?(phases, phase_order, time_rates)
        return (self.phases != phases || self.phase_order != phase_order ||
         self.time_rates != time_rates)
      end
    end

    TIME_RATES = [FPS, SPM, MPH, HPD]

    TONE_FOR_FRAME = []

    REBUILD = false

    if TONE_MODE == 0
    if (NO_CHECKS ? false : !File.exist?("Data/TimeSysConstruct.rvdata"))
      REBUILD = true
    else
      dat = load_data("Data/TimeSysConstruct.rvdata")
      REBUILD = dat.force_rebuild?(PHASES, PHASE_ORDER, TIME_RATES) unless NO_CHECKS
      TONE_FOR_FRAME = dat.tones unless REBUILD
    end

    if REBUILD
      4.times { |i|
        p1  = PHASE_ORDER[i%PHASE_ORDER.size] ; p2  = PHASE_ORDER[(i+1)%PHASE_ORDER.size]
        ph1 = PHASES[p1]       ; ph2 = PHASES[p2]
        t1  = ph1[1]           ; t2  = ph2[1]
        hr1 = ph1[0].to_a[0]   ; hr2 = ph1[0].to_a[-1] # // Single Phase
        phase_length = hr2 - hr1 # // Total hours
        phase_length = phase_length * MPH # // Total Minutes
        phase_length = phase_length * SPM # // Total Seconds
        phase_length = phase_length * FPS # // Total Frames
        TONE_FOR_FRAME += ISS.tone_transition(t1, t2, phase_length)
        save_data(SysConstruct.new( PHASES, PHASE_ORDER, TIME_RATES, TONE_FOR_FRAME),
         "Data/TimeSysConstruct.rvdata" )
      }
    end
    end # // Tone Mode 0
    TOTAL_FRAMES = HPD * MPH * SPM * FPS

    if DEBUG
      puts "Total tone changes: #{TONE_FOR_FRAME.size}"
      puts "Total frames per day: #{TOTAL_FRAMES}"
      if TONE_FOR_FRAME.size != TOTAL_FRAMES
        raise "Tone change size and total frames dont match up"
      end
    end if TONE_MODE == 0

  end

#==============================================================================#
# ** TimeSystem
#==============================================================================#
  class TimeSystem

  #--------------------------------------------------------------------------#
  # * Include Module(s)
  #--------------------------------------------------------------------------#
    include ISS::TIMESYS

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :frames
    attr_accessor :tone

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize()
      @frames   = 0
      $game_switches[TIME_SWITCH] = true
      $game_switches[TONE_SWITCH] = true
      if [1, 3].include?(TIME_MODE)
        update_variables()
        gv = $game_variables
        gv[MHOURS_VAR], gv[MINUTES_VAR], gv[SECONDS_VAR] = *START_TIME
        @frames = variables_to_frames()
        @frames %= TOTAL_FRAMES
      end
      @real_time = Time.new
      @tone = NO_TONE.clone
      update()
    end

  #--------------------------------------------------------------------------#
  # * new-method :time_on?
  #--------------------------------------------------------------------------#
    def time_on?() ; return $game_switches[TIME_SWITCH] ; end

  #--------------------------------------------------------------------------#
  # * new-method :tone_on?
  #--------------------------------------------------------------------------#
    def tone_on?() ; return $game_switches[TONE_SWITCH] ; end

  # // Raw time
  #--------------------------------------------------------------------------#
  # * new-method :aseconds
  #--------------------------------------------------------------------------#
    def aseconds ; return @frames / FPS    ; end
  #--------------------------------------------------------------------------#
  # * new-method :aminutes
  #--------------------------------------------------------------------------#
    def aminutes ; return aseconds / SPM   ; end
  #--------------------------------------------------------------------------#
  # * new-method :ahours
  #--------------------------------------------------------------------------#
    def ahours   ; return aminutes / MPH   ; end

  # // Adjusted Time
  #--------------------------------------------------------------------------#
  # * new-method :seconds
  #--------------------------------------------------------------------------#
    def seconds  ; return aseconds % SPM   ; end
  #--------------------------------------------------------------------------#
  # * new-method :minutes
  #--------------------------------------------------------------------------#
    def minutes  ; return aminutes % MPH   ; end
  #--------------------------------------------------------------------------#
  # * new-method :milthours
  #--------------------------------------------------------------------------#
    def milthours; return ((ahours+TIME_OFFSET) % HPD) ; end
  #--------------------------------------------------------------------------#
  # * new-method :hours
  #--------------------------------------------------------------------------#
    def hours    ; return (milthours%12) + 1 ; end

  #--------------------------------------------------------------------------#
  # * new-method :var_seconds_frames
  #--------------------------------------------------------------------------#
    def var_seconds_frames
      return $game_variables[SECONDS_VAR] * FPS
    end

  #--------------------------------------------------------------------------#
  # * new-method :var_minutes_frames
  #--------------------------------------------------------------------------#
    def var_minutes_frames()
      return $game_variables[MINUTES_VAR] * SPM * FPS
    end

  #--------------------------------------------------------------------------#
  # * new-method :var_hours_frames
  #--------------------------------------------------------------------------#
    def var_hours_frames()
      return ($game_variables[MHOURS_VAR]-TIME_OFFSET)%HPD * MPH * SPM * FPS
    end

  #--------------------------------------------------------------------------#
  # * new-method :var_seconds
  #--------------------------------------------------------------------------#
    def var_seconds() ; $game_variables[SECONDS_VAR] ; end

  #--------------------------------------------------------------------------#
  # * new-method :var_minutes
  #--------------------------------------------------------------------------#
    def var_minutes() ; $game_variables[MINUTES_VAR] ; end

  #--------------------------------------------------------------------------#
  # * new-method :var_hours
  #--------------------------------------------------------------------------#
    def var_hours() ; $game_variables[MHOURS_VAR] ; end

  #--------------------------------------------------------------------------#
  # * new-method :set_variables
  #--------------------------------------------------------------------------#
    def set_variables(s, m, h)
      $game_variables[SECONDS_VAR], $game_variables[MINUTES_VAR], $game_variables[MHOURS_VAR] = s, m, h
    end

  #--------------------------------------------------------------------------#
  # * new-method :variables_to_frames
  #--------------------------------------------------------------------------#
    def variables_to_frames()
      return var_seconds_frames() + var_minutes_frames() + var_hours_frames()
    end

  #--------------------------------------------------------------------------#
  # * new-method :current_phase
  #--------------------------------------------------------------------------#
    def current_phase() ; return PHASE_BY_HOUR[(var_hours-TIME_OFFSET)%HPD] ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update()
      update_time()
      update_tone()
      update_variables()
      #puts sprintf("Time is now: %02d:%02d:%02d", hours, minutes, seconds)
    end unless TIME_MODE == 3

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update() ; update_tone() ; end if TIME_MODE == 3

  #--------------------------------------------------------------------------#
  # * new-method :update_time
  #--------------------------------------------------------------------------#
  case TIME_MODE
  when 0
    def update_time()
      @last_frame = @frames
      return unless time_on?()
      @frames += FRAME_RATE
    end
  when 1
    def update_time()
      @last_frame = @frames
      return unless time_on?()
      @frames = variables_to_frames()
      @frames += FRAME_RATE
      @frames %= TOTAL_FRAMES
    end
  when 2
    def update_time()
      @last_frame = @frames
      set_variables(@real_time.sec, @real_time.min, @real_time.hour)
      @frames = variables_to_frames()
      @frames %= TOTAL_FRAMES
    end
  when 3
    def update_time()
      @last_frame = @frames
      return unless time_on?()
      @frames = variables_to_frames()
      @frames += FRAME_RATE
      @frames %= TOTAL_FRAMES
      update_variables()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_tone
  #--------------------------------------------------------------------------#
  case TONE_MODE
  when 0
    def update_tone()
      @tone = self.tone_on?() ? TONE_FOR_FRAME[@frames%TOTAL_FRAMES] : NO_TONE
    end
  when 1
    def update_tone()
      phase          = current_phase
      next_phase     = PHASE_ORDER[(PHASE_ORDER.index(phase)+1)%PHASE_ORDER.size]
      phase_set      = PHASES[phase]
      next_phase_set = PHASES[next_phase]
      start_hour     = phase_set[0].to_a[0]
      end_hour       = phase_set[0].to_a[-1]-1

      start_frames   = start_hour * MPH * SPM * FPS
      end_frames     = end_hour * MPH * SPM * FPS
      offset_frames  = MPH * SPM * FPS

      current_frames = @frames - start_frames - offset_frames
      change_frames  = end_frames - start_frames

      tone1, tone2   = phase_set[1], next_phase_set[1]
      @tone = tone1.clone

      [:red, :green, :blue, :gray].each { |m|
        cct = @tone.send(m)
        ct1, ct2 = tone1.send(m), tone2.send(m)
        cdif = (ct1-ct2).abs
        if ct1 > ct2
          cct = [[cct-((cdif/change_frames.to_f)*current_frames.to_f), ct2].max, cct].min
        elsif ct1 < ct2
          cct = [[cct+((cdif/change_frames.to_f)*current_frames.to_f), ct2].min, cct].max
        end
        @tone.send(m.to_s+"=", cct)
      }
      @tone = PHASES[PHASE_ORDER[0]][1].clone if @frames == 0
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_variables
  #--------------------------------------------------------------------------#
    def update_variables()
      $game_variables[SECONDS_VAR] = seconds
      $game_variables[MINUTES_VAR] = minutes
      $game_variables[MHOURS_VAR]  = milthours
      $game_variables[HOURS_VAR]   = hours
      case REFRESH_MAP
      when :frame
        $game_map.need_refresh = true if @last_frame != @frames
      when :second
        $game_map.need_refresh = true if $game_variables.changed?(SECONDS_VAR)
      when :minute
        $game_map.need_refresh = true if $game_variables.changed?(MINUTES_VAR)
      end
      update_phase() if $game_variables.changed?(MHOURS_VAR)
    end

  #--------------------------------------------------------------------------#
  # * new-method :update_phase
  #--------------------------------------------------------------------------#
    def update_phase()
      PHASE_SWITCH.keys.each { |key| $game_switches[PHASE_SWITCH[key]] = false }
      $game_switches[PHASE_SWITCH[current_phase()]] = true
      $game_map.need_refresh = true
    end

  end # // TimeSystem

end # // ISS

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iss021_gmm_update :update unless $@
  def update(*args, &block)
    iss021_gmm_update(*args, &block)
    $game_time.update()
  end

end

#==============================================================================#
# ** Game_Player
#==============================================================================#
class Game_Player

  #--------------------------------------------------------------------------#
  # * alias-method :increase_steps
  #--------------------------------------------------------------------------#
  alias :iss021_gmm_increase_steps :increase_steps unless $@
  def increase_steps(*args, &block)
    iss021_gmm_increase_steps(*args, &block)
    $game_time.update_time()
  end

end if ISS::TIMESYS::TIME_MODE == 3

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss021_spm_initialize :initialize unless $@
  def initialize(*args, &block)
    iss021_spm_initialize(*args, &block)
    create_ts_tone_viewport() ; update_ts_tone_viewport()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_ts_tone_viewport
  #--------------------------------------------------------------------------#
  def create_ts_tone_viewport()
    @ts_tone_viewport = Viewport.new(*@viewport1.rect.to_a)
    @ts_tone_viewport.z = 25
  end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose
  #--------------------------------------------------------------------------#
  alias :iss021_spm_dispose :dispose unless $@
  def dispose(*args, &block)
    iss021_spm_dispose(*args, &block)
    dispose_ts_tone_viewport() unless @ts_tone_viewport.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :dispose_ts_tone_viewport
  #--------------------------------------------------------------------------#
  def dispose_ts_tone_viewport() ; @ts_tone_viewport.dispose() ; end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iss021_spm_update :update unless $@
  def update(*args, &block)
    iss021_spm_update(*args, &block)
    update_ts_tone_viewport() unless @ts_tone_viewport.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_ts_tone_viewport
  #--------------------------------------------------------------------------#
  def update_ts_tone_viewport()
    @ts_tone_viewport.update()
    @ts_tone_viewport.tone = $game_time.tone
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :create_game_objects
  #--------------------------------------------------------------------------#
  alias :iss021_spm_create_game_objects :create_game_objects unless $@
  def create_game_objects(*args, &block)
    iss021_spm_create_game_objects(*args, &block)
    $game_time = ISS::TimeSystem.new
  end

end

if $imported["ISS-MGPAS"]
#==============================================================================#
# ** Scene_File
#==============================================================================#
module ISS::MGPAS

  class << self
    #--------------------------------------------------------------------------#
    # * alias-method :write_save_data
    #--------------------------------------------------------------------------#
    alias :iss_swapxt_scnf_write_save_data :write_save_data unless $@
    def write_save_data(file)
      iss_swapxt_scnf_write_save_data(file)
      Marshal.dump($game_time,      file)
    end

    #--------------------------------------------------------------------------#
    # * alias-method :read_save_data
    #--------------------------------------------------------------------------#
    alias :iss_swapxt_scnf_read_save_data :read_save_data unless $@
    def read_save_data(file)
      iss_swapxt_scnf_read_save_data(file)
      $game_time    = Marshal.load(file)
    end
  end

end

else

#==============================================================================#
# ** Scene_File
#==============================================================================#
class Scene_File < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :write_save_data
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_scnf_write_save_data :write_save_data unless $@
  def write_save_data(file)
    iss_swapxt_scnf_write_save_data(file)
    Marshal.dump($game_time,      file)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :read_save_data
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_scnf_read_save_data :read_save_data unless $@
  def read_save_data(file)
    iss_swapxt_scnf_read_save_data(file)
    $game_time    = Marshal.load(file)
  end

end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Time System"
#-define HDR_GDC :dc=>"03/17/2012"
#-define HDR_GDM :dm=>"05/26/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/time_system', '1.0.0', 'IEI Time System'
#-inject gen_class_header 'IEI::TimeSystem'
class IEI::TimeSystem
  FPS = 60.0
  SPM = 60.0
  MPH = 60.0
  HPD = 24.0
  DPW = 7.0
  PHASES = {}
  PHASES[:dawn]  = [ 0..6   , Tone.new(  17, -51,-102,   0) ]
  PHASES[:day]   = [ 6..12  , Tone.new(   0,   0,   0,   0) ]
  PHASES[:dusk]  = [ 12..18 , Tone.new(  17, -51,-102,   0) ]
  PHASES[:night] = [ 18..24 , Tone.new(-187,-119, -17,  68) ]
  TONE_HOUR_OFFSET = 6
  PHASE_ORDER = [ :dawn, :day, :dusk, :night ]
  # //
  PHASE_MAP = Array.new(HPD.to_i,:nil)
  PHASES.each_pair { |key,value| value[0].each { |i| PHASE_MAP[i] = key } }
  PHASE_NEXT = {}
  PHASE_ORDER.each_with_index do |v, i|
    PHASE_NEXT[v] = PHASE_ORDER[(i+1) % PHASE_ORDER.size]
  end
  def initialize
    @frames = 0.0
    @paused = false
  end
  def reset_frames
    @frames = 0.0
  end
  def time_s
    format("Time Now[%02d:%02d:%02d]",hours,minutes,seconds)
  end
  def time_s_thread
    Thread.new{loop{sleep 3.0;puts time_s};};
  end
  # //
  def paused?
    @paused
  end
  attr_writer :paused
  # //
  def seconds_real
    @frames / FPS
  end
  def minutes_real
    seconds_real / SPM
  end
  def hours_real
    minutes_real / MPH
  end
  def days_real
    hours_real / HPD
  end
  def weeks_real
    days_real / DPW
  end
  # //
  def seconds_f
    (seconds_real % SPM).to_f
  end
  def minutes_f
    (minutes_real % MPH).to_f
  end
  def hours_f
    (hours_real % HPD).to_f
  end
  def days_f
    (days_real % DPW).to_f
  end
  def weeks_f
    (weeks_real % WPM).to_f
  end
  [:seconds, :minutes, :hours, :days, :weeks].each { |sym|
    module_eval("def #{sym};#{sym}_f;end")
  }
  # //
  def thours
    (hours - TONE_HOUR_OFFSET) % HPD
  end
  def current_phase
    PHASE_MAP[thours.to_i]
  end
  def next_phase
    PHASE_NEXT[current_phase]
  end
  def current_tone
    PHASES[current_phase][1]
  end
  def next_tone
    PHASES[next_phase][1]
  end
  private :current_tone
  private :next_tone
  def phase_rate
    a = PHASES[current_phase][0]
    (thours - a.first) / (a.last - a.first).to_f
  end
  private :phase_rate
  def calc_tone
    current_tone.lerp(next_tone,phase_rate)
  end
  def tone
    @tone ||= calc_tone
  end
  def update
    update_time
    @tone = nil
  end
  def update_time
    @frames += 1000.0 unless(paused?)
    puts time_s
  end
end

class << DataManager
  alias iei_tsys_create_game_objects create_game_objects
  def create_game_objects
    iei_tsys_create_game_objects
    $game.time = IEI::TimeSystem.new
  end
end

#-inject gen_class_header 'Spriteset::Map'
class Spriteset::Map

  alias iei_tsys_initialize initialize
  def initialize
    iei_tsys_initialize
    @tone_viewport = Viewport.new *@viewport1.rect.to_a
  end

  alias iei_tsys_dispose dispose
  def dispose
    @tone_viewport.dispose if @tone_viewport
    iei_tsys_dispose
  end

  alias iei_tsys_update update
  def update
    iei_tsys_update
    if @tone_viewport
      @tone_viewport.update
      @tone_viewport.rect.set @viewport1.rect
      @tone_viewport.tone.set $game.time.tone
      @tone_viewport.z = @viewport1.z + 1
    end
  end

end

#-inject gen_class_header 'Scene::Map'
class Scene::Map

  alias iei_tsys_update update
  def update
    iei_tsys_update
    $game.time.update
  end

end
#-inject gen_script_footer

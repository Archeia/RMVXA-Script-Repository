#encoding:UTF-8
# ISS034 - PaT.TaP VX
module ISS
  module PaTTaP
  end
end

PaTTaP = ISS::PaTTaP

module ISS::PaTTaP::Helpers ; end
module ISS::PaTTaP::Helpers::Limits

  VOLUME_LIMIT    = [0, 100]   # // 0, 100
  PITCH_LIMIT     = [0, 150]   # // 0, 150
  KEY_LIMIT       = [0, 127]

  DEFAULT_VOLUME  = 100
  DEFAULT_PITCH   = 100
  DEFAULT_ROOTKEY = 60         # // C5

end

module ISS::PaTTaP::Helpers::DefaultsMix

  include PaTTaP::Helpers::Limits

  def volume_limit()
    return VOLUME_LIMIT
  end

  def pitch_limit()
    return PITCH_LIMIT
  end

  def key_limit()
    return KEY_LIMIT
  end

  def default_volume()
    return DEFAULT_VOLUME
  end

  def default_pitch()
    return DEFAULT_PITCH
  end

  def default_rootkey()
    return DEFAULT_ROOTKEY
  end

end

class ISS::PaTTaP::Sample

  include PaTTaP::Helpers::DefaultsMix

  attr_accessor :display_name
  attr_accessor :filename

  def initialize(name="", diname=nil)
    @filename = name
    @display_name = diname || name
  end

  def play(volume, pitch)
    return if self.filename.empty?()
    Audio.se_play("Audio/SE/"+self.filename, volume, pitch)
  end

  def stop()
    self.class.stop()
  end

  def self.stop()
    Audio.se_stop()
  end

end

module ISS::PaTTaP::Plugins ; end

class ISS::PaTTaP::Plugins::PluginBase

  include PaTTaP::Helpers::DefaultsMix

  attr_reader :volume
  attr_reader :pitch
  attr_reader :rootkey

  def initialize(preset={})
    @volume   = preset[:volume] || default_volume()
    @pitch    = preset[:pitch] || default_pitch()
    @rootkey  = preset[:rootkey] || default_rootkey()
    @disposed = false
  end

  def volume=(new_volume)
    @volume = new_volume
  end

  def pitch=(new_pitch)
    @pitch = new_pitch
  end

  def rootkey=(new_rootkey)
    @rootkey = new_rootkey
  end

  def play(info={})
  end

  def name()
    return "PluginBase"
  end

  def dispose()
  end

  def disposed?()
    return @disposed
  end

end

class ISS::PaTTaP::Plugins::NulLer < ISS::PaTTaP::Plugins::PluginBase # // Empty Plugin

  def play(info={})
  end

  def name()
    return "NulLer"
  end

end

class ISS::PaTTaP::Plugins::TaPLer < ISS::PaTTaP::Plugins::PluginBase # // BasicSampler

  PITCH_KEY = []
  for i in 0...128 ; PITCH_KEY[i] = 100 ; end
  PITCH_KEY[68] = 150 # // G5
  PITCH_KEY[60] = 100 # // C5
  PITCH_KEY[48] = 50  # // C4
  for i in 0...12  ; PITCH_KEY[48+i] = 50 + (50 * i / 12) ; end
  for i in 0...8   ; PITCH_KEY[60+i] = 50 + (50 * i / 8)  ; end

  def initialize(preset={})
    super(preset)
    @sample = preset[:sample_name].nil?() ? (preset[:sample] || PaTTaP::Sample.new()) : PaTTaP::Sample.new(preset[:sample_name])
  end

  def play(info={})
    vol = self.volume * (info[:volume] || default_volume()) / 100.0
    pit = self.pitch * (info[:pitch] || default_pitch()) / 100.0
    @sample.play(vol, pit)
  end

  def name()
    return "TaPLer #{@sample.display_name}"
  end

end

class ISS::PaTTaP::Plugins::PaTMuple < ISS::PaTTaP::Plugins::PluginBase # // Multi Sample Player

  KeyMap = Struct.new(:sample, :fine_pitch)

  DEFAULT_KEYMAPS = []
  for i in 0...128
    DEFAULT_KEYMAPS[i] = KeyMap.new(PaTTaP::Sample.new(), 100)
  end

  def initialize(preset={})
    super(preset)
    set_keymap(preset[:keymap])
  end

  def set_keymap(km)
    _keymap = km || {}
    @keymap = []
    for i in 0...128 ; @keymap = _keymap[i] || DEFAULT_KEYMAPS[i] ; end
  end

  def play(info={})
    vol = self.volume * (info[:volume] || default_volume()) / 100.0
    pit = self.pitch * (info[:pitch] || default_pitch()) / 100.0
    key = @keymap[info[:key] || self.rootkey()]
    key.sample.play(vol, key.fine_pitch * pit / 100.0)
  end

  def name()
    return "PaTMuple"
  end

end

class ISS::PaTTaP::Pattern

  include PaTTaP::Helpers::DefaultsMix

  class Step

    include PaTTaP::Helpers::DefaultsMix

    attr_accessor :volume
    attr_accessor :pitch
    attr_accessor :state
    attr_accessor :key

    attr_accessor :beat
    attr_accessor :even

    def initialize(preset={})
      @volume = preset[:volume] || default_volume()
      @pitch  = preset[:pitch] || default_pitch()
      @key    = preset[:key] || 60

      @beat   = preset[:beat] || false
      @even   = preset[:even] || false

      preset[:played] ? set_to_play() : set_to_unplay()
    end

    def basic_to_a()
      return @volume, @pitch, @key
    end

    def set_to_play(volume=@volume, pitch=@pitch, key=@key)
      @volume, @pitch, @key = volume, pitch, key
      @state = :played
    end

    def set_to_unplay()
      @state = :unplayed
    end

    def playable?
      return (@state == :played)
    end

  end

  attr_reader :steps
  attr_reader :size

  def initialize(size=16)
    @steps = [] ; @size ; resize(size)
  end

  def step_at(index)
    return @steps[index]
  end

  def resize(new_size)
    while @steps.size < new_size
      @steps << Step.new()
    end
    for i in 0...@steps.size
      @steps[i].beat = (i % 4) == 0
      @steps[i].even = ((i / 4) % 2) == 0
    end
    @size = new_size
  end

end

class ISS::PaTTaP::Channel

  include PaTTaP::Helpers::DefaultsMix
  include PaTTaP::Plugins

  NULL_PATTERN = PaTTaP::Pattern.new()

  attr_accessor :volume
  attr_accessor :pitch

  def initialize(preset={})
    @volume   = preset[:volume] || default_volume()
    @pitch    = preset[:pitch] || default_pitch()
    @patterns = preset[:patterns] || { 1 => PaTTaP::Pattern.new() }
    @active_pattern = preset[:active_pattern] || 1
    @name = preset[:name] || "Channel"
    @plugin = nil
    load_plugin(
      preset[:plugin] || NulLer,
      preset[:plugin_preset] || {}
    )
  end

  def load_plugin(plugin, preset={})
    @plugin.dispose() unless @plugin.disposed?() unless @plugin.nil?()
    @plugin = plugin.new(preset)
    @name = @plugin.name
  end

  def plugin()
    return @plugin
  end

  def maxvolume()
    return volume_limit()[1]
  end

  def maxpitch()
    return pitch_limit()[1]
  end

  def name()
    return @name
  end

  def rename(new_name)
    @name = new_name.to_s
  end

  def get_pattern(index)
    return @patterns[index] || NULL_PATTERN
  end

  def current_pattern()
    return get_pattern(@active_pattern)
  end

  def get_step_at(index, pat=@active_pattern)
    return get_pattern(pat ).step_at(index)
  end

  def play_step_at(index, pat=@active_pattern)
    step = get_step_at(index, pat)
    return unless step.playable?()
    nvolume, npitch, key = *step.basic_to_a()

    @plugin.play(
      {
        :volume => Integer(@volume * nvolume / 100.0),
        :pitch => Integer(@pitch * npitch / 100.0),
        :key => key
      }
    )
  end

  def test!()
    @sample.play(@volume, @pitch)
  end

  def panic!()
    @sample.stop()
  end

end

class ISS::PaTTaP::ChannelRack

  include PaTTaP::Helpers::DefaultsMix
  include PaTTaP::Plugins

  def initialize()
    @channels = []
    @channels[0] = PaTTaP::Channel.new() # // Kick
    @channels[1] = PaTTaP::Channel.new() # // Snare
    @channels[2] = PaTTaP::Channel.new() # // Clap
    @channels[3] = PaTTaP::Channel.new() # // Hat/Crash?

    @channels[0].load_plugin(TaPLer, { :sample_name => "PT_Kick Basic"  })
    @channels[1].load_plugin(TaPLer, { :sample_name => "PT_Snare Basic" })
    @channels[2].load_plugin(TaPLer, { :sample_name => "PT_Clap Basic"  })
    @channels[3].load_plugin(TaPLer, { :sample_name => "PT_Hat Basic"   })
  end

  def size
    return @channels.size
  end

  def dup_channel(dup_chan, target_chan)
    @channels[target_chan] = @channels[dup_chan].deep_clone()
  end

  def each_channel()
    @channels.each { |c| yield c }
  end

  def get_channel(index)
    return @channels[index]
  end

  def [](index)
    return get_channel(index)
  end

  def play_at(index, pat)
    each_channel { |c| c.play_step_at(index, pat) }
  end

  def test!()
    each_channel { |c| c.test!() }
  end

  def panic!()
    each_channel { |c| c.panic!() }
  end

end

class ISS::PaTTaP::Playlist

  class PlayRow

    def initialize()
      @data = {}
    end

    def pattern_at(index)
      return @data[index] || 0
    end

    def set_pattern_at(index, pattern_id)
      @data[index] = pattern_id
    end

    def remove_pattern_at(index)
      @data.delete(index)
    end

    def remove_pattern_by_id(*ids)
      ids.each { |i|
        keys = @data.keys
        keys.each { |key| @data.delete(key) if @data[key] == i }
      }
    end

  end

  def initialize()
    @rows = []
    4.times { |i| @rows[i] = PlayRow.new() }
  end

  def get_at(index)
    return @rows.inject([]) { |r, pl| r << pl.pattern_at(index) }
  end

  def set_at(row, index, value)
    @rows[row].set_pattern_at(index, value)
  end

  def delete_at(row, index)
    @rows[row].remove_pattern_at(index)
  end

end

class ISS::PaTTaP::Project

  attr_reader :channel_rack
  attr_reader :playlist
  attr_reader :bpm
  attr_reader :key_measure
  attr_reader :play_length

  def initialize()
    @playlist     = ISS::PaTTaP::Playlist.new()
    @channel_rack = ISS::PaTTaP::ChannelRack.new()
    @key_measure  = [4, 4]
    change_bpm(140)
    set_play_length(16)
  end

  def change_bpm(new_bpm)
    @bpm = new_bpm
  end

  def beats_per_bar()
    return @key_measure[0]
  end

  def bars_per_measure()
    return @key_measure[1]
  end

  def frame_per_beat()
    # // FrameRate / BPS
    return Graphics.frame_rate / ((@bpm * beats_per_bar()) / Graphics.frame_rate)
  end

  def play_at(index)
    @playlist.get_at(index/16).each { |i|
      @channel_rack.play_at(index, i) if i > 0
    }
  end

  def set_play_length(new_length)
    @play_length = new_length
  end

end

class ISS::PaTTaP::Sequencer

  attr_reader :counter

  def initialize(project)
    set_project(project)
    @counter        = ISS::Counter.new()
    @playing        = false
    @looped         = true
  end

  def set_project(project)
    @project = project
  end

  def current_index()
    return Integer(@counter.count / @project.frame_per_beat)
  end

  def beat?()
    return @counter.count % Integer(@project.frame_per_beat) == 0
  end

  def playing?() ; return @playing ; end

  def play()
    @playing = true
  end

  def stop()
    @playing = false
    @counter.reset!()
  end

  def pause()
    @playing = false
  end

  def update()
    if @playing
      @counter.update()
      (@looped ? @counter.reset!() : stop()) if current_index >= @project.play_length
      @project.play_at(current_index()) if beat?()
    end
  end

end

class ISS::PaTTaP::PianoRoll

  def initialize
  end

end

module ISS::PaTTaP::Responses ; end

class ISS::PaTTaP::Responses::Channel_Base < ISS::KeyCursor::ResponseChecker

  include PaTTaP::Helpers::DefaultsMix

  attr_reader :channel
  attr_reader :sprite

  def initialize(channel, sprite, rng=Vector4.new(0, 0, 0, 0 ))
    super(rng)
    @sprite  = sprite
    @channel = channel
  end

end

class ISS::PaTTaP::Responses::Channel_Group < ISS::PaTTaP::Responses::Channel_Base

  attr_accessor :responses

  def initialize(*args)
    super(*args)
    @responses = []
  end

  def on_cursor_over(cursor)
  end

  def update(cursor)
    cursor_over = cursor_over?(cursor)
    cursor_over ? on_cursor_over(cursor ) : on_cursor_not_over(cursor)
    return unless cursor_over
    update_response_group(cursor)
  end

  def update_response_group(cursor)
    @responses.each { |r| r.update(cursor) }
  end

end

class ISS::PaTTaP::Responses::Channel_Name < ISS::PaTTaP::Responses::Channel_Base

  def on_cursor_not_over(cursor)
  end

  def on_cursor_over(cursor)
  end

  def on_left_press(cursor)
  end

  def on_right_press(cursor)
  end

  def on_middle_press(cursor)
  end

end

class ISS::PaTTaP::Responses::Channel_Volume < ISS::PaTTaP::Responses::Channel_Base

  def on_left_press(cursor)
    x, y = *cursor_relative_pos(cursor)
    old_vol = @channel.volume
    @channel.volume = @channel.maxvolume * y / 24
    @sprite.refresh_volume() if old_vol != @channel.volume
  end

  def on_middle_click(cursor)
    old_vol = @channel.volume
    @channel.volume = ISS::PaTTaP::Helpers::Limits::DEFAULT_VOLUME
    @sprite.refresh_volume() if old_vol != @channel.volume
  end

end

class ISS::PaTTaP::Responses::Channel_Pitch < ISS::PaTTaP::Responses::Channel_Base

  def on_left_press(cursor)
    x, y = *cursor_relative_pos(cursor)
    old_pit = @channel.pitch
    @channel.pitch = @channel.maxpitch * y / 24
    @sprite.refresh_pitch() if old_pit != @channel.pitch
  end

  def on_middle_click(cursor)
    old_pit = @channel.pitch
    @channel.pitch = ISS::PaTTaP::Helpers::Limits::DEFAULT_PITCH
    @sprite.refresh_pitch() if old_pit != @channel.pitch
  end

end

class ISS::PaTTaP::Responses::Channel_Pattern < ISS::PaTTaP::Responses::Channel_Base

  def on_cursor_not_over(cursor)
    #@sprite.opacity = 198
  end

  def on_cursor_over(cursor)
    #@sprite.opacity = 255
  end

  def on_left_press(cursor)
    x, y = *cursor_relative_pos(cursor)
    index = x/20
    @channel.current_pattern().steps[index].set_to_play()
    @sprite.draw_step(index)
  end

  def on_right_press(cursor)
    x, y = *cursor_relative_pos(cursor)
    index = x/20
    @channel.current_pattern().steps[index].set_to_unplay()
    @sprite.draw_step(index)
  end

end

module ISS::PaTTaP::Sprites ; end

class ISS::PaTTaP::Sprites::Frame < ::Sprite
end

class ISS::PaTTaP::Sprites::Pattern < ::Sprite

  attr_accessor :pattern

  def initialize(pattern, viewport=nil)
    super(viewport)
    @pattern = pattern
    self.bitmap = Bitmap.new(320, 24)
  end

  def dispose()
    self.bitmap.dispose() unless self.bitmap.nil?() ; self.bitmap = nil
    super()
  end

  def refresh()
    self.bitmap.clear()
    for i in 0...@pattern.steps.size
      draw_step(i)
    end
  end

  def draw_step(index)
    draw_pattern_block(0+(index*20), 0, @pattern.steps[index])
  end

  def draw_pattern_block(x, y, step)
    bit = Cache.system("PaTTaP/PatternBlocks")
    case step.state
    when :unplayed
      rect = Rect.new(0, 0, 18, 24)
    when :played
      rect = Rect.new(18, 0, 18, 24)
    else ; return
    end
    rect.x += 36 if step.even
    rect2 = Rect.new(x, y, rect.width, rect.height)
    self.bitmap.clear_rect(rect2)
    self.bitmap.blt(x, y, bit, rect)
  end

end

class ISS::PaTTaP::Sprites::Channel < ::Sprite

  WLH = 20

  def initialize(channel, viewport=nil)
    super(viewport)
    @channel = channel
    @drawing_sprite = Sprite.new()
    @drawing_sprite.bitmap = Bitmap.new(112+48, 24)
    @pattern_sprite = ISS::PaTTaP::Sprites::Pattern.new(@channel.current_pattern)
    refresh()
  end

  def dispose()
    unless @drawing_sprite.nil?()
      @drawing_sprite.bitmap.dispose() unless @drawing_sprite.bitmap.nil?()
      @drawing_sprite.dispose() ; @drawing_sprite = nil
    end
    unless @pattern_sprite.nil?()
      @pattern_sprite.bitmap.dispose() unless @pattern_sprite.bitmap.nil?()
      @pattern_sprite.dispose ; @pattern_sprite = nil
    end
    super()
  end

  def x=(new_x)
    super(new_x)
    refresh_bounds()
  end

  def y=(new_y)
    super(new_y)
    refresh_bounds()
  end

  def refresh_bounds()
    @bounds      ||= Vector4.new(0, 0, 0, 0)
    @name_bounds ||= Vector4.new(0, 0, 0, 0)
    @vol_bounds  ||= Vector4.new(0, 0, 0, 0)
    @pit_bounds  ||= Vector4.new(0, 0, 0, 0)
    @pat_bounds  ||= Vector4.new(0, 0, 0, 0)
    @bounds.set(self.x, self.x+496, self.y, self.y+24)
    @name_bounds.set(@bounds.x1, @bounds.x1+111, @bounds.y1, @bounds.y2)
    @vol_bounds.set(@name_bounds.x2+1, @name_bounds.x2+23, @bounds.y1, @bounds.y2)
    @pit_bounds.set(@vol_bounds.x2+1, @vol_bounds.x2+23, @bounds.y1, @bounds.y2)
    @pat_bounds.set(@bounds.x1+168, @bounds.x1+168+320, @bounds.y1, @bounds.y2)
  end

  def refresh()
    @drawing_sprite.bitmap.clear()
    draw_name(0, 0)
    refresh_volume()
    refresh_pitch()
    @pattern_sprite.refresh()
    refresh_bounds()
    rs = ISS::PaTTaP::Responses
    @response = rs::Channel_Group.new(@channel, self, @bounds)
    @response.responses << rs::Channel_Name.new(@channel, self, @name_bounds)
    @response.responses << rs::Channel_Volume.new(@channel, self, @vol_bounds)
    @response.responses << rs::Channel_Pitch.new(@channel, self, @pit_bounds)
    @response.responses << rs::Channel_Pattern.new(@channel, @pattern_sprite, @pat_bounds)
  end

  def refresh_volume()
    @drawing_sprite.bitmap.clear_rect(112, 0, 24, 24)
    draw_volume(112, 0)
  end

  def refresh_pitch()
    @drawing_sprite.bitmap.clear_rect(136, 0, 24, 24)
    draw_pitch(136, 0)
  end

  def draw_name(x, y)
    @drawing_sprite.bitmap.font.size = Font.default_size - 6
    @drawing_sprite.bitmap.draw_text(x, y, 112, WLH, @channel.name)
    #@drawing_sprite.bitmap.font.size = Font.default_size - 10
    #@drawing_sprite.bitmap.draw_text(x+8, y+10, 112, WLH, "fn: "+@channel.sample.filename)
  end

  def draw_volume(x, y)
    volume, maxvolume = @channel.volume, @channel.maxvolume
    base = Bitmap.new(8, 24)
    bar  = Bitmap.new(6, 24)
    base.fill_rect(0, 0, 8, 24, gauge_back_color)
    bar.fill_rect(0, 0, 8, Integer(24 * volume / maxvolume.to_f), hp_gauge_color1)
    @drawing_sprite.bitmap.blt(x, y, base, base.rect)
    @drawing_sprite.bitmap.blt(x+1, y, bar, bar.rect)
    base.dispose() ; bar.dispose()
  end

  def draw_pitch(x, y)
    pitch, maxpitch = @channel.pitch, @channel.maxpitch
    base = Bitmap.new(8, 24)
    bar  = Bitmap.new(6, 24)
    base.fill_rect(0, 0, 8, 24, gauge_back_color)
    bar.fill_rect(0, 0, 6, Integer(24 * pitch / maxpitch.to_f), mp_gauge_color1)
    @drawing_sprite.bitmap.blt(x, y, base, base.rect)
    @drawing_sprite.bitmap.blt(x+1, y, bar, bar.rect)
    base.dispose() ; bar.dispose()
  end

  def update()
    super()
    @drawing_sprite.opacity = self.opacity
    @pattern_sprite.opacity = self.opacity

    @drawing_sprite.x, @drawing_sprite.y, @drawing_sprite.z = self.x, self.y, self.z
    @pattern_sprite.x, @pattern_sprite.y, @pattern_sprite.z = self.x+168, self.y, self.z
  end

  def response_update(cursor)
    @response.update(cursor)
  end

end

=begin
channel_rack = ISS::PaTTaP::ChannelRack.new()
channel_rack.dup_channel(3, 4)
channel_rack.dup_channel(3, 5)

# // Sequence
channel_rack.get_channel(0).current_pattern().steps[0].set_to_play()
channel_rack.get_channel(0).current_pattern().steps[6].set_to_play()
channel_rack.get_channel(0).current_pattern().steps[11].set_to_play(80)

channel_rack.get_channel(1).current_pattern().steps[8].set_to_play()
channel_rack.get_channel(1).current_pattern().steps[12].set_to_play(80, 80)
channel_rack.get_channel(1).current_pattern().steps[14].set_to_play(80, 120)

channel_rack.get_channel(2).current_pattern().steps[12].set_to_play()
channel_rack.get_channel(2).volume = 70

channel_rack.get_channel(3).current_pattern().steps[0].set_to_play()
channel_rack.get_channel(3).current_pattern().steps[4].set_to_play()
channel_rack.get_channel(3).current_pattern().steps[8].set_to_play()
channel_rack.get_channel(3).current_pattern().steps[12].set_to_play()

channel_rack.get_channel(4).current_pattern().steps[3].set_to_play()
channel_rack.get_channel(4).current_pattern().steps[11].set_to_play()
channel_rack.get_channel(4).current_pattern().steps[14].set_to_play()
channel_rack.get_channel(4).current_pattern().steps[15].set_to_play()
channel_rack.get_channel(4).volume = 50

for i in 0...16
  channel_rack.get_channel(5).current_pattern().steps[i].set_to_play()
end
channel_rack.get_channel(5).volume = 30
channel_rack.get_channel(5).pitch = 150

channel_sprites = []
channel_rack.each_channel { |c|
  channel_sprites << ISS::PaTTaP::Sprites::Channel.new(c)
}

for i in 0...channel_rack.size
  channel_sprites[i].x = 24
  channel_sprites[i].y = 96 + 4 + i * 26
end

tracker = Sprite.new()
tracker.bitmap = Bitmap.new(18, 26*channel_rack.size)
tracker.bitmap.fill_rect(2,2,14,(26*channel_rack.size)-4,tracker.bitmap.system_color)
tracker.bitmap.blur()
tracker.opacity = 198
tracker.z = 20

#bps = Graphics.frame_rate
bpm = 178*4
bps = bpm / Graphics.frame_rate #/ 16
fpb = Graphics.frame_rate / bps
puts "BPM = #{bpm}"
puts "BPS = #{bps}"
puts "FPB = #{fpb}"
@play_index = 0

tracker.y = 4
tracker.x = (24 + 112 + 56) + @play_index * 20

cursor = ISS::KeyCursor.new()

@audio_counter = 0
@audio_run = false

loop do

  Graphics.update
  Input.update

  cursor.release_clicks()
  cursor.check_clicks()
  cursor.x, cursor.y = *ISS::Mouse.pos

  #tracker.opacity = (128 * Math.cos((((Graphics.frame_count*3) % 360)/180.0)*Math::PI)).abs
  if Input.trigger?(Input::C)
    @audio_run = !@audio_run
    @audio_counter = 0
    @play_index = 0
  end
  if @audio_run
    #channel_sprites.each { |c| c.update() }
    @audio_counter += 1
    if @audio_counter % fpb == 0
      channel_rack.play_at(@play_index)
      tracker.x = 192 + @play_index * 20
      @play_index = (@play_index + 1) % 16
    end
  else
    #channel_sprites.each { |c| c.update() ; c.response_update(cursor) }
  end
  channel_sprites.each { |c| c.update() ; c.response_update(cursor) }

end
=end

class Scene_PaTTaP < Scene_Base

  def main
    start                         # Start processing
    perform_transition            # Perform transition
    post_start                    # Post-start processing
    Input.update                  # Update input information
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
  end

  def initialize(called_from=:title, return_index=0)
    super()
    @called_from  = called_from
    @return_index = return_index
    @return_bgm = RPG::BGM.last
    RPG::BGM.stop()
  end

  def start()
    super()
    #create_menu_background()
    @cursor    = ISS::KeyCursor.new()
    @sequencer ||= PaTTaP::Sequencer.new(nil)
    new_project()

    @channel_sprites = []
    @project.channel_rack.each_channel { |c|
      @channel_sprites << ISS::PaTTaP::Sprites::Channel.new(c)
    }

    for i in 0...@project.channel_rack.size
      @channel_sprites[i].x = 24
      @channel_sprites[i].y = 96 + 4 + i * 26
    end

    @tracker = Sprite.new()
    @tracker.bitmap = Bitmap.new(18, 26*@project.channel_rack.size)
    @tracker.bitmap.fill_rect(2,2,14,(26*@project.channel_rack.size)-4,@tracker.bitmap.system_color)
    @tracker.bitmap.blur()
    @tracker.opacity = 198
    @tracker.z = 20

    @project.set_play_length(16)
    @project.playlist.set_at(0, 0, 1)
    @seq_thread = Thread.new {
      loop do
        @sequencer.update()
        sleep(0.05)
      end }
    @res_thread = Thread.new {
      loop do
        @channel_sprites.each { |c| c.response_update(@cursor) }
        sleep(0.1)
      end
    }
  end

  def new_project()
    @project = PaTTaP::Project.new()
    @sequencer.set_project(@project)
  end

  def terminate()
    super()
    dispose_menu_background()
    @return_bgm.play()
  end

  def return_scene()
    case @called_from
    when :title
      $scene = Scene_Title.new()
    when :map
      $scene = Scene_Map.new()
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  def update()
    super()
    #update_menu_background()
    @cursor.update()
    if Input.trigger?(Input::C)
      @sequencer.playing?() ? @sequencer.pause() : @sequencer.play()
    end
    @channel_sprites.each { |c| c.update() } # ; c.response_update(@cursor) }
    @tracker.x = 192 + @sequencer.current_index * 20
    #@sequencer.update()
  end

end

#$scene = Scene_PaTTaP.new()
#$scene.main() until $scene.nil?()
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

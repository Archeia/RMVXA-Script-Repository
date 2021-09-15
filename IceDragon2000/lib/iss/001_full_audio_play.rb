#encoding:UTF-8
# ISS001 - Full Audio Play 1.0
#==============================================================================#
# ** ISS - Full Audio Play
#==============================================================================#
# ** Date Created  : 04/23/2011
# ** Date Modified : 04/28/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 001
# ** Version       : 1.0
# ** Requires      : ISS000 - Core 1.9 (or above)
#==============================================================================#
# How this works?
# This will play a given audio file using one of the 4 avaiable audio options
# BGM, play through and loop
# BGS, play through and loop
# ME will mute BGMs while playing, and are one shots
# SE can be called multiple times, and are one shots
#
# // In an event use the following line
# ISS.play_bgm(type, name, vol, pit)
# ISS.play_bgs(type, name, vol, pit)
# ISS.play_me(type, name, vol, pit)
# ISS.play_se(type, name, vol, pit)
#
# type :
# :bgm - Will play then a BGM file
# :bgs - Will play then a BGS file
# :se  - Will play then a SE file
# :me  - Will play then a ME file
#
# name - Filename
# vol  - Volume of the audio file (0-100)
# pitch- Pitch of the Audio File (50-150)
#
# EG
# ISS.play_bgm(:bgs, "Battle1", 90, 100)
# This will play the BGM battle1 using the BGS audio _play
#
# ISS.play_se(:me, "Absorb01", 90, 100)
# This will play the SE Absorb01 using the ME audio _play
#
#==============================================================================#
($imported ||= {})["ISS-FullAudioPlay"] = true
#==============================================================================#
# ISS
#==============================================================================#
module ISS
  install_script(1, :audio)
  module MixIns::ISS001 ; end

  module_function()

  #--------------------------------------------------------------------------#
  # * method :play_audio
  #--------------------------------------------------------------------------#
  def play_audio(play_type, set_type, name, vol, pit)
    a = case play_type
    when :bgm ; RPG::BGM.new(name, vol, pit)
    when :bgs ; RPG::BGS.new(name, vol, pit)
    when :me  ; RPG::ME.new(name, vol, pit)
    when :se  ; RPG::SE.new(name, vol, pit)
    end
    a.play_mode = set_type ; a.play() ; return a
  end

  #--------------------------------------------------------------------------#
  # * method :play_bgm
  #--------------------------------------------------------------------------#
  def play_bgm(type, name, vol, pit)
    return play_audio(type, :bgm, name, vol, pit)
  end

  #--------------------------------------------------------------------------#
  # * method :play_bgs
  #--------------------------------------------------------------------------#
  def play_bgs(type, name, vol, pit)
    return play_audio(type, :bgs, name, vol, pit)
  end

  #--------------------------------------------------------------------------#
  # * method :play_me
  #--------------------------------------------------------------------------#
  def play_me(type, name, vol, pit)
    return play_audio(type, :me, name, vol, pit)
  end

  #--------------------------------------------------------------------------#
  # * method :play_se
  #--------------------------------------------------------------------------#
  def play_se(type, name, vol, pit)
    return play_audio(type, :se, name, vol, pit)
  end

end

#==============================================================================#
# RPG
#==============================================================================#
module RPG
#==============================================================================#
# AudioFile
#==============================================================================#
  class AudioFile ; attr_accessor :play_mode end
#==============================================================================#
# BGM
#==============================================================================#
  class BGM < AudioFile
  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
    alias :iss_initialize :initialize unless $@
    def initialize(*args, &block)
      iss_initialize(*args, &block)
      @play_mode = :bgm
    end
  #--------------------------------------------------------------------------#
  # * overwrite method :play
  #--------------------------------------------------------------------------#
    def play()
      if @name.empty?()
        Audio.bgm_stop()
        @@last = BGM.new()
      else
        vol = @volume
        if $imported["SystemGameOptions"]
          if $game_variables != nil
            options = YEM::SYSTEM::OPTIONS
            vol = vol * $game_variables[options[:bgm_variable]] / 100
            vol = [[vol, 0].max, 100].min
            vol = 0 if $game_switches[options[:bgm_mute_sw]]
          end
        end
        @play_mode = :bgm if @play_mode.nil?()
        case @play_mode
        when :bgm
          Audio.bgm_play("Audio/BGM/" + @name, vol, @pitch)
        when :bgs
          Audio.bgm_play("Audio/BGS/" + @name, vol, @pitch)
        when :se
          Audio.bgm_play("Audio/SE/" + @name, vol, @pitch)
        when :me
          Audio.bgm_play("Audio/ME/" + @name, vol, @pitch)
        end
        @@last = self
      end
    end

  end
#==============================================================================#
# BGS
#==============================================================================#
  class BGS < AudioFile
  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
    alias :iss_initialize :initialize unless $@
    def initialize(*args, &block)
      iss_initialize(*args, &block)
      @play_mode = :bgs
    end
  #--------------------------------------------------------------------------#
  # * overwrite method :play
  #--------------------------------------------------------------------------#
    def play()
      if @name.empty?()
        Audio.bgs_stop()
        @@last = BGS.new()
      else
        vol = @volume
        if $imported["SystemGameOptions"]
          if $game_variables != nil
            options = YEM::SYSTEM::OPTIONS
            vol = vol * $game_variables[options[:bgs_variable]] / 100
            vol = [[vol, 0].max, 100].min
            vol = 0 if $game_switches[options[:bgs_mute_sw]]
          end
        end
        @play_mode = :bgs if @play_mode.nil?()
        case @play_mode
        when :bgm
          Audio.bgs_play("Audio/BGM/" + @name, vol, @pitch)
        when :bgs
          Audio.bgs_play("Audio/BGS/" + @name, vol, @pitch)
        when :se
          Audio.bgs_play("Audio/SE/" + @name, vol, @pitch)
        when :me
          Audio.bgs_play("Audio/ME/" + @name, vol, @pitch)
        end
        @@last = self
      end
    end

  end
#==============================================================================#
# ME
#==============================================================================#
  class ME < AudioFile
  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
    alias :iss_initialize :initialize unless $@
    def initialize(*args, &block)
      iss_initialize(*args, &block)
      @play_mode = :me
    end
  #--------------------------------------------------------------------------#
  # * overwrite method :play
  #--------------------------------------------------------------------------#
    def play()
      if @name.empty?()
        Audio.me_stop()
      else
        vol = @volume
        if $imported["SystemGameOptions"]
          if $game_variables != nil
            options = YEM::SYSTEM::OPTIONS
            vol = vol * $game_variables[options[:bgm_variable]] / 100
            vol = [[vol, 0].max, 100].min
            vol = 0 if $game_switches[options[:bgm_mute_sw]]
          end
        end
        @play_mode = :me if @play_mode.nil?()
        case @play_mode
        when :bgm
          Audio.me_play("Audio/BGM/" + @name, vol, @pitch)
        when :bgs
          Audio.me_play("Audio/BGS/" + @name, vol, @pitch)
        when :se
          Audio.me_play("Audio/SE/" + @name, vol, @pitch)
        when :me
          Audio.me_play("Audio/ME/" + @name, vol, @pitch)
        end
      end
    end

  end
#==============================================================================#
# SE
#==============================================================================#
  class SE < AudioFile
  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
    alias :iss_initialize :initialize unless $@
    def initialize(*args, &block)
      iss_initialize(*args, &block)
      @play_mode = :se
    end
  #--------------------------------------------------------------------------#
  # * overwrite method :play
  #--------------------------------------------------------------------------#
    def play()
      unless @name.empty?()
        vol = @volume
        if $imported["SystemGameOptions"]
          if $game_variables != nil
            options = YEM::SYSTEM::OPTIONS
            vol = vol * $game_variables[options[:sfx_variable]] / 100
            vol = [[vol, 0].max, 100].min
            vol = 0 if $game_switches[options[:sfx_mute_sw]]
          end
        end
        @play_mode = :se if @play_mode.nil?()
        case @play_mode
        when :bgm
          Audio.se_play("Audio/BGM/" + @name, vol, @pitch)
        when :bgs
          Audio.se_play("Audio/BGS/" + @name, vol, @pitch)
        when :se
          Audio.se_play("Audio/SE/" + @name, vol, @pitch)
        when :me
          Audio.se_play("Audio/ME/" + @name, vol, @pitch)
        end
      end
    end

  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

#encoding:UTF-8
# ISS002 - Audio Action 1.0
#==============================================================================#
# ** ISS - Audio Action (Sub) Engine
#==============================================================================#
# ** Date Created  : 04/23/2011
# ** Date Modified : 04/23/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 002
# ** Version       : 1.0
# ** Requires      : ISS000 - Core 1.9 (or above)
#==============================================================================#
($imported ||= {})["ISS-AudioAction"] = true
#==============================================================================#
# ISS
#==============================================================================#
module ISS
  install_script(2, :audio)
  module MixIns::ISS002 ; end
  class AudioAction
  #--------------------------------------------------------------------------#
  # * method :initialize
  #--------------------------------------------------------------------------#
    def initialize
      @wait_count = 0
      @action_list = []
    end
  #--------------------------------------------------------------------------#
  # * method :update_action
  #--------------------------------------------------------------------------#
    def update_action
      @wait_count -= 1 unless @wait_count == 0
      return unless @wait_count == 0
      return if @action_list.empty?
      @action_list.pop.each { |a|
        process_action(*a)
      }
    end
  #--------------------------------------------------------------------------#
  # * method :process_action
  #--------------------------------------------------------------------------#
    def process_action(action, parameters)
      case action()
      when "PLAY"
        action_play(parameters)
      when "FADE"
        action_fade(parameters)
      when "STOP"
        action_stop(parameters)
      when "WAIT"
        action_wait(parameters)
      end
    end
  #--------------------------------------------------------------------------#
  # * action method :action_play
  #--------------------------------------------------------------------------#
    def action_play(param)
      case param.pop()
      when :bgm
        ISS.play_bgm(*param)
      when :bgs
        ISS.play_bgs(*param)
      when :se
        ISS.play_se(*param)
      when :me
        ISS.play_me(*param)
      end
    end
  #--------------------------------------------------------------------------#
  # * action method :action_fade
  #--------------------------------------------------------------------------#
    def action_fade(param)
      case param.pop()
      when :bgm
        RPG::BGM.fade(param[0])
      when :bgs
        RPG::BGS.fade(param[0])
      when :se
        return
      when :me
        RPG::ME.fade(param[0])
      end
    end
  #--------------------------------------------------------------------------#
  # * action method :action_stop
  #--------------------------------------------------------------------------#
    def action_stop(param)
      case param.pop()
      when :bgm
        RPG::BGM.stop()
      when :bgs
        RPG::BGS.stop()
      when :se
        RPG::SE.stop()
      when :me
        RPG::ME.stop()
      end
    end
  #--------------------------------------------------------------------------#
  # * action method :action_wait
  #--------------------------------------------------------------------------#
    def action_wait(param)
      @wait_count = param[0]
    end

  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#

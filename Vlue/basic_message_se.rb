#Basic Message SE v1.2
#----------#
#Features: Let's you have a sound effect play every so-so letters while a
#           message is being displayed. Fancy!
#
#Usage:    Plug and play, script calls to change details in game:
#
#           message_freq(value)      - changes the frequency of the se
#           message_se("string")     - name of the se to play
#           message_volume(value)    - volume of the se to play
#           message_pitch([min,max]) - pitch variance between min and max
#           message_set(se,volume,pitch) - sets them all at once
#           message_set(se,volume,pitch,freq) - same as above but with freq
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

class Window_Message < Window_Base
  
  DEFAULT_SE_FREQ = 5
  DEFAULT_AUDIO_SOUND = "Cancel2"
  DEFAULT_AUDIO_VOLUME = 75
  DEFAULT_AUDIO_PITCH = [75,125]

  DISABLE_SOUND_SWITCH = 29

  attr_accessor  :se
  attr_accessor  :freq
  attr_accessor  :volume
  attr_accessor  :pitch
  
  alias mse_clear_instance_variables clear_instance_variables
  def clear_instance_variables
    mse_clear_instance_variables
    @key_timer = 0
  end
  def process_normal_character(c, pos)
    super
    if !$game_options.nil?
      return wait_for_one_character unless $game_options.message_se
    end
    return wait_for_one_character if $game_switches[DISABLE_SOUND_SWITCH]
	  se_det = $game_party.message_se_details
    if @key_timer % se_det[:freq] == 0
      Audio.se_play("Audio/SE/" + se_det[:se], se_det[:volume], rand(se_det[:pitch][1]-se_det[:pitch][0]) + se_det[:pitch][0]) 
    end
    @key_timer += 1
    wait_for_one_character
  end
end

class Game_Party
	attr_accessor	:message_se_details
	def message_se_details
		reset_se_details unless @message_se_details
		@message_se_details
	end
	def reset_se_details
		@message_se_details = { 
      :se => Window_Message::DEFAULT_AUDIO_SOUND, 
      :freq => Window_Message::DEFAULT_SE_FREQ, 
      :volume => Window_Message::DEFAULT_AUDIO_VOLUME, 
      :pitch => Window_Message::DEFAULT_AUDIO_PITCH
    }
	end
end

class Game_Interpreter
  def message_set(string, value, array, freq = -1)
    message_se(string)
    message_volume(value)
    message_pitch(array)
    message_freq(freq) if freq >= 0
  end
  def message_freq(value)
    $game_party.message_se_details.freq = value
  end
  def message_se(string)
    $game_party.message_se_details.se = string
  end
  def message_pitch(array)
    $game_party.message_se_details.pitch = array
  end
  def message_volume(value)
    $game_party.message_se_details.volume = value
  end
  def message_reset
    $game_party.message_se_details.reset_se_details
  end
end
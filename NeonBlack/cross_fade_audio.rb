###--------------------------------------------------------------------------###
#  Fade-across Audio script                                                    #
#  Version 1.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.0 - 6.4.2012                                                             #
#   Wrote and debugged main script                                             #
#  Beta - Dunno When                                                           #
#   Tested idea with dummy script                                              #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Audio: bgm_play, bgm_stop, bgm_fade, bgm_pos, bgs_play,       #
#                       bgs_stop, bgs_fade, bgs_pos, me_play                   #
#  New Objects - Audio: check_fades, stop_fades, cross_bgm, cross_bgs          #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is pretty much plug and play with a few options available to    #
#  change below.  To start the "cross-fade audio", simply enable the switch    #
#  you defined in the settings.  Note that this script uses the bgs            #
#  (background sound) to allow the cross fade to work, so you cannot play a    #
#  bgs while the switch is turned on.  Also note that playing a ME (music      #
#  effect) of any type will disable the cross-fade, so it will need to be      #
#  re-enabled afterwards.  It is recommended that you start playing a music    #
#  before enabling cross-fade since it will cause the newly played bgm to      #
#  cross fade either from the old bgm or from nothing.  Also note that this    #
#  script only works with .OGG and .WAV files.                                 #
#      Short Instructions:                                                     #
#  1. Turn switch on to enable.                                                #
#  2. Turn the switch off to diable.                                           #
#  3. Playing a ME disables cross-fade.                                        #
#  4. Only use .OGG and .WAV files.                                            #
#                                                                              #
#      Special Note:                                                           #
#  Okay, at the expense of sounding like I don't know what I'm doing (which I  #
#  can't say I entirely do) there are some issues with the script which I am   #
#  unable to resolve (and most likely will never be able to unless someone     #
#  decides to rip apart the "audio" module so I can find out how it actually   #
#  works).  The first issue involves stereo tracks and the position offset     #
#  (see below).  For some reason, a stereo track that has been offset and      #
#  played as a "bgs" will have a split second of static at the end and I'm     #
#  not entirely sure why.  The simple solution is to just now have any stereo  #
#  tracks (just use mono).  Of course if you have this issue with mono tracks  #
#  PLEASE LET ME KNOW!!  I will do what I can to solve the issue then.  The    #
#  second issue is also with the position tracking and has nothing to do with  #
#  anything I did at all but is actually a "bug" that vxa already has but      #
#  which would have been otherwise impossible to detect.  When trying to       #
#  determine the "position" of the current song, the value is actually only    #
#  updated every 8~12 frames.  This means no matter how much I try to modify   #
#  what I can see, there will always be a slight variance of roughly 150       #
#  milliseconds.  This is barely noticable and in my opinion no big deal.  I   #
#  no plans to try to fix this (once again, unless someone rips apart the      #
#  audio module).  If there are any other issues noted with the script         #
#  besides these two, please contact me with details (and a demo with the      #
#  issue or a video or something else).                                        #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP          # Do not edit                                               #
module FADE_AUDIO  #  these two lines.                                         #
#                                                                              #
###-----                                                                -----###
# This is the switch used by the script to determine if cross fading is being  #
# used or not.                                                                 #
SWITCH = 11 # Default = 11                                                     #
#                                                                              #
# This determines what to do if the program tries to play a bms while cross-   #
# fade is enabled.  If this is set to TRUE it will treat it the same as        #
# bgm_play.  If this is set to FALSE it does nothing.                          #
DO_BGM = false # Default = false                                               #
#                                                                              #
# Okay, this one is kind of odd.  When a new bgm is called and the script      #
# tries to play it from the old position, it doesn't play from exactly the     #
# same position.  This value actually tells the script to play the new song    #
# from a position a little later in the song to account for discrepancy,       #
# however, even then it is not exact (see above).  If you are using music      #
# with a different bitrate than the demo, this may need to be adjusted.  This  #
# value is (I believe) in bytes, not any actual length of time.                #
OFFSET = 26650 # Default = 26650                                               #
#                                                                              #
#                                                                              #
end # Don't edit                                                               #
end #  either of these.                                                        #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###

$imported = {} if $imported == nil
$imported["CP_CROSSFADE"] = true

module Audio
  class << self
    alias cp_bgm_play bgm_play unless $@  ## Initialize alias
    alias cp_bgs_play bgs_play unless $@
    alias cp_bgm_stop bgm_stop unless $@
    alias cp_bgs_stop bgs_stop unless $@
    alias cp_bgm_fade bgm_fade unless $@
    alias cp_bgs_fade bgs_fade unless $@
    alias cp_bgm_pos bgm_pos unless $@
    alias cp_bgs_pos bgs_pos unless $@
    alias cp_me_play me_play unless $@
    
    $fades = false if $fades == nil    ## Initialize variables
    $switch = false if $switch == nil
    
    def bgm_play(*args)  ## Creates the new bgm_play
      check_fades
      if $fades
        if $switch
          spot = cross_bgs# + CP::FADE_AUDIO::OFFSET
          @bgm = args
          @bgs = nil
          cp_bgm_play(args[0],args[1],args[2],spot)
          cp_bgs_fade(1000)
        else
          spot = cross_bgm# + CP::FADE_AUDIO::OFFSET
          @bgs = args
          @bgm = nil
          cp_bgs_play(args[0],args[1],args[2],spot)
          cp_bgm_fade(1000)
        end
        $switch = $switch ? false : true
      else  ## Plays the bgm like normal if disabled.
        unless $switch
          cp_bgm_play(*args)
          @bgm = args
        else
          cp_bgs_play(*args)
          @bgs = args
        end
      end
    end
    
    def check_fades  ## New method that checks the related switch
      return if $game_switches == nil
      $fades = $game_switches[CP::FADE_AUDIO::SWITCH]
    end
    
    def bgs_play(*args)  ## Changes method for ambient sounds
      check_fades
      if $fades
        bgm_play(*args) if CP::FADE_AUDIO::DO_BGM
      else
        unless $switch
          cp_bgs_play(*args)
          @bgs = args
        else
          cp_bgm_play(*args)
          @bgm = args
        end
      end
    end
        
    def me_play(*args)  ## Resets BGM and BGS when playing a ME
      stop_fades
      unless $switch
        cp_me_play(*args)
      else
        temp = @bgs
        spot = cp_bgs_pos
        cp_bgs_stop
        cp_bgs_play(@bgm[0],@bgm[1],@bgm[2],0) unless @bgm == nil
        @bgs = @bgm
        cp_bgm_stop
        cp_bgm_play(temp[0],temp[1],temp[2],spot) unless temp == nil
        @bgm = temp
        cp_me_play(*args)
        $switch = false
      end
    end
    
    def stop_fades  ## Reverts to normal audio
      return if $game_switches == nil
      $fades = false
      $game_switches[CP::FADE_AUDIO::SWITCH] = false
    end
    
    def bgm_stop      ## Ungodly number of aliased methods here
      unless $switch
        cp_bgm_stop
        @bgm = nil
      else
        cp_bgs_stop
        @bgs = nil
      end
    end
    
    def bgs_stop
      unless $switch
        cp_bgs_stop
        @bgs = nil
      else
        cp_bgm_stop
        @bgm = nil
      end
    end
    
    def bgm_fade(time)
      unless $switch
        cp_bgm_fade(time)
        @bgm = nil
      else
        cp_bgs_fade(time)
        @bgs = nil
      end
    end
    
    def bgs_fade(time)
      unless $switch
        cp_bgs_fade(time)
        @bgs = nil
      else
        cp_bgm_fade(time)
        @bgm = nil
      end
    end
    
    def bgm_pos
      unless $switch
        cp_bgm_pos
      else
        cp_bgs_pos
      end
    end
    
    def bgs_pos
      unless $switch
        cp_bgs_pos
      else
        cp_bgm_pos
      end
    end
    
    def cross_bgm
      i = cp_bgm_pos
      i += CP::FADE_AUDIO::OFFSET
      return i
    end
    
    def cross_bgs
      i = cp_bgs_pos
      i += CP::FADE_AUDIO::OFFSET
      return i
    end
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###
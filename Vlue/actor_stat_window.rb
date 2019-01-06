#Actor Stat Window
#----------#
#Features: Let's show a fancy window showing an actor and his stats!
#
#Usage:   Don't make a mistake!
#   @(varname) = W_Merc.new(actor id)
#   @(varname).dispose
#
#Examples: @mew = W_Merc.new(1)
#          Random Text Box <<
#          @mew.dispose
#
#   If you don't call that dispose, that window won't go away and you will
#   be quite a sad kitty.
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

class W_Merc < Window_Base
  WLH = 24
  def initialize(actor, x = 5, y = 5)
    super(5, 5, 96*2 - WLH,96 + WLH * 7)
    self.z = 255
    @actor = $game_actors[actor]
    refresh
  end
  def refresh
    draw_actor_face(@actor, 0, WLH)
    draw_actor_name(@actor, 0, 0)
    draw_actor_nickname(@actor, 0, 96 + WLH)
    draw_actor_level(@actor, 0, 96 + WLH * 2)
    draw_actor_class(@actor, 0, 96 + WLH * 3)
    draw_actor_hp(@actor, 0, 96 + WLH * 4)
    draw_actor_mp(@actor, 0, 96 + WLH * 5)
  end
end
#Script Event Page Conditions v1.1
#----------#
#Features: Set conditions for event pages to activate via script calls made with
#           comments. Comment must start with SC: and be the first thing listed
#           on the event page. Note, that's "SC: " with a space and not "SC:".
#
#Usage:   Comment:
#           SC: script_call
#         
#         Example:
#
#           SC: if $game_party.gold >= 100
#
#          ^^ (that page will only activate if players gold is 100 or higher)
#
#           SC: unless $game_party.item_number($data_items[0]) <= 2
#
#          ^^ (that page will only activate if player has less then 3 of item 1)
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

class Game_Event
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid
      return false unless $game_switches[c.switch1_id]
    end
    if c.switch2_valid
      return false unless $game_switches[c.switch2_id]
    end
    if c.variable_valid
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid
      item = $data_items[c.item_id]
      return false unless $game_party.has_item?(item)
    end
    if c.actor_valid
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    if page.list[0].code == 108
      com = page.list[0].parameters[0]
      index = 1
      while page.list[index].code == 408
        com += page.list[index].parameters[0]
        index += 1
      end
      if com.index("SC:") != nil
        string = "return true " + com[3,com.length-3]
        return false unless eval(string)
      elsif com.index("SR:") != nil
        string = com[3,com.length-3]
        eval(string)
      end
    end
    return true
  end
end
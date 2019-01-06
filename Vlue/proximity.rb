##Proximity Detection Script v1.5a
#
#Usage: Functions mainly used to activate events when within a certain range!
#
#Functions:
#  Proxy.inprox?(@event_id, distance, los)
#    -distance is the range of detection and los is whether to use line of sight,
#     both have default values
#  Proxy.inprox_d?(@event_id, distance, los)
#    -same as original but only checks in the direction the event is facing
#  Proxy.inprox_r?(@event_id, width, height)
#    -checks a rectangle of width/height around the event (odd values best)
#
# All calls return true if within range and false when not
#
#Examples:
# Proxy.inprox?(@event_id)
# Proxy.inprox?(@event_id,10)
# Proxy.inprox?(@event_id,5,false)
# Proxy.inprox_d?(@event_id,6)
# Proxy.inprox_r?(@event_id,3,3)
#
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
 
module Proxy
  #Default radius of detection:
  PROXYRANGE = 4
  #Region for transparent obstacles
  REGION = 20
  #Switch to be turned on to pause Proximity
  PAUSE_SWITCH = 100
  #----#
  def self.inprox?(id, distance = PROXYRANGE, los = true, second_id = nil)
    return if $game_switches[PAUSE_SWITCH]
    x = $game_map.events[id].x
    y = $game_map.events[id].y
    if !second_id
      x2 = $game_player.x; y2 = $game_player.y
    else
      x2 = $game_map.events[second_id].x;y2 = $game_map.events[second_id].y
    end
    x_d = x - x2; y_d = y - y2
    x_d *= -1 if x_d < 0; y_d *= -1 if y_d < 0
    t_d = x_d + y_d
    return false if t_d > distance
    return false if !line_of_sight($game_player.x,$game_player.y,x,y) and los
    return true
  end
  def self.inprox_d?(id, distance = PROXYRANGE, los = true)
    if self.inprox?(id, distance, los) then else return false end
    x1 = $game_player.x; x2 = $game_map.events[id].x
    y1 = $game_player.y; y2 = $game_map.events[id].y
    x1 > x2 ? xx = x1 - x2 : xx = x2 - x1
    y1 > y2 ? yy = y1 - y2 : yy = y2 - y1
    case $game_map.events[id].direction
    when 2
      if $game_player.y > $game_map.events[id].y then
        if yy >= xx then return true end end
    when 4
      if $game_player.x < $game_map.events[id].x then
        if xx >= yy then return true end end
    when 6
      if $game_player.x > $game_map.events[id].x then
        if xx >= yy then return true end end
    when 8
      if $game_player.y < $game_map.events[id].y then
        if yy >= xx then return true end end
    end
    return false
  end
  def self.inprox_r?(id, width, height)
    return if $game_switches[PAUSE_SWITCH]
    width % 2 == 0 ? hwidth = width / 2 : hwidth = (width - 1) / 2
    height % 2 == 0 ? hheight = height / 2 : hheight = (height - 1) / 2
    x = $game_map.events[id].x - hwidth
    y = $game_map.events[id].y - hheight
    if $game_player.x >= x and $game_player.x < (x + width)
      if $game_player.y >= y and $game_player.y < (y + height)
        return true
      end
    end
    return false
  end
  def self.line_of_sight(x,y,x2,y2)
    tile_array = []
    x_d = x - x2; y_d = y - y2
    x_d *= -1 if x_d < 0
    y_d *= -1 if y_d < 0
    t_d = x_d + y_d
    t_d.to_i.times do |i|
      x_distance = x - x2
      y_distance = y - y2
      x_distance *= -1 if x_distance < 0
      y_distance *= -1 if y_distance < 0
      if x_distance > y_distance or y_distance == 0
        x < x2 ? x += 1 : x -= 1
      elsif
        y < y2 ? y += 1 : y -= 1 or x_distance == 0
      end
      tile_array.push([x,y])
    end
    tile_array.each do |cord|
      next if $game_map.region_id(cord[0],cord[1]) == REGION
      return false if !$game_map.check_passage(cord[0], cord[1], 0x002)
    end
    return true
  end
end
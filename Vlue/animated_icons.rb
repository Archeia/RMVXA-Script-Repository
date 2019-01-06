#Animated Icons v1.1
#----------#
#Features: This script let's you set up and use animated icons! Woot!
#
#Usage:   Set up the frames below and set your icons. Animated!
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
# Base_index => [icon_index1, icon_index2, icon_index3, ... ],
ANIMATED_ICONS = {
 528 => [528, 529, 530, 531, 532, 533, 534, 535, 528, 528, 528],
 544 => [544, 545, 546, 547, 546, 545, 544, 544, 544, 544],
 560 => [560, 561, 562, 563, 564, 565, 566, 560, 560],
 576 => [576, 577, 578, 579, 580, 581, 580, 579, 578, 577, 576, 576],
 592 => [592, 593, 594, 595, 596, 596, 594, 592, 593, 592, 593, 592, 592, 592, 592],
 608 => [608,609,610,611,612,613,608,608,608,608,608,608,608,608],
 536 => [536,537,538,539,540,541,542,536,536,536,536,536,536,536],
 548 => [548,549,550,551,549,551,548,550,551,548,549,550],
 552 => [552,553,554,555,553,555,552,554,555,552,553,554],
 556 => [556,557,558,559,557,559,556,558,559,556,557,558],
 567 => [567,567,569,569,570,570,569,569,567,567,569,569,570,568,570,568,570,
          568,570,568,570,568,569,567],
 571 => [571,572,573,574,574,574,574,574]
}

SIMPLE_REFRESH = true
 
class Window_Base < Window
  alias animicon_init initialize
  alias animicon_update update
  alias animicon_draw_icon draw_icon
  def initialize(*args)
    animicon_init(*args)
    @icon_timer = 0
    @icons = []
  end
  def refresh
  end
  def update(*args)
    animicon_update(*args)
    if contents.refresh_icons
      @icons = []
      contents.refresh_icons = false
    end
    if Graphics.frame_count % 10 == 0
      @icon_timer += 1
      redraw_icons if !@icons.empty? && SIMPLE_REFRESH
      refresh unless SIMPLE_REFRESH
    end
  end
  def draw_icon(icon_index, x, y, enabled = true)
    if !ANIMATED_ICONS.include?(icon_index)
      animicon_draw_icon(icon_index, x, y, enabled)
    else
      @icons.push([icon_index,x,y,enabled])
      index = ANIMATED_ICONS[icon_index][@icon_timer % ANIMATED_ICONS[icon_index].size]
      animicon_draw_icon(index, x, y, enabled)
    end
  end
  def redraw_icons
    @icons.each do |array|
      index = ANIMATED_ICONS[array[0]][@icon_timer % ANIMATED_ICONS[array[0]].size]
      contents.clear_rect(Rect.new(array[1],array[2],24,24))
      animicon_draw_icon(index,array[1],array[2],array[3])
    end
  end
end

class Window_Selectable < Window_Base
  alias anim_draw_all_items draw_all_items
  def draw_all_items
    @icons = []
    anim_draw_all_items
  end
end

class Bitmap
  attr_accessor :refresh_icons
  alias anim_clear clear
  def clear
    anim_clear
    @refresh_icons = true
  end
end
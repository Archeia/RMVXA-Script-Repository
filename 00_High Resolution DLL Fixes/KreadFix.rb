
# Put [update] in the event's name and the move route will always update.
# ~Kread

class Game_Event < Game_Character 
  #--------------------------------------------------------------------------
  # * Determine if Near Visible Area of Screen
  #--------------------------------------------------------------------------
  alias_method(:krx_alfix_ge_nts?, :near_the_screen?)
  def near_the_screen?(dx = 12, dy = 8)
    # YEA compatibility
    if $imported && $imported["YEA-CoreEngine"]
      dx = dy = nil
    end # YEA compatibility
    return true if @event.name.include?('[update]')
    return krx_alfix_ge_nts?(dx, dy)
  end
end
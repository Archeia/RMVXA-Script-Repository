#encoding:UTF-8
# Game_Pictures
#==============================================================================
# ** Game_Pictures
#------------------------------------------------------------------------------
#  This is a wrapper for a picture array. This class is used within the
# Game_Screen class. Map screen pictures and battle screen pictures are
# handled separately.
#==============================================================================

class Game_Pictures
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Get Picture
  #--------------------------------------------------------------------------
  def [](number)
    @data[number] ||= Game_Picture.new(number)
  end
  #--------------------------------------------------------------------------
  # * Iterator
  #--------------------------------------------------------------------------
  def each
    @data.compact.each {|picture| yield picture } if block_given?
  end
end

#encoding:UTF-8
# Cache
#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads graphics, creates bitmap objects, and retains them.
# To speed up load times and conserve memory, this module holds the
# created bitmap object in the internal hash, allowing the program to
# return preexisting objects when the same bitmap is requested again.
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * Get Animation Graphic
  #--------------------------------------------------------------------------
  def self.animation(filename, hue)
    load_bitmap("Graphics/Animations/", filename, hue)
  end
  #--------------------------------------------------------------------------
  # * Get Battle Background (Floor) Graphic
  #--------------------------------------------------------------------------
  def self.battleback1(filename)
    load_bitmap("Graphics/Battlebacks1/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Battle Background (Wall) Graphic
  #--------------------------------------------------------------------------
  def self.battleback2(filename)
    load_bitmap("Graphics/Battlebacks2/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Battle Graphic
  #--------------------------------------------------------------------------
  def self.battler(filename, hue)
    load_bitmap("Graphics/Battlers/", filename, hue)
  end
  #--------------------------------------------------------------------------
  # * Get Character Graphic
  #--------------------------------------------------------------------------
  def self.character(filename)
    load_bitmap("Graphics/Characters/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Face Graphic
  #--------------------------------------------------------------------------
  def self.face(filename)
    load_bitmap("Graphics/Faces/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Parallax Background Graphic
  #--------------------------------------------------------------------------
  def self.parallax(filename)
    load_bitmap("Graphics/Parallaxes/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Picture Graphic
  #--------------------------------------------------------------------------
  def self.picture(filename)
    load_bitmap("Graphics/Pictures/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get System Graphic
  #--------------------------------------------------------------------------
  def self.system(filename)
    load_bitmap("Graphics/System/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Tileset Graphic
  #--------------------------------------------------------------------------
  def self.tileset(filename)
    load_bitmap("Graphics/Tilesets/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Title (Background) Graphic
  #--------------------------------------------------------------------------
  def self.title1(filename)
    load_bitmap("Graphics/Titles1/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Title (Frame) Graphic
  #--------------------------------------------------------------------------
  def self.title2(filename)
    load_bitmap("Graphics/Titles2/", filename)
  end
  #--------------------------------------------------------------------------
  # * Load Bitmap
  #--------------------------------------------------------------------------
  def self.load_bitmap(folder_name, filename, hue = 0)
    @cache ||= {}
    if filename.empty?
      empty_bitmap
    elsif hue == 0
      normal_bitmap(folder_name + filename)
    else
      hue_changed_bitmap(folder_name + filename, hue)
    end
  end
  #--------------------------------------------------------------------------
  # * Create Empty Bitmap
  #--------------------------------------------------------------------------
  def self.empty_bitmap
    Bitmap.new(32, 32)
  end
  #--------------------------------------------------------------------------
  # * Create/Get Normal Bitmap
  #--------------------------------------------------------------------------
  def self.normal_bitmap(path)
    @cache[path] = Bitmap.new(path) unless include?(path)
    @cache[path]
  end
  #--------------------------------------------------------------------------
  # * Create/Get Hue-Changed Bitmap
  #--------------------------------------------------------------------------
  def self.hue_changed_bitmap(path, hue)
    key = [path, hue]
    unless include?(key)
      @cache[key] = normal_bitmap(path).clone
      @cache[key].hue_change(hue)
    end
    @cache[key]
  end
  #--------------------------------------------------------------------------
  # * Check Cache Existence
  #--------------------------------------------------------------------------
  def self.include?(key)
    @cache[key] && !@cache[key].disposed?
  end
  #--------------------------------------------------------------------------
  # * Clear Cache
  #--------------------------------------------------------------------------
  def self.clear
    @cache ||= {}
    @cache.clear
    GC.start
  end
end

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# RGSS3 Plane v1.3.1
# FenixFyreX
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# This is a rewrite of RGSS3's Plane class, mainly for use with custom resolution
# alterations of RPG Maker VXAce. This allows Plane to function properly on
# larger resolutions than the hard-coded 640px x 480px in the dll.
# 
# It also correctly displays ox and oy offset and such, just like the original.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# CHANGELOG
#   - Added in caching of plane bitmaps, to stop the lag from persisting.
#   - Fixed potential bug where when the viewport was set, the bitmap would
#     retile incorrectly.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# To remove any artifacts / conflicts with the original, we alias it then remove
# the original tie.
RGSS3Plane = Plane
Object.send(:remove_const, :Plane)

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Bitmap
#   Saves a bitmap's name, for future reference.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
class Bitmap
  alias fyx_initialize_save_name initialize
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # initialize
  #   Instantiate a bitmap's name, if given one.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def initialize(*argv, &argb)
    @name = ''
    if name = argv.find {|arg| arg.is_a?(String) }
      @name = name
    end
    fyx_initialize_save_name(*argv, &argb)
  end
  attr_reader :name
end

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Cache
#   Add in Plane caching, to speed up processing at the slight cost of memory.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module Cache
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Cache::plane_cache
  #   Convenience method, to not have to type it out in the below methods.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.plane_cache
    @plane_cache ||= {}
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Cache::plane
  #   Get a cached plane bitmap.
  #   key : Object  ( most likely an Array e.g. [Rect, String] )
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.plane(key)
    return plane_cache[key]
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Cache::add_plane
  #   Add a tiled plane bitmap to the cache.
  #   key : Object ( see above )
  #   bmp : Bitmap
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.add_plane(key, bmp)
    plane_cache[key] = bmp
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Cache::has_plane?
  #   Check for a cached plane bitmap.
  #   key : Object ( see above )
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.has_plane?(key)
    plane_cache[key].is_a?(Bitmap)
  end
  
  class << self; alias clear_b4_fyx_plane_cache clear; end
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Cache::clear
  #   See original documentation.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.clear
    plane_cache.each_value {|v| v.dispose unless v.nil? || v.disposed? }
    plane_cache.clear
    clear_b4_fyx_plane_cache
  end
end

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Plane
#   Tiles a bitmap across either the window rect, or a given viewport's rect.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
class Plane

  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # initialize
  #   Setup an allocated instance of Plane.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def initialize(v = nil)
    @sprite = Sprite.new(v)
    @bitmap = nil
  end

  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # dispose
  #   Free an instance of Plane.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def dispose
    @sprite.bitmap.dispose unless bitmap_disposed?
    @sprite.dispose unless disposed?
    return nil
  end

  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # bitmap_disposed?
  #   Check whether this instance of Plane's bitmap has been freed.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def bitmap_disposed?
    disposed? || @sprite.bitmap.nil? || @sprite.bitmap.disposed?
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # disposed?
  #   Check whether this instance of Plane has been freed.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def disposed?
    @sprite.nil? || @sprite.disposed?
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # ox=
  #   Set the offset x of this instance of Plane.
  #   val : Integer
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def ox=(val)
    @sprite.ox = (val % (@bitmap.nil? ? 1 : @bitmap.width))
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # oy=
  #   Set the offset y of this instance of Plane.
  #   val : Integer
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def oy=(val)
    @sprite.oy = (val % (@bitmap.nil? ? 1 : @bitmap.height))
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # bitmap
  #   Get the tile bitmap of this instance of Plane.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def bitmap
    @bitmap
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # viewport=
  #   Set the viewport, and refresh if the vrect has changed.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def viewport=(v)
    r = v.nil? ? Rect.new(0, 0, Graphics.width, Graphics.height) : v.rect
    b = r != vrect
    ret = @sprite.viewport = v
    self.bitmap = @bitmap if b
    return ret
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # bitmap=
  #   Set the tile bitmap of this instance of Plane.
  #   bmp : Bitmap
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def bitmap=(bmp)
    w, h = vrect.width, vrect.height
    
    nw = bmp.width <= 100 ? 2 : 3
    nh = bmp.height <= 100 ? 2 : 3
    
    dx = [(w / bmp.width).ceil, 1].max * nw
    dy = [(h / bmp.height).ceil, 1].max * nh

    bw = dx * bmp.width
    bh = dy * bmp.height

    @bitmap = bmp
    key = [vrect.clone, bmp.name]
    if Cache.has_plane?(key)
      @sprite.bitmap = Cache.plane(key)
    else
      @sprite.bitmap = Bitmap.new(bw, bh)
      
      dx.times do |x|
        dy.times do |y|
          @sprite.bitmap.blt(x * bmp.width, y * bmp.height, @bitmap, @bitmap.rect)
        end
      end
      Cache.add_plane(key, @sprite.bitmap)
    end
  end
  
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # method_missing
  #   Here we let any methods not found in this class be redirected to our
  #   underlying sprite.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def method_missing(sym, *argv, &argb)
    if @sprite.respond_to?(sym)
      return @sprite.send(sym, *argv, &argb)
    end
    super(sym, *argv, &argb)
  end
  
  # private methods from here down
  private
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # vrect
  #   Get the view rect of this instance of Plane, which depends on if the
  #   viewport has been set or not.
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def vrect
    @sprite.viewport.nil? ? Rect.new(0, 0, Graphics.width, Graphics.height) : 
    @sprite.viewport.rect
  end
end
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# SCRIPT END
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
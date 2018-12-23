#========================================================================
# ** Cache Back Add-On by: KilloZapit
#------------------------------------------------------------------------
# Pre-cache sounds. Requires Audio Pump Up: FMOD Ex by mikb89 and
# some fiddling to work.
#------------------------------------------------------------------------
# Addon to Cache Back and Audio Pump Up to cache sounds
module Cache
  
  class << self
    alias precache_bitmaps precache
  end
  def self.precache
    @cache ||= {}
    for sound in $data_system.sounds
      FMod::cache('Audio/SE/'+sound.name).keep_cached = true
    end
    precache_bitmaps
  end

end

module FMod
  
  def self.cache(name)
    # Get a valid file name
    filename = self.selectBGMFilename(name)
    # Create Sound or Stream and set initial values
    sound = @fmod.createSound(filename)
    return sound
  end
  
  class << self
    alias selectBGMFilename_cache_base selectBGMFilename
  end
  def self.selectBGMFilename(name)
    (@path_hash ||= {})[name.to_sym] ||= selectBGMFilename_cache_base(name)
  end
  
end

module FModEx
  
  class System
    
    alias_method :createSound_cache_base, :createSound
    def createSound(filename, mode = FMOD_DEFAULT_SOFTWARWE)
      unless sound = Cache.get_key(filename)
        puts("Loading Sound: " + filename)
        sound = createSound_cache_base(filename, mode)
        Cache.set_key(filename, sound)
      end
      sound
    end
    
  end
  
  class Sound
    # * Added Public Instance Variable: Flag set when a bitmap is cached
    attr_accessor :cached
    # * Added Public Instance Variable: Flag set to keep bitmap in memory
    attr_accessor :keep_cached
    # * Added Public Instance Variable: Bitmap age value
    attr_accessor :age
  
    # * Alias: Code run when a bitmap is erased/unloaded
    alias_method :cache_dispose, :dispose
    def dispose
      # Never dispose bitmaps with keep_cached set
      return if self.disposed? || @keep_cached
      # Don't despose chached bitmaps if the settings say to keep them
      if @cached && Cache::KEEP_DISPOSED_BITMAPS
        # Tell the cache to add this bitmap to it's list of bitmaps
        # to be disposed later (if BUFFER_DISPOSED_BITMAPS is true) 
        Cache.add_dispose(self) if Cache::BUFFER_DISPOSED_BITMAPS
      else
        cache_dispose
      end
    end
    
    def disposed?
      return true unless @handle && @handle > 0
      false
    end
    
  end
  
end
#========================================================================
# ** Cache Back, by: KilloZapit
#------------------------------------------------------------------------
# Hey, anyone ever test or play VX ace games which are stored over a
# network connection? I do! And it does have a pretty noticeable delay
# sometimes when loading stuff or in battle.
#
# Sooo... I looked in to improving the cache. But the only script
# I found for "Cache Optimization" apparently was written by someone
# who didn't seam to realize why preloading all files and duplicating
# them whenever they are looked up is a bad idea (Hint: it has to do
# with ram useage and page swapping).
#
# Sooooo... I decided to make my own widdle script! And here it is!
# So what can it do? Welll, for starters it can set some bitmaps to
# be loaded once and never disposed! Only a few system images are by
# default though. It can also keep cached bitmaps around till the
# current scene ends instead of disposing them right away! Helpful for
# animations in battle! Last it automatically cleans up bitmaps that have
# not been used in a while! That will make it use less memory over time.
#
# I am not sure about the most optimal settings yet, but I am pretty
# happy with some of the speed improvements I get.
#------------------------------------------------------------------------
# Version 2: Tweaked the default settings, added some settings for
# printing stuff, and a garbage collection tweak to try and fix some
# problems with crashing.
#------------------------------------------------------------------------
# Version 3: Added the option to automatically precache all actor's 
# sprites or faces. Also added get_key and set_key methods for caching 
# objects besides loaded bitmaps such as dynamic graphics and stuff.
#------------------------------------------------------------------------
# Version 4: Little fix to recache tileset graphics if BITMAP_MAX_AGE is
# set. Otherwise switching between maps with the same tileset wouldn't
# count the ages right. Thankies to Galv for finding the bug!
#========================================================================
# Version 5: Redid the code to recache tileset graphics so that instead
# it disposes and recreates the whole spritesheet which should fix more
# incompatibilitys. Also added the DISPOSE_ON_NEWMAP option so users can
# turn off disposing things on map transfer entirly if needed. Thanks to
# RydiaMist for pointing out that recashing tilesets did nothing to help
# parallax and other sprites from being disposed incorrectly!
#========================================================================
module Cache
  
  # When this is true, cached bitmaps are not disposed normaly
  KEEP_DISPOSED_BITMAPS = true
  
  # When this is true disposed bitmaps in the cache are disposed when 
  # the current scene terminates. Try turning this on if there is too
  # much memory being used.
  BUFFER_DISPOSED_BITMAPS = false
  
  # When this is not null, every map change or return to the map scene,
  # all cached bitmaps have their age value increased by one. Bitmaps
  # with an age value over the max are disposed. The age value is reset
  # when the bitmap is loaded from the cache. 1 is the recommended 
  # minimum, otherwise lots of bitmap are likely to be disposed  and 
  # reloaded returning from menus.   
  BITMAP_MAX_AGE = 1 
  
  # Dispose bitmaps on transfering between maps if this is true.
  # Set this to false if you get disposed bitmap errors when transfering 
  # between maps.
  DISPOSE_ON_NEWMAP = true
  
  # Print messages when the cache is cleaned up if this is true.
  PRINT_CACHE_STATUS = true
  
  # Print messages when a bitmap is loaded in the cache if this is true.
  PRINT_LOADED_BITMAPS = true
  
  # Temporarily disables ruby garbage collection while disposing old
  # bitmaps. May or may not help stability.
  GARBAGE_COLLECTION_TWEAK = true
  
  # Precaches character sprites for all actors. Better to turn it off
  # if there are a lot of actors/sprites.
  PRECACHE_ACTOR_SPRITES = true
  # Same as above but for faces.
  PRECACHE_ACTOR_FACES = false
  
  
  # * New Method: run when the game starts and when the cache is cleared
  # Load any bitmaps you want to keep around here, and set keep_cached
  # on them to true like below.
  def self.precache
    system("IconSet").keep_cached = true
    system("Window").keep_cached = true
    
    for actor in $data_actors
      next unless actor
      if PRECACHE_ACTOR_SPRITES 
        character(actor.character_name).keep_cached = true
      end
      if PRECACHE_ACTOR_FACES
        face(actor.face_name).keep_cached = true
      end
    end if PRECACHE_ACTOR_SPRITES || PRECACHE_ACTOR_FACES
    
    if PRINT_CACHE_STATUS
      n = @cache.values.count {|bitmap| bitmap.keep_cached}
      puts("Cashe contains " + n.to_s + " precashed objects.")
    end
    
  end
  
  # * Alias: Load bitmap and set flags
  class << self
    alias load_bitmap_cache load_bitmap
  end
  def self.load_bitmap(folder_name, filename, hue = 0)
    bitmap = load_bitmap_cache(folder_name.downcase, filename.downcase, hue)
    bitmap.cached = true
    bitmap.age = 0
    bitmap
  end
  
  # * Overwriten Method: Clear Cache
  # Is this even ever used? Well it's here just incase.
  def self.clear
    @disposed_bitmaps = nil
    @cache ||= {}
    @cache.each {|bitmap| bitmap.cache_dispose rescue next}
    @cache.clear
    GC.start
    precache
    puts("Cleared Cache") if PRINT_CACHE_STATUS
  end
  
  # * New Method: Adds bitmap to an array to be disposed later
  def self.add_dispose(bitmap)
    @disposed_bitmaps ||= []
    @disposed_bitmaps |= [bitmap]
  end
  
  # * New Method: Dispose bitmaps needing to be disposed
  def self.do_dispose
    GC.disable if GARBAGE_COLLECTION_TWEAK
    # dispose disposed bitmaps for this scene
    # (mostly animations and stuff)
    if @disposed_bitmaps
      for bitmap in @disposed_bitmaps 
        bitmap.cache_dispose unless bitmap.disposed?
      end
      puts("Disposed of " + @disposed_bitmaps.size.to_s + " objects.") if PRINT_CACHE_STATUS
      @disposed_bitmaps = nil
    end
    # dispose bitmaps that haven't been used in a while.
    if BITMAP_MAX_AGE && SceneManager.scene_is?(Scene_Map)
      n = 0
      @cache.values.each do |bitmap|
        next if bitmap.keep_cached || bitmap.disposed?
        bitmap.age ||= 0
        if bitmap.age > BITMAP_MAX_AGE
          bitmap.cache_dispose
          n += 1
        else
          bitmap.age += 1 
        end
      end
      puts("Disposed of " + n.to_s + " old objects.") if PRINT_CACHE_STATUS
    end
    # Clean up cache hash, because I wanted to count the non-disposed
    # bitmaps during debugging anyway, so why not?
    @cache.delete_if do |key, bitmap|
      bitmap.disposed? && !bitmap.keep_cached
    end
    puts("Cache now contains " + @cache.size.to_s + " objects.") if PRINT_CACHE_STATUS
    if GARBAGE_COLLECTION_TWEAK 
      GC.enable 
      GC.start
    end
  end

  def self.set_key(key, value)
    unless include?(key)
      puts("Cache Key Set: " + key.to_s) if PRINT_CACHE_STATUS
      @cache[key] = value
    end
    value.cached = true
    value.age = 0
  end
  
  def self.get_key(key)
    return nil unless include?(key)
    value = @cache[key]
    value.age = 0
    value
  end

  if PRINT_LOADED_BITMAPS
    
  def self.normal_bitmap(path)
    unless include?(path)
      puts("Loading Bitmap: " + path)
      @cache[path] = Bitmap.new(path)
    end
    @cache[path]
  end
  
  end
  
end

class Bitmap
  
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
  
  # * Alias: clear flags when copying bitmaps
  alias_method :cache_dup, :dup
  def dup
    bitmap = cache_dup
    bitmap.cached = false
    bitmap.keep_cached = false
    bitmap
  end
 
  # * Alias: same as above (clone and dup are not QUITE the same)
  alias_method :cache_clone, :clone
  def clone
    bitmap = cache_clone
    bitmap.cached = false
    bitmap.keep_cached = false
    bitmap
  end   
  
end

class Scene_Base
  
  # * Alias: tell the cache to dispose stuff when the scene changes
  alias_method :cache_main_base, :main
  def main
    cache_main_base
    Cache.do_dispose
  end
  
end

class Game_Map
  
  # * Alias: tell the cache to dispose stuff when the map changes too
  alias_method :cache_setup_base, :setup
  def setup(map_id)
    if SceneManager.scene.is_a?(Scene_Map)
      SceneManager.scene.dispose_spriteset
      Cache.do_dispose
    end
    cache_setup_base(map_id)
    SceneManager.scene.create_spriteset if SceneManager.scene.is_a?(Scene_Map)
  end if Cache::DISPOSE_ON_NEWMAP
  
end

module DataManager

  class << self
    alias load_database_cache load_database
  end
  def self.load_database
    load_database_cache
    Cache.precache
  end

end
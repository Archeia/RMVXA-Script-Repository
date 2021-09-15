$simport.r 'iek/cache_awesome', '1.0.0', 'Improves the functionality of default Cache'

### prepare for loading the new cache module
Object.send(:remove_const, :Cache) if Object.constants.include?(:Cache)
module Cache
  class CacheBitmap < Bitmap
    attr_accessor :cache_key
  end

  Loader = Struct.new(:id, :dirname, :loader_func, :fallback_func)

  attr_accessor :logger
  attr_accessor :root

  ##
  # init
  def init
    @root = 'Graphics'
    @logger = Moon::Logfmt::NullLogger
    @loader = {}
    @cache = {}
  end

  # @param [String] key
  # @return [Boolean]
  def include?(key)
    @cache[key] && !@cache[key].disposed?
  end

  ##
  # clear
  def clear
    @cache ||= {}
    @cache.clear
    GC.start
  end

  ##
  # empty_bitmap
  def empty_bitmap
    CacheBitmap.new 32, 32
  end

  def cache_bitmap(key)
    @logger.write fn: 'cache_bitmap', key: key
    unless include? key
      bitmap = yield key
      @cache[key] = bitmap
      bitmap.cache_key = key
      return bitmap
    end
    @cache[key]
  end

  ##
  # normal_bitmap(String path)
  def normal_bitmap(path)
    cache_bitmap path do
      CacheBitmap.new path
    end
    @cache[path]
  end

  ###
  # hue_changed_bitmap(String path, Integer hue)
  # @param [String] path
  # @param [Integer] hue
  # @return [Bitmap]
  ###
  def hue_changed_bitmap(path, hue=0)
    key = [path, hue]
    cache_bitmap key do
      org_bmp = normal_bitmap(path)
      bmp = CacheBitmap.new org_bmp.width, org_bmp.height
      bmp.blt 0,0,org_bmp,org_bmp.rect
      bmp.hue_change hue
      bmp
    end
  end

  ##
  # load_bitmap
  def load_bitmap(folder_name, filename, hue=0)
    @cache ||= {}
    path = File.join(folder_name, filename)
    if filename.empty?
      key = [path, hue]
      cache_bitmap key do
        empty_bitmap
      end
    elsif hue != 0
      hue_changed_bitmap path, hue
    else
      normal_bitmap path
    end
  end

  ##
  # new_loader(Symbol sym, String dir)
  def new_loader(sym, dir, &fallback)
    dirpath = File.join(@root, dir)
    ## create_loader
    loader = lambda do |filename, hue = 0|
      begin
        load_bitmap dirpath, filename, hue
      rescue Errno::ENOENT => ex
        if fallback
          fallback.call dirpath, filename, hue
        else
          raise ex
        end
      end
    end
    ## set_loader
    @loader[sym] = Loader.new(sym, dir, loader, fallback)
    define_method(sym, loader)
  end

  extend self
  init
end

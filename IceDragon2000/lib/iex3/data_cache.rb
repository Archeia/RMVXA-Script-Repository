$simport.r 'iex3/data_cache', '1.0.0', 'Data Caching for RMVX'

class DataCacheClass
  attr_accessor :logger

  def initialize
    @cache = {}
  end

  def data_extname
    '.rvdata'
  end

  def clear
    @cache.clear
  end

  def load(filename)
    @cache[filename] ||= begin
      map = load_data(filename)
      yield map if block_given?
      map
    end
  end

  def patch_map(map, filename)
    if map.data.zsize != 4
      STDERR.puts "[DataCache] Repairing broken map data (filename: #{filename})"
      map.data.resize(map.data.xsize, map.data.ysize, 4)
    end
  end
  private :patch_map

  def load_map(filename)
    load filename do |map|
      patch_map map, filename
    end
  end

  def load_map_by_id(map_id)
    load_map sprintf('Data/Map%03d%s', map_id, data_extname)
  end
end

DataCache = DataCacheClass.new

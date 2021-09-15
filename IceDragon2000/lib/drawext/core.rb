#
# module/drawext/core.rb
#
module DrawExt
  @flags = []

  def self.flags
    return @flags[-1]
  end

  def self.flag_set(key, value)
    (@flags[-1] ||= {})[key] = value
  end

  def self.flag_clear(key)
    if fl = flags
      fl.delete(key)
    end
  end

  def self.flag?(key)
    flgs = flags
    return false unless flgs
    return flgs.key?(key)
  end

  def self.flag(key)
    flgs = flags
    return nil unless flgs
    return flgs[key]
  end

  def self.restore
    @flags.pop
  end

  def self.snapshot
    flgs = flags || {}
    @flags.push(flgs.dup)
    if block_given?
      yield self
      restore
    end
  end
end

require 'drawext/core/blend'
require 'drawext/core/border'
require 'drawext/core/box'
require 'drawext/core/distortion'
require 'drawext/core/draw_icon'
require 'drawext/core/gauge'
require 'drawext/core/gauge_specia'
require 'drawext/core/outline'
require 'drawext/core/padded_rect'
require 'drawext/core/repeat'
require 'drawext/core/slant'
require 'drawext/core/special'
require 'drawext/core/subtractive'
require 'drawext/core/text'

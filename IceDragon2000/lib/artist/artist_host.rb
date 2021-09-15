#
# EDOS/lib/mixin/artist.rb
#   by IceDragon
module Mixin
  module ArtistHost
    def standard_artist
      Artist
    end

    def init_artist
      @artist = standard_artist.new(self)
    end

    def artist
      yield @artist if block_given?
      return @artist
    end
  end
end

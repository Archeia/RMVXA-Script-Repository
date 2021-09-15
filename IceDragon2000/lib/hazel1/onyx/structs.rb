#
# EDOS/src/hazel/onyx/Structs.rb
#   by IceDragon
#   dc 22/04/2013
#   dm 22/04/2013
# vr 1.0.0
module Hazel
  module Onyx
    module Struct

      class Atlas

        attr_accessor :bitmap, :content

        def initialize(bitmap, content={})
          @bitmap  = bitmap
          @content = content
        end

        def clear
          @content.clear
        end

        def add(name, rect)
          @content[name] = rect
        end

        def remove(name)
          @content.delete(name)
        end

        def cell_rect(name)
          raise(AtlasError,
                "content %s does not exist" % name) unless @content.has_key?(name)
          return @content[name]
        end

        def content_merge(hash)
          @content.merge(hash)
        end

        def content_to_json_hash
          Hash[json_hash.map { |(k, r)| [k, r.to_a] }]
        end

        ##
        # json_patch(Hash json_hash)
        #   json_hash is a Ruby Hash read directly from a JSON file, which
        #   needs to have its Rects setup
        def self.json_patch(json_hash)
          Hash[json_hash.map { |(k, a)| [k, Rect.new(*a)] }]
        end

      end

      class Spritesheet

        attr_accessor :bitmap, :cell_width, :cell_height, :cols, :rows

        def initialize(*args)
          @bitmap, @cell_width, @cell_height, @cols, @rows = *args
        end

        def cell_rect_xy(x, y)
          Rect.new(@cell_width * x, @cell_height * y, @cell_width, @cell_height)
        end

        def cell_rect_vec2(vec2)
          cell_rect_xy(vec2.x, vec2.y)
        end

        def cell_rect(index)
          if @cols
            cell_rect_xy((index % @cols), (index / @cols))
          elsif @rows
            cell_rect_xy((index / @rows), (index % @rows))
          else
            raise(RuntimeError, "please set either @rows or @cols")
          end
        end

      end

      class Iconset < Spritesheet

      end

      class Icon
        attr_accessor :iconset, :icon_index

        def initialize(*args)
          @iconset, @icon_index = *args
        end

        def bitmap
          @iconset.bitmap
        end

        def rect
          @iconset.cell_rect(@icon_index)
        end

        def width
          @iconset.cell_width
        end

        def height
          @iconset.cell_height
        end
      end
    end
  end
end

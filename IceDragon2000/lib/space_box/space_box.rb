#
# EDOS/lib/module/lacio/space_box.rb
#   by IceDragon
#   dc 14/06/2013
#   dm 19/06/2013
# vr 1.0.1
#   CHANGELOG
#     vr 1.0.1 [19/06/2013]
#       Moved to Lacio module
module Lacio
  class SpaceBox

    ### errors
    class SpaceBoxError < RuntimeError; end

    ### mixins
    include MACL::Mixin::Surface2Bang
    include Mixin::SpaceBoxBody
    include Mixin::IDisposable
    include Mixin::Automatable
    include Mixin::WindowClient

    ### instance_attributes
    attr_accessor :bodies
    attr_reader :x, :y, :z
    #%attr_reader :width, :height, :depth
    # affects size, if true width/height/depth is calculated only once,
    # else all sizes are recalculated from the bodies
    attr_accessor :is_static

    ##
    # initialize
    def initialize(bodies=[])
      @bodies = bodies
      @x, @y, @z, @width, @height, @depth = 0, 0, 0, nil, nil, nil
      @is_static = true
      refresh_bodies
      init_automations
    end

    def dispose
      dispose_automations
      super
    end

    def update
      update_automations
    end

    ##
    # calc_width
    def calc_width
      @bodies.max_by(&:x2).x2 - @bodies.min_by(&:x).x
    end

    ##
    # calc_height
    def calc_height
      @bodies.max_by(&:y2).y2 - @bodies.min_by(&:y).y
    end

    ##
    # calc_depth
    def calc_depth
      @bodies.max_by(&:z2).z2 - @bodies.min_by(&:z).z
    end

    ##
    # recalc_size
    def recalc_size
      @width  = calc_width
      @height = calc_height
      @depth  = calc_depth
    end

    ##
    # width
    def width
      @is_static ? @width ||= calc_width : @width = calc_width
      return @width
    end

    ##
    # height
    def height
      @is_static ? @height ||= calc_height : @height = calc_height
      return @height
    end

    ##
    # depth
    def depth
      @is_static ? @depth ||= calc_depth : @depth = calc_depth
      return @depth
    end

    ##
    # clear_bodies
    def clear_bodies
      @bodies.each do |body|
        # clear the relative positions
        body.rel_x = nil
        body.rel_y = nil
        body.rel_z = nil
      end
      @bodies.clear
    end

    ##
    # restore_body_rel(body)
    def restore_body_rel(body)
      (body.x = body.rel_x; body.rel_x = nil) if body.rel_x
      (body.y = body.rel_y; body.rel_y = nil) if body.rel_y
      (body.z = body.rel_z; body.rel_z = nil) if body.rel_z
    end

    ##
    # refresh_body_rel(body)
    def refresh_body_rel(body)
      body.rel_x = body.x
      body.rel_y = body.y
      body.rel_z = body.z
    end

    ##
    # refresh_body_pos(body)
    def refresh_body_pos(body)
      body.x = self.x + body.rel_x
      body.y = self.y + body.rel_y
      body.z = self.z + body.rel_z
    end

    ##
    # restore_bodies_rel
    #   Restore bodies original rel[x|y|z]
    def restore_bodies_rels
      @bodies.each do |body|
        restore_body_rel(body)
      end
    end

    ##
    # refresh_bodies_rels
    def refresh_bodies_rels
      @bodies.each do |body|
        refresh_body_rel(body)
      end
    end

    ##
    # refresh_bodies_pos
    def refresh_bodies_pos
      @bodies.each do |body|
        refresh_body_pos(body)
      end
    end

    ##
    # refresh
    #   Refreshes the bodies relative x, y position to the current SpaceRect
    def refresh_bodies
      restore_bodies_rels
      refresh_bodies_rels
      refresh_bodies_pos
    end

    ##
    # remove_body(body)
    def remove_body(body)
      clear_body_rel(body)
      @bodies.delete(body) if @bodies.include?(body)
      self
    end

    ##
    # add_body(body)
    def add_body(body)
      raise(SpaceBoxError, "cannot contain a body with self") if body == self
      # remove this line unless you have MACL/core_ext/module.rb installed
      Mixin::SpaceBoxBody.assert_type(body) if Module.respond_to?(:assert_type)
      ##
      refresh_body_rel(body)
      @bodies.push(body) unless @bodies.include?(body)
      self
    end

    ##
    # x=(new_x)
    def x=(new_x)
      @x = new_x
      refresh_bodies_pos
    end

    ##
    # y=(new_y)
    def y=(new_y)
      @y = new_y
      refresh_bodies_pos
    end

    ##
    # z=(new_z)
    def z=(new_z)
      @z = new_z
      refresh_bodies_pos
    end

    ##
    # move(x, y, z)
    def move(x, y, z=0)
      @x += x
      @y += y
      @z += z
      refresh_bodies_pos
    end

    ##
    # moveto(int x, int y, int z)
    def moveto(x, y, z=self.z)
      @x, @y, @z = x, y, z
      refresh_bodies_pos
    end

  end
end
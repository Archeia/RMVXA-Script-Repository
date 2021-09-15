#
# EDOS/lib/mixin/space_box_body.rb
#   by IceDragon
#   dc 14/06/2013
#   dm 14/06/2013
# vr 1.0.0
#  include this Mixin in any object you need to use in a SpaceBox
module Mixin
  module SpaceBoxBody
    ### instance_attributes
    attr_accessor :rel_x, :rel_y, :rel_z # relative_xyz
  end
end
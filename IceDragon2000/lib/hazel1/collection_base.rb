#
# hazel/collection_base.rb
# vr 1.0
module Hazel
  class CollectionBase

    def initialize
      @objs = []
    end

    def add_obj(new_object)
      @objs.push(new_object)
      return self
    end

    def rem_obj(new_object)
      @objs.delete(new_object)
      return self
    end

    def objs
      return @objs
    end

    def clear
      @objs.clear
    end

  end
end
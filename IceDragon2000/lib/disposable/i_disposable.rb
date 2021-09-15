# The Object disposal Interface mixin.
module Mixin
  module IDisposable
    def disposed?
      !!@disposed
    end

    private def check_disposed
      raise DisposedError, "disposed #{self} cannot be modified" if disposed?
    end

    def dispose
      check_disposed
      @disposed = true
    end
  end
end

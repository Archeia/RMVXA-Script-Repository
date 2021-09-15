module Automation
  class Toner < BaseEased
    def setup_values(src, dst)
      @src, @dst = Convert.Tone(src), Convert.Tone(dst)
    end

    def update_value(target, v)
      target.tone = v
    end

    type :toner
  end
end

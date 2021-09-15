#
# EDOS/src/REI/component/health.rb
#
module REI
  module Component
    class Health

      extend REI::Mixin::REIComponent
      include Ygg4::Component
      include Ygg4::Gaugable

      def initialize
        init_component
        init_gauge
      end

      def update
        update_gauge
        super
      end

      def on_rate_changed
        if evs = comp(:event_server)
          r = rate
          if @_last_rate_ != r
            if min?
              evs.add(:health, :min, r)
            elsif r < REI::System.hp_critical_thresh
              evs.add(:health, :critical, r)
            elsif r < REI::System.hp_warning_thresh
              evs.add(:health, :warning, r)
            elsif max?
              evs.add(:health, :max, r)
            end
            @_last_rate_ = r
          end
        end
      end

      def on_value_changed
        on_rate_changed
      end

      def on_max_changed
        on_rate_changed
      end

      def on_min_changed
        on_rate_changed
      end

      alias :dead? :min?

      opt :event_server
      rei_register :health

    end
  end
end
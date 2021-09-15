#-// 23/06/2012
#-// 23/06/2012
#-skip 1
$simport.r 'iei/tracker', '1.0.0', 'IEI Tracker'
#-inject gen_module_header 'IEI::Tracker'
module IEI
  module Tracker
#-inject gen_module_header 'IEI::Tracker::Class'
    module Class

      attr_accessor :default_values, :alert_procs, :accepted_types, :read_only

      def init_svt
        @default_values = {}
        @alert_procs = {
          # // id => proc
        }
        @read_only = {}
        @read_only.default = false
        @accepted_types = []

        alias_method :pre_svt_initialize, :initialize
        define_method :initialize do |*args, &block|
          pre_svt_initialize *args,&block
          init_svt
        end

        alias_method :set, :[]= unless method_defined?(:set)

        define_method :[]= do |id, value|
          return unless(accepted_types.any? do |obj| value.is_a? obj end) if accepted_types.size > 0
          raise(NameError,"ID: #{id} is read only") if read_only?(id)

          refresh = false

          if @data[id] != value
            get_alert_proc(id).call(id, value) if(alert_proc?(id))
            @last_data[id] = @data[id]
            refresh = true
          end
          set(id, value)
          call_refresh if refresh
        end

      end
    end

    def self.included(mod)
      mod.send :extend, IEI::Tracker::Class
      mod.init_svt
    end

    def init_svt
      default_values.each_pair do |key,value| @data[key] = value end
      @last_data = Array.new
    end

    def last(id)
      @last_data[id] || @default
    end

    attr_accessor :default

  private

    def get_alert_proc(id)
      return self.class.alert_procs[id]
    end

    def alert_proc?(id)
      !!self.class.alert_procs[id]
    end

    def read_only?(id)
      return self.class.read_only[id]
    end

    def default_values
      self.class.default_values
    end

    def alert_prcos
      self.class.default_values
    end

    def accepted_types
      self.class.accepted_types
    end

    def call_refresh
    end

  end
end

#-inject gen_class_header 'Game::Variables'
class Game::Variables

  include IEI::Tracker

end

#-inject gen_class_header 'Game::Switches'
class Game::Switches

  include IEI::Tracker

end

#-inject gen_script_footer

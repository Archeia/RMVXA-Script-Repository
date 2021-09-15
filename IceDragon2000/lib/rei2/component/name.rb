#
# EDOS/src/REI/component/name.rb
#
module REI
  module Component
    class Name

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      # The internal System name, will be used to locate the proper Locale name
      attr_accessor :sys_tag
      attr_accessor :sys_name
      attr_accessor :sys_title_tag
      attr_accessor :sys_title_name

      def initialize
        init_component
        @sys_tag = nil
        @sys_name = ""
        @sys_title_tag  = nil
        @sys_title_name = ""
      end

      def locale_name(tag, name)
        REI::System.locale(tag, name)
      end

      def name
        locale_name(@sys_tag, @sys_name)
      end

      def title_name
        locale_name(@sys_title_tag, @sys_title_name)
      end

      def on_name_change
        if evs = comp(:event_server)
          evs.add(:name, :name, @sys_tag, @sys_name)
        end
      end

      def on_title_change
        if evs = comp(:event_server)
          evs.add(:name, :title, @sys_title_tag, @sys_title_name)
        end
      end

      def setup_name(tag, name)
        @sys_tag = tag
        @sys_name = name
        on_name_change
        self
      end

      def setup_title(tag, name)
        @sys_title_tag = tag
        @sys_title_name = name
        on_title_change
        self
      end

      opt :event_server
      rei_register :name

    end
  end
end
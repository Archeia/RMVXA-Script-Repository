module IEK
  module Mixin
    module MetaNote
      attr_writer :meta

      #
      # @return [Hash<String, String>]
      def meta
        @meta || init_metanote
      end

      def init_metanote
        @meta = {}
        note.scan(/<meta\s(\S+)=(.+)>/i).each { |k, v| @meta[k] = v }
        @meta
      end

      private :init_metanote
    end
  end
end

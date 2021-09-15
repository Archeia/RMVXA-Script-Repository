# The simpliest script for 'mixing' items
module IEK
  class Xpresso
    class MixResultItem
      attr_accessor :kind
      attr_accessor :id
      attr_accessor :number

      def initialize(kind, id, number)
        @kind, @id, @number = kind, id, number
      end

      def item
        case @kind
        when 0
          nil
        when 1
          $data_items[id]
        when 2
          $data_weapons[id]
        when 3
          $data_armors[id]
        when 4
          $data_skills[id]
        end
      end
    end

    class MixResult
      attr_accessor :items    # Array<MixResultItem>
      attr_accessor :message  # String

      def initialize(items, message)
        @items = items
        @message = message
      end

      def valid?
        !@items.empty?
      end

      def gain_items(target)
        @items.each do |mix_result_item|
          target.gain_item mix_result_item.item, number
        end
      end
    end

    attr_reader :mix_table

    def initialize
      @mix_table = {}
    end

    def mix(item1, item2)
      if !item1 || !item2
        return MixResult.new([], 'Invalid items')
      end

      key = [item1.to_mix_key, item2.to_mix_key]
      mix_results = @mix_table[key]

      if mix_results
        return MixResult.new(mix_results, 'Mixed!')
      end

      MixResult.new([], 'No mix result')
    end
  end
end

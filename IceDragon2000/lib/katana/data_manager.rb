module Katana
  class DataManagerPatch
    attr_reader :data_manager

    def initialize(data_manager)
      @data_manager = data_manager
    end

    def patch(scene)
      scene.data_manager = @data_manager
    end
  end

  class DataManager
    class Entry
      attr_accessor :name
      attr_accessor :src
      attr_accessor :cb

      def initialize(name, options, &cb)
        @src = options.fetch(:src)
        @cb = cb
        @name = name
      end

      def call(value)
        @cb.call(value) if @cb
      end
    end

    class Database
      include Enumerable

      attr_reader :data

      def initialize
        @data = {}
      end

      def each(&block)
        @data.each(&block)
      end

      def entries
        self.class.entries
      end

      def trigger(key, value)
        if entry = entries[key]
          entry.call(value)
        end
      end

      def get(key)
        @data.fetch(key)
      end
      alias :[] :get

      def set(key, value)
        @data[key] = value
        trigger(key, value)
      end
      alias :[]= :set

      def self.entries
        @entries ||= {}
      end

      def self.define_entry(entry)
        define_method(entry.name) do
          get(entry.name)
        end

        define_method(entry.name.to_s + '=') do |value|
          set(entry.name, value)
        end
      end

      def self.entry(key, options, &cb)
        entry = Entry.new(key, options, &cb)
        entries[key] = entry
        define_entry entry
      end
    end

    attr_accessor :logger

    def initialize(root = 'Data')
      @logger = Logfmt::NullLogger
      @root = root
      @database = create_database
    end

    def create_database
      raise
    end

    def extname
      '.rvdata'
    end

    def data_filename(basename)
      File.join(@root, basename + extname)
    end
    private :data_filename

    def data_load(basename)
      load_data(data_filename(basename))
    end
    private :data_load

    def data_save(basename, data)
      save_data(data, data_filename(basename))
    end
    private :data_save

    def pre_load_database
    end

    def post_load_database
    end

    def load_database
      l = @logger.new fn: 'load_database'
      l.write({})
      pre_load_database
      @database.entries.each do |_, entry|
        l.write name: entry.name, src: entry.src
        @database.set(entry.name, data_load(entry.src))
      end
      post_load_database
    end

    def pre_save_database
    end

    def post_save_database
    end

    def save_database
      l = @logger.new fn: 'save_database'
      l.write({})
      pre_save_database
      @database.entries.each do |_, entry|
        l.write name: entry.name, src: entry.src
        data_save(basename, @database.get(entry.name))
      end
      post_save_database
    end
  end
end

$simport.r 'iei/core', '1.1.0', 'IEI Core'

module IEI
  def self.debug
    yield STDERR
  end

  module Core
    module Mixin
      module InitCore
        private def pre_init_iei
          # // Nothing here but us Whitespace
        end

        private def init_iei
          # // Nothing here but us Whitespace
        end

        private def post_init_iei
          # // Nothing here but us Whitespace
        end

        private def do_init_iei
          pre_init_iei  # // . x . Like, make arrays and stuff
          init_iei      # // @.@ Dirty Initializes and stuff
          post_init_iei # // =w= Cleaning up
        end
      end
    end
    extend MACL::Mixin::Log

    @data_load_stack = []

    def self.on_data_load(name = nil, &block)
      warn 'Depreceated on_data_load call, please provide a valid (name)' if !name || name.empty?
      @data_load_stack.push([name, block])
    end

    def self.exc_load_stack
      size = @data_load_stack.size
      try_log { |l| l.puts('IEI | Executing Load Stack') }
      @data_load_stack.each_with_index do |(name, func), i|
        func.call
        try_log do |l|
          barsize = 42
          mul = (barsize * ((i + 1) / size.to_f)).to_i
          prog = ('=' * mul).concat((mul < barsize) ? '>' : '')
          l.puts(format("LOADING [%-018s] [%-0#{barsize}s]", name, prog))
        end
      end
    end

    def self.do_obj_cache(obj)
      obj.note_eval
    end

    def self.init
      exc_load_stack
      try_log { |l| l.puts("IEI | Core has been Initialized") }
    end

    NoteFolder = Struct.new :header,:body

    def self.mk_notefolder_tags str
      return [/<#{str}>/i,/<\/#{str}>/i]
    end

    def self.get_note_folders((open_tag,close_tag),note)
      lines  = note.split(/[\r\n]+/i)
      i,line,result,arra = 0, nil,nil,[]
      while i < lines.size
        line = lines[i]
        if n = line.match(open_tag)
          result = NoteFolder.new n,[]
          until line =~ close_tag
            i += 1
            line = lines[i]
            result.body << line
            raise "End of note reached!" if(i > lines.size)
          end
          arra << notef; result = nil
        end
        i += 1
      end
      arra
    end
  end

  module Sprite

  end

  module Window

  end

  module Scene

  end

  class Tileset
    attr_reader :bitmap

    def initialize(columns, rows, cell_width, cell_height)
      @grid = MACL::Grid.new(columns, rows, cell_width, cell_height)
      @bitmap = Bitmap.new(columns * cell_width, rows * cell_height)
    end

    def cell_r(*args, &block)
      @grid.cell_r(*args, &block)
    end

    def columns
      @grid.columns
    end

    def rows
      @grid.rows
    end

    def width
      @bitmap.width
    end

    def height
      @bitmap.height
    end

    def cell_width
      @grid.cell_width
    end

    def cell_height
      @grid.cell_height
    end

    def disposed?
      @bitmap.nil? || @bitmap.disposed?
    end
  end
end

class RPG::BaseItem
  def get_note_folders(tags)
    IEI::Core.get_note_folders(tags, @note)
  end
end

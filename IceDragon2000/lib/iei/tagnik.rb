#encoding:UTF-8
# [IEI]Tagnik
# // 03/31/2012
# // 04/01/2012
# // IEI - Tagnik
$simport.r 'iei/tagnik', '1.0.0', 'IEI Tagnik'

module IEI
  class Tagnik

    TAGPROCS = {
      "default"  => proc { |value| value },
      "int"      => proc { |value| value.to_i },
      "uint"     => proc { |value| value.max(0).to_i },
      "string"   => proc { |value| value.to_s },
      "float"    => proc { |value| value.to_f },
      "int[]"    => proc { |value| value.split(/(\d+)/).collect{|i|i.to_i}}
    }

    # // type - "line" or "folder"
    Tag = Struct.new(:name,:type,:block)

    attr_accessor :tag_lib

    def initialize()
      @tag_lib = {}
      @regex = [/<(.+):[ ]*(.+)>/i, /<(.+)>/i, /<\/(.+)>/i] # // Line1, Line2, Close Folder
    end

    def clear_tags()
      @tag_lib.clear()
      self
    end

    def add_tag(string, type="line", &block)
      @tag_lib[string.upcase] = Tag.new(string.upcase,type,block)
      self
    end

    def set_regex(id,n)
      @regex[id] = n
      self
    end

    def compare_ex(string)
      result, line, i, a = [], "", 0, string.split(/[\r\n]+/i)
      while(i < a.size)
        line = a[i]
        matd = line.match(@regex[0]); matd = line.match(@regex[1]) unless(matd)
        next i += 1 unless(matd); name, value = matd[1].upcase, matd[2]
        next i += 1 unless(@tag_lib.has_key?(name)); tg = @tag_lib[name]
        case(tg.type)
        when "line"
          result << [tg.name,tg.block.call(value)]
        when "folder"
          fa = [tg.name,tg.block.call(value),[]]; clstag = @regex[2]
          while(i < a.size)
            break if((a[i].match(clstag)||[nil,""])[1].upcase==tg.name.upcase)
            i += 1 ; fa[2] << a[i]
          end
          fa[2].pop; result << fa
        end
        i += 1
      end
      result
    end
  end

end

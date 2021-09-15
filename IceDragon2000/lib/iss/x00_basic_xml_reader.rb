#encoding:UTF-8
# ISSX00 - Basic XML Reader
module ISSX
  module BXMLR
    
    module_function()
    
    def get_element_contents( name, file )
      opentag  = /<#{name}>/i
      closetag = /<\/#{name}>/i
      openned  = false
      result   = []
      file.each_line { |l|
        case l
        when opentag
          openned = true
        when closetag  
          openned = false
        else  
          result << l if openned
        end  
      }
      return result
    end
    
    # // file == File Object, Properties == ["property name", regexcheck]
    # // Property == ["value", %Q("(\\d+)")]
    def get_element_contents2( name, file, *properties )
      closetag = /<\/#{name}>/i
      prop = properties.inject("") { |r, p| r + " " + p[0] + "=" + p[1] }
      opentag = /<#{name} #{prop}>/i
      openned = false
      contents = []
      propvalues = []
      file.each_line { |l|
        case l
        when opentag
          openned = true
          properties.size.times { |i|
            propvalues[i] = l[opentag, i+1]
          }
        when closetag
          openned = false
        else
          result << l if openned
        end 
      }
      return propvalues, contents
    end
    
  end  
end  


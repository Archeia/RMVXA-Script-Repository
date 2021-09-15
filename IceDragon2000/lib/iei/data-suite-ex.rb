=begin
  The Self Data Suite
  by PK8
  Ex By IceDragon
  20/07/2012
  20/07/2012
=end
$simport.r 'iei/data_suite', '0.1.0', 'IEI Data Suite'
#-inject gen_module_header 'IEI::DataSuiteEx'
module IEI
  module DataSuiteEx

    def ds_variables
      @ds_variables ||= IEI::DataSuiteEx::Variables.new
    end

    def ds_switches
      @ds_switches ||= IEI::DataSuiteEx::Switches.new
    end

    def ds_self_switches
      @ds_self_switches ||= IEI::DataSuiteEx::SelfSwitches.new
    end

    def ds_metadata
      @ds_metadata ||= IEI::DataSuiteEx::MetaData.new
    end

  end
end

#-inject gen_module_header 'IEI::DataSuiteEx::Base'
class IEI::DataSuiteEx::Base

  def initialize size=1
    @size = size
    @data = block_given? ? yield(@size) : Array.new(@size, _default)
    @default = nil
  end

  def _default
    nil
  end

  def convert_key obj
    obj
  end

  def convert_value obj
    obj
  end

  def enforce_size?
    false
  end

  private :_default, :convert_key, :convert_value, :enforce_size?

  def get key
    return @data[convert_key(key)] || @default
  end

  def set key, value
    res = @data[convert_key(key)] = convert_value(value)
    raise(StandardError, "Suite size changed") if enforce_size? and @data.size != @size
    res
  end

  alias [] get
  alias []= set

end

#-inject gen_module_header 'IEI::DataSuiteEx::Variables'
class IEI::DataSuiteEx::Variables < IEI::DataSuiteEx::Base

  def initialize
    super 5000
  end

  def _default
    0
  end

  def convert_key obj
    obj.to_i
  end

  def convert_value obj
    obj.to_i
  end

end

#-inject gen_module_header 'IEI::DataSuiteEx::Switches'
class IEI::DataSuiteEx::Switches < IEI::DataSuiteEx::Base

  def initialize
    super 5000
  end

  def _default
    0
  end

  def convert_key obj
    obj.to_i
  end

  def convert_value obj
    !!obj
  end

end

#-inject gen_module_header 'IEI::DataSuiteEx::SelfSwitches'
class IEI::DataSuiteEx::SelfSwitches < IEI::DataSuiteEx::Base

  def initialize
    super do Hash.new end
  end

  def convert_key obj
    obj.to_s.downcase
  end

  def convert_value obj
    !!obj
  end

end

#-inject gen_module_header 'IEI::DataSuiteEx::MetaData'
class IEI::DataSuiteEx::MetaData < IEI::DataSuiteEx::Base

  def initialize
    super do Hash.new end
  end

  def convert_key obj
    obj.to_s
  end

  def convert_value obj
    obj.to_s
  end

end
#-inject gen_script_footer

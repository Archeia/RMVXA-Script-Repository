#encoding:UTF-8
# ISS008 - AudioRef
module ISS
  module MixIns::ISS008 ; end
  module AudioRef

    SES = { }
    SES["Climb"] = RPG::SE.new("INT-Jump002", 80, 100)
    SES["Door1"] = RPG::SE.new("MEC-Servo004", 80, 100)
    SES["Jump1"] = RPG::SE.new("INT-Jump002", 80, 90)
    SES["Trans"] = RPG::SE.new("XINFX-Interface0D007", 80, 100)

    SES["Chest1"]= RPG::SE.new("INT-Chest003", 80, 100)

    module_function

    def play_transfer(type, params=[])
      case type
      when :door
        case params[0]
        when 1
          SES["Door1"].play
        end
      when :stairs, :floor
      when :normal
        SES["Trans"].play
      when :climb
        SES["Climb"].play
      else ; print sprintf("%s transfer given but doesn't exixt", type.to_s)
      end
    end

    def play_jump(type)
      case type
      when 1
        SES["Jump1"].play
      else ; print sprintf("%s jump given but doesn't exixt", type.to_s)
      end
    end

    def play_chest(type)
      case type
      when :normal
        SES["Chest1"].play
      else ; print sprintf("%s chest given but doesn't exixt", type.to_s)
      end
    end

  end

end

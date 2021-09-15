# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IEK (https://github.com/IceDragon200/IEK)
# Eval Note
#   by IceDragon (https://github.com/IceDragon200)
# Description
#   --
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
$simport.r 'eval_note', '1.0.0', 'Use eval blocks in your note boxes'

module EvalNote
  def exec(str)
    eval(str)
  end

  def parse_eval_note()
  end
end

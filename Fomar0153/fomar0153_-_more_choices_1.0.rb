=begin
More Choices
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Allows you to have more than four choices
----------------------
Instructions
----------------------
Edit the method more_choice and then use the call in 
a choice option.
----------------------
Known bugs
----------------------
None
=end
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● Edit Here
  # when handle
  #   $game_message.choices.push("a choice")
  #--------------------------------------------------------------------------
  def more_choice(p)
    case p
    when "Pizza Topping"
      $game_message.choices.push("Ham & Pineapple")
      $game_message.choices.push("Meat Feast")
      $game_message.choices.push("Chocolate")
      $game_message.choices.push("BBQ")
      $game_message.choices.push("Diamonds")
      $game_message.choices.push("Spicy Chicken")
      $game_message.choices.push("Garlic")
    else
      $game_message.choices.push(p)
    end
  end
  #--------------------------------------------------------------------------
  # ● Long Choices - Don't edit this bit
  #--------------------------------------------------------------------------
  def setup_choices(params)
    for s in params[0]
      more_choice(s)
    end
    $game_message.choice_cancel_type = params[1]
    $game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end
end

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # ● Feel free to change the 1 to another variable that you'd prefer
  #--------------------------------------------------------------------------
  alias mc_call_ok_handler call_ok_handler
  def call_ok_handler
    $game_variables[1] = index
    mc_call_ok_handler
  end
end
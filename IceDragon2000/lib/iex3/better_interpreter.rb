class Game_Interpreter
  def command_355
    script = @list[@index].parameters[0] + "\n"
    loop do
      if @list[@index+1].code == 655        # Second line of script and after
        script += @list[@index+1].parameters[0] + "\n"
      else
        break
      end
      @index += 1
    end
    eval(script, self.send(:binding), "#{self.class}/script", @index)
  end
end

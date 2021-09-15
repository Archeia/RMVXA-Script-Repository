module RPG
  constants.to_a.each { |c| remove_const(c) }
end
Object.send(:remove_const, :RPG)

#
# EDOS/src/REI/legacy.rb
# vr 1.0.0

# REI's legacy scripts from Version 1.x.x
#   Will be depreceated once V 2.0.0 is ready
__END__
dir = File.dirname(__FILE__)
Dir.glob(File.join(dir, "legacy", "*.rb")).sort.each do |fn|
  require fn
end

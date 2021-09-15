class Scene_Base
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    start                         # Start processing
    perform_transition            # Perform transition
    post_start                    # Post-start processing
    Input.update                  # Update input information
    loop do
      Graphics.update             # Update game screen
      Input.update                # Update input information
      update                      # Update frame
      break if $scene != self     # When screen is switched, interrupt loop
    end
    Graphics.update
    pre_terminate                 # Pre-termination processing
    Graphics.freeze               # Prepare transition
    terminate                     # Termination processing
    lingering = [] +
                ObjectSpace.each_object(Bitmap).to_a +
                ObjectSpace.each_object(Plane).to_a +
                ObjectSpace.each_object(Sprite).to_a +
                ObjectSpace.each_object(Tilemap).to_a +
                ObjectSpace.each_object(Viewport).to_a +
                ObjectSpace.each_object(Window).to_a +
                []
    lingering.reject! { |o| o.is_a?(Cache::CacheBitmap) || o.disposed? }
    STDERR.puts "Lingering from #{self.class}"
    STDERR.puts lingering
  end
end

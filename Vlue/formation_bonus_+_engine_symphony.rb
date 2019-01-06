##FORMATION BONUS + YAMI ENGINE SYMPHONY PATCH (Script order: Formation Bonus, Engine Symphony, Patch)
class Game_Actor
  def set_default_position
    super
    return if @origin_x && @origin_y
    return unless $game_party.battle_members.include?(self)
    @origin_x = @screen_x = @destination_x = FORMATION_LOCATIONS[@formation_slot][0]
    @origin_y = @screen_y = @destination_y = FORMATION_LOCATIONS[@formation_slot][1]
    return unless emptyview?
    @origin_x = @screen_x = @destination_x = self.screen_x
    @origin_y = @screen_y = @destination_y = self.screen_y
  end
  def correct_origin_position
    return if @origin_x && @origin_y
    @origin_x = @screen_x = FORMATION_LOCATIONS[@formation_slot][0]
    @origin_y = @screen_y = FORMATION_LOCATIONS[@formation_slot][1]
    return unless emptyview?
    @origin_x = @screen_x = @destination_x = self.screen_x
    @origin_y = @screen_y = @destination_y = self.screen_y
  end
end
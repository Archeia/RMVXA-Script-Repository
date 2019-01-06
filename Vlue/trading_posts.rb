#--# Trading Posts v1.1b
#
# Allow shops to use a random price range (defined in item notetags) to buy and
#   sell certain items for different prices.
#
# Usage: Customize and set up note tags as needed.
#
#   Item Notetags:
#     <LOCATION# min-max>
#       # is the number of the trade post (between 1 and MAX_TRADE_POSTS)
#       min is the lowest price that tradepost will sell for
#       max is the highest price that tradepost will sell for
#    Example: <LOCATION1 500-6000>
#     Include a tag for every trade post, even if it doesn't sell it, it needs
#      to know how much ot buy it for!
#
#    Set up trade posts like you would Shops, adding tradepost items as regular price
#     Their prices will be fixed when the shop starts.
#
#   Script Calls:
#    $trade_location = #   - where # is the id of the trade post when Shop is used
#    Trade_Values.reset_values   - call this to randomize all trade values again
#
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
#--Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#Maximum Number of Trade Posts
MAX_TRADE_POSTS = 2
#Buyback price of trade goods, percent
BUYBACK_PRICE = 0.9
 
$trade_location = 0
class RPG::BaseItem
  def trade_value_range(location)
    self.note =~ /<LOCATION#{location} (\d+)-(\d+)>/
    return false unless $~
    return [$1.to_i,$2.to_i]
  end
end
 
module Trade_Values
  def self.start
    reset_values
  end
  def self.reset_values
    @locations = [0]
    MAX_TRADE_POSTS.times do |i|
      value_array = [{},{},{}]
      container = [$data_items,$data_weapons,$data_armors]
      3.times do |ii|
        container[ii].each do |item|
          next if item.nil?
          if item.trade_value_range(i+1)
            range = item.trade_value_range(i+1)
            value_array[ii][item.id] = rand(range[1]-range[0])+range[0]
          end
        end
      end
      @locations.push(value_array)
    end
  end
  def self.get_location(location)
    self.start if @locations.nil?
    @locations[location]
  end
end
 
class Scene_Shop
  def prepare(goods, purchase_only)
    @goods = goods
    @trade_values = []
    if $trade_location > 0
      @trade_values = Trade_Values.get_location($trade_location)
      @goods.each do |good|
        if @trade_values[good[0]][good[1]]
          good[2] = true
          good[3] = @trade_values[good[0]][good[1]]
        end
      end
    end
    @purchase_only = purchase_only
  end
  def selling_price
    type = 0 if @item.is_a?(RPG::Item)
    type = 1 if @item.is_a?(RPG::Weapon)
    type = 2 if @item.is_a?(RPG::Armor)
    if @trade_values[type][@item.id]
      return (@trade_values[type][@item.id] * BUYBACK_PRICE).to_i
    else
      @item.price / 2
    end
  end
end
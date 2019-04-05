class Player
  attr_accessor :money
  attr_accessor :name
  attr_accessor :properties
  attr_accessor :tile

  def initialize(money: 0, name:, tile:)
    @money = money
    @name = name
    @properties = []
    @tile = tile
  end

  def update_property_button_coordinates(x, y, offset)
    properties.each do |property|
      property.button.update_coordinates(x, y)
      y += offset
    end
  end
end

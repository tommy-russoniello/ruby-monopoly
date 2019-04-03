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
end

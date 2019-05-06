class TileGroup
  attr_accessor :name
  attr_reader :tiles

  def initialize(name:)
    @name = name
    @tiles = []
  end

  def amount_owned(player)
    return 0 if player.nil?

    @tiles.count { |tile| tile.owner == player }
  end

  def monopolized?
    owners = @tiles.map(&:owner)
    owner = owners.pop

    return false if owner.nil?

    owners.all? { |tile_owner| tile_owner == owner }
  end
end

class ColorGroup < TileGroup
  attr_accessor :color
  attr_accessor :house_cost

  def initialize(color:, house_cost:, name:)
    @color = color
    @house_cost = house_cost
    @name = name
    @tiles = []
  end
end

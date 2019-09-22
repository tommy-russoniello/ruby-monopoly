class TileGroup
  attr_accessor :name
  attr_reader :tiles

  def initialize(name:)
    self.name = name
    self.tiles = []
  end

  def amount_owned(player)
    return 0 if player.nil?

    tiles.count { |tile| tile.owner == player }
  end

  def monopolized?
    owners = tiles.map(&:owner)
    owner = owners.pop

    return false if owner.nil?

    owners.all? { |tile_owner| tile_owner == owner }
  end
end

class ColorGroup < TileGroup
  attr_accessor :color
  attr_accessor :house_cost

  def initialize(color:, house_cost:, name:)
    self.color = color
    self.house_cost = house_cost
    self.name = name
    self.tiles = []
  end
end

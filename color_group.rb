class ColorGroup
  attr_accessor :color
  attr_accessor :house_cost
  attr_accessor :name
  attr_reader :street_tiles

  def initialize(color:, house_cost:, name:)
    @color = color
    @house_cost = house_cost
    @name = name
    @street_tiles = []
  end

  def monopolized?
    street_tile_owners = @street_tiles.map(&:owner)
    return false unless street_tile_owners.size == street_tile_owners.compact.size

    owner = street_tile_owners.pop
    street_tile_owners.all? { |street_tile_owner| street_tile_owner == owner }
  end
end

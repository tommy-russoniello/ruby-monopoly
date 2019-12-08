module Monopoly
  class TileGroup
    attr_accessor :image
    attr_accessor :name
    attr_accessor :tiles

    def initialize(image:, name:)
      self.image = image
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

    def initialize(color:, house_cost:, image:, name:)
      super(image: image, name: name)

      self.color = color
      self.house_cost = house_cost
    end
  end
end

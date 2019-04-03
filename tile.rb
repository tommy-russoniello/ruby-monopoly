class Tile
  attr_accessor :name
  attr_accessor :tile_image

  def initialize(name:, tile_image:)
    @name = name
    @tile_image = tile_image
  end
end

class CardTile < Tile
end

class FreeParkingTile < Tile
end

class GoTile < Tile
end

class GoToJailTile < Tile
end

class JailTile < Tile
end

class PropertyTile < Tile
  attr_accessor :deed_image
  attr_accessor :house_count
  # attr_accessor :name
  attr_accessor :owner
  attr_accessor :purchase_price
  attr_accessor :rent_scale
  # attr_accessor :tile_image

  def initialize(
    deed_image: nil,
    house_count: 0,
    mortgaged: false,
    name:,
    owner: nil,
    purchase_price: nil,
    rent_scale: [],
    tile_image: nil
  )
    @deed_image = deed_image
    @house_count = house_count
    @mortgaged = mortgaged
    @name = name
    @owner = owner
    @purchase_price = purchase_price
    @rent_scale = rent_scale
    @tile_image = tile_image
  end

  def mortgaged?
    @mortgage
  end

  def rent
    rent_scale[house_count]
  end
end

class RailroadTile < Tile
end

class TaxTile < Tile
end

class UtilityTile < Tile
end

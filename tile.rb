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
  MORTGAGE_INTEREST = 0
  MORTGAGE_PERCENTAGE = 0.5

  attr_accessor :button
  attr_accessor :deed_image
  attr_accessor :mortgaged
  attr_accessor :owner
  attr_accessor :purchase_price

  def initialize(
    button: nil,
    deed_image: nil,
    mortgaged: false,
    name:,
    owner: nil,
    purchase_price:,
    tile_image: nil
  )
    @button = button
    @deed_image = deed_image
    @mortgaged = mortgaged
    @name = name
    @owner = owner
    @purchase_price = purchase_price
    @tile_image = tile_image
  end

  def mortgage_cost
    (purchase_price * PropertyTile::MORTGAGE_PERCENTAGE).to_i
  end

  def mortgaged?
    @mortgaged
  end

  def rent
    rent_scale[house_count]
  end

  def unmortgage_cost
    (mortgage_cost + (mortgage_cost * PropertyTile::MORTGAGE_INTEREST)).to_i
  end
end

class StreetTile < PropertyTile
  attr_accessor :house_count
  attr_accessor :rent_scale

  def initialize(
    button: nil,
    deed_image: nil,
    house_count: 0,
    mortgaged: false,
    name:,
    owner: nil,
    purchase_price: nil,
    rent_scale: [],
    tile_image: nil
  )
    super(
      button: button,
      deed_image: deed_image,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image
    )

    @house_count = house_count
    @rent_scale = rent_scale
  end

  def rent
    rent_scale[house_count]
  end
end

class RailroadTile < PropertyTile
  attr_accessor :rent_scale

  def initialize(
    button: nil,
    deed_image: nil,
    mortgaged: false,
    name:,
    owner: nil,
    purchase_price: nil,
    rent_scale: [],
    tile_image: nil
  )
    super(
      button: button,
      deed_image: deed_image,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image
    )

    @rent_scale = rent_scale
  end

  def rent(railroad_count)
    rent_scale[railroad_count]
  end
end

class TaxTile < Tile
end

class UtilityTile < PropertyTile
  attr_accessor :rent_multiplier_scale

  def initialize(
    button: nil,
    deed_image: nil,
    mortgaged: false,
    name:,
    owner: nil,
    purchase_price: nil,
    rent_multiplier_scale: [],
    tile_image: nil
  )
    super(
      button: button,
      deed_image: deed_image,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image
    )

    @rent_multiplier_scale = rent_multiplier_scale
  end

  def rent(utility_count, dice_roll)
    rent_multiplier_scale[utility_count] * dice_roll
  end
end

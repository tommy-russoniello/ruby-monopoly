class Tile
  attr_accessor :name
  attr_accessor :tile_image

  def initialize(name:, tile_image:)
    self.name = name
    self.tile_image = tile_image
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
  attr_accessor :group
  attr_accessor :mortgaged
  attr_accessor :owner
  attr_accessor :purchase_price

  def initialize(
    button: nil,
    deed_image: nil,
    group: nil,
    mortgaged: false,
    name:,
    owner: nil,
    purchase_price:,
    tile_image: nil
  )
    self.button = button
    self.deed_image = deed_image
    self.group = group
    self.mortgaged = mortgaged
    self.name = name
    self.owner = owner
    self.purchase_price = purchase_price
    self.tile_image = tile_image

    group.tiles << self
  end

  def mortgage_cost
    (purchase_price * PropertyTile::MORTGAGE_PERCENTAGE).to_i
  end

  def mortgaged?
    mortgaged
  end

  def rent
    rent_scale[house_count]
  end

  def unmortgage_cost
    (mortgage_cost + (mortgage_cost * PropertyTile::MORTGAGE_INTEREST)).to_i
  end
end

class StreetTile < PropertyTile
  MONOPOLY_RENT_MULTIPLIER = 2

  attr_accessor :house_count
  attr_accessor :rent_scale

  def initialize(
    button: nil,
    group: nil,
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
      group: group,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image
    )

    self.house_count = house_count
    self.rent_scale = rent_scale
  end

  def rent
    if house_count == 0
      rent_scale[house_count] * (group.monopolized? ? MONOPOLY_RENT_MULTIPLIER : 1)
    else
      rent_scale[house_count]
    end
  end
end

class RailroadTile < PropertyTile
  attr_accessor :rent_scale

  def initialize(
    button: nil,
    deed_image: nil,
    group: nil,
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
      group: group,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image
    )

    self.rent_scale = rent_scale
  end

  def rent
    rent_scale[group.amount_owned(owner) - 1]
  end
end

class TaxTile < Tile
end

class UtilityTile < PropertyTile
  attr_accessor :dice_roll
  attr_accessor :rent_multiplier_scale

  def initialize(
    button: nil,
    deed_image: nil,
    group: nil,
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
      group: group,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image
    )

    self.rent_multiplier_scale = rent_multiplier_scale
  end

  def rent
    rent_multiplier_scale[group.amount_owned(owner) - 1] * dice_roll
  end
end

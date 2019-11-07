class Tile
  attr_accessor :name
  attr_accessor :tile_image

  def initialize(name:, tile_image:)
    self.name = name
    self.tile_image = tile_image
  end

  def corner?
    false
  end
end

class CardTile < Tile
  attr_accessor :card_type

  def initialize(card_type:, name:, tile_image:)
    super(name: name, tile_image: tile_image)

    self.card_type = card_type
  end
end

class FreeParkingTile < Tile
  def corner?
    true
  end
end

class GoTile < Tile
  def corner?
    true
  end
end

class GoToJailTile < Tile
  def corner?
    true
  end
end

class JailTile < Tile
  def corner?
    true
  end
end

class PropertyTile < Tile
  MORTGAGE_INTEREST = 0
  MORTGAGE_PERCENTAGE = 0.5
  RENT_MULTIPLIER = 1

  attr_accessor :button
  attr_accessor :deed_image
  attr_accessor :group
  attr_accessor :mortgaged
  attr_accessor :owner
  attr_accessor :purchase_price
  attr_accessor :window

  def initialize(
    button: nil,
    deed_image: nil,
    group: nil,
    mortgaged: false,
    name:,
    owner: nil,
    purchase_price:,
    tile_image: nil,
    window:
  )
    super(name: name, tile_image: tile_image)

    self.button = button
    self.deed_image = deed_image
    self.group = group
    self.mortgaged = mortgaged
    self.owner = owner
    self.purchase_price = purchase_price
    self.window = window

    group.tiles << self
  end

  def mortgage_cost
    (purchase_price * PropertyTile::MORTGAGE_PERCENTAGE).to_i
  end

  def mortgaged?
    mortgaged
  end

  def rent
    _rent * RENT_MULTIPLIER * (window.temporary_rent_multiplier || 1)
  end

  def unmortgage_cost
    (mortgage_cost + (mortgage_cost * PropertyTile::MORTGAGE_INTEREST)).to_i
  end

  private

  def _rent
    rent_scale[house_count]
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
    tile_image: nil,
    window:
  )
    super(
      button: button,
      deed_image: deed_image,
      group: group,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image,
      window: window
    )

    self.house_count = house_count
    self.rent_scale = rent_scale
  end

  private

  def _rent
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
    tile_image: nil,
    window:
  )
    super(
      button: button,
      deed_image: deed_image,
      group: group,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image,
      window: window
    )

    self.rent_scale = rent_scale
  end

  private

  def _rent
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
    tile_image: nil,
    window:
  )
    super(
      button: button,
      deed_image: deed_image,
      group: group,
      mortgaged: mortgaged,
      name: name,
      owner: owner,
      purchase_price: purchase_price,
      tile_image: tile_image,
      window: window
    )

    self.rent_multiplier_scale = rent_multiplier_scale
  end

  def rent
    if window.temporary_rent_multiplier
      dice_roll * RENT_MULTIPLIER * window.temporary_rent_multiplier
    else
      super
    end
  end

  private

  def _rent
    rent_multiplier_scale[group.amount_owned(owner) - 1] * dice_roll
  end
end

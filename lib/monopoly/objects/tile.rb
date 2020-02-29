module Monopoly
  class Tile
    attr_accessor :icon
    attr_accessor :name
    attr_accessor :tile_image

    def initialize(icon: nil, name:, tile_image:)
      self.icon = icon
      self.name = name
      self.tile_image = tile_image
    end

    def corner?
      false
    end
  end

  class CardTile < Tile
    attr_accessor :card_type

    def initialize(card_type:, icon: nil, name:, tile_image:)
      super(icon: icon, name: name, tile_image: tile_image)

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

    attr_accessor :deed_image
    attr_accessor :game
    attr_accessor :group
    attr_accessor :mortgaged
    attr_accessor :owner
    attr_accessor :purchase_price

    def initialize(
      deed_image: nil,
      game:,
      group: nil,
      icon: nil,
      mortgaged: false,
      name:,
      owner: nil,
      purchase_price:,
      tile_image: nil
    )
      super(icon: icon, name: name, tile_image: tile_image)

      self.deed_image = deed_image
      self.game = game
      self.group = group
      self.mortgaged = mortgaged
      self.owner = owner
      self.purchase_price = purchase_price

      group.tiles << self
    end

    def mortgage_cost
      (purchase_price * PropertyTile::MORTGAGE_PERCENTAGE).to_i
    end

    def mortgaged?
      mortgaged
    end

    def rent
      _rent * RENT_MULTIPLIER * (game.temporary_rent_multiplier || 1)
    end

    def unmortgage_cost
      (mortgage_cost + (mortgage_cost * PropertyTile::MORTGAGE_INTEREST)).to_i
    end

    private

    def _rent
      0
    end
  end

  class StreetTile < PropertyTile
    MONOPOLY_RENT_MULTIPLIER = 2

    attr_accessor :house_count
    attr_accessor :rent_scale

    def initialize(
      deed_image: nil,
      game:,
      group: nil,
      house_count: 0,
      icon: nil,
      mortgaged: false,
      name:,
      owner: nil,
      purchase_price: nil,
      rent_scale: [],
      tile_image: nil
    )
      super(
        deed_image: deed_image,
        game: game,
        group: group,
        icon: icon,
        mortgaged: mortgaged,
        name: name,
        owner: owner,
        purchase_price: purchase_price,
        tile_image: tile_image
      )

      self.house_count = house_count
      self.rent_scale = rent_scale
    end

    def base_rent_with_color_group
      rent_scale.first * MONOPOLY_RENT_MULTIPLIER
    end

    def rent_with_houses(houses)
      rent_scale[houses]
    end

    private

    def _rent
      if house_count == 0 && group.monopolized?
        base_rent_with_color_group
      else
        rent_with_houses(house_count)
      end
    end
  end

  class RailroadTile < PropertyTile
    attr_accessor :rent_scale

    def initialize(
      deed_image: nil,
      game:,
      group: nil,
      icon: nil,
      mortgaged: false,
      name:,
      owner: nil,
      purchase_price: nil,
      rent_scale: [],
      tile_image: nil
    )
      super(
        deed_image: deed_image,
        game: game,
        group: group,
        icon: icon,
        mortgaged: mortgaged,
        name: name,
        owner: owner,
        purchase_price: purchase_price,
        tile_image: tile_image
      )

      self.rent_scale = rent_scale
    end

    def rent_with_railroads(railroads)
      rent_scale[railroads - 1]
    end

    private

    def _rent
      rent_with_railroads(group.amount_owned(owner))
    end
  end

  class TaxTile < Tile
    attr_accessor :tax_amount

    def initialize(name:, icon: nil, tax_amount:, tile_image:)
      super(icon: icon, name: name, tile_image: tile_image)

      self.tax_amount = tax_amount
    end
  end

  class UtilityTile < PropertyTile
    attr_accessor :dice_roll
    attr_accessor :rent_multiplier_scale

    def initialize(
      deed_image: nil,
      game:,
      group: nil,
      icon: nil,
      mortgaged: false,
      name:,
      owner: nil,
      purchase_price: nil,
      rent_multiplier_scale: [],
      tile_image: nil
    )
      super(
        deed_image: deed_image,
        game: game,
        group: group,
        icon: icon,
        mortgaged: mortgaged,
        name: name,
        owner: owner,
        purchase_price: purchase_price,
        tile_image: tile_image
      )

      self.rent_multiplier_scale = rent_multiplier_scale
    end

    def rent
      if game.temporary_rent_multiplier
        dice_roll * RENT_MULTIPLIER * game.temporary_rent_multiplier
      else
        super
      end
    end

    private

    def _rent
      rent_multiplier_scale[group.amount_owned(owner) - 1] * dice_roll
    end
  end
end

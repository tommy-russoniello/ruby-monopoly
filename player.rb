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

  def has_assets_for?(amount)
    amount < total_asset_liquidation_amount
  end

  def total_asset_liquidation_amount
    total_mortgage = properties.inject(0) do |sum, property|
      property.mortgaged? ? sum : sum + property.mortgage_cost
    end

    # TODO: total value for selling houses

    money + total_mortgage
  end

  def update_property_button_coordinates(x, y, offset)
    properties.each do |property|
      property.button.update_coordinates(x, y)
      y += offset
    end
  end
end

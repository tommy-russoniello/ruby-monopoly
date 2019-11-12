class Player
  attr_accessor :cards
  attr_accessor :jail_turns
  attr_accessor :money
  attr_accessor :name
  attr_accessor :number
  attr_accessor :properties
  attr_accessor :tile
  attr_accessor :window

  def initialize(jail_turns: 0, money: 0, name:, number:, tile:, window:)
    self.cards = []
    self.jail_turns = jail_turns
    self.money = money
    self.name = name
    self.number = number
    self.properties = []
    self.tile = tile
    self.window = window
  end

  def has_assets_for?(amount)
    amount < total_asset_liquidation_amount
  end

  def in_jail?
    jail_turns.positive?
  end

  def total_asset_liquidation_amount
    money + properties.inject(0) do |sum, property|
      sum += property.mortgage_cost unless property.mortgaged?
      if property.is_a?(StreetTile)
        house_worth = (property.group.house_cost * window.class::BUILDING_SELL_PERCENTAGE).to_i
        sum += property.house_count * house_worth
      end

      sum
    end
  end

  def update_property_button_coordinates(x, y, offset)
    properties.sort_by! { |property| window.tile_indexes[property] }

    properties.each do |property|
      property.button.update_coordinates(x, y)
      y += offset
    end
  end
end

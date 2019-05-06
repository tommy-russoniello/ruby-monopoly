class Player
  attr_accessor :money
  attr_accessor :name
  attr_accessor :properties
  attr_accessor :tile
  attr_accessor :window

  def initialize(money: 0, name:, tile:, window:)
    @money = money
    @name = name
    @properties = []
    @tile = tile
    @window = window
  end

  def has_assets_for?(amount)
    amount < total_asset_liquidation_amount
  end

  def total_asset_liquidation_amount
    building_sell_percentage = window.instance_variable_get(:@building_sell_percentage)
    money + properties.inject(0) do |sum, property|
      sum += property.mortgage_cost unless property.mortgaged?
      if property.is_a?(StreetTile)
        sum +=
          (property.house_count * (property.group.house_cost * building_sell_percentage)).to_i
      end

      sum
    end
  end

  def update_property_button_coordinates(x, y, offset)
    tile_indexes = window.instance_variable_get(:@tile_indexes)
    properties.sort! { |a, b| tile_indexes[a] <=> tile_indexes[b] }

    properties.each do |property|
      property.button.update_coordinates(x, y)
      y += offset
    end
  end
end

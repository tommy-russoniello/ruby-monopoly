module Monopoly
  class Player
    attr_accessor :cards
    attr_accessor :eliminated
    attr_accessor :game
    attr_accessor :jail_turns
    attr_accessor :money
    attr_accessor :name
    attr_accessor :number
    attr_accessor :properties
    attr_accessor :stats
    attr_accessor :tile
    attr_accessor :token_image

    def initialize(game:, jail_turns: 0, money: 0, name:, number:, tile:, token_image:)
      self.cards = []
      self.game = game
      self.jail_turns = jail_turns
      self.money = money
      self.name = name
      self.number = number
      self.properties = []
      self.stats = {
        money_gained: {
          buildings: 0,
          game: money,
          mortgages: 0,
          rent: 0,
          trades: 0
        },
        money_lost: {
          buildings: 0,
          game: 0,
          mortgages: 0,
          properties: 0,
          rent: 0,
          trades: 0
        },
        time_played: 0,
        times_passed_go: 0,
        turns_in_jail: 0
      }
      self.tile = tile
      self.token_image = token_image
    end

    def add_money(amount, reason)
      self.money += amount
      stats[:money_gained][reason] += amount
    end

    def eliminated?
      eliminated
    end

    def has_assets_for?(amount)
      amount < total_asset_liquidation_amount
    end

    def in_jail?
      jail_turns.positive?
    end

    def liquidate_assets
      properties.each do |property|
        if property.is_a?(StreetTile)
          house_worth = (property.group.house_cost * game.building_sell_percentage).to_i
          add_money(property.house_count * house_worth, :buildings)
          property.house_count = 0
        end

        add_money(property.mortgage_cost, :mortgages) unless property.mortgaged?
      end
    end

    def subtract_money(amount, reason)
      self.money -= amount
      stats[:money_lost][reason] += amount
    end

    def total_asset_liquidation_amount
      money + properties.inject(0) do |sum, property|
        sum += property.mortgage_cost unless property.mortgaged?
        if property.is_a?(StreetTile)
          house_worth = (property.group.house_cost * game.building_sell_percentage).to_i
          sum += property.house_count * house_worth
        end

        sum
      end
    end
  end
end

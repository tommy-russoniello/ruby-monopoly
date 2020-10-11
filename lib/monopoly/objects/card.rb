module Monopoly
  class Card
    attr_accessor :game
    attr_accessor :image
    attr_accessor :player
    attr_accessor :triggered
    attr_accessor :type

    def initialize(game:, image:, player: nil, type:)
      self.game = game
      self.image = image
      self.player = player
      self.triggered = false
      self.type = type
    end

    def clear_transient_attributes
      self.player = nil
      self.triggered = false
    end

    def continue_button_text
      'Continue'
    end

    def keepable?
      false
    end
  end

  class MoneyCard < Card
    attr_accessor :amount
    attr_accessor :every_other_player

    def initialize(amount:, game:, image:, every_other_player: false, player: nil, type:)
      super(game: game, image: image, type: type, player: player)

      self.amount = amount
      self.every_other_player = every_other_player
    end

    def continue_button_text
      if every_other_player
        if amount.negative?
          "Pay #{game.format_money(-amount)} To Every Player"
        else
          "Collect #{game.format_money(amount)} From Every Player"
        end
      else
        if amount.negative?
          "Pay #{game.format_money(-amount)}"
        else
          "Collect #{game.format_money(amount)}"
        end
      end
    end

    def perform_action
      if every_other_player
        charges =
          if amount.negative?
            (game.players - [player]).map do |other_player|
              {
                amount: -amount,
                player: player,
                recipient: other_player
              }
            end
          else
            (game.players - [player]).map do |other_player|
              {
                amount: amount,
                player: other_player,
                recipient: player
              }
            end
          end

        game.process_consecutive_charges(
          charges,
          actions: :return_new_card,
          on_current_player_eliminated: [[:return_new_card, actions: :end_turn, next_action: nil]],
          reason: :game
        )
      else
        if amount.negative?
          game.charge_money(
            amount: -amount,
            on_bankrupt: [[:return_new_card, actions: :end_turn, next_action: nil]],
            on_failure: proc do
              game.current_card.triggered = false
              game.set_visible_card_menu_buttons
            end,
            on_success: :return_new_card,
            player: player,
            reason: :game
          )
        else
          game.log_event("#{player.name} collected #{game.format_money(amount)}.")
          player.add_money(amount, :game)
          game.return_new_card
        end
      end
    end
  end

  class MoveCard < Card
    attr_accessor :go_money
    attr_accessor :move_value
    attr_accessor :rent_multiplier

    def initialize(
      game:, image:, go_money: true, move_value:, player: nil, rent_multiplier: nil, type:
    )
      super(game: game, image: image, type: type, player: player)

      self.go_money = go_money
      self.move_value = move_value
      self.rent_multiplier = rent_multiplier
    end

    def continue_button_text
      spaces = move_spaces
      if spaces.negative?
        "Move Back #{-spaces} Spaces"
      else
        "Move Forward #{spaces} Spaces"
      end
    end

    def move_spaces
      if move_value.is_a?(Integer)
        move_value
      elsif move_value.is_a?(Class) && move_value < Tile
        next_tile_index = (game.tile_indexes[game.current_tile] + 1) % game.tile_count
        indexes = (next_tile_index...game.tile_count).to_a + (0...next_tile_index).to_a
        new_index = indexes.find { |index| game.tiles[index].is_a?(move_value) }
        (new_index - game.tile_indexes[player.tile]) % game.tile_count
      elsif move_value.is_a?(Tile)
        (game.tile_indexes[move_value] - game.tile_indexes[player.tile]) % game.tile_count
      else
        pp('WARNING: INVALID MOVE VALUE')
        0
      end
    end

    def perform_action
      spaces = move_spaces
      game.move(spaces: spaces, player: player)
      event =
        if spaces.negative?
          "#{player.name} moved back #{-spaces} spaces to #{player.tile.name}."
        else
          "#{player.name} advanced #{spaces} spaces to #{player.tile.name}."
        end

      game.log_event(event)
      multiply_rent = rent_multiplier && player.tile.owner && player.tile.owner != player &&
        !player.tile.mortgaged? && player.tile.is_a?(PropertyTile)
      if multiply_rent
        game.temporary_rent_multiplier = rent_multiplier
        if player.tile.is_a?(UtilityTile)
          return game.return_new_card(
            next_action: [:roll_dice_for_rent, message: 'Roll Dice To Determine Rent']
          )
        end
      end

      game.return_new_card(actions: :land, next_action: nil)
    end
  end

  class GetOutOfJailFreeCard < Card
    def continue_button_text
      'Take Card'
    end

    def keepable?
      true
    end

    def perform_action
      player.jail_turns = 0
      game.log_event("#{player.name} used a Get Out Of Jail Free Card to get out of jail.")
    end
  end

  class GoToJailCard < Card
    def continue_button_text
      'Go To Jail'
    end

    def perform_action
      game.return_new_card(actions: :go_to_jail, next_action: nil)
    end
  end

  class PropertyRepairCard < Card
    attr_accessor :cost_per_house

    def initialize(game:, image:, cost_per_house:, player: nil, type:)
      super(game: game, image: image, type: type, player: player)

      self.cost_per_house = cost_per_house
    end

    def clear_transient_attributes
      @total_cost = nil
      super
    end

    def continue_button_text
      "Pay #{game.format_money(total_cost)}"
    end

    def perform_action
      game.charge_money(
        amount: total_cost,
        on_bankrupt: [[:return_new_card, actions: :end_turn, next_action: nil]],
        on_failure: proc do
          game.current_card.triggered = false
          game.set_visible_card_menu_buttons
        end,
        on_success: :return_new_card,
        player: player,
        reason: :game
      )
    end

    def total_cost
      @total_cost ||= player.properties.inject(0) do |sum, property|
        cost = property.is_a?(StreetTile) ? property.house_count * cost_per_house : 0
        sum + cost
      end
    end
  end
end

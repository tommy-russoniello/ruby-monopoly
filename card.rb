class Card
  attr_accessor :image
  attr_accessor :player
  attr_accessor :type
  attr_accessor :window

  def initialize(image:, player: nil, type:, window:)
    self.image = image
    self.player = player
    self.type = type
    self.window = window
  end

  def clear_transient_attributes
    self.player = nil
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

  def initialize(amount:, image:, every_other_player: false, player: nil, type:, window:)
    super(image: image, type: type, player: player, window: window)

    self.amount = amount
    self.every_other_player = every_other_player
  end

  def continue_button_text
    if every_other_player
      if amount.negative?
        "Pay $#{window.format_number(-amount)} To Every Player"
      else
        "Collect $#{window.format_number(amount)} From Every Player"
      end
    else
      if amount.negative?
        "Pay $#{window.format_number(-amount)}"
      else
        "Collect $#{window.format_number(amount)}"
      end
    end
  end

  def perform_action
    if every_other_player
      charges =
        if amount.negative?
          (window.players - [player]).map do |other_player|
            {
              amount: -amount,
              player: player,
              recipient: other_player
            }
          end
        else
          (window.players - [player]).map do |other_player|
            {
              amount: amount,
              player: other_player,
              recipient: player
            }
          end
        end

      window.process_consecutive_charges(
        charges,
        actions: :return_new_card,
        on_current_player_eliminated:
          [[:return_new_card, actions: :end_turn, new_visible_buttons: nil]]
      )
    else
      if amount.negative?
        window.charge_money(
          amount: -amount,
          on_bankrupt: [[:return_new_card, actions: :end_turn, new_visible_buttons: nil]],
          on_success: :return_new_card,
          player: player
        )
      else
        player.money += amount
        window.return_new_card
      end
    end
  end
end

class MoveCard < Card
  attr_accessor :go_money
  attr_accessor :move_value
  attr_accessor :rent_multiplier

  def initialize(
    image:, go_money: true, move_value:, player: nil, rent_multiplier: nil, type:, window:
  )
    super(image: image, type: type, player: player, window: window)

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
      new_index = (0...window.tile_count).find { |index| window.tiles[index].is_a?(move_value) }
      (new_index - window.tile_indexes[player.tile]) % window.tile_count
    elsif move_value.is_a?(Tile)
      (window.tile_indexes[move_value] - window.tile_indexes[player.tile]) % window.tile_count
    else
      pp('WARNING: INVALID MOVE VALUE')
      0
    end
  end

  def perform_action
    spaces = move_spaces
    window.move(spaces: spaces, player: player)
    message =
      if spaces.negative?
        "#{player.name} moved back #{-spaces} spaces to #{player.tile.name}."
      else
        "#{player.name} advanced #{spaces} spaces to #{player.tile.name}."
      end

    window.add_message(message)
    multiply_rent = rent_multiplier && player.tile.owner && player.tile.owner != player &&
      !player.tile.mortgaged? && player.tile.is_a?(PropertyTile)
    if multiply_rent
      window.temporary_rent_multiplier = rent_multiplier
      return window.return_new_card(new_visible_buttons: :roll_dice_for_rent) if
        player.tile.is_a?(UtilityTile)
    end

    window.return_new_card(actions: :land, new_visible_buttons: nil)
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
    window.add_message("#{player.name} used a Get Out Of Jail Free Card to get out of jail.")
  end
end

class GoToJailCard < Card
  def continue_button_text
    'Go To Jail'
  end

  def perform_action
    window.return_new_card(actions: :go_to_jail, new_visible_buttons: nil)
  end
end

class PropertyRepairCard < Card
  attr_accessor :cost_per_house

  def initialize(image:, cost_per_house:, player: nil, type:, window:)
    super(image: image, type: type, player: player, window: window)

    self.cost_per_house = cost_per_house
  end

  def clear_transient_attributes
    @total_cost = nil
    super
  end

  def continue_button_text
    "Pay $#{window.format_number(total_cost)}"
  end

  def perform_action
    window.charge_money(
      amount: total_cost,
      on_bankrupt: :return_new_card,
      on_success: :return_new_card,
      player: player
    )
  end

  def total_cost
    @total_cost ||= player.properties.inject(0) do |sum, property|
      cost = property.is_a?(StreetTile) ? property.house_count * cost_per_house : 0
      sum + cost
    end
  end
end

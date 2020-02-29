module Monopoly
  class Game < Gosu::Window
    module GameActions
      def charge_money(
        amount:, on_bankrupt: nil, on_success: nil, player: current_player, recipient: nil
      )
        recipient_name = recipient&.name || 'the bank'

        if player.money < amount
          if player.has_assets_for?(amount)
            add_message(
              "#{current_player.name} cannot afford to pay #{recipient_name} " \
              "#{format_money(amount)} in cash but can afford it by liquidating " \
              "assets (selling houses and/or mortgaging properties)."
            )
          else
            add_message("#{player.name} does not have the cash or assets to pay #{recipient_name}.")
            total_asset_liquidation_amount = player.total_asset_liquidation_amount
            recipient.money += total_asset_liquidation_amount if recipient
            player.money = 0
            add_message(
              "#{player.name} liquidated their remaining assets and payed " \
              "#{format_money(total_asset_liquidation_amount)} to #{recipient_name}."
            )
            eliminate_player(player)
            execute_actions(format_actions(on_bankrupt)) if on_bankrupt
          end
        else
          recipient.money += amount if recipient
          player.money -= amount
          add_message("#{player.name} payed #{format_money(amount)} to #{recipient_name}.")
          execute_actions(format_actions(on_success)) if on_success
        end
      end

      def collect_go_money(times_passed_go, player: current_player)
        return unless times_passed_go > 0

        go_money_collected = go_money_amount * times_passed_go
        extra_string = " #{times_passed_go} times" if times_passed_go > 1
        add_message(
          "#{player.name} has gained #{format_money(go_money_collected)} for " \
          "passing Go#{extra_string}."
        )
        player.money += go_money_collected

        set_visible_player_menu_buttons
      end

      def eliminate_player(player = current_player)
        add_message(
          "#{player.name} is eliminated! All of #{player.name}'s properties " \
          "have been reclaimed by the bank."
        )
        player.properties.each do |property|
          property.owner = nil
          property.house_count = 0 if property.is_a?(StreetTile)
          property.mortgaged = false
        end

        player.properties = []
        player.cards.each do |card|
          card.clear_transient_attributes
          cards[card.type] << card
        end

        player.cards = []
        players.delete(player)
        if player == current_player
          self.current_player_index =
            current_player_index == 0 ? players.size - 1 : current_player_index - 1
        end
      end

      def increment_current_player
        self.current_player_index = (current_player_index + 1) % players.size
        self.current_player = players[current_player_index]
        self.current_tile = self.focused_tile = current_player.tile
        self.current_player_landed = false

        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons(refresh: true)
      end

      def land
        self.current_player_landed = true
        set_visible_tile_menu_buttons
        case current_tile
        when CardTile
          update_visible_buttons(:draw_card)
        when FreeParkingTile
          add_message('whoopdie doo, free parking')
          update_visible_buttons(:end_turn)
        when GoTile
          update_visible_buttons(:end_turn)
        when GoToJailTile
          update_visible_buttons(:go_to_jail)
        when JailTile
          update_visible_buttons(:end_turn)
        when PropertyTile
          if current_tile.owner
            if current_tile.owner == current_player
              update_visible_buttons(:end_turn)
            elsif current_tile.mortgaged?
              add_message(
                "No rent is due to #{current_tile.owner.name} as " \
                "#{current_tile.name} is currently mortgaged."
              )
              update_visible_buttons(:end_turn)
            else
              current_tile.dice_roll = die_a + die_b if current_tile.is_a?(UtilityTile)
              buttons[:pay_rent].text = "Pay Rent (#{format_money(current_tile.rent)})"
              update_visible_buttons(:pay_rent)
            end
          else
            update_visible_buttons(:end_turn)
          end
        when TaxTile
          buttons[:pay_tax].text = "Pay Tax (#{format_money(current_tile.tax_amount)})"
          update_visible_buttons(:pay_tax)
        else
          pp('WARNING: INVALID TILE TYPE')
        end
      end

      def move(spaces: die_a + die_b, collect: true, player: current_player)
        new_index = tile_indexes[current_tile] + spaces
        times_passed_go = new_index / tile_count
        new_tile = tiles[new_index % tile_count]
        self.current_tile = self.focused_tile = new_tile if player == current_player
        player.tile = new_tile
        collect_go_money(times_passed_go, player: player) if collect
        times_passed_go
      end

      def process_consecutive_charges(charges, actions: nil, on_current_player_eliminated: nil)
        cache_current_player
        process_consecutive_charges_helper(charges, actions, on_current_player_eliminated)
      end

      def return_new_card(actions: nil, new_visible_buttons: [])
        toggle_card_menu if drawing_card_menu?
        current_card.clear_transient_attributes
        cards[current_card.type] << current_card
        self.current_card = nil
        execute_actions(format_actions(actions)) if actions
        return unless new_visible_buttons

        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons
        new_visible_buttons = [:end_turn] if new_visible_buttons.empty?
        update_visible_buttons(*new_visible_buttons)
      end

      def roll_die
        SecureRandom.rand(6) + 1
      end

      def send_player_to_jail(player)
        add_message("#{player.name} has gone to jail!")
        player.tile = tiles[:jail]
        player.jail_turns = jail_time
      end

      private

      def process_consecutive_charge(charges, actions, on_current_player_eliminated)
        charge = charges.first
        charges_without_player =
          charges.reject { |later_charge| later_charge[:player] == charge[:player] }

        on_bankrupt = [
          [
            :process_consecutive_charges_helper,
            charges_without_player,
            actions,
            on_current_player_eliminated
          ]
        ]

        on_success = [
          [
            :process_consecutive_charges_helper,
            charges.drop(1),
            actions,
            on_current_player_eliminated
          ]
        ]

        charge_money(
          amount: charge[:amount],
          on_bankrupt: on_bankrupt,
          on_success: on_success,
          player: charge[:player],
          recipient: charge[:recipient]
        )
      end

      def process_consecutive_charges_helper(charges, actions, on_current_player_eliminated)
        if charges.empty?
          pop_current_player_cache
          if on_current_player_eliminated && !players.include?(current_player)
            execute_actions(format_actions(on_current_player_eliminated))
          elsif actions
            execute_actions(format_actions(actions))
          end

          return
        end

        charge = charges.first
        self.current_player = charge[:player]
        buttons[:consecutive_charge].text =
          "Pay #{format_money(charge[:amount])} to #{charge[:recipient].name}"
        buttons[:consecutive_charge].actions =
          [[:process_consecutive_charge, charges, actions, on_current_player_eliminated]]
        set_visible_player_menu_buttons
        update_visible_buttons(:consecutive_charge)
      end
    end
  end
end

module Monopoly
  class Game < Gosu::Window
    module GameActions
      def charge_money(
        amount:,
        on_bankrupt: nil,
        on_failure: nil,
        on_success: nil,
        player: current_player,
        reason:,
        recipient: nil
      )
        recipient_name = recipient&.name || 'the bank'

        if player.money < amount
          if player.has_assets_for?(amount)
            display_error(
              "You can't afford to pay #{recipient_name} #{format_money(amount)} " \
              'in cash but you can afford it by liquidating assets (selling houses ' \
              'and/or mortgaging properties).'
            )
            execute_actions(format_actions(on_failure)) if on_failure
          else
            display_error("You don't have the cash or assets to pay #{recipient_name}.")
            player.liquidate_assets
            remaining_money = player.money
            player.subtract_money(remaining_money, reason)
            recipient.add_money(remaining_money, reason) if recipient
            log_event(
              "#{player.name} liquidated their remaining assets and payed " \
              "#{format_money(remaining_money)} to #{recipient_name}."
            )
            eliminate_player(player)
            execute_actions(format_actions(on_bankrupt)) if on_bankrupt
          end
        else
          recipient.add_money(amount, reason) if recipient
          player.subtract_money(amount, reason)
          log_event("#{player.name} payed #{format_money(amount)} to #{recipient_name}.")
          execute_actions(format_actions(on_success)) if on_success
        end
      end

      def close_pop_up_menus
        toggle_deed_menu if drawing_deed_menu?
        toggle_event_history_menu if drawing_event_history_menu?
        group_menu.close if group_menu.drawing?
        toggle_player_inspector if drawing_player_inspector?
        player_list_menu.close if player_list_menu.drawing?
      end

      def collect_go_money(times_passed_go, player: current_player)
        return unless times_passed_go > 0

        go_money_collected = go_money_amount * times_passed_go
        extra_string = " #{times_passed_go} times" if times_passed_go > 1
        log_event(
          "#{player.name} gained #{format_money(go_money_collected)} for " \
          "passing Go#{extra_string}."
        )
        player.add_money(go_money_collected, :game)

        set_visible_player_menu_buttons
      end

      def eliminate_player(player = current_player)
        log_event(
          "#{player.name} is eliminated, and all of their properties are reclaimed by the bank."
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
        player.money = 0
        player.eliminated_on = turn
        eliminated_players << players.delete(player)
        if player == (current_player_cache || current_player)
          self.current_player_index =
            current_player_index == 0 ? players.size - 1 : current_player_index - 1
        else
          set_visible_player_menu_buttons(refresh: true)
        end

        map_menu.buttons[:tokens].delete(player)
      end

      def increment_current_player
        update_current_player_time_played

        self.current_player_index = (current_player_index + 1) % players.size
        self.current_player = players[current_player_index]
        self.current_tile = self.focused_tile = current_player.tile
        self.current_player_landed = false
        self.die_a = self.die_b = nil

        close_error_dialogue
        set_visible_compass_menu_buttons
        tile_menu.update
        set_visible_player_menu_buttons(refresh: true)
      end

      def land
        log_event("#{current_player.name} landed on #{current_tile.name}.") unless
          current_player_landed
        self.current_player_landed = true
        set_visible_compass_menu_buttons
        tile_menu.update
        case current_tile
        when CardTile
          set_next_action(:draw_card)
        when FreeParkingTile
          set_next_action(:end_turn)
        when GoTile
          set_next_action(:end_turn)
        when GoToJailTile
          set_next_action(:go_to_jail)
        when JailTile
          set_next_action(:end_turn)
        when PropertyTile
          if current_tile.owner
            if current_tile.owner == current_player || current_tile.mortgaged?
              set_next_action(:end_turn)
            else
              current_tile.dice_roll = die_a + die_b if current_tile.is_a?(UtilityTile)
              set_next_action(
                :pay_rent,
                message: "Rent Due: #{format_money(current_tile.rent)}",
                warning: true
              )
            end
          else
            set_next_action(:end_turn)
          end
        when TaxTile
          set_next_action(
            :pay_tax,
            message: "Tax Due: #{format_money(current_tile.tax_amount)}",
            warning: true
          )
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
        if collect
          player.stats[:times_passed_go] += times_passed_go
          collect_go_money(times_passed_go, player: player)
        end

        times_passed_go
      end

      def process_consecutive_charges(
        charges, actions: nil, on_current_player_eliminated: nil, reason:
      )
        cache_current_player
        process_consecutive_charges_helper(charges, actions, on_current_player_eliminated, reason)
      end

      def return_new_card(actions: nil, next_action: :end_turn)
        toggle_card_menu if drawing_card_menu?
        current_card.clear_transient_attributes
        cards[current_card.type] << current_card
        self.current_card = nil
        execute_actions(format_actions(actions)) if actions
        return unless next_action

        tile_menu.update
        set_visible_player_menu_buttons
        set_next_action(*next_action)
      end

      def roll_die
        SecureRandom.rand(6) + 1
      end

      def send_player_to_jail(player)
        log_event("#{player.name} went to jail.")
        player.tile = tiles[:jail]
        player.jail_turns = jail_time
      end

      private

      def process_consecutive_charge(charges, actions, on_current_player_eliminated, reason)
        charge = charges.first
        charges_without_player =
          charges.reject { |later_charge| later_charge[:player] == charge[:player] }

        on_bankrupt = [
          [
            :process_consecutive_charges_helper,
            charges_without_player,
            actions,
            on_current_player_eliminated,
            reason
          ]
        ]

        on_success = [
          [
            :process_consecutive_charges_helper,
            charges.drop(1),
            actions,
            on_current_player_eliminated,
            reason
          ]
        ]

        charge_money(
          amount: charge[:amount],
          on_bankrupt: on_bankrupt,
          on_success: on_success,
          player: charge[:player],
          reason: reason,
          recipient: charge[:recipient]
        )
      end

      def process_consecutive_charges_helper(charges, actions, on_current_player_eliminated, reason)
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
        action_menu.buttons[:consecutive_charge].actions =
          [[:process_consecutive_charge, charges, actions, on_current_player_eliminated, reason]]
        set_visible_player_menu_buttons
        set_next_action(
          :consecutive_charge,
          message: "Payment Due: #{format_money(charge[:amount])}",
          warning: true
        )
      end
    end
  end
end

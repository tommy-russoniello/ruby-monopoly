module Monopoly
  class Game < Gosu::Window
    include GameActions
    include PlayerActions
    include UserInterface

    BUILDING_SELL_PERCENTAGE = 0.5
    GO_MONEY_AMOUNT = 200
    JAIL_TIME = 3
    MAX_HOUSE_COUNT = 5
    RESOLUTION_HEIGHT = ENV['RESOLUTION_HEIGHT'].to_i
    RESOLUTION_WIDTH = ENV['RESOLUTION_WIDTH'].to_i

    attr_accessor :buttons
    attr_accessor :card_menu_buttons
    attr_accessor :cards
    attr_accessor :color_groups
    attr_accessor :colors
    attr_accessor :current_card
    attr_accessor :current_player
    attr_accessor :current_player_cache
    attr_accessor :current_player_index
    attr_accessor :current_tile
    attr_accessor :current_tile_cache
    attr_accessor :deed_menu_buttons
    attr_accessor :deed_name_text
    attr_accessor :dialogue_box_buttons
    attr_accessor :die_a
    attr_accessor :die_b
    attr_accessor :drawing_card_menu
    attr_accessor :drawing_deed_menu
    attr_accessor :drawing_dialogue_box
    attr_accessor :drawing_group_menu
    attr_accessor :drawing_options_menu
    attr_accessor :draw_mouse_x
    attr_accessor :draw_mouse_y
    attr_accessor :focused_tile
    attr_accessor :fonts
    attr_accessor :group_menu_alt_button_positions
    attr_accessor :group_menu_buttons
    attr_accessor :group_menu_tiles
    attr_accessor :messages
    attr_accessor :options_menu_buttons
    attr_accessor :options_menu_bar_paramaters
    attr_accessor :players
    attr_accessor :previous_player_number
    attr_accessor :property_button_color_cache
    attr_accessor :property_button_hover_color_cache
    attr_accessor :railroads_group
    attr_accessor :temporary_rent_multiplier
    attr_accessor :tile_count
    attr_accessor :tile_indexes
    attr_accessor :tile_menu_buttons
    attr_accessor :tiles
    attr_accessor :turn
    attr_accessor :utilities_group
    attr_accessor :visible_buttons_cache
    attr_accessor :visible_buttons
    attr_accessor :visible_card_menu_buttons
    attr_accessor :visible_deed_menu_buttons
    attr_accessor :visible_group_menu_buttons
    attr_accessor :visible_tile_menu_buttons

    def initialize
      super(RESOLUTION_WIDTH, RESOLUTION_HEIGHT, fullscreen: ARGV.include?('-f'))

      self.caption = 'Monopoly'

      monopoly_font = 'media/fonts/JosefinSans-Regular.ttf'
      self.fonts = {
        deed: { type: Gosu::Font.new(28, name: monopoly_font), offset: 35 },
        deed_name: { type: Gosu::Font.new(30, name: monopoly_font), offset: 35 },
        dialogue: { type: Gosu::Font.new(50), offset: 55 },
        default: { type: Gosu::Font.new(DEFAULT_FONT_SIZE), offset: 35 },
        house_count: { type: Gosu::Font.new(45), offset: 50 },
        title: { type: Gosu::Font.new(55), offset: 55 }
      }

      self.colors = {
        blur: Gosu::Color.new(200, 200, 200, 200),
        deed: Gosu::Color::WHITE,
        deed_accent: Gosu::Color::BLACK,
        default_button: Gosu::Color::WHITE,
        default_button_hover: Gosu::Color.new(255, 219, 219, 219),
        default_text: Gosu::Color::BLACK,
        dialogue_box_background: Gosu::Color::BLACK,
        dialogue_box_text: Gosu::Color::WHITE,
        house_count: Gosu::Color.new(255, 33, 203, 103),
        main_background: Gosu::Color.new(255, 145, 200, 204),
        options_menu_background: Gosu::Color.new(255, 14, 58, 61),
        options_menu_button: Gosu::Color.new(255, 153, 153, 153),
        options_menu_button_hover: Gosu::Color.new(255, 95, 95, 95),
        pop_up_menu_background: Gosu::Color.new(255, 39, 138, 134),
        pop_up_menu_border: Gosu::Color.new(255, 29, 102, 99),
        positive_green: Gosu::Color.new(255, 54, 165, 56),
        property_button_selected: Gosu::Color.new(255, 127, 158, 209),
        property_button_selected_hover: Gosu::Color.new(255, 105, 130, 170),
        tile_button: Gosu::Color.new(25, 0, 0, 0),
        tile_button_hover: Gosu::Color.new(75, 0, 0, 0),
        token_monopoly_background: Gosu::Color.new(100, 54, 165, 56),
        warning: Gosu::Color.new(255, 214, 19, 19)
      }

      self.color_groups = {
        brown: ColorGroup.new(
          color: Gosu::Color.new(255, 149, 84, 54),
          image: Gosu::Image.new('media/images/user_interface/blank_street_tile.png'),
          house_cost: 50,
          name: 'brown'
        ),
        light_blue: ColorGroup.new(
          color: Gosu::Color.new(255, 0, 114, 187),
          image: Gosu::Image.new('media/images/user_interface/blank_street_tile.png'),
          house_cost: 200,
          name: 'light blue'
        )
      }

      self.railroads_group = TileGroup.new(
        image: Gosu::Image.new('media/images/user_interface/train.png'),
        name: 'Railroads'
      )
      self.utilities_group = TileGroup.new(
        image: Gosu::Image.new('media/images/user_interface/wrench.png'),
        name: 'Utilities'
      )

      self.tile_count = 0
      self.tiles = {}
      self.tile_indexes = {}
      [
        GoTile.new(
          name: 'Go',
          tile_image: Gosu::Image.new('media/images/tiles/go.jpg')
        ),
        StreetTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/mediterranean_avenue.jpg'),
          game: self,
          group: color_groups[:brown],
          name: 'Mediterranean Avenue',
          purchase_price: 60,
          rent_scale: [2, 10, 30, 90, 160, 250],
          tile_image: Gosu::Image.new('media/images/tiles/mediterranean_avenue.png')
        ),
        StreetTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/baltic_avenue.jpg'),
          game: self,
          group: color_groups[:brown],
          name: 'Baltic Avenue',
          purchase_price: 60,
          rent_scale: [4, 20, 60, 180, 320, 450],
          tile_image: Gosu::Image.new('media/images/tiles/baltic_avenue.png')
        ),
        RailroadTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/reading_railroad.jpg'),
          game: self,
          group: railroads_group,
          name: 'Reading Railroad',
          purchase_price: 200,
          rent_scale: [25, 50, 100, 200],
          tile_image: Gosu::Image.new('media/images/tiles/reading_railroad.png')
        ),
        CardTile.new(
          card_type: :chance,
          name: 'Chance',
          tile_image: Gosu::Image.new('media/images/tiles/chance_1.jpg')
        ),
        JailTile.new(
          name: 'Jail',
          tile_image: Gosu::Image.new('media/images/tiles/jail.jpg')
        ),
        UtilityTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/electric_company.jpg'),
          game: self,
          group: utilities_group,
          name: 'Electric Company',
          purchase_price: 150,
          rent_multiplier_scale: [4, 10],
          tile_image: Gosu::Image.new('media/images/tiles/electric_company.png')
        ),
        RailroadTile.new(
         deed_image: Gosu::Image.new('media/images/deeds/pennsylvania_railroad.jpg'),
         game: self,
         group: railroads_group,
         name: 'Pennsylvania Railroad',
         purchase_price: 200,
         rent_scale: [25, 50, 100, 200],
         tile_image: Gosu::Image.new('media/images/tiles/pennsylvania_railroad.png')
       ),
        CardTile.new(
          card_type: :community_chest,
          name: 'Community Chest',
          tile_image: Gosu::Image.new('media/images/tiles/community_chest.jpg')
        ),
        FreeParkingTile.new(
          name: 'Free Parking',
          tile_image: Gosu::Image.new('media/images/tiles/free_parking.jpg')
        ),
        RailroadTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/b_o_railroad.jpg'),
          game: self,
          group: railroads_group,
          name: 'B. & O. Railroad',
          purchase_price: 200,
          rent_scale: [25, 50, 100, 200],
          tile_image: Gosu::Image.new('media/images/tiles/b_o_railroad.png')
        ),
        UtilityTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/water_works.jpg'),
          game: self,
          group: utilities_group,
          name: 'Water Works',
          purchase_price: 150,
          rent_multiplier_scale: [4, 10],
          tile_image: Gosu::Image.new('media/images/tiles/water_works.png')
        ),
        GoToJailTile.new(
          name: 'Go To Jail',
          tile_image: Gosu::Image.new('media/images/tiles/gotojail.jpg')
        ),
        RailroadTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/short_line.jpg'),
          game: self,
          group: railroads_group,
          name: 'Short Line',
          purchase_price: 200,
          rent_scale: [25, 50, 100, 200],
          tile_image: Gosu::Image.new('media/images/tiles/short_line.png')
        ),
        StreetTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/park_place.jpg'),
          game: self,
          group: color_groups[:light_blue],
          name: 'Park Place',
          purchase_price: 350,
          rent_scale: [35, 175, 500, 1100, 1300, 1500],
          tile_image: Gosu::Image.new('media/images/tiles/park_place.png')
        ),
        TaxTile.new(
          name: 'Luxury Tax',
          tax_amount: 75,
          tile_image: Gosu::Image.new('media/images/tiles/luxury_tax.jpg')
        ),
        StreetTile.new(
          deed_image: Gosu::Image.new('media/images/deeds/boardwalk.jpg'),
          game: self,
          group: color_groups[:light_blue],
          name: 'Boardwalk',
          purchase_price: 400,
          rent_scale: [50, 200, 600, 1400, 1700, 2000],
          tile_image: Gosu::Image.new('media/images/tiles/boardwalk.png')
        )
      ].each.with_index do |tile, index|
        self.tile_count += 1
        tiles[index] = tile
        tile_indexes[tile] = index

        if tile.is_a?(CardTile)
          tiles[tile.card_type] ||= []
          tiles[tile.card_type] << tile
        else
          tiles[tile.name.downcase.tr(' ', '_').to_sym] = tile
        end

        if tile.is_a?(PropertyTile)
          tile.button = Button.new(
            actions: [:display_tile, tile],
            font: fonts[:default][:type],
            game: self,
            text: tile.name,
            width: Button::DEFAULT_WIDTH + (Button::DEFAULT_WIDTH / 3.to_f)
          )
        end
      end

      self.players = [
        Player.new(
          game: self,
          name: 'Tom',
          number: 1,
          money: 200,
          tile: tiles[:go],
          token_image: Gosu::Image.new('media/images/tokens/iron.png')
        ),
        Player.new(
          game: self,
          name: 'Jerry',
          number: 2,
          money: 200,
          tile: tiles[:go],
          token_image: Gosu::Image.new('media/images/tokens/thimble.png')
        ),
        Player.new(
          game: self,
          name: 'Marahz',
          number: 3,
          money: 200,
          tile: tiles[:go],
          token_image: Gosu::Image.new('media/images/tokens/top_hat.png')
        )
      ]
      self.current_player_index = 0
      self.previous_player_number = -1
      self.current_player = players.first

      dialogue_box_button_width =
        (Coordinates::DIALOGUE_BOX_WIDTH - (DIALOGUE_BOX_BUTTON_GAP * 3)) / 2

      self.buttons = {
        consecutive_charge: Button.new(
          actions: nil,
          font: fonts[:default][:type],
          game: self,
          text: 'Pay',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        continue: Button.new(
          actions: :end_turn,
          font: fonts[:default][:type],
          game: self,
          text: 'Continue',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        draw_card: Button.new(
          actions: :draw_card,
          font: fonts[:default][:type],
          game: self,
          text: 'Draw Card',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        end_turn: Button.new(
          actions: :end_turn,
          font: fonts[:default][:type],
          game: self,
          text: 'End Turn',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        go_to_jail: Button.new(
          actions: :go_to_jail,
          font: fonts[:default][:type],
          game: self,
          text: 'Go To Jail',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        options: Button.new(
          actions: :toggle_options_menu,
          color: nil,
          game: self,
          height: 50,
          hover_color: nil,
          hover_image: Gosu::Image.new('media/images/user_interface/options_gear_hover.png'),
          image_height: 45,
          image_width: 45,
          image: Gosu::Image.new('media/images/user_interface/options_gear.png'),
          width: 50,
          x: Coordinates::RIGHT_X - 50,
          y: Coordinates::TOP_Y,
          z: ZOrder::MENU_UI
        ),
        pay_rent: Button.new(
          actions: :pay_rent,
          font: fonts[:default][:type],
          game: self,
          text: 'Pay Rent',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        pay_tax: Button.new(
          actions: :pay_tax,
          font: fonts[:default][:type],
          game: self,
          text: 'Pay Tax',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        roll_dice_for_move: Button.new(
          actions: [[:roll_dice], [:move], [:land]],
          font: fonts[:default][:type],
          game: self,
          text: 'Roll Dice',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        roll_dice_for_rent: Button.new(
          actions: [[:roll_dice], [:land]],
          font: fonts[:default][:type],
          game: self,
          text: 'Roll Dice',
          x: Coordinates::BUTTON_1_X,
          y: Coordinates::BUTTON_1_Y
        ),
        use_get_out_of_jail_free_card: Button.new(
          actions: :use_get_out_of_jail_free_card,
          font: fonts[:default][:type],
          game: self,
          text: 'Use Get Out Of Jail Free Card',
          x: Coordinates::BUTTON_2_X,
          y: Coordinates::BUTTON_2_Y
        )
      }

      self.options_menu_buttons = {
        save: Button.new(
          actions: :save_game,
          color: colors[:options_menu_button],
          font: fonts[:default][:type],
          game: self,
          hover_color: colors[:options_menu_button_hover],
          text: 'Save'
        ),
        exit: Button.new(
          actions: [[:toggle_dialogue_box, actions: :exit_game, button_text: 'Exit']],
          color: colors[:options_menu_button],
          font: fonts[:default][:type],
          game: self,
          hover_color: colors[:options_menu_button_hover],
          text: 'Exit'
        ),
        forfeit: Button.new(
          actions: [[:toggle_dialogue_box, actions: :forfeit, button_text: 'Forfeit']],
          color: colors[:options_menu_button],
          font: fonts[:default][:type],
          game: self,
          hover_color: colors[:warning],
          text: 'Forfeit'
        )
      }

      set_options_menu_button_coordinates

      self.dialogue_box_buttons = {
        cancel: Button.new(
          actions: :toggle_dialogue_box,
          font: fonts[:default][:type],
          game: self,
          text: 'Cancel',
          width: dialogue_box_button_width,
          x: Coordinates::DIALOGUE_BOX_LEFT_X + DIALOGUE_BOX_BUTTON_GAP,
          y: Coordinates::DIALOGUE_BOX_BOTTOM_Y - Button::DEFAULT_HEIGHT - 10,
          z: ZOrder::DIALOGUE_UI
        ),
        action: Button.new(
          actions: :toggle_dialogue_box,
          font: fonts[:default][:type],
          game: self,
          text: 'Cancel',
          width: dialogue_box_button_width,
          x: Coordinates::DIALOGUE_BOX_RIGHT_X - DIALOGUE_BOX_BUTTON_GAP - dialogue_box_button_width,
          y: Coordinates::DIALOGUE_BOX_BOTTOM_Y - Button::DEFAULT_HEIGHT - 10,
          z: ZOrder::DIALOGUE_UI
        )
      }

      house_button_options = {
        actions: nil,
        color: nil,
        game: self,
        height: DEFAULT_TILE_BUTTON_HEIGHT,
        hover_color: nil,
        hover_image: Gosu::Image.new('media/images/user_interface/house.png'),
        image: Gosu::Image.new('media/images/user_interface/house.png'),
        image_height: DEFAULT_TILE_BUTTON_HEIGHT,
        image_width: DEFAULT_TILE_BUTTON_HEIGHT * 1.1,
        width: DEFAULT_TILE_BUTTON_HEIGHT * 1.1,
        x: Coordinates::FIRST_HOUSE_BUTTON_X,
        z: ZOrder::MAIN_UI
      }
      build_house_button_options = {
        actions: :build_house,
        hover_image: Gosu::Image.new('media/images/user_interface/build_house_hover.png'),
        image: Gosu::Image.new('media/images/user_interface/build_house.png')
      }
      sell_house_button_options = {
        actions: :sell_house,
        hover_image: Gosu::Image.new('media/images/user_interface/sell_house_hover.png'),
        image: Gosu::Image.new('media/images/user_interface/sell_house.png')
      }

      house_button_offset = house_button_options[:image_height] + TILE_BUTTON_GAP
      house_buttons = []
      build_house_buttons = []
      sell_house_buttons = []
      (0..MAX_HOUSE_COUNT).map do |offset_multiplier|
        house_button_options[:y] =
          Coordinates::FIRST_HOUSE_BUTTON_Y + (house_button_offset * offset_multiplier)
        house_buttons << Button.new(house_button_options)
        build_house_buttons << Button.new(house_button_options.merge(build_house_button_options))
        sell_house_buttons << Button.new(house_button_options.merge(sell_house_button_options))
      end

      mortgage_lock_button_options = {
        color: nil,
        game: self,
        height: DEFAULT_TILE_BUTTON_HEIGHT,
        hover_color: nil,
        image_height: DEFAULT_TILE_BUTTON_HEIGHT,
        image_width: 70,
        width: 70,
        x: Coordinates::MORTGAGE_LOCK_X,
        y: Coordinates::MORTGAGE_LOCK_Y,
        z: ZOrder::MAIN_UI
      }

      self.tile_menu_buttons = {
        back: CircularButton.new(
          actions: :back_to_current_tile,
          color: colors[:tile_button],
          game: self,
          hover_color: Gosu::Color.new(255, 36, 72, 130),
          hover_image: Gosu::Image.new('media/images/user_interface/back.png'),
          image: Gosu::Image.new('media/images/user_interface/back.png'),
          image_height: 42,
          radius: 30,
          x: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_X,
          y: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_Y,
          z: ZOrder::MAIN_UI
        ),
        build_house: build_house_buttons,
        buy: CircularButton.new(
          actions: :buy,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:positive_green],
          hover_image: Gosu::Image.new('media/images/user_interface/buy.png'),
          image: Gosu::Image.new('media/images/user_interface/buy.png'),
          image_height: TOKEN_HEIGHT,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::BUY_BUTTON_X,
          y: Coordinates::BUY_BUTTON_Y,
          z: ZOrder::MAIN_UI
        ),
        house: house_buttons,
        mortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: :mortgage,
            hover_image: Gosu::Image.new('media/images/user_interface/mortgage_hover.png'),
            image: Gosu::Image.new('media/images/user_interface/mortgage.png')
          )
        ),
        mortgage_lock: Button.new(
          mortgage_lock_button_options.merge(
            actions: nil,
            hover_image: Gosu::Image.new('media/images/user_interface/mortgage_lock.png'),
            image: Gosu::Image.new('media/images/user_interface/mortgage_lock.png')
          )
        ),
        owner: CircularButton.new(
          actions: nil,
          game: self,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::TILE_OWNER_TOKEN_X,
          y: Coordinates::TILE_OWNER_TOKEN_Y,
          z: ZOrder::MAIN_UI
        ),
        sell_house: sell_house_buttons,

        # TODO: Move to action menu once it is implemented
        show_card: Button.new(
          actions: :toggle_card_menu,
          font: fonts[:default][:type],
          game: self,
          text: 'Show Card',
          x: Coordinates::BUTTON_2_X,
          y: Coordinates::BUTTON_2_Y
        ),
        show_deed: CircularButton.new(
          actions: :toggle_deed_menu,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Gosu::Image.new('media/images/user_interface/blank_deed.png'),
          image: Gosu::Image.new('media/images/user_interface/blank_deed.png'),
          image_height: 70,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::BUY_BUTTON_X,
          y: Coordinates::BUY_BUTTON_Y + DEFAULT_TILE_BUTTON_HEIGHT + TILE_BUTTON_GAP,
          z: ZOrder::MAIN_UI
        ),
        show_group: CircularButton.new(
          actions: :toggle_group_menu,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:positive_green],
          image_height: TOKEN_HEIGHT,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::BUY_BUTTON_X,
          y: Coordinates::BUY_BUTTON_Y + ((DEFAULT_TILE_BUTTON_HEIGHT + TILE_BUTTON_GAP) * 2),
          z: ZOrder::MAIN_UI
        ),
        unmortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: :unmortgage,
            hover_image: Gosu::Image.new('media/images/user_interface/unmortgage_hover.png'),
            image: Gosu::Image.new('media/images/user_interface/unmortgage.png')
          )
        )
      }

      group_menu_tile_button_options = {
        actions: nil,
        color: nil,
        game: self,
        height: Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT,
        hover_color: colors[:blur],
        width: Coordinates::GROUP_MENU_TILE_BUTTON_WIDTH,
        z: ZOrder::MENU_UI
      }
      group_menu_sub_button_edge = group_menu_tile_button_options[:width] -
        (DEFAULT_TILE_BUTTON_HEIGHT * 3) - (TILE_BUTTON_GAP * 2)
      group_menu_sub_button_edge /= 2
      group_menu_sub_button_y = Coordinates::GROUP_MENU_FIRST_TILE_Y +
        Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT + TILE_BUTTON_GAP

      arrow_button_x_offset =
        (
          Coordinates::GROUP_MENU_FIRST_TILE_X -
          Coordinates::GROUP_MENU_LEFT_X -
          Coordinates::GROUP_MENU_BORDER_WIDTH
        ) / 2 + Coordinates::GROUP_MENU_BORDER_WIDTH

      self.group_menu_buttons = {
        close: Button.new(
          actions: :toggle_group_menu,
          color: nil,
          game: self,
          height: 40,
          hover_color: nil,
          hover_image: Gosu::Image.new('media/images/user_interface/x_hover.png'),
          image: Gosu::Image.new('media/images/user_interface/x.png'),
          image_height: 40,
          width: 40,
          x: Coordinates::GROUP_MENU_LEFT_X + Coordinates::GROUP_MENU_BORDER_WIDTH + 5,
          y: Coordinates::GROUP_MENU_TOP_Y + Coordinates::GROUP_MENU_BORDER_WIDTH + 5,
          z: ZOrder::MENU_UI
        ),
        left: CircularButton.new(
          actions: [
            proc do
              group_menu_tiles.shift_back
              set_visible_group_menu_buttons if drawing_group_menu?
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Gosu::Image.new('media/images/user_interface/arrow_left_hover.png'),
          image: Gosu::Image.new('media/images/user_interface/arrow_left.png'),
          image_height: 40,
          radius: 30,
          x: Coordinates::GROUP_MENU_LEFT_X + arrow_button_x_offset,
          y: Coordinates::GROUP_MENU_FIRST_TILE_Y +
            (Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT / 2),
          z: ZOrder::MENU_UI
        ),
        right: CircularButton.new(
          actions: [
            proc do
              group_menu_tiles.shift_forward
              set_visible_group_menu_buttons if drawing_group_menu?
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Gosu::Image.new('media/images/user_interface/arrow_right_hover.png'),
          image: Gosu::Image.new('media/images/user_interface/arrow_right.png'),
          image_height: 40,
          radius: 30,
          x: Coordinates::GROUP_MENU_RIGHT_X - arrow_button_x_offset,
          y: Coordinates::GROUP_MENU_FIRST_TILE_Y +
            (Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT / 2),
          z: ZOrder::MENU_UI
        ),
        tiles: (0...4).map do |number|
          x = Coordinates::GROUP_MENU_FIRST_TILE_X +
            (
              (Coordinates::GROUP_MENU_TILE_BUTTON_WIDTH + Coordinates::GROUP_MENU_TILE_GAP) *
              number
            )
          {
            build_house: Button.new(
              actions: nil,
              color: nil,
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              hover_color: nil,
              hover_image: Gosu::Image.new('media/images/user_interface/arrow_up_hover.png'),
              image: Gosu::Image.new('media/images/user_interface/arrow_up.png'),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              width: DEFAULT_TILE_BUTTON_HEIGHT,
              x: x + group_menu_sub_button_edge,
              y: group_menu_sub_button_y,
              z: group_menu_tile_button_options[:z]
            ),
            house_big: Button.new(
              actions: nil,
              color: nil,
              font: fonts[:house_count][:type],
              font_color: colors[:house_count],
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Gosu::Image.new('media/images/user_interface/house.png'),
              image: Gosu::Image.new('media/images/user_interface/house.png'),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT,
              text_position_y: 0.4,
              width: DEFAULT_TILE_BUTTON_HEIGHT,
              x: x + group_menu_sub_button_edge,
              y: group_menu_sub_button_y,
              z: group_menu_tile_button_options[:z]
            ),
            house_small: Button.new(
              actions: nil,
              color: nil,
              font: fonts[:house_count][:type],
              font_color: colors[:house_count],
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              hover_color: nil,
              hover_image: Gosu::Image.new('media/images/user_interface/house.png'),
              image: Gosu::Image.new('media/images/user_interface/house.png'),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              text_position_y: 0.4,
              width: DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              x: x + group_menu_sub_button_edge + ((DEFAULT_TILE_BUTTON_HEIGHT * 0.55) / 2),
              y: group_menu_sub_button_y + 25,
              z: group_menu_tile_button_options[:z]
            ),
            owner: CircularButton.new(
              actions: nil,
              color: colors[:tile_button],
              game: self,
              hover_color: colors[:tile_button],
              radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
              x: x + group_menu_sub_button_edge + DEFAULT_TILE_BUTTON_HEIGHT + TILE_BUTTON_GAP +
                (DEFAULT_TILE_BUTTON_HEIGHT / 2),
              y: group_menu_sub_button_y + (DEFAULT_TILE_BUTTON_HEIGHT / 2),
              z: group_menu_tile_button_options[:z]
            ),
            mortgage: Button.new(
              actions: nil,
              color: nil,
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Gosu::Image.new('media/images/user_interface/mortgage_hover.png'),
              image: Gosu::Image.new('media/images/user_interface/mortgage.png'),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT,
              image_width: 70,
              width: 70,
              x: x + group_menu_sub_button_edge + (TILE_BUTTON_GAP * 2) +
                (DEFAULT_TILE_BUTTON_HEIGHT * 2),
              y: group_menu_sub_button_y,
              z: group_menu_tile_button_options[:z]
            ),
            mortgage_lock: Button.new(
              actions: nil,
              color: nil,
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Gosu::Image.new('media/images/user_interface/mortgage_lock.png'),
              image: Gosu::Image.new('media/images/user_interface/mortgage_lock.png'),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT,
              image_width: 70,
              width: 70,
              x: x + group_menu_sub_button_edge + (TILE_BUTTON_GAP * 2) +
                (DEFAULT_TILE_BUTTON_HEIGHT * 2),
              y: group_menu_sub_button_y,
              z: group_menu_tile_button_options[:z]
            ),
            sell_house: Button.new(
              actions: nil,
              color: nil,
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              hover_color: nil,
              hover_image: Gosu::Image.new('media/images/user_interface/arrow_down_hover.png'),
              image: Gosu::Image.new('media/images/user_interface/arrow_down.png'),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              width: DEFAULT_TILE_BUTTON_HEIGHT,
              x: x + group_menu_sub_button_edge,
              y: group_menu_sub_button_y + DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
              z: group_menu_tile_button_options[:z]
            ),
            tile: Button.new(
              group_menu_tile_button_options.merge(
                image_height: Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT * 0.9,
                x: x,
                y: Coordinates::GROUP_MENU_FIRST_TILE_Y
              )
            ),
            unmortgage: Button.new(
              actions: nil,
              color: nil,
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Gosu::Image.new('media/images/user_interface/unmortgage_hover.png'),
              image: Gosu::Image.new('media/images/user_interface/unmortgage.png'),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT,
              image_width: 70,
              width: 70,
              x: x + group_menu_sub_button_edge + (TILE_BUTTON_GAP * 2) +
                (DEFAULT_TILE_BUTTON_HEIGHT * 2),
              y: group_menu_sub_button_y,
              z: group_menu_tile_button_options[:z]
            ),
          }
        end
      }

      self.deed_menu_buttons = {
        close: Button.new(
          actions: :toggle_deed_menu,
          color: nil,
          game: self,
          height: 40,
          hover_color: nil,
          hover_image: Gosu::Image.new('media/images/user_interface/x_hover.png'),
          image: Gosu::Image.new('media/images/user_interface/x.png'),
          image_height: 40,
          width: 40,
          x: Coordinates::DEED_MENU_LEFT_X + Coordinates::DEED_MENU_BORDER_WIDTH + 5,
          y: Coordinates::DEED_MENU_TOP_Y + Coordinates::DEED_MENU_BORDER_WIDTH + 5,
          z: ZOrder::MENU_UI
        )
      }

      self.card_menu_buttons = {
        back: CircularButton.new(
          actions: :back_to_current_tile,
          color: colors[:tile_button],
          game: self,
          hover_color: Gosu::Color.new(255, 36, 72, 130),
          hover_image: Gosu::Image.new('media/images/user_interface/back.png'),
          image: Gosu::Image.new('media/images/user_interface/back.png'),
          image_height: 42,
          radius: 30,
          x: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_X,
          y: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_Y,
          z: ZOrder::MAIN_UI
        ),
        continue: Button.new(
          actions: :use_new_card,
          font: fonts[:default][:type],
          game: self,
          text: 'Continue',
          x: Coordinates::BUTTON_1_X - 50,
          y: Coordinates::BUTTON_1_Y - 50
        )
      }

      self.cards = {
        chance: [
          MoneyCard.new(
            amount: -50,
            every_other_player: true,
            game: self,
            image: Gosu::Image.new('media/images/cards/chairman_of_the_board.jpg'),
            type: :chance
          ),
          MoveCard.new(
            game: self,
            image: Gosu::Image.new('media/images/cards/go_back_3_spaces.jpg'),
            move_value: -3,
            type: :chance
          ),
          MoveCard.new(
            game: self,
            image: Gosu::Image.new('media/images/cards/nearest_utility.jpg'),
            move_value: UtilityTile,
            rent_multiplier: 10,
            type: :chance
          ),
          MoneyCard.new(
            amount: -15,
            game: self,
            image: Gosu::Image.new('media/images/cards/poor_tax.jpg'),
            type: :chance
          ),
          GetOutOfJailFreeCard.new(
            game: self,
            image: Gosu::Image.new('media/images/cards/get_out_of_jail_free.jpg'),
            type: :chance
          ),
          MoveCard.new(
            game: self,
            go_money: true,
            image: Gosu::Image.new('media/images/cards/advance_to_boardwalk.jpg'),
            move_value: tiles[:boardwalk],
            type: :chance
          )
        ],
        community_chest: [
          GoToJailCard.new(
            game: self,
            image: Gosu::Image.new('media/images/cards/go_to_jail_community_chest.jpg'),
            type: :community_chest
          ),
          PropertyRepairCard.new(
            cost_per_house: 40,
            game: self,
            image: Gosu::Image.new('media/images/cards/street_repairs.jpg'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 50,
            every_other_player: true,
            game: self,
            image: Gosu::Image.new('media/images/cards/opera.jpg'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 25,
            game: self,
            image: Gosu::Image.new('media/images/cards/receive_for_services.jpg'),
            type: :community_chest
          )
        ]
      }

      cards.values.each(&:shuffle!)

      self.current_tile = self.focused_tile = tiles[0]

      self.messages = []

      self.turn = 1
      add_message('Turn 1...')

      self.die_a = 1
      self.die_b = 1

      self.deed_name_text = ['DOOFENSHMI-', 'RTZ EVIL OH YEAH IN-', 'CORPORATEEEEED']

      self.visible_card_menu_buttons = []
      self.visible_deed_menu_buttons = []
      self.visible_group_menu_buttons = []
      self.visible_tile_menu_buttons = []
      self.group_menu_tiles = ScrollingList.new(items: [], view_size: 4)
      self.group_menu_alt_button_positions = false
      self.visible_buttons = [buttons[:roll_dice_for_move]]
    end

    %i[current_player current_tile visible_buttons].each do |value|
      define_method(:"cache_#{value}") do
        send(:"#{value}_cache=", send(value))
      end

      define_method(:"pop_#{value}_cache") do
        send(:"#{value}=", send(:"#{value}_cache"))
        send(:"#{value}_cache=", nil)
      end
    end

    %i[card_menu deed_menu dialogue_box group_menu options_menu].each do |value|
      define_method(:"drawing_#{value}?") do
        send(:"drawing_#{value}")
      end
    end

    def button_down(id)
      case id
      when Gosu::MS_LEFT
        handle_click(mouse_x, mouse_y)

      # FOR DEVELOPMENT: Enter debugger breakpoint
      when Gosu::KB_D
        byebug if ctrl_cmd_down?

      # FOR DEVELOPMENT: Print out current state of the instance to STDOUT
      when Gosu::KB_P
        print_state if ctrl_cmd_down?

      # FOR DEVELOPMENT: Make current player land exactly 1 tile backward
      when Gosu::KB_B
        if ctrl_cmd_down?
          toggle_deed_menu if drawing_deed_menu?
          toggle_group_menu if drawing_group_menu?
          toggle_dialogue_box if drawing_dialogue_box?
          self.current_card = nil
          move(spaces: -1, collect: false)
          land
        end

      # FOR DEVELOPMENT: Make current player re-land on current tile
      when Gosu::KB_R
        if ctrl_cmd_down?
          toggle_deed_menu if drawing_deed_menu?
          toggle_group_menu if drawing_group_menu?
          toggle_dialogue_box if drawing_dialogue_box?
          self.current_card = nil
          land
        end

      # FOR DEVELOPMENT: Make current player land exactly 1 tile forward
      when Gosu::KB_N
        if ctrl_cmd_down?
          toggle_deed_menu if drawing_deed_menu?
          toggle_group_menu if drawing_group_menu?
          toggle_dialogue_box if drawing_dialogue_box?
          self.current_card = nil
          move(spaces: 1, collect: false)
          land
        end

      # FOR DEVELOPMENT: Take $100 away from current player
      when Gosu::KB_MINUS
        if ctrl_cmd_down?
          current_player.money -= 100
          current_player.money = 0 if current_player.money.negative?
        end

      # FOR DEVELOPMENT: Give current player $100
      when Gosu::KB_EQUALS
        current_player.money += 100 if ctrl_cmd_down?
      else
        super
      end
    end

    def ctrl_cmd_down?
      # If on Mac OS
      if RUBY_PLATFORM =~ /darwin/
        button_down?(Gosu::KB_RIGHT_META) || button_down?(Gosu::KB_LEFT_META)
      else
        button_down?(Gosu::KB_RIGHT_CONTROL) || button_down?(Gosu::KB_LEFT_CONTROL)
      end
    end

    def execute_actions(actions)
      actions&.each do |action|
        if action.is_a?(Array)
          parameters = action[1..-1]
          action = action.first
          if action.is_a?(Proc)
            action.call(*parameters)
          elsif action.is_a?(Symbol)
            send(action, *parameters)
          else
            puts("invalid action: #{action.inspect}")
          end
        else
          if action.is_a?(Proc)
            action.call
          elsif action.is_a?(Symbol)
            send(action)
          else
            puts("invalid action: #{action.inspect}")
          end
        end
      end
    end

    def format_actions(actions)
      if actions.nil?
        nil
      elsif actions.is_a?(Array) && actions.first.is_a?(Array)
        actions
      else
        [actions]
      end
    end

    def format_money(amount)
      formatted_amount =
        ActiveSupport::NumberHelper.number_to_currency(amount, strip_insignificant_zeros: true)
      formatted_amount << '0' if formatted_amount.match?(/\.\d$/)
      formatted_amount
    end

    def format_number(number)
      number.to_s(:delimited)
    end

    def handle_click(x, y)
      buttons_to_check =
        if drawing_dialogue_box?
          dialogue_box_buttons.values
        else
          temp_buttons_to_check = [buttons[:options]]
          temp_buttons_to_check += options_menu_buttons.values.reverse if drawing_options_menu?
          if drawing_group_menu?
            temp_buttons_to_check += visible_group_menu_buttons.reverse
          elsif drawing_deed_menu?
            temp_buttons_to_check += visible_deed_menu_buttons.reverse
          else
            temp_buttons_to_check +=
              (drawing_card_menu? ? visible_card_menu_buttons : visible_tile_menu_buttons).reverse

            temp_buttons_to_check += visible_buttons.reverse
            temp_buttons_to_check += current_player.properties.map { |property| property.button }
          end

          temp_buttons_to_check
        end

      buttons_to_check.each do |button|
        if button.within?(x, y)
          button.perform_actions
          break
        end
      end
    end

    def inspect
      to_s
    end

    def needs_cursor?
      true
    end

    def print_state
      puts('--------------------------')
      puts('PRINTING STATE')
      puts

      instance_variables.each do |instance_variable_name|
        puts("#{instance_variable_name.to_s[1..-1].tr('_', ' ').upcase}:")
        pp(instance_variable_get(instance_variable_name))
        puts
      end

      puts
      puts('--------------------------')
      puts
    end

    def ticks_for_seconds(seconds)
      seconds * 60
    end
  end
end

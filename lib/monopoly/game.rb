module Monopoly
  class Game < Gosu::Window
    include GameActions
    include PlayerActions
    include UserInterface

    DEFAULT_BUILDING_SELL_PERCENTAGE = 0.5
    DEFAULT_GO_MONEY_AMOUNT = 200
    DEFAULT_JAIL_TIME = 3
    DEFAULT_MAX_HOUSE_COUNT = 5
    EVENT_HISTORY_LIMIT = 1_000
    RESOLUTION_HEIGHT = ENV['RESOLUTION_HEIGHT'].to_i
    RESOLUTION_WIDTH = ENV['RESOLUTION_WIDTH'].to_i

    attr_accessor :action_menu
    attr_accessor :card_menu
    attr_accessor :cards
    attr_accessor :clock_data
    attr_accessor :color_groups
    attr_accessor :colors
    attr_accessor :compass_menu_buttons
    attr_accessor :compass_menu_data
    attr_accessor :current_card
    attr_accessor :current_player
    attr_accessor :current_player_cache
    attr_accessor :current_player_index
    attr_accessor :current_player_landed
    attr_accessor :current_player_start_time
    attr_accessor :current_tile
    attr_accessor :current_tile_cache
    attr_accessor :deed_menu
    attr_accessor :dialogue_box_menu
    attr_accessor :die_a
    attr_accessor :die_b
    attr_accessor :drawing_compass_menu
    attr_accessor :drawing_event_history_menu
    attr_accessor :drawing_game_menu
    attr_accessor :drawing_player_inspector
    attr_accessor :drawing_player_menu
    attr_accessor :draw_mouse_x
    attr_accessor :draw_mouse_y
    attr_accessor :eliminated_players
    attr_accessor :error_dialogue_buttons
    attr_accessor :error_dialogue_data
    attr_accessor :error_ticks
    attr_accessor :event_history
    attr_accessor :event_history_menu_buttons
    attr_accessor :event_history_view
    attr_accessor :focused_tile
    attr_accessor :fonts
    attr_accessor :game_menu_buttons
    attr_accessor :group_menu
    attr_accessor :images
    attr_accessor :inspected_player
    attr_accessor :map_menu
    attr_accessor :next_action
    attr_accessor :next_players
    attr_accessor :options_menu
    attr_accessor :player_inspector_buttons
    attr_accessor :player_inspector_color_groups
    attr_accessor :player_inspector_data
    attr_accessor :player_inspector_railroad_groups
    attr_accessor :player_inspector_show_stats
    attr_accessor :player_inspector_utility_groups
    attr_accessor :player_list_menu
    attr_accessor :player_menu_buttons
    attr_accessor :player_menu_data
    attr_accessor :player_menu_color_groups
    attr_accessor :player_menu_railroad_groups
    attr_accessor :player_menu_utility_groups
    attr_accessor :players
    attr_accessor :previous_time_elapsed
    attr_accessor :previous_player_number
    attr_accessor :property_button_color_cache
    attr_accessor :property_button_hover_color_cache
    attr_accessor :railroad_groups
    attr_accessor :start_time
    attr_accessor :temporary_rent_multiplier
    attr_accessor :tile_count
    attr_accessor :tile_indexes
    attr_accessor :tile_menu
    attr_accessor :tiles
    attr_accessor :turn
    attr_accessor :utility_groups
    attr_accessor :visible_compass_menu_buttons
    attr_accessor :visible_event_history_menu_buttons
    attr_accessor :visible_player_inspector_buttons
    attr_accessor :visible_player_menu_buttons

    def initialize
      super(RESOLUTION_WIDTH, RESOLUTION_HEIGHT, fullscreen: ARGV.include?('-f'))

      self.caption = 'Monopoly'

      self.colors = {
        blur: Gosu::Color.new(200, 200, 200, 200),
        button_hover_highlight_light: Gosu::Color.new(25, 255, 255, 255),
        clickable_text: Gosu::Color.new(255, 159, 224, 222),
        clickable_text_hover: Gosu::Color::WHITE,
        deed: Gosu::Color::WHITE,
        deed_accent: Gosu::Color::BLACK,
        deed_highlight: Gosu::Color.new(255, 173, 181, 91),
        default_button: Gosu::Color::WHITE,
        default_button_hover: Gosu::Color.new(255, 219, 219, 219),
        default_button_hover_highlight: Gosu::Color.new(100, 255, 255, 255),
        default_text: Gosu::Color::BLACK,
        dialogue_box_background: Gosu::Color.new(255, 29, 102, 99),
        dialogue_box_button_hover: Gosu::Color.new(255, 219, 219, 219),
        dialogue_box_text: Gosu::Color::WHITE,
        house_count: Gosu::Color.new(255, 33, 203, 103),
        jail: Gosu::Color.new(255, 217, 52, 52),
        main_background: Gosu::Color.new(255, 145, 200, 204),
        monopoly_button_background: Gosu::Color.new(100, 54, 165, 56),
        monopoly_button_background_hover: Gosu::Color.new(100, 42, 133, 44),
        neutral_blue: Gosu::Color.new(255, 36, 72, 130),
        neutral_blue_light: Gosu::Color.new(255, 55, 71, 191),
        neutral_yellow: Gosu::Color.new(255, 198, 201, 0),
        options_menu_button: Gosu::Color.new(255, 153, 153, 153),
        options_menu_button_hover: Gosu::Color.new(255, 95, 95, 95),
        pop_up_menu_background: Gosu::Color.new(255, 39, 138, 134),
        pop_up_menu_background_alt: Gosu::Color.new(255, 38, 130, 130),
        pop_up_menu_background_light: Gosu::Color.new(255, 80, 166, 163),
        pop_up_menu_background_light_hover: Gosu::Color.new(255, 159, 224, 222),
        pop_up_menu_border: Gosu::Color.new(255, 29, 102, 99),
        positive_green: Gosu::Color.new(255, 54, 165, 56),
        property_button_selected: Gosu::Color.new(255, 127, 158, 209),
        property_button_selected_hover: Gosu::Color.new(255, 105, 130, 170),
        shadow: Gosu::Color.new(255, 75, 75, 75),
        tile_background: Gosu::Color.new(255, 205, 230, 208),
        tile_button: Gosu::Color.new(25, 0, 0, 0),
        tile_button_hover: Gosu::Color.new(75, 0, 0, 0),
        warning: Gosu::Color.new(255, 214, 19, 19)
      }

      monopoly_font = 'media/fonts/JosefinSans-Regular.ttf'
      self.fonts = {
        small: { type: Gosu::Font.new(25), offset: 30 },
        default: { type: Gosu::Font.new(DEFAULT_FONT_SIZE), offset: 35 },
        large: { type: Gosu::Font.new(45), offset: 50 },
        extra_large: { type: Gosu::Font.new(50), offset: 55 },
        title: { type: Gosu::Font.new(55), offset: 55 },
        big_title: { type: Gosu::Font.new(80), offset: 80 },

        deed_name: { type: Gosu::Font.new(30, name: monopoly_font), offset: 35 },
        deed: { type: Gosu::Font.new(28, name: monopoly_font), offset: 35 }
      }

      self.images = {
        all_properties: 'user_interface/all_properties.png',
        arrow_down: 'user_interface/arrow_down.png',
        arrow_down_hover: 'user_interface/arrow_down_hover.png',
        arrow_left: 'user_interface/arrow_left.png',
        arrow_left_hover: 'user_interface/arrow_left_hover.png',
        arrow_right: 'user_interface/arrow_right.png',
        arrow_right_hover: 'user_interface/arrow_right_hover.png',
        arrow_up: 'user_interface/arrow_up.png',
        arrow_up_hover: 'user_interface/arrow_up_hover.png',
        back: 'user_interface/back.png',
        back_alt: 'user_interface/back_alt.png',
        bar_graph: 'user_interface/bar_graph.png',
        blank_deed: 'user_interface/blank_deed.png',
        blank_street_tile: 'user_interface/blank_street_tile.png',
        build_house: 'user_interface/build_house.png',
        build_house_hover: 'user_interface/build_house_hover.png',
        checkbox_checked: 'user_interface/checkbox_checked.png',
        checkbox_checked_hover: 'user_interface/checkbox_checked_hover.png',
        checkbox_unchecked: 'user_interface/checkbox_unchecked.png',
        checkbox_unchecked_hover: 'user_interface/checkbox_unchecked_hover.png',
        community_chest: 'tiles/icons/community_chest.png',
        dice: 'user_interface/dice.png',
        die_1: 'user_interface/die_1.png',
        die_2: 'user_interface/die_2.png',
        die_3: 'user_interface/die_3.png',
        die_4: 'user_interface/die_4.png',
        die_5: 'user_interface/die_5.png',
        die_6: 'user_interface/die_6.png',
        dollar_sign: 'user_interface/dollar_sign.png',
        double_arrow_left: 'user_interface/double_arrow_left.png',
        double_arrow_left_hover: 'user_interface/double_arrow_left_hover.png',
        double_arrow_right: 'user_interface/double_arrow_right.png',
        double_arrow_right_hover: 'user_interface/double_arrow_right_hover.png',
        exclamation_point: 'user_interface/exclamation_point.png',
        expand: 'user_interface/expand.png',
        expand_hover: 'user_interface/expand_hover.png',
        handshake: 'user_interface/handshake.png',
        house: 'user_interface/house.png',
        houses_1: 'user_interface/houses_1.png',
        houses_2: 'user_interface/houses_2.png',
        houses_3: 'user_interface/houses_3.png',
        houses_4: 'user_interface/houses_4.png',
        jail_cell: 'user_interface/jail_cell.png',
        key: 'user_interface/key.png',
        list: 'user_interface/list.png',
        map: 'user_interface/map.png',
        message: 'user_interface/message.png',
        mortgage: 'user_interface/mortgage.png',
        mortgage_hover: 'user_interface/mortgage_hover.png',
        mortgage_lock: 'user_interface/mortgage_lock.png',
        no_key: 'user_interface/no_key.png',
        options_gear: 'user_interface/options_gear.png',
        options_gear_hover: 'user_interface/options_gear_hover.png',
        people: 'user_interface/people.png',
        pinpoint: 'user_interface/pinpoint.png',
        rotate_clockwise: 'user_interface/rotate_clockwise.png',
        rotate_clockwise_hover: 'user_interface/rotate_clockwise_hover.png',
        rotate_counterclockwise: 'user_interface/rotate_counterclockwise.png',
        rotate_counterclockwise_hover: 'user_interface/rotate_counterclockwise_hover.png',
        sell_house: 'user_interface/sell_house.png',
        sell_house_hover: 'user_interface/sell_house_hover.png',
        train: 'user_interface/train.png',
        unmortgage: 'user_interface/unmortgage.png',
        unmortgage_hover: 'user_interface/unmortgage_hover.png',
        wrench: 'user_interface/wrench.png',
        x: 'user_interface/x.png',
        x_hover: 'user_interface/x_hover.png'
      }.map { |name, path| [name, Gosu::Image.new("media/images/#{path}")] }.to_h

      self.color_groups = {
        brown: ColorGroup.new(
          color: Gosu::Color.new(255, 149, 84, 54),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 50,
          plural_name: 'Browns',
          singular_name: 'Brown'
        ),
        light_blue: ColorGroup.new(
          color: Gosu::Color.new(255, 170, 224, 250),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 50,
          plural_name: 'Light Blues',
          singular_name: 'Light Blue'
        ),
        pink: ColorGroup.new(
          color: Gosu::Color.new(255, 217, 58, 150),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 100,
          plural_name: 'Pinks',
          singular_name: 'Pink'
        ),
        orange: ColorGroup.new(
          color: Gosu::Color.new(255, 247, 148, 29),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 100,
          plural_name: 'Oranges',
          singular_name: 'Orange'
        ),
        red: ColorGroup.new(
          color: Gosu::Color.new(255, 237, 27, 36),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 150,
          plural_name: 'Reds',
          singular_name: 'Red'
        ),
        yellow: ColorGroup.new(
          color: Gosu::Color.new(255, 254, 242, 0),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 150,
          plural_name: 'Yellows',
          singular_name: 'Yellow'
        ),
        green: ColorGroup.new(
          color: Gosu::Color.new(255, 31, 178, 90),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 200,
          plural_name: 'Greens',
          singular_name: 'Green'
        ),
        dark_blue: ColorGroup.new(
          color: Gosu::Color.new(255, 0, 114, 187),
          image: Image.new(images[:blank_street_tile]),
          house_cost: 200,
          plural_name: 'Dark Blues',
          singular_name: 'Dark Blue'
        )
      }

      self.railroad_groups = {
        railroads: TileGroup.new(
          image: Image.new(images[:train]),
          plural_name: 'Railroads',
          singular_name: 'Railroad'
        )
      }

      self.utility_groups = {
        utilities: TileGroup.new(
          image: Image.new(images[:wrench]),
          plural_name: 'Utilities',
          singular_name: 'Utility'
        )
      }

      self.tile_count = 0
      self.tiles = {}
      self.tile_indexes = {}
      [
        GoTile.new(
          icon: Image.new('media/images/tiles/icons/go.png'),
          name: 'Go',
          tile_image: Image.new('media/images/tiles/go.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:brown],
          name: 'Mediterranean Avenue',
          purchase_price: 60,
          rent_scale: [2, 10, 30, 90, 160, 250],
          tile_image: Image.new('media/images/tiles/mediterranean_avenue.png')
        ),
        CardTile.new(
          card_type: :community_chest,
          icon: Image.new(images[:community_chest]),
          name: 'Community Chest',
          tile_image: Image.new('media/images/tiles/community_chest.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:brown],
          name: 'Baltic Avenue',
          purchase_price: 60,
          rent_scale: [4, 20, 60, 180, 320, 450],
          tile_image: Image.new('media/images/tiles/baltic_avenue.png')
        ),
        TaxTile.new(
          icon: Image.new('media/images/tiles/icons/income_tax.png'),
          name: 'Income Tax',
          tax_amount: 200,
          tile_image: Image.new('media/images/tiles/income_tax.png')
        ),
        RailroadTile.new(
          game: self,
          group: railroad_groups[:railroads],
          icon: Image.new(images[:train]),
          name: 'Reading Railroad',
          purchase_price: 200,
          rent_scale: [25, 50, 100, 200],
          tile_image: Image.new('media/images/tiles/reading_railroad.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:light_blue],
          name: 'Oriental Avenue',
          purchase_price: 100,
          rent_scale: [6, 30, 90, 270, 400, 550],
          tile_image: Image.new('media/images/tiles/oriental_avenue.png')
        ),
        CardTile.new(
          card_type: :chance,
          icon: Image.new('media/images/tiles/icons/chance_1.png'),
          name: 'Chance',
          tile_image: Image.new('media/images/tiles/chance_1.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:light_blue],
          name: 'Vermont Avenue',
          purchase_price: 100,
          rent_scale: [6, 30, 90, 270, 400, 550],
          tile_image: Image.new('media/images/tiles/vermont_avenue.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:light_blue],
          name: 'Connecticut Avenue',
          purchase_price: 120,
          rent_scale: [8, 40, 100, 300, 450, 600],
          tile_image: Image.new('media/images/tiles/connecticut_avenue.png')
        ),
        JailTile.new(
          icon: Image.new('media/images/tiles/icons/jail.png'),
          name: 'Jail',
          tile_image: Image.new('media/images/tiles/jail.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:pink],
          name: 'St. Charles Place',
          purchase_price: 140,
          rent_scale: [10, 50, 150, 450, 625, 750],
          tile_image: Image.new('media/images/tiles/st_charles_place.png')
        ),
        UtilityTile.new(
          game: self,
          group: utility_groups[:utilities],
          icon: Image.new('media/images/tiles/icons/electric_company.png'),
          name: 'Electric Company',
          purchase_price: 150,
          rent_multiplier_scale: [4, 10],
          tile_image: Image.new('media/images/tiles/electric_company.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:pink],
          name: 'States Avenue',
          purchase_price: 140,
          rent_scale: [10, 50, 150, 450, 625, 750],
          tile_image: Image.new('media/images/tiles/states_avenue.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:pink],
          name: 'Virginia Avenue',
          purchase_price: 160,
          rent_scale: [12, 60, 180, 500, 700, 900],
          tile_image: Image.new('media/images/tiles/virginia_avenue.png')
        ),
        RailroadTile.new(
          game: self,
          group: railroad_groups[:railroads],
          icon: Image.new(images[:train]),
          name: 'Pennsylvania Railroad',
          purchase_price: 200,
          rent_scale: [25, 50, 100, 200],
          tile_image: Image.new('media/images/tiles/pennsylvania_railroad.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:orange],
          name: 'St. James Place',
          purchase_price: 180,
          rent_scale: [14, 70, 200, 550, 750, 950],
          tile_image: Image.new('media/images/tiles/st_james_place.png')
        ),
        CardTile.new(
          card_type: :community_chest,
          icon: Image.new(images[:community_chest]),
          name: 'Community Chest',
          tile_image: Image.new('media/images/tiles/community_chest.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:orange],
          name: 'Tennessee Avenue',
          purchase_price: 180,
          rent_scale: [14, 70, 200, 550, 750, 950],
          tile_image: Image.new('media/images/tiles/tennessee_avenue.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:orange],
          name: 'New York Avenue',
          purchase_price: 200,
          rent_scale: [16, 80, 220, 600, 800, 1_000],
          tile_image: Image.new('media/images/tiles/new_york_avenue.png')
        ),
        FreeParkingTile.new(
          icon: Image.new('media/images/tiles/icons/free_parking.png'),
          name: 'Free Parking',
          tile_image: Image.new('media/images/tiles/free_parking.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:red],
          name: 'Kentucky Avenue',
          purchase_price: 220,
          rent_scale: [18, 90, 250, 700, 875, 1_050],
          tile_image: Image.new('media/images/tiles/kentucky_avenue.png')
        ),
        CardTile.new(
          card_type: :chance,
          icon: Image.new('media/images/tiles/icons/chance_2.png'),
          name: 'Chance',
          tile_image: Image.new('media/images/tiles/chance_2.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:red],
          name: 'Indiana Avenue',
          purchase_price: 220,
          rent_scale: [18, 90, 250, 700, 875, 1_050],
          tile_image: Image.new('media/images/tiles/indiana_avenue.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:red],
          name: 'Illinois Avenue',
          purchase_price: 240,
          rent_scale: [20, 100, 300, 750, 925, 1_100],
          tile_image: Image.new('media/images/tiles/illinois_avenue.png')
        ),
        RailroadTile.new(
          game: self,
          group: railroad_groups[:railroads],
          icon: Image.new(images[:train]),
          name: 'B. & O. Railroad',
          purchase_price: 200,
          rent_scale: [25, 50, 100, 200],
          tile_image: Image.new('media/images/tiles/b_o_railroad.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:yellow],
          name: 'Atlantic Avenue',
          purchase_price: 260,
          rent_scale: [22, 110, 330, 800, 975, 1_150],
          tile_image: Image.new('media/images/tiles/atlantic_avenue.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:yellow],
          name: 'Ventnor Avenue',
          purchase_price: 260,
          rent_scale: [22, 110, 330, 800, 975, 1_150],
          tile_image: Image.new('media/images/tiles/ventnor_avenue.png')
        ),
        UtilityTile.new(
          game: self,
          group: utility_groups[:utilities],
          icon: Image.new('media/images/tiles/icons/water_works.png'),
          name: 'Water Works',
          purchase_price: 150,
          rent_multiplier_scale: [4, 10],
          tile_image: Image.new('media/images/tiles/water_works.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:yellow],
          name: 'Marvin Gardens',
          purchase_price: 280,
          rent_scale: [24, 120, 360, 850, 1_025, 1_200],
          tile_image: Image.new('media/images/tiles/marvin_gardens.png')
        ),
        GoToJailTile.new(
          icon: Image.new('media/images/tiles/icons/go_to_jail.png'),
          name: 'Go To Jail',
          tile_image: Image.new('media/images/tiles/go_to_jail.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:green],
          name: 'Pacific Avenue',
          purchase_price: 300,
          rent_scale: [26, 130, 390, 900, 1_100, 1_275],
          tile_image: Image.new('media/images/tiles/pacific_avenue.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:green],
          name: 'North Carolina Avenue',
          purchase_price: 300,
          rent_scale: [26, 130, 390, 900, 1_100, 1_275],
          tile_image: Image.new('media/images/tiles/north_carolina_avenue.png')
        ),
        CardTile.new(
          card_type: :community_chest,
          icon: Image.new(images[:community_chest]),
          name: 'Community Chest',
          tile_image: Image.new('media/images/tiles/community_chest.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:green],
          name: 'Pennsylvania Avenue',
          purchase_price: 320,
          rent_scale: [28, 150, 450, 1_000, 1_200, 1_400],
          tile_image: Image.new('media/images/tiles/pennsylvania_avenue.png')
        ),
        RailroadTile.new(
          game: self,
          group: railroad_groups[:railroads],
          icon: Image.new(images[:train]),
          name: 'Short Line',
          purchase_price: 200,
          rent_scale: [25, 50, 100, 200],
          tile_image: Image.new('media/images/tiles/short_line.png')
        ),
        CardTile.new(
          card_type: :chance,
          icon: Image.new('media/images/tiles/icons/chance_3.png'),
          name: 'Chance',
          tile_image: Image.new('media/images/tiles/chance_3.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:dark_blue],
          name: 'Park Place',
          purchase_price: 350,
          rent_scale: [35, 175, 500, 1100, 1300, 1500],
          tile_image: Image.new('media/images/tiles/park_place.png')
        ),
        TaxTile.new(
          icon: Image.new('media/images/tiles/icons/luxury_tax.png'),
          name: 'Luxury Tax',
          tax_amount: 75,
          tile_image: Image.new('media/images/tiles/luxury_tax.png')
        ),
        StreetTile.new(
          game: self,
          group: color_groups[:dark_blue],
          name: 'Boardwalk',
          purchase_price: 400,
          rent_scale: [50, 200, 600, 1400, 1700, 2000],
          tile_image: Image.new('media/images/tiles/boardwalk.png')
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

        tile.thumbnail = generate_tile_thumbnail(tile)
      end

      self.players = [
        Player.new(
          game: self,
          name: 'Tom',
          number: 1,
          money: 1_500,
          tile: tiles[:go],
          token_image: Image.new('media/images/tokens/iron.png')
        ),
        Player.new(
          game: self,
          name: 'Jerry',
          number: 2,
          money: 1_500,
          tile: tiles[:go],
          token_image: Image.new('media/images/tokens/thimble.png')
        ),
        Player.new(
          game: self,
          name: 'Marahz',
          number: 3,
          money: 1_500,
          tile: tiles[:go],
          token_image: Image.new('media/images/tokens/top_hat.png')
        )
      ]
      self.current_player_index = 0
      self.previous_player_number = -1
      self.current_player = players.first

      error_dialogue_close_button_height = DEFAULT_TILE_BUTTON_HEIGHT * 0.2
      error_dialogue_button_gap = error_dialogue_close_button_height * 0.25
      self.error_dialogue_buttons = {
        close: Button.new(
          actions: :close_error_dialogue,
          color: nil,
          game: self,
          height: error_dialogue_close_button_height,
          hover_color: nil,
          hover_image: Image.new(images[:x_hover]),
          image: Image.new(images[:x]),
          image_height: error_dialogue_close_button_height,
          width: error_dialogue_close_button_height,
          x: Coordinates::ERROR_DIALOGUE_LEFT_X + Coordinates::ERROR_DIALOGUE_BORDER_WIDTH +
            error_dialogue_button_gap,
          y: Coordinates::ERROR_DIALOGUE_TOP_Y + Coordinates::ERROR_DIALOGUE_BORDER_WIDTH +
            error_dialogue_button_gap,
          z: ZOrder::DIALOGUE_UI
        )
      }

      self.error_dialogue_data = {
        exclamation_point: {
          image: Image.new(images[:exclamation_point]),
          params: {
            draw_width: error_dialogue_close_button_height,
            x: Coordinates::ERROR_DIALOGUE_RIGHT_X - Coordinates::ERROR_DIALOGUE_BORDER_WIDTH -
              error_dialogue_close_button_height - (error_dialogue_button_gap * 2),
            y: Coordinates::ERROR_DIALOGUE_TOP_Y + Coordinates::ERROR_DIALOGUE_BORDER_WIDTH +
              (error_dialogue_button_gap * 3) + error_dialogue_close_button_height,
            z: ZOrder::DIALOGUE_UI
          }
        },
        rectangles: [
          {
            color: colors[:pop_up_menu_border],
            height: Coordinates::ERROR_DIALOGUE_HEIGHT,
            width: Coordinates::ERROR_DIALOGUE_WIDTH,
            x: Coordinates::ERROR_DIALOGUE_LEFT_X,
            y: Coordinates::ERROR_DIALOGUE_TOP_Y,
            z: ZOrder::DIALOGUE_BACKGROUND
          },
          {
            color: colors[:pop_up_menu_background],
            height: Coordinates::ERROR_DIALOGUE_HEIGHT -
              (Coordinates::ERROR_DIALOGUE_BORDER_WIDTH * 2),
            width: Coordinates::ERROR_DIALOGUE_WIDTH -
              (Coordinates::ERROR_DIALOGUE_BORDER_WIDTH * 2),
            x: Coordinates::ERROR_DIALOGUE_LEFT_X + Coordinates::ERROR_DIALOGUE_BORDER_WIDTH,
            y: Coordinates::ERROR_DIALOGUE_TOP_Y + Coordinates::ERROR_DIALOGUE_BORDER_WIDTH,
            z: ZOrder::DIALOGUE_BACKGROUND
          }
        ],
        text: {
          color: colors[:default_text],
          x: Coordinates::ERROR_DIALOGUE_LEFT_X + Coordinates::ERROR_DIALOGUE_BORDER_WIDTH +
            (error_dialogue_button_gap * 5) + error_dialogue_close_button_height,
          z: ZOrder::DIALOGUE_UI
        }
      }

      event_history_edge_button_height = 40
      event_history_button_gap = 5
      event_history_text_height = 83
      event_history_text_initial_y = Coordinates::EVENT_HISTORY_MENU_TOP_Y +
        Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH + event_history_edge_button_height +
        (event_history_button_gap * 3)
      self.event_history_menu_buttons = {
        close: Button.new(
          actions: :toggle_event_history_menu,
          color: nil,
          game: self,
          height: event_history_edge_button_height,
          hover_color: nil,
          hover_image: Image.new(images[:x_hover]),
          image: Image.new(images[:x]),
          image_height: event_history_edge_button_height,
          width: event_history_edge_button_height,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X + Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH +
            event_history_button_gap,
          y: Coordinates::EVENT_HISTORY_MENU_TOP_Y + Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH +
            event_history_button_gap,
          z: ZOrder::POP_UP_MENU_UI
        ),
        down: Button.new(
          actions: [
            proc do
              event_history_view.shift_forward
              set_visible_event_history_menu_buttons if drawing_event_history_menu?
            end
          ],
          color: colors[:pop_up_menu_border],
          game: self,
          height: event_history_edge_button_height,
          hover_color: colors[:pop_up_menu_border],
          hover_image: Image.new(images[:arrow_down_hover]),
          image: Image.new(images[:arrow_down]),
          image_height: event_history_edge_button_height * 0.8,
          image_width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.1,
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.25,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X +
            (Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.375),
          y: Coordinates::EVENT_HISTORY_MENU_BOTTOM_Y -
            Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH - event_history_button_gap -
            event_history_edge_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        events: (0...10).map do |number|
          Button.new(
            actions: nil,
            color: colors[:pop_up_menu_background_alt],
            game: self,
            height: event_history_text_height,
            hover_color: colors[:pop_up_menu_background_light],
            width: Coordinates::EVENT_HISTORY_MENU_WIDTH -
              (Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH * 2) - (event_history_button_gap * 2),
            x: Coordinates::EVENT_HISTORY_MENU_LEFT_X +
              Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH + event_history_button_gap,
            y: event_history_text_initial_y +
              (event_history_text_height + event_history_button_gap) * number,
            z: ZOrder::POP_UP_MENU_UI
          )
        end,
        page_down: Button.new(
          actions: [
            proc do
              event_history_view.shift_forward(10)
              set_visible_event_history_menu_buttons if drawing_event_history_menu?
            end
          ],
          color: colors[:pop_up_menu_border],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          height: event_history_edge_button_height,
          hover_color: colors[:pop_up_menu_border],
          text: 'Page down',
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.25,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X +
            (Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.12),
          y: Coordinates::EVENT_HISTORY_MENU_BOTTOM_Y -
            Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH - event_history_button_gap -
            event_history_edge_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        page_up: Button.new(
          actions: [
            proc do
              event_history_view.shift_back(10)
              set_visible_event_history_menu_buttons if drawing_event_history_menu?
            end
          ],
          color: colors[:pop_up_menu_border],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          height: event_history_edge_button_height,
          hover_color: colors[:pop_up_menu_border],
          text: 'Page up',
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.25,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X +
            (Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.12),
          y: Coordinates::EVENT_HISTORY_MENU_TOP_Y + Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH +
            event_history_button_gap,
          z: ZOrder::POP_UP_MENU_UI
        ),
        skip_to_bottom: Button.new(
          actions: [
            proc do
              event_history_view.full_shift_forward
              set_visible_event_history_menu_buttons if drawing_event_history_menu?
            end
          ],
          color: colors[:pop_up_menu_border],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          height: event_history_edge_button_height,
          hover_color: colors[:pop_up_menu_border],
          text: 'Skip to bottom',
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.25,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X +
            (Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.63),
          y: Coordinates::EVENT_HISTORY_MENU_BOTTOM_Y -
            Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH - event_history_button_gap -
            event_history_edge_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        skip_to_top: Button.new(
          actions: [
            proc do
              event_history_view.full_shift_back
              set_visible_event_history_menu_buttons if drawing_event_history_menu?
            end
          ],
          color: colors[:pop_up_menu_border],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          height: event_history_edge_button_height,
          hover_color: colors[:pop_up_menu_border],
          text: 'Back to top',
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.25,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X +
            (Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.63),
          y: Coordinates::EVENT_HISTORY_MENU_TOP_Y + Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH +
            event_history_button_gap,
          z: ZOrder::POP_UP_MENU_UI
        ),
        up: Button.new(
          actions: [
            proc do
              event_history_view.shift_back
              set_visible_event_history_menu_buttons if drawing_event_history_menu?
            end
          ],
          color: colors[:pop_up_menu_border],
          game: self,
          height: event_history_edge_button_height,
          hover_color: colors[:pop_up_menu_border],
          hover_image: Image.new(images[:arrow_up_hover]),
          image: Image.new(images[:arrow_up]),
          image_height: event_history_edge_button_height * 0.8,
          image_width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.1,
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.25,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X +
            (Coordinates::EVENT_HISTORY_MENU_WIDTH * 0.375),
          y: Coordinates::EVENT_HISTORY_MENU_TOP_Y + Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH +
            event_history_button_gap,
          z: ZOrder::POP_UP_MENU_UI
        )
      }

      self.compass_menu_buttons = (-COMPASS_RANGE..COMPASS_RANGE).map do |number|
        [
          number,
          Button.new(
            actions:
              proc { display_tile(tiles[(tile_indexes[current_tile] + number) % tile_count]) },
            color: nil,
            game: self,
            height: DEFAULT_TILE_BUTTON_HEIGHT,
            highlight_hover_color: colors[:default_button_hover_highlight],
            hover_color: nil,
            image_height: DEFAULT_TILE_BUTTON_HEIGHT,
            width: DEFAULT_TILE_BUTTON_HEIGHT,
            x: Coordinates::CENTER_X,
            y: Coordinates::COMPASS_TOP_Y + COMPASS_BORDER_WIDTH,
            z: ZOrder::MENU_UI
          )
        ]
      end.to_h

      compass_triangle_height = COMPASS_BORDER_WIDTH * 1.5
      self.compass_menu_data = {
        bottom_border: {
          color: colors[:pop_up_menu_border],
          height: COMPASS_BORDER_WIDTH + 1,
          y: Coordinates::COMPASS_TOP_Y + COMPASS_BORDER_WIDTH + DEFAULT_TILE_BUTTON_HEIGHT - 1,
          z: ZOrder::MENU_UI
        },
        inner_circle: Image.new(
          Gosu::Circle.new(
            color: colors[:pop_up_menu_background],
            radius: DEFAULT_TILE_BUTTON_HEIGHT / 2
          )
        ),
        left_circle_params: {
          from_center: true,
          y: Coordinates::COMPASS_TOP_Y + (DEFAULT_TILE_BUTTON_HEIGHT / 2) + COMPASS_BORDER_WIDTH,
          z: ZOrder::MENU_BACKGROUND
        },
        outer_circle: Image.new(
          Gosu::Circle.new(
            color: colors[:pop_up_menu_border],
            radius: (DEFAULT_TILE_BUTTON_HEIGHT / 2) + COMPASS_BORDER_WIDTH
          )
        ),
        point: {
          color: colors[:pop_up_menu_border],
          x1: Coordinates::CENTER_X,
          x2: Coordinates::CENTER_X + compass_triangle_height,
          x3: Coordinates::CENTER_X - compass_triangle_height,
          y1: Coordinates::COMPASS_TOP_Y + COMPASS_BORDER_WIDTH + compass_triangle_height,
          y2: Coordinates::COMPASS_TOP_Y + COMPASS_BORDER_WIDTH,
          y3: Coordinates::COMPASS_TOP_Y + COMPASS_BORDER_WIDTH,
          z: ZOrder::MENU_UI
        },
        right_circle_params: {
          from_center: true,
          y: Coordinates::COMPASS_TOP_Y + (DEFAULT_TILE_BUTTON_HEIGHT / 2) + COMPASS_BORDER_WIDTH,
          z: ZOrder::MENU_BACKGROUND
        },
        tile_background: {
          color: colors[:pop_up_menu_background],
          height: DEFAULT_TILE_BUTTON_HEIGHT,
          y: Coordinates::COMPASS_TOP_Y + COMPASS_BORDER_WIDTH,
          z: ZOrder::MENU_BACKGROUND
        },
        top_border: {
          color: colors[:pop_up_menu_border],
          height: COMPASS_BORDER_WIDTH + 1,
          y: Coordinates::COMPASS_TOP_Y,
          z: ZOrder::MENU_UI
        }
      }

      self.game_menu_buttons = {
        event_history: Button.new(
          actions: :toggle_event_history_menu,
          color: nil,
          game: self,
          height: HEADER_HEIGHT,
          hover_color: colors[:pop_up_menu_background],
          hover_image: Image.new(images[:list]),
          image: Image.new(images[:list]),
          image_height: HEADER_HEIGHT * 0.6,
          image_width: HEADER_HEIGHT * 0.6,
          width: HEADER_HEIGHT,
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::MENU_UI
        ),
        map: Button.new(
          actions: proc { map_menu.open },
          color: nil,
          game: self,
          height: HEADER_HEIGHT,
          hover_color: colors[:pop_up_menu_background],
          hover_image: Image.new(images[:map]),
          image: Image.new(images[:map]),
          image_height: HEADER_HEIGHT * 0.6,
          image_width: HEADER_HEIGHT * 0.6,
          width: HEADER_HEIGHT,
          x: Coordinates::LEFT_X + (HEADER_HEIGHT * 2),
          y: Coordinates::TOP_Y,
          z: ZOrder::MENU_UI
        ),
        player_list: Button.new(
          actions: lambda { player_list_menu.open },
          color: nil,
          game: self,
          height: HEADER_HEIGHT,
          hover_color: colors[:pop_up_menu_background],
          hover_image: Image.new(images[:people]),
          image: Image.new(images[:people]),
          image_height: HEADER_HEIGHT * 0.6,
          image_width: HEADER_HEIGHT * 0.6,
          width: HEADER_HEIGHT,
          x: Coordinates::LEFT_X + HEADER_HEIGHT,
          y: Coordinates::TOP_Y,
          z: ZOrder::MENU_UI
        )
      }

      player_inspector_button_height = DEFAULT_TILE_BUTTON_HEIGHT * 0.75
      player_inspector_button_gap = DEFAULT_TILE_BUTTON_HEIGHT * 0.1
      player_inspector_color_group_offset = player_inspector_button_height +
        player_inspector_button_gap
      player_inspector_color_group_initial_x = Coordinates::PLAYER_INSPECTOR_LEFT_X +
        (player_inspector_color_group_offset * 1.2)
      player_inspector_color_group_color_height = player_inspector_button_height * 0.2
      player_inspector_close_button_height = 40
      player_inspector_close_button_y_offset = Coordinates::PLAYER_INSPECTOR_TOP_Y +
        Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH + player_inspector_close_button_height +
        (player_inspector_button_gap * 1.5)
      player_inspector_left_button_x = Coordinates::PLAYER_INSPECTOR_LEFT_X +
        Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH + (player_inspector_button_gap / 2)
      player_inspector_text_width = Coordinates::PLAYER_INSPECTOR_WIDTH -
        (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2) - (DEFAULT_TILE_BUTTON_HEIGHT * 2) -
        (player_inspector_button_gap * 3)
      player_inspector_money_text_width_difference = (player_inspector_button_height / 2) +
        player_inspector_button_gap
      player_inspector_stats_button_args = {
        actions: nil,
        color: nil,
        font: fonts[:default][:type],
        font_color: colors[:clickable_text],
        game: self,
        height: fonts[:default][:type].height,
        hover_color: nil,
        text_position_x: 0,
        text_relative_position_x: 0,
        width: Coordinates::PLAYER_INSPECTOR_WIDTH,
        y: player_inspector_close_button_y_offset,
        z: ZOrder::POP_UP_MENU_UI
      }
      player_inspector_stats_indent = player_inspector_button_height / 2
      self.player_inspector_buttons = {
        all_properties: CircularButton.new(
          actions: proc { group_menu.open(inspected_player.properties) },
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:all_properties]),
          image: Image.new(images[:all_properties]),
          image_height: player_inspector_button_height * 1.25,
          radius: player_inspector_button_height,
          x: (Coordinates::PLAYER_INSPECTOR_LEFT_X + Coordinates::PLAYER_INSPECTOR_RIGHT_X) / 2,
          y: player_inspector_close_button_y_offset +
            (player_inspector_button_height + player_inspector_button_gap) * 3 +
            player_inspector_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        close: Button.new(
          actions: :toggle_player_inspector,
          color: nil,
          game: self,
          height: player_inspector_close_button_height,
          hover_color: nil,
          hover_image: Image.new(images[:x_hover]),
          image: Image.new(images[:x]),
          image_height: player_inspector_close_button_height,
          width: player_inspector_close_button_height,
          x: player_inspector_left_button_x,
          y: Coordinates::PLAYER_INSPECTOR_TOP_Y + Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH +
            (player_inspector_button_gap / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        color_groups: (0...8).map do |number|
          color_y = player_inspector_close_button_y_offset +
            (player_inspector_button_height + player_inspector_button_gap) * 5 +
            player_inspector_button_height
          count_y = player_inspector_close_button_y_offset +
            (player_inspector_button_height + player_inspector_button_gap) * 4 +
            (player_inspector_button_height * 1.5)

          {
            color: Button.new(
              actions: nil,
              color: nil,
              game: self,
              height: player_inspector_color_group_color_height,
              hover_color: nil,
              width: player_inspector_button_height,
              x: player_inspector_color_group_initial_x +
                (number * player_inspector_color_group_offset) -
                (player_inspector_button_height / 2),
              y: color_y,
              z: ZOrder::POP_UP_MENU_UI
            ),
            count: CircularButton.new(
              actions:
                proc { group_menu.open(player_inspector_color_groups.items[number].tiles) },
              color: colors[:tile_button],
              font: fonts[:default][:type],
              font_color: colors[:clickable_text],
              font_hover_color: colors[:clickable_text_hover],
              game: self,
              hover_color: colors[:tile_button_hover],
              radius: player_inspector_button_height / 2,
              x: player_inspector_color_group_initial_x +
                (number * player_inspector_color_group_offset),
              y: count_y,
              z: ZOrder::POP_UP_MENU_UI
            )
          }
        end,
        color_groups_left: Button.new(
          actions: [
            proc do
              player_inspector_color_groups.shift_back
              set_visible_player_inspector_buttons if drawing_player_inspector?
            end
          ],
          color: nil,
          game: self,
          height: player_inspector_button_height,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_width: player_inspector_button_height * 0.25,
          width: player_inspector_button_height * 0.25,
          x: Coordinates::PLAYER_INSPECTOR_LEFT_X + (player_inspector_button_gap * 2) +
            Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH,
          y: player_inspector_close_button_y_offset +
            (player_inspector_button_height + player_inspector_button_gap) * 4 +
            player_inspector_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        color_groups_right: Button.new(
          actions: [
            proc do
              player_inspector_color_groups.shift_forward
              set_visible_player_inspector_buttons if drawing_player_inspector?
            end
          ],
          color: nil,
          game: self,
          height: player_inspector_button_height,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_width: player_inspector_button_height * 0.25,
          width: player_inspector_button_height * 0.25,
          x: Coordinates::PLAYER_INSPECTOR_RIGHT_X - Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH -
            (player_inspector_button_gap * 2) - (player_inspector_button_height * 0.25),
          y: player_inspector_close_button_y_offset +
            (player_inspector_button_height + player_inspector_button_gap) * 4 +
            player_inspector_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        currently_on: Button.new(
          actions: proc { display_tile(inspected_player.tile) },
          color: nil,
          font: fonts[:title][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          height: player_inspector_button_height,
          hover_color: nil,
          hover_image: Image.new(images[:pinpoint]),
          image: Image.new(images[:pinpoint]),
          image_height: player_inspector_button_height * 0.7,
          image_position_x: 0.05,
          text_position_x: 0.125,
          text_relative_position_x: 0,
          text_relative_width: 0.875,
          width: player_inspector_text_width,
          x: player_inspector_left_button_x,
          y: player_inspector_close_button_y_offset + player_inspector_button_height +
            player_inspector_button_gap,
          z: ZOrder::POP_UP_MENU_UI
        ),
        get_out_of_jail_free: CircularButton.new(
          actions: nil,
          color: nil,
          game: self,
          hover_color: nil,
          hover_image: Image.new(images[:key]),
          image: Image.new(images[:key]),
          image_height: player_inspector_button_height * 0.7,
          radius: player_inspector_button_height / 2,
          x: player_inspector_left_button_x + player_inspector_text_width +
            player_inspector_button_gap + player_inspector_button_height,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 2 + (player_inspector_button_height / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        jail_turns: CircularButton.new(
          actions: nil,
          color: colors[:pop_up_menu_background_light],
          font: fonts[:large][:type],
          font_color: colors[:default_text],
          game: self,
          radius: player_inspector_button_height / 2,
          hover_color: colors[:pop_up_menu_background_light],
          hover_image: Image.new(images[:jail_cell]),
          image: Image.new(images[:jail_cell]),
          image_height: player_inspector_button_height * 0.6,
          x: player_inspector_left_button_x + player_inspector_text_width,
          y: player_inspector_close_button_y_offset +
            (player_inspector_button_height + player_inspector_button_gap) * 2 +
            (player_inspector_button_height / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        message: CircularButton.new(
          actions: nil,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:neutral_blue],
          hover_image: Image.new(images[:message]),
          image: Image.new(images[:message]),
          image_height: (player_inspector_button_height * 0.75),
          radius: player_inspector_button_height,
          x: Coordinates::PLAYER_INSPECTOR_LEFT_X + (player_inspector_button_height * 2) +
            player_inspector_button_gap,
          y: player_inspector_close_button_y_offset +
            (player_inspector_button_height + player_inspector_button_gap) * 6 +
            player_inspector_button_height + player_inspector_color_group_color_height +
            (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2) + (player_inspector_button_gap * 1.5),
          z: ZOrder::POP_UP_MENU_UI
        ),
        money: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:title][:type],
          font_color: colors[:clickable_text],
          game: self,
          height: player_inspector_button_height,
          hover_color: nil,
          hover_image: Image.new(images[:dollar_sign]),
          image: Image.new(images[:dollar_sign]),
          image_height: player_inspector_button_height * 0.7,
          image_position_x: 0.05 +
            (0.05 * player_inspector_money_text_width_difference / player_inspector_text_width),
          text_position_x: 0.125 +
            (0.125 * player_inspector_money_text_width_difference / player_inspector_text_width),
          text_relative_position_x: 0,
          text_relative_width: 1 - 0.125 -
            (0.125 * player_inspector_money_text_width_difference / player_inspector_text_width),
          width: player_inspector_text_width - player_inspector_money_text_width_difference,
          x: player_inspector_left_button_x,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 2,
          z: ZOrder::POP_UP_MENU_UI
        ),
        mortgaged_properties: CircularButton.new(
          actions: proc { group_menu.open(inspected_player.properties.select(&:mortgaged?)) },
          color: nil,
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:mortgage_lock]),
          image: Image.new(images[:mortgage_lock]),
          image_height: player_inspector_button_height * 0.7,
          radius: player_inspector_button_height / 2,
          x: player_inspector_left_button_x + player_inspector_text_width +
            (player_inspector_button_gap * 2) + (player_inspector_button_height * 2),
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 2 + (player_inspector_button_height / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        no_get_out_of_jail_free: CircularButton.new(
          actions: nil,
          color: nil,
          game: self,
          hover_color: nil,
          hover_image: Image.new(images[:no_key]),
          image: Image.new(images[:no_key]),
          image_height: player_inspector_button_height * 0.7,
          radius: player_inspector_button_height / 2,
          x: player_inspector_left_button_x + player_inspector_text_width +
            player_inspector_button_gap + player_inspector_button_height,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 2 + (player_inspector_button_height / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        no_mortgaged_properties: CircularButton.new(
          actions: nil,
          color: nil,
          game: self,
          hover_color: nil,
          hover_image: Image.new(images[:mortgage]),
          image: Image.new(images[:mortgage]),
          image_height: player_inspector_button_height * 0.7,
          radius: player_inspector_button_height / 2,
          x: player_inspector_left_button_x + player_inspector_text_width +
            (player_inspector_button_gap * 2) + (player_inspector_button_height * 2),
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 2 + (player_inspector_button_height / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        player_name: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:big_title][:type],
          font_color: colors[:clickable_text],
          game: self,
          height: player_inspector_button_height,
          hover_color: nil,
          width: player_inspector_text_width,
          x: player_inspector_left_button_x,
          y: player_inspector_close_button_y_offset,
          z: ZOrder::POP_UP_MENU_UI
        ),
        player_token: CircularButton.new(
          actions: nil,
          border_color: colors[:pop_up_menu_border],
          border_hover_color: colors[:pop_up_menu_border],
          border_width: DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          color: colors[:pop_up_menu_background_light],
          game: self,
          hover_color: colors[:pop_up_menu_background_light],
          radius: DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::PLAYER_INSPECTOR_RIGHT_X - Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH -
            DEFAULT_TILE_BUTTON_HEIGHT - player_inspector_button_gap,
          y: Coordinates::PLAYER_INSPECTOR_TOP_Y + Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH +
            DEFAULT_TILE_BUTTON_HEIGHT + player_inspector_button_gap,
          z: ZOrder::POP_UP_MENU_UI
        ),
        railroad_group: CircularButton.new(
          actions: proc { group_menu.open(player_inspector_railroad_groups.items.first.tiles) },
          color: colors[:tile_button],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          hover_color: colors[:tile_button_hover],
          image_height: player_inspector_button_height * 0.75,
          image_position_y: 0.35,
          radius: player_inspector_button_height,
          text_position_y: 0.75,
          x: Coordinates::PLAYER_INSPECTOR_LEFT_X + (player_inspector_button_height * 2) +
            player_inspector_button_gap,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 3 + player_inspector_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        railroad_group_left: Button.new(
          actions: [
            proc do
              player_inspector_railroad_groups.shift_back
              set_visible_player_inspector_buttons if drawing_player_inspector?
            end
          ],
          color: nil,
          game: self,
          height: player_inspector_button_height * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_width: player_inspector_button_height / 2,
          width: player_inspector_button_height / 2,
          x: Coordinates::PLAYER_INSPECTOR_LEFT_X + (player_inspector_button_height / 2),
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 3,
          z: ZOrder::POP_UP_MENU_UI
        ),
        railroad_group_right: Button.new(
          actions: [
            proc do
              player_inspector_railroad_groups.shift_forward
              set_visible_player_inspector_buttons if drawing_player_inspector?
            end
          ],
          color: nil,
          game: self,
          height: player_inspector_button_height * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_width: player_inspector_button_height * 0.5,
          width: player_inspector_button_height * 0.5,
          x: Coordinates::PLAYER_INSPECTOR_LEFT_X + (player_inspector_button_height * 3) +
            (player_inspector_button_gap * 2),
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 3,
          z: ZOrder::POP_UP_MENU_UI
        ),
        show_stats: CircularButton.new(
          actions: proc do
            self.player_inspector_show_stats = true
            set_visible_player_inspector_buttons
          end,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:positive_green],
          hover_image: Image.new(images[:bar_graph]),
          image: Image.new(images[:bar_graph]),
          image_height: player_inspector_button_height,
          radius: player_inspector_button_height,
          x: (Coordinates::PLAYER_INSPECTOR_LEFT_X + Coordinates::PLAYER_INSPECTOR_RIGHT_X) / 2,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 6 + player_inspector_button_height +
            player_inspector_color_group_color_height +
            (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2) +
            (player_inspector_button_gap * 1.5),
          z: ZOrder::POP_UP_MENU_UI
        ),
        stats: [
          {
            function: lambda { |player| format_money(player.total_asset_liquidation_amount) },
            name: 'Net worth'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_gained].values.sum) },
            name: 'Total money gained'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_gained][:buildings]) },
            indent: true,
            name: 'Gained from selling buildings'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_gained][:game]) },
            indent: true,
            name: 'Received from the game'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_gained][:mortgages]) },
            indent: true,
            name: 'Gained from mortgaging properties'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_gained][:rent]) },
            indent: true,
            name: 'Collected in rent'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_gained][:trades]) },
            indent: true,
            name: 'Gained in trades'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_lost].values.sum) },
            name: 'Total money lost'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_lost][:buildings]) },
            indent: true,
            name: 'Spent buying buildings'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_lost][:game]) },
            indent: true,
            name: 'Lost to the game'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_lost][:mortgages]) },
            indent: true,
            name: 'Spent repaying mortgages'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_lost][:properties]) },
            indent: true,
            name: 'Spent buying properties'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_lost][:rent]) },
            indent: true,
            name: 'Spent paying rent'
          },
          {
            function: lambda { |player| format_money(player.stats[:money_lost][:trades]) },
            indent: true,
            name: 'Spent in trades'
          },
          {
            function: lambda { |player| Duration.new(player.stats[:time_played]).to_words },
            name: 'Time played'
          },
          {
            function: lambda { |player| format_number(player.stats[:times_passed_go]) },
            name: 'Times passed Go'
          },
          {
            function: lambda { |player| format_number(player.stats[:turns_in_jail]) },
            name: 'Turns spent in Jail'
          },
          {
            function: lambda { |player| format_number(player.eliminated_on) },
            name: 'Eliminated on turn'
          }
        ].map.with_index do |data, number|
          x = player_inspector_left_button_x
          x += player_inspector_stats_indent if data.delete(:indent)
          y = player_inspector_close_button_y_offset + (fonts[:default][:offset] * number)
          data[:name] = Button.new(
            **player_inspector_stats_button_args.merge(text: "#{data[:name]}:", x: x, y: y)
          )
          data[:value] = Button.new(**player_inspector_stats_button_args.merge(y: y))

          data[:name].width = data[:name].font.text_width(data[:name].text) + 5
          new_x = data[:name].x + data[:name].width + player_inspector_button_gap
          data[:value].width = Coordinates::PLAYER_INSPECTOR_RIGHT_X -
            Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH - player_inspector_button_gap - new_x
          data[:value].update_coordinates(x: new_x)
          data
        end,
        stats_back: CircularButton.new(
          actions: proc do
            self.player_inspector_show_stats = false
            set_visible_player_inspector_buttons
          end,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:neutral_blue],
          hover_image: Image.new(images[:back]),
          image: Image.new(images[:back]),
          image_height: player_inspector_close_button_height * 0.7,
          radius: player_inspector_close_button_height / 2,
          x: Coordinates::PLAYER_INSPECTOR_RIGHT_X - Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH -
            (player_inspector_button_gap / 2) - (player_inspector_close_button_height / 2),
          y: Coordinates::PLAYER_INSPECTOR_TOP_Y + Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH +
            (player_inspector_button_gap / 2) + (player_inspector_close_button_height / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        stats_player_name: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:title][:type],
          font_color: colors[:clickable_text],
          game: self,
          height: player_inspector_close_button_height,
          hover_color: nil,
          width: Coordinates::PLAYER_INSPECTOR_WIDTH -
            (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2) - (player_inspector_button_gap * 3) -
            (player_inspector_close_button_height * 2),
          x: player_inspector_left_button_x + player_inspector_close_button_height +
            player_inspector_button_gap,
          y: Coordinates::PLAYER_INSPECTOR_TOP_Y + Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH +
            (player_inspector_button_gap / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        trade: CircularButton.new(
          actions: nil,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:neutral_yellow],
          hover_image: Image.new(images[:handshake]),
          image: Image.new(images[:handshake]),
          image_height: player_inspector_button_height,
          radius: player_inspector_button_height,
          x: Coordinates::PLAYER_INSPECTOR_RIGHT_X - (player_inspector_button_height * 2) -
            player_inspector_button_gap,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 6 + player_inspector_button_height +
            player_inspector_color_group_color_height +
            (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2) + (player_inspector_button_gap * 1.5),
          z: ZOrder::POP_UP_MENU_UI
        ),
        utility_group: CircularButton.new(
          actions: proc { group_menu.open(player_inspector_utility_groups.items.first.tiles) },
          color: colors[:tile_button],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          hover_color: colors[:tile_button_hover],
          image_height: player_inspector_button_height * 0.75,
          image_position_y: 0.35,
          radius: player_inspector_button_height,
          text_position_y: 0.75,
          x: Coordinates::PLAYER_INSPECTOR_RIGHT_X - (player_inspector_button_height * 2) -
            player_inspector_button_gap,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 3 + player_inspector_button_height,
          z: ZOrder::POP_UP_MENU_UI
        ),
        utility_group_left: Button.new(
          actions: [
            proc do
              player_inspector_utility_groups.shift_back
              set_visible_player_inspector_buttons if drawing_player_inspector?
            end
          ],
          color: nil,
          game: self,
          height: player_inspector_button_height * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_width: player_inspector_button_height / 2,
          width: player_inspector_button_height / 2,
          x: Coordinates::PLAYER_INSPECTOR_RIGHT_X - (player_inspector_button_height * 3.5) -
            (player_inspector_button_gap * 2),
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 3,
          z: ZOrder::POP_UP_MENU_UI
        ),
        utility_group_right: Button.new(
          actions: [
            proc do
              player_inspector_utility_groups.shift_forward
              set_visible_player_inspector_buttons if drawing_player_inspector?
            end
          ],
          color: nil,
          game: self,
          height: player_inspector_button_height * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_width: player_inspector_button_height / 2,
          width: player_inspector_button_height / 2,
          x: Coordinates::PLAYER_INSPECTOR_RIGHT_X - player_inspector_button_height,
          y: player_inspector_close_button_y_offset + (player_inspector_button_height +
            player_inspector_button_gap) * 3,
          z: ZOrder::POP_UP_MENU_UI
        ),
      }

      player_menu_button_gap = PLAYER_MENU_BUTTON_HEIGHT * 0.1
      color_group_offset = PLAYER_MENU_BUTTON_HEIGHT + player_menu_button_gap
      color_group_initial_x = Coordinates::PLAYER_MENU_LEFT_X + color_group_offset
      color_group_color_height = PLAYER_MENU_BUTTON_HEIGHT * 0.2
      next_players_initial_y = Coordinates::PLAYER_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS -
        (DEFAULT_TILE_BUTTON_HEIGHT / 2) - DEFAULT_TILE_BUTTON_BORDER_WIDTH -
        (DEFAULT_TILE_BUTTON_HEIGHT * 0.75) - TILE_BUTTON_GAP
      next_players_y_offset = DEFAULT_TILE_BUTTON_HEIGHT + TILE_BUTTON_GAP
      self.player_menu_buttons = {
        all_properties: CircularButton.new(
          actions: proc { group_menu.open(current_player.properties) },
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:all_properties]),
          image: Image.new(images[:all_properties]),
          image_height: PLAYER_MENU_BUTTON_HEIGHT * 1.25,
          radius: PLAYER_MENU_BUTTON_HEIGHT,
          x: (Coordinates::PLAYER_MENU_LEFT_X + Coordinates::PLAYER_MENU_RIGHT_X) / 2,
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT * 2.5) -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        color_groups: (0...8).map do |number|
          {
            color: Button.new(
              actions: nil,
              color: nil,
              game: self,
              height: color_group_color_height,
              hover_color: nil,
              width: PLAYER_MENU_BUTTON_HEIGHT,
              x: color_group_initial_x +
                (number * color_group_offset - (PLAYER_MENU_BUTTON_HEIGHT / 2)),
              y: Coordinates::PLAYER_MENU_BOTTOM_Y - color_group_color_height,
              z: ZOrder::MENU_UI
            ),
            count: CircularButton.new(
              actions: proc { group_menu.open(player_menu_color_groups.items[number].tiles) },
              color: colors[:tile_button],
              font: fonts[:default][:type],
              font_color: colors[:clickable_text],
              font_hover_color: colors[:clickable_text_hover],
              game: self,
              hover_color: colors[:tile_button_hover],
              radius: PLAYER_MENU_BUTTON_HEIGHT / 2,
              x: color_group_initial_x + (number * color_group_offset),
              y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT / 2) -
                color_group_color_height - player_menu_button_gap,
              z: ZOrder::MENU_UI
            )
          }
        end,
        color_groups_left: Button.new(
          actions: [
            proc do
              player_menu_color_groups.shift_back
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: PLAYER_MENU_BUTTON_HEIGHT,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_width: PLAYER_MENU_BUTTON_HEIGHT * 0.25,
          width: PLAYER_MENU_BUTTON_HEIGHT * 0.25,
          x: Coordinates::PLAYER_MENU_LEFT_X + player_menu_button_gap,
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - PLAYER_MENU_BUTTON_HEIGHT -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        color_groups_right: Button.new(
          actions: [
            proc do
              player_menu_color_groups.shift_forward
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: PLAYER_MENU_BUTTON_HEIGHT,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_width: PLAYER_MENU_BUTTON_HEIGHT * 0.25,
          width: PLAYER_MENU_BUTTON_HEIGHT * 0.25,
          x: Coordinates::PLAYER_MENU_RIGHT_X - PLAYER_MENU_RIGHT_BORDER_WIDTH -
            player_menu_button_gap - (PLAYER_MENU_BUTTON_HEIGHT * 0.25),
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - PLAYER_MENU_BUTTON_HEIGHT -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        get_out_of_jail_free: CircularButton.new(
          actions: :use_get_out_of_jail_free_card,
          color: nil,
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:key]),
          image: Image.new(images[:key]),
          image_height: (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) * 0.7,
          radius: PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          x: Coordinates::PLAYER_MENU_RIGHT_X - (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 3),
          y: Coordinates::PLAYER_MENU_TOP_Y + (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) +
            (DEFAULT_TILE_BUTTON_HEIGHT / 2) + DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MENU_UI
        ),
        money: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:title][:type],
          font_color: colors[:clickable_text],
          game: self,
          height: PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2,
          hover_color: nil,
          text_position_x: 0.05,
          text_relative_position_x: 0,
          text_relative_width: 0.95,
          width: Coordinates::PLAYER_MENU_WIDTH - (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 4),
          x: Coordinates::PLAYER_MENU_LEFT_X,
          y: Coordinates::PLAYER_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS +
            (DEFAULT_TILE_BUTTON_HEIGHT / 2) + DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MENU_UI
        ),
        mortgaged_properties: CircularButton.new(
          actions: proc { group_menu.open(current_player.properties.select(&:mortgaged?)) },
          color: nil,
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:mortgage_lock]),
          image: Image.new(images[:mortgage_lock]),
          image_height: (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) * 0.7,
          radius: PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          x: Coordinates::PLAYER_MENU_RIGHT_X - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          y: Coordinates::PLAYER_MENU_TOP_Y + (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) +
            (DEFAULT_TILE_BUTTON_HEIGHT / 2) + DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MENU_UI
        ),
        next_players: (0...4).map do |number|
          CircularButton.new(
            actions: proc do
              self.inspected_player = next_players.items[number]
              toggle_player_inspector
            end,
            color: colors[:tile_button],
            game: self,
            hover_color: colors[:tile_button_hover],
            radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
            x: Coordinates::PLAYER_MENU_LEFT_X + (DEFAULT_TILE_BUTTON_HEIGHT / 2) +
              DEFAULT_TILE_BUTTON_BORDER_WIDTH,
            y: next_players_initial_y - (next_players_y_offset * number),
            z: ZOrder::MENU_UI
          )
        end,
        next_players_down: Button.new(
          actions: [
            proc do
              next_players.shift_back
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_down_hover]),
          image: Image.new(images[:arrow_down]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
          width: DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::PLAYER_MENU_LEFT_X + DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          y: next_players_initial_y + (DEFAULT_TILE_BUTTON_HEIGHT * 0.5) + (TILE_BUTTON_GAP / 2),
          z: ZOrder::MENU_UI
        ),
        next_players_up: Button.new(
          actions: [
            proc do
              next_players.shift_forward
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_up_hover]),
          image: Image.new(images[:arrow_up]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
          width: DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::PLAYER_MENU_LEFT_X + DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          y: next_players_initial_y - (next_players_y_offset * 3) -
            (DEFAULT_TILE_BUTTON_HEIGHT * 0.75) - (TILE_BUTTON_GAP / 2),
          z: ZOrder::MENU_UI
        ),
        no_get_out_of_jail_free: CircularButton.new(
          actions: nil,
          color: nil,
          game: self,
          hover_color: nil,
          hover_image: Image.new(images[:no_key]),
          image: Image.new(images[:no_key]),
          image_height: (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) * 0.7,
          radius: PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          x: Coordinates::PLAYER_MENU_RIGHT_X - (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 3) ,
          y: Coordinates::PLAYER_MENU_TOP_Y + (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) +
            (DEFAULT_TILE_BUTTON_HEIGHT / 2) + DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MENU_UI
        ),
        no_mortgaged_properties: CircularButton.new(
          actions: nil,
          color: nil,
          game: self,
          hover_color: nil,
          hover_image: Image.new(images[:mortgage]),
          image: Image.new(images[:mortgage]),
          image_height: (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) * 0.7,
          radius: PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          x: Coordinates::PLAYER_MENU_RIGHT_X - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          y: Coordinates::PLAYER_MENU_TOP_Y + (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2) +
            (DEFAULT_TILE_BUTTON_HEIGHT / 2) + DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MENU_UI
        ),
        player_name: Button.new(
          actions: nil,
          color: colors[:pop_up_menu_border],
          font: fonts[:title][:type],
          font_color: colors[:clickable_text],
          game: self,
          height: PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2,
          hover_color: colors[:pop_up_menu_border],
          width: Coordinates::PLAYER_MENU_WIDTH - DEFAULT_TILE_BUTTON_HEIGHT -
            (DEFAULT_TILE_BUTTON_BORDER_WIDTH * 2) - (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2),
          x: Coordinates::PLAYER_MENU_LEFT_X + DEFAULT_TILE_BUTTON_HEIGHT +
            (DEFAULT_TILE_BUTTON_BORDER_WIDTH * 2),
          y: Coordinates::PLAYER_MENU_TOP_Y,
          z: ZOrder::MENU_UI
        ),
        player_token: CircularButton.new(
          actions: proc do
            self.inspected_player = current_player
            toggle_player_inspector
          end,
          border_color: colors[:pop_up_menu_border],
          border_hover_color: colors[:pop_up_menu_border],
          border_width: DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          color: colors[:pop_up_menu_background_light],
          game: self,
          hover_color: colors[:pop_up_menu_background_light_hover],
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::PLAYER_MENU_LEFT_X + (DEFAULT_TILE_BUTTON_HEIGHT / 2) +
            DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          y: Coordinates::PLAYER_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          z: ZOrder::MENU_UI
        ),
        railroad_group: CircularButton.new(
          actions: proc { group_menu.open(player_menu_railroad_groups.items.first.tiles) },
          color: colors[:tile_button],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          hover_color: colors[:tile_button_hover],
          image_height: PLAYER_MENU_BUTTON_HEIGHT * 0.75,
          image_position_y: 0.35,
          radius: PLAYER_MENU_BUTTON_HEIGHT,
          text_position_y: 0.75,
          x: Coordinates::PLAYER_MENU_LEFT_X + (PLAYER_MENU_BUTTON_HEIGHT * 2) +
            player_menu_button_gap,
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT * 2.5) -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        railroad_group_left: Button.new(
          actions: [
            proc do
              player_menu_railroad_groups.shift_back
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: PLAYER_MENU_BUTTON_HEIGHT * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          x: Coordinates::PLAYER_MENU_LEFT_X + (PLAYER_MENU_BUTTON_HEIGHT * 0.5),
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT * 3.5) -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        railroad_group_right: Button.new(
          actions: [
            proc do
              player_menu_railroad_groups.shift_forward
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: PLAYER_MENU_BUTTON_HEIGHT * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          x: Coordinates::PLAYER_MENU_LEFT_X + (PLAYER_MENU_BUTTON_HEIGHT * 3) +
            (player_menu_button_gap * 2),
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT * 3.5) -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        utility_group: CircularButton.new(
          actions: proc { group_menu.open(player_menu_utility_groups.items.first.tiles) },
          color: colors[:tile_button],
          font: fonts[:default][:type],
          font_color: colors[:clickable_text],
          font_hover_color: colors[:clickable_text_hover],
          game: self,
          hover_color: colors[:tile_button_hover],
          image_height: PLAYER_MENU_BUTTON_HEIGHT * 0.75,
          image_position_y: 0.35,
          radius: PLAYER_MENU_BUTTON_HEIGHT,
          text_position_y: 0.75,
          x: Coordinates::PLAYER_MENU_RIGHT_X - (PLAYER_MENU_BUTTON_HEIGHT * 2) -
            player_menu_button_gap,
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT * 2.5) -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        utility_group_left: Button.new(
          actions: [
            proc do
              player_menu_utility_groups.shift_back
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: PLAYER_MENU_BUTTON_HEIGHT * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          x: Coordinates::PLAYER_MENU_RIGHT_X - (PLAYER_MENU_BUTTON_HEIGHT * 3.5) -
            (player_menu_button_gap * 2),
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT * 3.5) -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        ),
        utility_group_right: Button.new(
          actions: [
            proc do
              player_menu_utility_groups.shift_forward
              set_visible_player_menu_buttons if drawing_player_menu?
            end
          ],
          color: nil,
          game: self,
          height: PLAYER_MENU_BUTTON_HEIGHT * 2,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          width: PLAYER_MENU_BUTTON_HEIGHT * 0.5,
          x: Coordinates::PLAYER_MENU_RIGHT_X - (PLAYER_MENU_BUTTON_HEIGHT * 1),
          y: Coordinates::PLAYER_MENU_BOTTOM_Y - (PLAYER_MENU_BUTTON_HEIGHT * 3.5) -
            color_group_color_height - player_menu_button_gap,
          z: ZOrder::MENU_UI
        )
      }

      jail_turns_button_params = {
        actions: nil,
        color: colors[:pop_up_menu_background_light],
        game: self,
        radius: PLAYER_MENU_BUTTON_HEIGHT / 2,
        hover_color: colors[:pop_up_menu_background_light],
        hover_image: Image.new(images[:jail_cell]),
        image: Image.new(images[:jail_cell]),
        image_height: PLAYER_MENU_BUTTON_HEIGHT * 0.6,
        x: Coordinates::PLAYER_MENU_RIGHT_X - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
        y: Coordinates::PLAYER_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
        z: ZOrder::MENU_UI
      }

      if jail_time > DEFAULT_JAIL_TIME
        jail_turns_button_params.merge!(
          border_color: colors[:jail],
          border_hover_color: colors[:jail],
          border_width: DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          font: fonts[:large][:type],
          font_color: colors[:default_text]
        )
      end

      player_menu_buttons[:jail_turns] = CircularButton.new(**jail_turns_button_params)

      jail_bar_gap = player_menu_button_gap * 0.4
      jail_bar_params = {
        color: colors[:jail],
        height: color_group_color_height,
        width: PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2 - jail_bar_gap,
        y: Coordinates::PLAYER_MENU_TOP_Y + (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2),
        z: ZOrder::MENU_UI
      }
      self.player_menu_data = {
        background_params: {
          color: colors[:pop_up_menu_background],
          height: Coordinates::PLAYER_MENU_HEIGHT - (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2),
          width: Coordinates::PLAYER_MENU_WIDTH - PLAYER_MENU_RIGHT_BORDER_WIDTH,
          x: Coordinates::PLAYER_MENU_LEFT_X,
          y: Coordinates::PLAYER_MENU_TOP_Y + (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2),
          z: ZOrder::MENU_BACKGROUND
        },
        jail_bar_count: 0,
        jail_bars: if jail_time <= DEFAULT_JAIL_TIME
          (0...3).map do |number|
            jail_bar_params.merge(
              x: Coordinates::PLAYER_MENU_RIGHT_X - PLAYER_MENU_RIGHT_BORDER_WIDTH -
                ((number + 1) * (PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2)) + jail_bar_gap
            )
          end
        end,
        right_border_params: {
          color: colors[:pop_up_menu_border],
          height: Coordinates::PLAYER_MENU_HEIGHT - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          width: PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          x: Coordinates::PLAYER_MENU_RIGHT_X - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          y: Coordinates::PLAYER_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          z: ZOrder::MENU_BACKGROUND
        },
        rounded_corner_circle: Image.new(
          Gosu::Circle.new(
            color: colors[:pop_up_menu_border],
            radius: PLAYER_MENU_ROUNDED_CORNER_RADIUS
          )
        ),
        rounded_corner_circle_params: {
          from_center: true,
          x: Coordinates::PLAYER_MENU_RIGHT_X - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          y: Coordinates::PLAYER_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          z: ZOrder::MENU_BACKGROUND
        },
        top_border_params: {
          color: colors[:pop_up_menu_border],
          height: PLAYER_MENU_ROUNDED_CORNER_RADIUS * 2,
          width: Coordinates::PLAYER_MENU_WIDTH - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          x: Coordinates::PLAYER_MENU_LEFT_X,
          y: Coordinates::PLAYER_MENU_TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        }
      }

      self.player_inspector_data = {
        rectangles: [
          {
            color: colors[:pop_up_menu_border],
            height: Coordinates::PLAYER_INSPECTOR_HEIGHT,
            stats: true,
            width: Coordinates::PLAYER_INSPECTOR_WIDTH,
            x: Coordinates::PLAYER_INSPECTOR_LEFT_X,
            y: Coordinates::PLAYER_INSPECTOR_TOP_Y,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          },
          {
            color: colors[:pop_up_menu_background],
            height: Coordinates::PLAYER_INSPECTOR_HEIGHT -
              (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2),
            stats: true,
            width: Coordinates::PLAYER_INSPECTOR_WIDTH -
              (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2),
            x: Coordinates::PLAYER_INSPECTOR_LEFT_X + Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH,
            y: Coordinates::PLAYER_INSPECTOR_TOP_Y + Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          },
          {
            color: colors[:pop_up_menu_border],
            height: Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2,
            width: Coordinates::PLAYER_INSPECTOR_WIDTH -
              (Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH * 2),
            x: Coordinates::PLAYER_INSPECTOR_LEFT_X + Coordinates::PLAYER_INSPECTOR_BORDER_WIDTH,
            y: player_inspector_close_button_y_offset + (player_inspector_button_height +
              player_inspector_button_gap) * 5 + player_inspector_button_height +
              player_inspector_color_group_color_height,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        ]
      }

      self.cards = {
        chance: [
          MoneyCard.new(
            amount: -50,
            every_other_player: true,
            game: self,
            image: Image.new('media/images/cards/chairman_of_the_board.png'),
            type: :chance
          ),
          MoneyCard.new(
            amount: 150,
            game: self,
            image: Image.new('media/images/cards/building_and_loan.png'),
            type: :chance
          ),
          GetOutOfJailFreeCard.new(
            game: self,
            image: Image.new('media/images/cards/get_out_of_jail_free_chance.png'),
            type: :chance
          ),
          MoneyCard.new(
            amount: 50,
            game: self,
            image: Image.new('media/images/cards/dividend.png'),
            type: :chance
          ),
          MoneyCard.new(
            amount: -15,
            game: self,
            image: Image.new('media/images/cards/poor_tax.png'),
            type: :chance
          ),
          MoveCard.new(
            game: self,
            go_money: true,
            image: Image.new('media/images/cards/take_a_ride.png'),
            move_value: tiles[:reading_railroad],
            type: :chance
          ),
          MoveCard.new(
            game: self,
            go_money: true,
            image: Image.new('media/images/cards/advance_to_go_chance.png'),
            move_value: tiles[:go],
            type: :chance
          ),
          MoveCard.new(
            game: self,
            image: Image.new('media/images/cards/go_back_3_spaces.png'),
            move_value: -3,
            type: :chance
          ),
          MoveCard.new(
            game: self,
            go_money: true,
            image: Image.new('media/images/cards/advance_to_boardwalk.png'),
            move_value: tiles[:boardwalk],
            type: :chance
          ),
          MoveCard.new(
            game: self,
            image: Image.new('media/images/cards/nearest_railroad.png'),
            move_value: RailroadTile,
            rent_multiplier: 2,
            type: :chance
          ),
          MoveCard.new(
            game: self,
            image: Image.new('media/images/cards/nearest_utility.png'),
            move_value: UtilityTile,
            rent_multiplier: 10,
            type: :chance
          ),
          MoveCard.new(
            game: self,
            image: Image.new('media/images/cards/nearest_railroad.png'),
            move_value: RailroadTile,
            rent_multiplier: 2,
            type: :chance
          ),
          MoveCard.new(
            game: self,
            go_money: true,
            image: Image.new('media/images/cards/advance_to_illinois_ave.png'),
            move_value: tiles[:illinois_avenue],
            type: :chance
          ),
          GoToJailCard.new(
            game: self,
            image: Image.new('media/images/cards/go_to_jail_chance.png'),
            type: :chance
          ),
          PropertyRepairCard.new(
            cost_per_house: 25,
            game: self,
            image: Image.new('media/images/cards/general_repairs.png'),
            type: :chance
          )
        ],
        community_chest: [
          MoveCard.new(
            game: self,
            go_money: true,
            image: Image.new('media/images/cards/advance_to_go_community_chest.png'),
            move_value: tiles[:go],
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 45,
            game: self,
            image: Image.new('media/images/cards/sale_of_stock.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 100,
            game: self,
            image: Image.new('media/images/cards/inherit.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: -100,
            game: self,
            image: Image.new('media/images/cards/hospital.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 50,
            every_other_player: true,
            game: self,
            image: Image.new('media/images/cards/opera.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 20,
            game: self,
            image: Image.new('media/images/cards/income_tax_refund.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 25,
            game: self,
            image: Image.new('media/images/cards/receive_for_services.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: -50,
            game: self,
            image: Image.new('media/images/cards/doctors_fee.png'),
            type: :community_chest
          ),
          GoToJailCard.new(
            game: self,
            image: Image.new('media/images/cards/go_to_jail_community_chest.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 200,
            game: self,
            image: Image.new('media/images/cards/bank_error.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 100,
            game: self,
            image: Image.new('media/images/cards/xmas_fund.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 100,
            game: self,
            image: Image.new('media/images/cards/life_insurance.png'),
            type: :community_chest
          ),
          GetOutOfJailFreeCard.new(
            game: self,
            image: Image.new('media/images/cards/get_out_of_jail_free_community_chest.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: -150,
            game: self,
            image: Image.new('media/images/cards/school_tax.png'),
            type: :community_chest
          ),
          MoneyCard.new(
            amount: 10,
            game: self,
            image: Image.new('media/images/cards/beauty_contest.png'),
            type: :community_chest
          ),
          PropertyRepairCard.new(
            cost_per_house: 40,
            game: self,
            image: Image.new('media/images/cards/street_repairs.png'),
            type: :community_chest
          )
        ]
      }

      cards.values.each(&:shuffle!)

      self.current_tile = self.focused_tile = tiles[0]

      self.event_history = []

      self.turn = 1
      log_event('Turn 1 began.')

      self.eliminated_players = []

      self.player_menu_color_groups = ScrollingList.new(items: color_groups.values, view_size: 8)
      self.player_menu_railroad_groups =
        ScrollingList.new(items: railroad_groups.values, view_size: 1)
      self.player_menu_utility_groups =
        ScrollingList.new(items: utility_groups.values, view_size: 1)
      self.player_inspector_color_groups =
        ScrollingList.new(items: color_groups.values, view_size: 8)
      self.player_inspector_railroad_groups =
        ScrollingList.new(items: railroad_groups.values, view_size: 1)
      self.player_inspector_utility_groups =
        ScrollingList.new(items: utility_groups.values, view_size: 1)
      self.drawing_compass_menu = true
      self.drawing_game_menu = true
      self.drawing_player_menu = true
      self.next_players = ScrollingList.new(items: players[1..-1], view_size: 4)
      self.visible_event_history_menu_buttons = []
      self.visible_player_inspector_buttons = []
      set_visible_compass_menu_buttons
      set_visible_player_menu_buttons

      self.action_menu = ActionMenu.new(self)
      self.deed_menu = DeedMenu.new(self)
      self.dialogue_box_menu = DialogueBoxMenu.new(self)
      self.card_menu = CardMenu.new(self)
      self.group_menu = GroupMenu.new(self)
      self.map_menu = MapMenu.new(self)
      self.options_menu = OptionsMenu.new(self)
      self.player_list_menu = PlayerListMenu.new(self)
      self.tile_menu = TileMenu.new(self)

      self.clock_data = {
        font: fonts[:small][:type],
        text_params: {
          color: colors[:default_text],
          rel_x: 1,
          rel_y: 0.5,
          x: options_menu.buttons[:toggle].x - (DEFAULT_TILE_BUTTON_HEIGHT / 2),
          y: options_menu.buttons[:toggle].y + (HEADER_HEIGHT / 2),
          z: ZOrder::MENU_UI
        }
      }

      set_next_action(:roll_dice_for_move)

      self.previous_time_elapsed = 0
      self.start_time = self.current_player_start_time = current_time
    end

    %i[current_player current_tile].each do |value|
      define_method(:"cache_#{value}") do
        send(:"#{value}_cache=", send(value))
      end

      define_method(:"pop_#{value}_cache") do
        send(:"#{value}=", send(:"#{value}_cache"))
        send(:"#{value}_cache=", nil)
      end
    end

    %i[
      compass_menu
      event_history_menu
      game_menu
      player_inspector
      player_menu
    ].each do |value|
      define_method(:"drawing_#{value}?") do
        send(:"drawing_#{value}")
      end
    end

    def active_buttons(x, y)
      temp_buttons = []
      if drawing_error_dialogue?
        temp_buttons += error_dialogue_buttons.values.reverse

        # Prevent clicking on buttons behind the error dialogue
        # without preventing clicks elsewhere
        return temp_buttons if x >= Coordinates::ERROR_DIALOGUE_LEFT_X &&
          x < Coordinates::ERROR_DIALOGUE_RIGHT_X && y >= Coordinates::ERROR_DIALOGUE_TOP_Y &&
          y < Coordinates::ERROR_DIALOGUE_BOTTOM_Y
      end

      if dialogue_box_menu.drawing?
        temp_buttons += dialogue_box_menu.visible_buttons.reverse
      else
        temp_buttons += options_menu.visible_buttons.reverse

        if drawing_event_history_menu?
          temp_buttons += visible_event_history_menu_buttons.reverse
        elsif group_menu.drawing?
          temp_buttons += group_menu.visible_buttons.reverse
        elsif deed_menu.drawing?
          temp_buttons += deed_menu.visible_buttons.reverse
        elsif player_list_menu.drawing?
          temp_buttons += player_list_menu.visible_buttons.reverse
        elsif drawing_player_inspector?
          temp_buttons += visible_player_inspector_buttons.reverse
        elsif map_menu.drawing?
          temp_buttons += map_menu.visible_buttons.reverse
        else
          temp_buttons +=
            (card_menu.drawing? ? card_menu.visible_buttons : tile_menu.visible_buttons).reverse

          if action_menu.drawing?
            temp_buttons << action_menu.buttons[:minimap] if standard_board?
            temp_buttons += action_menu.visible_buttons.reverse
          end

          temp_buttons += visible_player_menu_buttons.reverse if drawing_player_menu?
          temp_buttons += visible_compass_menu_buttons.reverse if drawing_compass_menu?
          temp_buttons += game_menu_buttons.values.reverse if drawing_game_menu?
        end
      end

      temp_buttons
    end

    def building_sell_percentage
      DEFAULT_BUILDING_SELL_PERCENTAGE
    end

    def current_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def drawing_error_dialogue?
      !error_ticks.nil?
    end

    def drawing_pop_up_menu?
      deed_menu.drawing? || drawing_event_history_menu? || group_menu.drawing? ||
        drawing_player_inspector? || player_list_menu.drawing?
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
          return_new_card if current_card
          close_pop_up_menus
          dialogue_box_menu.close if dialogue_box_menu.drawing?
          move(spaces: -1, collect: false)
          land
          map_menu.update if map_menu.drawing?
        end

      # FOR DEVELOPMENT: Make current player re-land on current tile
      when Gosu::KB_R
        if ctrl_cmd_down?
          return_new_card if current_card
          close_pop_up_menus
          dialogue_box_menu.close if dialogue_box_menu.drawing?
          land
          map_menu.update if map_menu.drawing?
        end

      # FOR DEVELOPMENT: Make current player land exactly 1 tile forward
      when Gosu::KB_N
        if ctrl_cmd_down?
          return_new_card if current_card
          close_pop_up_menus
          dialogue_box_menu.close if dialogue_box_menu.drawing?
          move(spaces: 1, collect: false)
          land
          map_menu.update if map_menu.drawing?
        end

      # FOR DEVELOPMENT: Take $100 away from current player
      when Gosu::KB_MINUS
        if ctrl_cmd_down?
          current_player.money -= 100
          current_player.money = 0 if current_player.money.negative?
          map_menu.drawing? ? map_menu.update : set_visible_player_menu_buttons
        end

      # FOR DEVELOPMENT: Give current player $100
      when Gosu::KB_EQUALS
        if ctrl_cmd_down?
          current_player.money += 100 if ctrl_cmd_down?
          map_menu.drawing? ? map_menu.update : set_visible_player_menu_buttons
        end
      end

      super
    end

    def close
      dialogue_box_menu.open(actions: :exit_game, button_text: 'Exit')
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

    def format_money(amount, dollar_sign: true)
      unit = dollar_sign ? '$' : ''
      formatted_amount = ActiveSupport::NumberHelper.number_to_currency(
        amount,
        strip_insignificant_zeros: true,
        unit: unit
      )
      formatted_amount << '0' if formatted_amount.match?(/\.\d$/)
      formatted_amount
    end

    def format_number(number)
      number.to_s(:delimited)
    end

    def generate_tile_thumbnail(tile)
      Gosu.render(Coordinates::THUMBNAIL_HEIGHT, Coordinates::THUMBNAIL_HEIGHT) do
        Gosu.draw_rect(
          color: Gosu::Color::BLACK,
          height: Coordinates::THUMBNAIL_HEIGHT,
          width: Coordinates::THUMBNAIL_HEIGHT,
          x: 0,
          y: 0,
          z: 0
        )

        offset = 1
        Gosu.draw_rect(
          color: colors[:tile_background],
          height: Coordinates::THUMBNAIL_HEIGHT - (offset * 2),
          width: Coordinates::THUMBNAIL_HEIGHT - (offset * 2),
          x: offset,
          y: offset,
          z: 0
        )
        offset += 2

        if tile.icon
          dimension_params =
            if tile.icon.height > tile.icon.width
              { draw_height: Coordinates::THUMBNAIL_HEIGHT - (offset * 2) }
            else
              { draw_width: Coordinates::THUMBNAIL_HEIGHT - (offset * 2) }
            end

          tile.icon.draw(
            **dimension_params,
            from_center: true,
            x: Coordinates::THUMBNAIL_HEIGHT / 2,
            y: Coordinates::THUMBNAIL_HEIGHT / 2,
            z: 0
          )
        else
          Gosu.draw_rect(
            color: tile.group.color,
            height: Coordinates::THUMBNAIL_HEIGHT - (offset * 4),
            width: Coordinates::THUMBNAIL_HEIGHT - (offset * 4),
            x: offset * 2,
            y: offset * 2,
            z: 0
          )
        end
      end
    end

    def go_money_amount
      DEFAULT_GO_MONEY_AMOUNT
    end

    def handle_click(x, y)
      active_buttons(x, y).each do |button|
        if button.within?(x, y)
          button.perform_actions
          break
        end
      end
    end

    def inspect
      to_s
    end

    def jail_time
      DEFAULT_JAIL_TIME
    end

    def log_event(event)
      text = event.tr("\n", '')
      puts(text)
      event_history.unshift(text: text, time: Time.now).slice!(EVENT_HISTORY_LIMIT..-1)
    end

    def max_house_count
      DEFAULT_MAX_HOUSE_COUNT
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

    def set_next_action(action, message: nil, warning: false)
      action_menu.set_message(
        color: warning ? colors[:warning] : colors[:default_text],
        message: message
      )

      self.next_action = action
      action_menu.update
    end

    def standard_board?
      return @standard_board unless @standard_board.nil?

      corners, middles = tile_indexes.keys.partition { |tile| tile_indexes[tile] % 10 == 0 }
      @standard_board = tile_count == 40 && middles.none?(&:corner?) &&
        corners.all? { |tile| tile.corner? && !tile.is_a?(PropertyTile) }
    end

    def ticks_for_seconds(seconds)
      seconds * 60
    end

    def time_elapsed
      Duration.new((previous_time_elapsed + current_time - start_time).floor).to_numbers
    end

    def update_current_player_time_played
      current_player.stats[:time_played] += (current_time - current_player_start_time).floor
      self.current_player_start_time = current_time
    end
  end
end

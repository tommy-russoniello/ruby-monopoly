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

    attr_accessor :action_menu_buttons
    attr_accessor :action_menu_data
    attr_accessor :card_menu_buttons
    attr_accessor :cards
    attr_accessor :clock_data
    attr_accessor :color_groups
    attr_accessor :colors
    attr_accessor :compass_menu_buttons
    attr_accessor :compass_menu_data
    attr_accessor :current_card
    attr_accessor :current_map_tile
    attr_accessor :current_map_tile_button
    attr_accessor :current_player
    attr_accessor :current_player_cache
    attr_accessor :current_player_index
    attr_accessor :current_player_landed
    attr_accessor :current_player_start_time
    attr_accessor :current_tile
    attr_accessor :current_tile_cache
    attr_accessor :deed_data
    attr_accessor :deed_menu_buttons
    attr_accessor :deed_rent_line_index
    attr_accessor :dialogue_box_buttons
    attr_accessor :die_a
    attr_accessor :die_b
    attr_accessor :drawing_action_menu
    attr_accessor :drawing_card_menu
    attr_accessor :drawing_compass_menu
    attr_accessor :drawing_deed_menu
    attr_accessor :drawing_dialogue_box
    attr_accessor :drawing_event_history_menu
    attr_accessor :drawing_game_menu
    attr_accessor :drawing_group_menu
    attr_accessor :drawing_map_menu
    attr_accessor :drawing_options_menu
    attr_accessor :drawing_player_inspector
    attr_accessor :drawing_player_list_menu
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
    attr_accessor :group_menu_alt_button_positions
    attr_accessor :group_menu_buttons
    attr_accessor :group_menu_tiles
    attr_accessor :images
    attr_accessor :inspected_player
    attr_accessor :map_menu_buttons
    attr_accessor :map_menu_data
    attr_accessor :map_menu_first_tile_index
    attr_accessor :map_menu_last_tile_index
    attr_accessor :map_menu_tiles
    attr_accessor :next_action
    attr_accessor :next_players
    attr_accessor :options_button
    attr_accessor :options_menu_buttons
    attr_accessor :options_menu_bar_paramaters
    attr_accessor :player_inspector_buttons
    attr_accessor :player_inspector_color_groups
    attr_accessor :player_inspector_data
    attr_accessor :player_inspector_railroad_groups
    attr_accessor :player_inspector_show_stats
    attr_accessor :player_inspector_utility_groups
    attr_accessor :player_list_menu_buttons
    attr_accessor :player_list_menu_data
    attr_accessor :player_list_menu_players
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
    attr_accessor :tile_menu_buttons
    attr_accessor :tile_menu_data
    attr_accessor :tiles
    attr_accessor :turn
    attr_accessor :utility_groups
    attr_accessor :visible_action_menu_buttons
    attr_accessor :visible_card_menu_buttons
    attr_accessor :visible_compass_menu_buttons
    attr_accessor :visible_deed_menu_buttons
    attr_accessor :visible_event_history_menu_buttons
    attr_accessor :visible_group_menu_buttons
    attr_accessor :visible_map_menu_buttons
    attr_accessor :visible_player_inspector_buttons
    attr_accessor :visible_player_list_menu_buttons
    attr_accessor :visible_player_menu_buttons
    attr_accessor :visible_tile_menu_buttons

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

      dialogue_box_button_width =
        (Coordinates::DIALOGUE_BOX_WIDTH - (DIALOGUE_BOX_BUTTON_GAP * 3)) / 2

      action_menu_inner_border_width = 10
      action_menu_outer_border_width = 20
      transluscent_white = Gosu::Color::WHITE.dup
      transluscent_white.alpha = 175
      self.action_menu_data = {
        background_params: {
          color: colors[:pop_up_menu_background],
          height: Coordinates::ACTION_MENU_HEIGHT - (Coordinates::THUMBNAIL_HEIGHT * 2) -
            action_menu_inner_border_width - action_menu_outer_border_width,
          width: Coordinates::ACTION_MENU_WIDTH - (Coordinates::THUMBNAIL_HEIGHT * 2) -
            action_menu_inner_border_width - action_menu_outer_border_width,
          x: Coordinates::ACTION_MENU_LEFT_X + Coordinates::THUMBNAIL_HEIGHT + 20,
          y: Coordinates::ACTION_MENU_TOP_Y + Coordinates::THUMBNAIL_HEIGHT + 20,
          z: ZOrder::MENU_BACKGROUND
        },
        bottom_border_params: {
          color: colors[:pop_up_menu_border],
          height: 10,
          width: Coordinates::ACTION_MENU_WIDTH,
          x: Coordinates::ACTION_MENU_LEFT_X,
          y: Coordinates::ACTION_MENU_BOTTOM_Y - action_menu_inner_border_width,
          z: ZOrder::MENU_BACKGROUND
        },
        left_border_params: {
          color: colors[:pop_up_menu_border],
          height: Coordinates::ACTION_MENU_HEIGHT,
          width: action_menu_outer_border_width,
          x: Coordinates::ACTION_MENU_LEFT_X,
          y: Coordinates::ACTION_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          z: ZOrder::MENU_BACKGROUND
        },
        minimap_current_tile_dot_circle: Image.new(
          Gosu::Circle.new(
            color: Gosu::Color::BLACK,
            radius: 10
          )
        ),
        minimap_current_tile_dot_circle_params: {
          from_center: true,
          z: ZOrder::MENU_UI
        },
        minimap_current_tile_highlight_params: {
          color: transluscent_white,
          height: Coordinates::THUMBNAIL_HEIGHT,
          width: Coordinates::THUMBNAIL_HEIGHT,
          z: ZOrder::MENU_UI
        },
        rounded_corner_circle: Image.new(
          Gosu::Circle.new(
            color: colors[:pop_up_menu_border],
            radius: PLAYER_MENU_ROUNDED_CORNER_RADIUS
          )
        ),
        rounded_corner_circle_params: {
          from_center: true,
          x: Coordinates::ACTION_MENU_LEFT_X + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          y: Coordinates::ACTION_MENU_TOP_Y + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          z: ZOrder::MENU_BACKGROUND
        },
        right_border_params: {
          color: colors[:pop_up_menu_border],
          height: Coordinates::ACTION_MENU_HEIGHT,
          width: action_menu_inner_border_width,
          x: Coordinates::ACTION_MENU_RIGHT_X - action_menu_inner_border_width,
          y: Coordinates::ACTION_MENU_TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        },
        top_border_params: {
          color: colors[:pop_up_menu_border],
          height: PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          width: Coordinates::ACTION_MENU_WIDTH - PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          x: Coordinates::ACTION_MENU_LEFT_X + PLAYER_MENU_ROUNDED_CORNER_RADIUS,
          y: Coordinates::ACTION_MENU_TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        }
      }

      minimap_image = Image.new(generate_minimap_image)
      minimap_center_x = Coordinates::ACTION_MENU_LEFT_X + action_menu_outer_border_width +
        (minimap_image.width / 2)
      minimap_center_y = Coordinates::ACTION_MENU_TOP_Y + action_menu_outer_border_width +
        (minimap_image.height / 2)
      self.action_menu_data.merge!(
        dice_background_params: {
          color: colors[:pop_up_menu_border],
          height: DEFAULT_TILE_BUTTON_HEIGHT + (TILE_BUTTON_GAP * 2),
          width: (DEFAULT_TILE_BUTTON_HEIGHT * 2) + (TILE_BUTTON_GAP * 4),
          x: minimap_center_x - (TILE_BUTTON_GAP * 2) - DEFAULT_TILE_BUTTON_HEIGHT,
          y: minimap_center_y,
          z: ZOrder::MENU_UI
        },
        die_a_params: {
          draw_height: DEFAULT_TILE_BUTTON_HEIGHT,
          draw_width: DEFAULT_TILE_BUTTON_HEIGHT,
          x: minimap_center_x - TILE_BUTTON_GAP - DEFAULT_TILE_BUTTON_HEIGHT,
          y: minimap_center_y + TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        },
        die_b_params: {
          draw_height: DEFAULT_TILE_BUTTON_HEIGHT,
          draw_width: DEFAULT_TILE_BUTTON_HEIGHT,
          x: minimap_center_x + TILE_BUTTON_GAP,
          y: minimap_center_y + TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        },
        die_images: {
          1 => Image.new(images[:die_1]),
          2 => Image.new(images[:die_2]),
          3 => Image.new(images[:die_3]),
          4 => Image.new(images[:die_4]),
          5 => Image.new(images[:die_5]),
          6 => Image.new(images[:die_6])
        }
      )

      unless standard_board?
        action_menu_data[:background_params].merge!(
          height: Coordinates::ACTION_MENU_HEIGHT - action_menu_inner_border_width -
            action_menu_outer_border_width,
          width: Coordinates::ACTION_MENU_WIDTH - action_menu_inner_border_width -
            action_menu_outer_border_width,
          x: Coordinates::ACTION_MENU_LEFT_X + 20,
          y: Coordinates::ACTION_MENU_TOP_Y + 20
        )
      end

      self.action_menu_buttons = {
        consecutive_charge: CircularButton.new(
          actions: nil,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:dollar_sign]),
          image: Image.new(images[:dollar_sign]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - TILE_BUTTON_GAP - (DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        draw_card: Button.new(
          actions: :draw_card,
          font: fonts[:default][:type],
          game: self,
          text: 'Draw Card',
          x: Coordinates::CENTER_X - (Button::DEFAULT_WIDTH / 2),
          y: Coordinates::CENTER_Y + (Coordinates::TILE_HEIGHT / 2) + TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        ),
        end_turn: CircularButton.new(
          actions: :end_turn,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:checkbox_checked]),
          image: Image.new(images[:checkbox_checked]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - TILE_BUTTON_GAP - (DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        go_to_jail: Button.new(
          actions: :go_to_jail,
          font: fonts[:default][:type],
          game: self,
          text: 'Go To Jail',
          x: Coordinates::CENTER_X - (Button::DEFAULT_WIDTH / 2),
          y: Coordinates::CENTER_Y + (Coordinates::TILE_HEIGHT / 2) + TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        ),
        no_action: CircularButton.new(
          actions: nil,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - TILE_BUTTON_GAP - (DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        pay_rent: CircularButton.new(
          actions: :pay_rent,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:dollar_sign]),
          image: Image.new(images[:dollar_sign]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - TILE_BUTTON_GAP - (DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        pay_tax: CircularButton.new(
          actions: :pay_tax,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:dollar_sign]),
          image: Image.new(images[:dollar_sign]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - TILE_BUTTON_GAP - (DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        roll_dice_for_move: CircularButton.new(
          actions: [[:roll_dice], [:move], [:land]],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:dice]),
          image: Image.new(images[:dice]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - TILE_BUTTON_GAP - (DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        roll_dice_for_rent: CircularButton.new(
          actions: [[:roll_dice], [:land]],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:dice]),
          image: Image.new(images[:dice]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - TILE_BUTTON_GAP - (DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        show_card: Button.new(
          actions: :toggle_card_menu,
          font: fonts[:default][:type],
          game: self,
          text: 'Show Card',
          x: Coordinates::CENTER_X - (Button::DEFAULT_WIDTH / 2),
          y: Coordinates::CENTER_Y + (Coordinates::TILE_HEIGHT / 2) + TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        )
      }
      if standard_board?
        action_menu_buttons[:minimap] = Button.new(
          actions: :toggle_map_menu,
          color: nil,
          deadzones: [action_menu_data[:background_params].slice(:height, :width, :x, :y)],
          game: self,
          height: minimap_image.height,
          highlight_hover_color: colors[:button_hover_highlight_light],
          hover_color: nil,
          hover_image: minimap_image,
          image: minimap_image,
          width: minimap_image.width,
          x: Coordinates::ACTION_MENU_LEFT_X + action_menu_outer_border_width,
          y: Coordinates::ACTION_MENU_TOP_Y + action_menu_outer_border_width,
          z: ZOrder::MENU_BACKGROUND
        )
      end

      self.options_button = Button.new(
        actions: :toggle_options_menu,
        color: nil,
        game: self,
        height: HEADER_HEIGHT,
        hover_color: nil,
        hover_image: Image.new(images[:options_gear_hover]),
        image_height: HEADER_HEIGHT * 0.9,
        image_width: HEADER_HEIGHT * 0.9,
        image: Image.new(images[:options_gear]),
        width: HEADER_HEIGHT,
        x: Coordinates::RIGHT_X - HEADER_HEIGHT,
        y: Coordinates::TOP_Y,
        z: ZOrder::POP_UP_MENU_UI
      )
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

      options_menu_buttons.values.each.with_index do |options_menu_button, index|
        options_menu_button.update_coordinates(
          x: options_button.x - Button::DEFAULT_WIDTH + 10,
          y: options_button.y + (index * (Button::DEFAULT_HEIGHT + 1)) +
            options_button.height + 1,
          z: ZOrder::POP_UP_MENU_UI
        )
      end

      self.dialogue_box_buttons = {
        cancel: Button.new(
          actions: :toggle_dialogue_box,
          font: fonts[:default][:type],
          game: self,
          hover_color: colors[:dialogue_box_button_hover],
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
          hover_color: colors[:dialogue_box_button_hover],
          text: 'Cancel',
          width: dialogue_box_button_width,
          x: Coordinates::DIALOGUE_BOX_RIGHT_X - DIALOGUE_BOX_BUTTON_GAP -
            dialogue_box_button_width,
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
        hover_image: Image.new(images[:house]),
        image: Image.new(images[:house]),
        image_height: DEFAULT_TILE_BUTTON_HEIGHT,
        image_width: DEFAULT_TILE_BUTTON_HEIGHT * 1.1,
        width: DEFAULT_TILE_BUTTON_HEIGHT * 1.1,
        x: Coordinates::FIRST_HOUSE_BUTTON_X,
        z: ZOrder::MAIN_UI
      }
      build_house_button_options = {
        actions: :build_house,
        hover_image: Image.new(images[:build_house_hover]),
        image: Image.new(images[:build_house])
      }
      sell_house_button_options = {
        actions: :sell_house,
        hover_image: Image.new(images[:sell_house_hover]),
        image: Image.new(images[:sell_house])
      }

      house_button_offset = house_button_options[:image_height] + TILE_BUTTON_GAP
      house_buttons = []
      build_house_buttons = []
      sell_house_buttons = []
      (0..max_house_count).map do |offset_multiplier|
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
      tile_menu_back_button_radius = 30

      self.tile_menu_buttons = {
        back: CircularButton.new(
          actions: :back_to_current_tile,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:neutral_blue],
          hover_image: Image.new(images[:back]),
          image: Image.new(images[:back]),
          image_height: tile_menu_back_button_radius * 1.4,
          radius: tile_menu_back_button_radius,
          x: 0,
          y: 0,
          z: ZOrder::MAIN_UI
        ),
        build_house: build_house_buttons,
        build_house_arrow: Button.new(
          actions: :build_house,
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_up_hover]),
          image: Image.new(images[:arrow_up]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::FIRST_HOUSE_BUTTON_X,
          y: Coordinates::FIRST_HOUSE_BUTTON_Y,
          z: ZOrder::MAIN_UI
        ),
        buy: CircularButton.new(
          actions: :buy,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:positive_green],
          hover_image: Image.new(images[:dollar_sign]),
          image: Image.new(images[:dollar_sign]),
          image_height: TOKEN_HEIGHT,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::BUY_BUTTON_X,
          y: Coordinates::BUY_BUTTON_Y,
          z: ZOrder::MAIN_UI
        ),
        house: house_buttons,
        house_with_number: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:large][:type],
          font_color: colors[:house_count],
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT,
          hover_color: nil,
          hover_image: Image.new(images[:house]),
          image: Image.new(images[:house]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT,
          text_relative_position_y: 0.4,
          width: DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::FIRST_HOUSE_BUTTON_X,
          y: Coordinates::FIRST_HOUSE_BUTTON_Y + (DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        ),
        mortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: :mortgage,
            hover_image: Image.new(images[:mortgage_hover]),
            image: Image.new(images[:mortgage])
          )
        ),
        mortgage_lock: Button.new(
          mortgage_lock_button_options.merge(
            actions: nil,
            hover_image: Image.new(images[:mortgage_lock]),
            image: Image.new(images[:mortgage_lock])
          )
        ),
        owner: CircularButton.new(
          actions: proc do
            return unless focused_tile.owner

            self.inspected_player = focused_tile.owner
            toggle_player_inspector
          end,
          game: self,
          hover_color: colors[:tile_button_hover],
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::TILE_OWNER_TOKEN_X,
          y: Coordinates::TILE_OWNER_TOKEN_Y,
          z: ZOrder::MAIN_UI
        ),
        sell_house: sell_house_buttons,
        sell_house_arrow: Button.new(
          actions: :sell_house,
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_down_hover]),
          image: Image.new(images[:arrow_down]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::FIRST_HOUSE_BUTTON_X,
          y: Coordinates::FIRST_HOUSE_BUTTON_Y + (DEFAULT_TILE_BUTTON_HEIGHT * 1.45),
          z: ZOrder::MAIN_UI
        ),
        show_deed: CircularButton.new(
          actions: :toggle_deed_menu,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:blank_deed]),
          image: Image.new(images[:blank_deed]),
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
        show_players: CircularButton.new(
          actions: proc do
            toggle_player_list_menu(players.select { |player| player.tile == focused_tile })
          end,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:people]),
          image: Image.new(images[:people]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: 0,
          y: 0,
          z: ZOrder::MAIN_UI
        ),
        unmortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: :unmortgage,
            hover_image: Image.new(images[:unmortgage_hover]),
            image: Image.new(images[:unmortgage])
          )
        )
      }

      self.tile_menu_data = {
        back: {
          corner: {
            x: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_X +
              (Coordinates::TILE_HEIGHT - Coordinates::TILE_WIDTH) / 2,
            y: Coordinates::BUY_BUTTON_Y -
              ((DEFAULT_TILE_BUTTON_HEIGHT / 2) - tile_menu_back_button_radius)
          },
          middle: {
            x: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_X,
            y: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_Y
          }
        },
        show_players: {
          corner: {
            x: Coordinates::BUY_BUTTON_X -
              (Coordinates::TILE_HEIGHT - Coordinates::TILE_WIDTH) / 2,
            y: Coordinates::BUY_BUTTON_Y
          },
          middle: {
            non_property: {
              x: Coordinates::BUY_BUTTON_X,
              y: Coordinates::BUY_BUTTON_Y,
            },
            property: {
              x: Coordinates::BUY_BUTTON_X,
              y: Coordinates::BUY_BUTTON_Y + ((DEFAULT_TILE_BUTTON_HEIGHT + TILE_BUTTON_GAP) * 3),
            }
          }
        }
      }

      group_menu_tile_button_options = {
        actions: nil,
        color: nil,
        game: self,
        height: Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT,
        hover_color: colors[:blur],
        width: Coordinates::GROUP_MENU_TILE_BUTTON_WIDTH,
        z: ZOrder::POP_UP_MENU_UI
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
          hover_image: Image.new(images[:x_hover]),
          image: Image.new(images[:x]),
          image_height: 40,
          width: 40,
          x: Coordinates::GROUP_MENU_LEFT_X + Coordinates::GROUP_MENU_BORDER_WIDTH + 5,
          y: Coordinates::GROUP_MENU_TOP_Y + Coordinates::GROUP_MENU_BORDER_WIDTH + 5,
          z: ZOrder::POP_UP_MENU_UI
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
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_height: 40,
          radius: 30,
          x: Coordinates::GROUP_MENU_LEFT_X + arrow_button_x_offset,
          y: Coordinates::GROUP_MENU_FIRST_TILE_Y +
            (Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT / 2),
          z: ZOrder::POP_UP_MENU_UI
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
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_height: 40,
          radius: 30,
          x: Coordinates::GROUP_MENU_RIGHT_X - arrow_button_x_offset,
          y: Coordinates::GROUP_MENU_FIRST_TILE_Y +
            (Coordinates::GROUP_MENU_TILE_BUTTON_HEIGHT / 2),
          z: ZOrder::POP_UP_MENU_UI
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
              hover_image: Image.new(images[:arrow_up_hover]),
              image: Image.new(images[:arrow_up]),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              width: DEFAULT_TILE_BUTTON_HEIGHT,
              x: x + group_menu_sub_button_edge,
              y: group_menu_sub_button_y,
              z: group_menu_tile_button_options[:z]
            ),
            house_big: Button.new(
              actions: nil,
              color: nil,
              font: fonts[:large][:type],
              font_color: colors[:house_count],
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Image.new(images[:house]),
              image: Image.new(images[:house]),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT,
              text_relative_position_y: 0.4,
              width: DEFAULT_TILE_BUTTON_HEIGHT,
              x: x + group_menu_sub_button_edge,
              y: group_menu_sub_button_y,
              z: group_menu_tile_button_options[:z]
            ),
            house_small: Button.new(
              actions: nil,
              color: nil,
              font: fonts[:large][:type],
              font_color: colors[:house_count],
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              hover_color: nil,
              hover_image: Image.new(images[:house]),
              image: Image.new(images[:house]),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              text_relative_position_y: 0.4,
              width: DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              x: x + group_menu_sub_button_edge + ((DEFAULT_TILE_BUTTON_HEIGHT * 0.55) / 2),
              y: group_menu_sub_button_y + DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              z: group_menu_tile_button_options[:z]
            ),
            owner: CircularButton.new(
              actions: proc do
                index = number
                index -= 1 if group_menu_tiles.all_items.size <= 2
                self.inspected_player = group_menu_tiles.items[index].owner
                toggle_player_inspector
              end,
              color: colors[:tile_button],
              game: self,
              hover_color: colors[:tile_button_hover],
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
              hover_image: Image.new(images[:mortgage_hover]),
              image: Image.new(images[:mortgage]),
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
              hover_image: Image.new(images[:mortgage_lock]),
              image: Image.new(images[:mortgage_lock]),
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
              hover_image: Image.new(images[:arrow_down_hover]),
              image: Image.new(images[:arrow_down]),
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
              hover_image: Image.new(images[:unmortgage_hover]),
              image: Image.new(images[:unmortgage]),
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
          hover_image: Image.new(images[:x_hover]),
          image: Image.new(images[:x]),
          image_height: 40,
          width: 40,
          x: Coordinates::DEED_MENU_LEFT_X + Coordinates::DEED_MENU_BORDER_WIDTH + 5,
          y: Coordinates::DEED_MENU_TOP_Y + Coordinates::DEED_MENU_BORDER_WIDTH + 5,
          z: ZOrder::POP_UP_MENU_UI
        ),
        down: Button.new(
          actions: [
            proc do
              self.deed_rent_line_index += 1
              set_visible_deed_menu_buttons if drawing_deed_menu?
            end
          ],
          color: nil,
          game: self,
          height: fonts[:deed][:offset],
          hover_color: nil,
          hover_image: Image.new(images[:arrow_down_hover]),
          image: Image.new(images[:arrow_down]),
          image_height: fonts[:deed][:offset],
          width: Coordinates::DEED_WIDTH * 0.75,
          x: Coordinates::CENTER_X - Coordinates::DEED_WIDTH * 0.4,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.125) +
            (fonts[:deed][:offset] * 5),
          z: ZOrder::POP_UP_MENU_UI
        ),
        up: Button.new(
          actions: [
            proc do
              self.deed_rent_line_index -= 1
              set_visible_deed_menu_buttons if drawing_deed_menu?
            end
          ],
          color: nil,
          game: self,
          height: fonts[:deed][:offset],
          hover_color: nil,
          hover_image: Image.new(images[:arrow_up_hover]),
          image: Image.new(images[:arrow_up]),
          image_height: fonts[:deed][:offset],
          width: Coordinates::DEED_WIDTH * 0.75,
          x: Coordinates::CENTER_X - Coordinates::DEED_WIDTH * 0.4,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.125) +
            (fonts[:deed][:offset] * 2),
          z: ZOrder::POP_UP_MENU_UI
        )
      }

      self.card_menu_buttons = {
        back: CircularButton.new(
          actions: :back_to_current_tile,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:neutral_blue],
          hover_image: Image.new(images[:back]),
          image: Image.new(images[:back]),
          image_height: 42,
          radius: 30,
          x: Coordinates::CENTER_X + (Coordinates::CARD_WIDTH / 2) - 30,
          y: Coordinates::CENTER_Y + (Coordinates::CARD_HEIGHT / 2) + 35,
          z: ZOrder::MAIN_UI
        ),
        continue: Button.new(
          actions: :use_new_card,
          font: fonts[:default][:type],
          game: self,
          text: 'Continue',
          width: 300,
          x: Coordinates::CENTER_X - 150,
          y: Coordinates::CENTER_Y + (Coordinates::CARD_HEIGHT / 2) + 10
        )
      }

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
          actions: :toggle_map_menu,
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
          actions: :toggle_player_list_menu,
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

      map_menu_tile_center_y =
        standard_board? ? Coordinates::CENTER_Y + 50 : Coordinates::MAP_MENU_TILE_CENTER_Y
      transluscent_white = Gosu::Color::WHITE.dup
      transluscent_white.alpha = 220
      map_menu_toggle_player_tokens_height = DEFAULT_TILE_BUTTON_HEIGHT / 2
      map_menu_toggle_player_tokens_params = {
        color: nil,
        font: fonts[:default][:type],
        font_color: colors[:clickable_text],
        font_hover_color: colors[:clickable_text_hover],
        game: self,
        height: map_menu_toggle_player_tokens_height,
        hover_color: nil,
        image_height: map_menu_toggle_player_tokens_height * 0.6,
        image_position_x: 0.9,
        text: 'Show player tokens',
        text_position_x: 0,
        text_relative_position_x: 0,
        text_relative_width: 0.8,
        width: map_menu_toggle_player_tokens_height * 4.5,
        x: Coordinates::RIGHT_X - (map_menu_toggle_player_tokens_height * 4.5) - 5,
        y: Coordinates::BOTTOM_Y - map_menu_toggle_player_tokens_height - 5,
        z: ZOrder::MAIN_UI
      }
      map_menu_mortgage_lock_button_options = {
        color: nil,
        game: self,
        height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
        hover_color: nil,
        image_height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
        image_width: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
        width: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
        x: Coordinates::CENTER_X - (DEFAULT_TILE_BUTTON_HEIGHT * 0.175),
        y: map_menu_tile_center_y + (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
        z: ZOrder::MAIN_UI
      }
      self.map_menu_buttons = {
        back: Button.new(
          actions: proc do
            self.current_map_tile = nil
            set_visible_map_menu_buttons
          end,
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          hover_color: nil,
          hover_image: Image.new(images[:back]),
          image: Image.new(images[:back_alt]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (Coordinates::MAP_MENU_TILE_WIDTH / 2) - MAP_MENU_BUTTON_GAP -
            (DEFAULT_TILE_BUTTON_HEIGHT / 2),
          y: map_menu_tile_center_y + (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        build_house: Button.new(
          actions: proc { build_house(current_map_tile) },
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_up_hover]),
          image: Image.new(images[:arrow_up]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          width: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (DEFAULT_TILE_BUTTON_HEIGHT / 4),
          y: map_menu_tile_center_y - (DEFAULT_TILE_BUTTON_HEIGHT * 2.025),
          z: ZOrder::MAIN_UI
        ),
        close: Button.new(
          actions: :toggle_map_menu,
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          hover_color: nil,
          hover_image: Image.new(images[:x_hover]),
          image: Image.new(images[:x]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          width: DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          x: Coordinates::LEFT_X + 5,
          y: Coordinates::TOP_Y + 5,
          z: ZOrder::MAIN_UI
        ),
        house: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:large][:type],
          font_color: colors[:house_count],
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          hover_color: nil,
          hover_image: Image.new(images[:house]),
          image: Image.new(images[:house]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          text_relative_position_y: 0.4,
          width: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (DEFAULT_TILE_BUTTON_HEIGHT / 4),
          y: map_menu_tile_center_y - (DEFAULT_TILE_BUTTON_HEIGHT * 1.85),
          z: ZOrder::MAIN_UI
        ),
        money: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:title][:type],
          font_color: colors[:clickable_text],
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT,
          hover_color: nil,
          text_position_x: 0.05,
          text_relative_position_x: 0,
          text_relative_width: 0.95,
          width: DEFAULT_TILE_BUTTON_HEIGHT * 3,
          x: Coordinates::LEFT_X + DEFAULT_TILE_BUTTON_HEIGHT +
            (DEFAULT_TILE_BUTTON_BORDER_WIDTH * 2),
          y: Coordinates::BOTTOM_Y - DEFAULT_TILE_BUTTON_HEIGHT - DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MAIN_UI
        ),
        mortgage: Button.new(
          map_menu_mortgage_lock_button_options.merge(
            actions: proc { mortgage(current_map_tile) },
            hover_image: Image.new(images[:mortgage_hover]),
            image: Image.new(images[:mortgage])
          )
        ),
        mortgage_lock: Button.new(
          map_menu_mortgage_lock_button_options.merge(
            actions: nil,
            hover_image: Image.new(images[:mortgage_lock]),
            image: Image.new(images[:mortgage_lock])
          )
        ),
        open_in_tile_menu: Button.new(
          actions: proc do
            self.focused_tile = current_map_tile
            set_visible_tile_menu_buttons
            toggle_map_menu
          end,
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          hover_color: nil,
          hover_image: Image.new(images[:expand_hover]),
          image: Image.new(images[:expand]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (Coordinates::MAP_MENU_TILE_WIDTH / 2) - MAP_MENU_BUTTON_GAP -
            (DEFAULT_TILE_BUTTON_HEIGHT / 2),
          y: map_menu_tile_center_y + (DEFAULT_TILE_BUTTON_HEIGHT * 0.75) -
            MAP_MENU_BUTTON_GAP,
          z: ZOrder::MAIN_UI
        ),
        owner: CircularButton.new(
          actions: proc do
            return unless current_map_tile.owner

            self.inspected_player = current_map_tile.owner
            toggle_player_inspector
          end,
          game: self,
          hover_color: colors[:tile_button_hover],
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: map_menu_tile_center_y - (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
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
          x: Coordinates::LEFT_X + (DEFAULT_TILE_BUTTON_HEIGHT / 2) +
            DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          y: Coordinates::BOTTOM_Y - (DEFAULT_TILE_BUTTON_HEIGHT / 2) -
            DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MAIN_UI
        ),
        player_tokens_hide: Button.new(
          map_menu_toggle_player_tokens_params.merge(
            actions: proc do
              map_menu_data[:show_player_tokens][current_player] = false
              set_visible_map_menu_buttons
            end,
            hover_image: Image.new(images[:checkbox_checked_hover]),
            image: Image.new(images[:checkbox_checked])
          )
        ),
        player_tokens_show: Button.new(
          map_menu_toggle_player_tokens_params.merge(
            actions: proc do
              map_menu_data[:show_player_tokens][current_player] = true
              set_visible_map_menu_buttons
            end,
            hover_image: Image.new(images[:checkbox_unchecked_hover]),
            image: Image.new(images[:checkbox_unchecked])
          )
        ),
        sell_house: Button.new(
          actions: proc { sell_house(current_map_tile) },
          color: nil,
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          hover_color: nil,
          hover_image: Image.new(images[:arrow_down_hover]),
          image: Image.new(images[:arrow_down]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          width: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (DEFAULT_TILE_BUTTON_HEIGHT / 4),
          y: map_menu_tile_center_y - (DEFAULT_TILE_BUTTON_HEIGHT * 1.3),
          z: ZOrder::MAIN_UI
        ),
        show_deed: CircularButton.new(
          actions: :toggle_deed_menu,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:blank_deed]),
          image: Image.new(images[:blank_deed]),
          image_height: 70,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: map_menu_tile_center_y + (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        show_group: CircularButton.new(
          actions: proc { toggle_group_menu(current_map_tile.group.tiles) },
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:positive_green],
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: map_menu_tile_center_y - (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        show_players: CircularButton.new(
          actions: proc do
            toggle_player_list_menu(players.select { |player| player.tile == current_map_tile })
          end,
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button_hover],
          hover_image: Image.new(images[:people]),
          image: Image.new(images[:people]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: map_menu_tile_center_y + (DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        tile_icon: CircularButton.new(
          actions: nil,
          border_color: colors[:pop_up_menu_border],
          border_hover_color: colors[:pop_up_menu_border],
          border_width: DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          color: colors[:pop_up_menu_background_light],
          game: self,
          hover_color: colors[:pop_up_menu_background_light],
          radius: DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::CENTER_X,
          y: map_menu_tile_center_y,
          z: ZOrder::MAIN_UI
        ),
        tile_name: Button.new(
          actions: nil,
          color: nil,
          font: fonts[:big_title][:type],
          font_color: colors[:clickable_text],
          game: self,
          height: DEFAULT_TILE_BUTTON_HEIGHT,
          hover_color: nil,
          width: Coordinates::MAP_MENU_TILE_WIDTH - (MAP_MENU_BUTTON_GAP * 2),
          x: Coordinates::CENTER_X - (Coordinates::MAP_MENU_TILE_WIDTH / 2) + MAP_MENU_BUTTON_GAP,
          y: map_menu_tile_center_y - (Coordinates::MAP_MENU_TILE_HEIGHT / 2),
          z: ZOrder::MAIN_UI
        ),
        tokens: players.map do |player|
          button = CircularButton.new(
            actions: nil,
            color: transluscent_white,
            game: self,
            hover_color: transluscent_white,
            hover_image: player.token_image.clone,
            image: player.token_image.clone,
            radius: MAP_MENU_BUTTON_HEIGHT / 2,
            z: ZOrder::MAIN_UI
          )
          button.maximize_images_in_square(MAP_MENU_BUTTON_HEIGHT * 0.7)
          [player, button]
        end.to_h,
        unmortgage: Button.new(
          map_menu_mortgage_lock_button_options.merge(
            actions: proc { unmortgage(current_map_tile) },
            hover_image: Image.new(images[:unmortgage_hover]),
            image: Image.new(images[:unmortgage])
          )
        )
      }

      map_menu_tile_height = (DEFAULT_TILE_BUTTON_HEIGHT * 1.4).round
      map_menu_tile_width =
        (map_menu_tile_height / (Coordinates::TILE_HEIGHT / Coordinates::TILE_WIDTH.to_f)).to_i
      owner_button_radius = (map_menu_tile_width * 0.325).round
      edge_length = (map_menu_tile_width * 9) + (map_menu_tile_height * 2)

      inner_rectangle_length = edge_length - (map_menu_tile_height * 2) + 2
      inner_rectangle_width = owner_button_radius + 2
      self.map_menu_data = {
        max_token_buttons_per_tile: {
          jail: 4,
          jail_visiting: 5,
          normal: 4
        },
        player_plus_x_offset_corner: map_menu_tile_height * (5 / 6.0),
        player_plus_x_offset_jail: map_menu_tile_height / 2,
        player_plus_x_offset_normal: map_menu_tile_width * 0.74,
        rectangles: [
          {
            color: colors[:pop_up_menu_background],
            height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
            width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
            x: Coordinates::LEFT_X,
            y: Coordinates::TOP_Y,
            z: ZOrder::MAIN_BACKGROUND
          }
        ],
        show_player_tokens: players.map { |player| [player, true] }.to_h
      }

      # Inner map border
      if standard_board?
        map_menu_data[:rectangles] += [
          {
            color: colors[:pop_up_menu_border],
            height: inner_rectangle_width,
            width: inner_rectangle_length,
            x: Coordinates::CENTER_X - (edge_length / 2) + map_menu_tile_height - 1,
            y: Coordinates::CENTER_Y - (edge_length / 2) + map_menu_tile_height - 1,
            z: ZOrder::MAIN_BACKGROUND
          },
          {
            color: colors[:pop_up_menu_border],
            height: inner_rectangle_length,
            width: inner_rectangle_width,
            x: Coordinates::CENTER_X - (edge_length / 2) + map_menu_tile_height - 1,
            y: Coordinates::CENTER_Y - (edge_length / 2) + map_menu_tile_height - 1,
            z: ZOrder::MAIN_BACKGROUND
          },
          {
            color: colors[:pop_up_menu_border],
            height: inner_rectangle_length,
            width: inner_rectangle_width,
            x: Coordinates::CENTER_X + (edge_length / 2) - map_menu_tile_height -
              owner_button_radius - 1,
            y: Coordinates::CENTER_Y - (edge_length / 2) + map_menu_tile_height - 1,
            z: ZOrder::MAIN_BACKGROUND
          },
          {
            color: colors[:pop_up_menu_border],
            height: inner_rectangle_width,
            width: inner_rectangle_length,
            x: Coordinates::CENTER_X - (edge_length / 2) + map_menu_tile_height - 1,
            y: Coordinates::CENTER_Y + (edge_length / 2) - map_menu_tile_height -
              owner_button_radius - 1,
            z: ZOrder::MAIN_BACKGROUND
          }
        ]
      end

      map_menu_tile_button_params = {
        color: nil,
        game: self,
        height: map_menu_tile_height,
        highlight_hover_color: colors[:default_button_hover_highlight],
        hover_color: nil,
        image_height: map_menu_tile_height,
        z: ZOrder::MAIN_UI
      }

      house_height = map_menu_tile_height * 0.12
      map_menu_houses_button_params = {
        actions: nil,
        color: nil,
        font: fonts[:default][:type],
        font_color: colors[:house_count],
        game: self,
        height: house_height,
        hover_color: nil,
        image_height: house_height,
        width: map_menu_tile_width,
        z: ZOrder::MAIN_UI
      }

      # TODO: Update this check once hotels are implemented
      if max_house_count >= DEFAULT_MAX_HOUSE_COUNT
        map_menu_houses_button_params.merge!(
          font: fonts[:small][:type],
          font_color: colors[:house_count],
          height: house_height * 1.5,
          hover_image: Image.new(images[:house]),
          image: Image.new(images[:house]),
          image_height: house_height * 1.5,
          text_relative_position_y: 0.4,
          text_relative_width: 0.85,
          width: house_height * 1.5
        )
      end

      map_menu_owner_button_params = {
        actions: nil,
        color: Gosu::Color::WHITE,
        game: self,
        hover_color: nil,
        radius: owner_button_radius,
        z: ZOrder::MAIN_UI
      }

      transluscent_warning = colors[:warning].dup
      transluscent_warning.alpha = 50
      map_menu_mortgage_lock_button_params = {
        actions: nil,
        color: transluscent_warning,
        game: self,
        hover_color: transluscent_warning,
        hover_image: Image.new(images[:mortgage_lock]),
        image: Image.new(images[:mortgage_lock]),
        image_height: MAP_MENU_BUTTON_HEIGHT * 0.43,
        radius: MAP_MENU_BUTTON_HEIGHT * 0.3,
        z: ZOrder::MAIN_UI
      }

      map_menu_player_plus_button_params = {
        actions: nil,
        color: transluscent_white,
        font: fonts[:default][:type],
        font_color: colors[:default_text],
        game: self,
        hover_color: transluscent_white,
        radius: MAP_MENU_BUTTON_HEIGHT / 2,
        z: ZOrder::MAIN_UI
      }

      if standard_board?
        map_menu_buttons[:rotate_clockwise] = CircularButton.new(
          actions: [
            proc do
              return unless drawing_map_menu?

              self.map_menu_first_tile_index = (map_menu_first_tile_index - 10) % 40
              set_visible_map_menu_buttons(refresh: true)
            end
          ],
          color: nil,
          game: self,
          hover_color: nil,
          hover_image: Image.new(images[:rotate_clockwise_hover]),
          image: Image.new(images[:rotate_clockwise]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + ((edge_length + DEFAULT_TILE_BUTTON_HEIGHT) / 2) +
            (MAP_MENU_BUTTON_GAP * 3),
          y: Coordinates::CENTER_Y,
          z: ZOrder::MAIN_UI
        )
        map_menu_buttons[:rotate_counterclockwise] = CircularButton.new(
          actions: [
            proc do
              return unless drawing_map_menu?

              self.map_menu_first_tile_index = (map_menu_first_tile_index + 10) % 40
              set_visible_map_menu_buttons(refresh: true)
            end
          ],
          color: nil,
          game: self,
          hover_color: nil,
          hover_image: Image.new(images[:rotate_counterclockwise_hover]),
          image: Image.new(images[:rotate_counterclockwise]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - ((edge_length + DEFAULT_TILE_BUTTON_HEIGHT) / 2) -
            (MAP_MENU_BUTTON_GAP * 3),
          y: Coordinates::CENTER_Y,
          z: ZOrder::MAIN_UI
        )

        map_menu_offsets = {
          houses: {
            0 => {
              x: map_menu_tile_width / 2,
              y:
                # TODO: Update this check once hotels are implemented
                if max_house_count < DEFAULT_MAX_HOUSE_COUNT
                  (map_menu_tile_height * 0.05) + (map_menu_houses_button_params[:height] / 2)
                else
                  (map_menu_tile_height * 0.02) + (map_menu_houses_button_params[:height] / 2)
                end
            }
          },
          mortgage_lock: {
            0 => {
              x: map_menu_tile_width - MAP_MENU_BUTTON_GAP -
                map_menu_mortgage_lock_button_params[:radius],
              y: map_menu_tile_height - MAP_MENU_BUTTON_GAP -
                map_menu_mortgage_lock_button_params[:radius]
            }
          },
          owner: {
            0 => {
              data: { image_position_y: 0.275 },
              x: map_menu_tile_width / 2,
              y: 0
            },
            90 => {
              data: { image_position_x: 0.725 }
            },
            180 => {
              data: { image_position_y: 0.725 }
            },
            270 => {
              data: { image_position_x: 0.275 }
            }
          }
        }

        map_menu_offsets.each do |button_name, data|
          x = data[0][:x]
          y = data[0][:y]
          data.deep_merge!(
            90 => { x: map_menu_tile_height - y, y: x },
            180 => { x: map_menu_tile_width - x, y: map_menu_tile_height - y },
            270 => { x: y, y: map_menu_tile_width - x }
          )
        end

        top = Coordinates::CENTER_Y - (edge_length / 2)
        bottom = Coordinates::CENTER_Y + (edge_length / 2)
        left = Coordinates::CENTER_X - (edge_length / 2)
        right = Coordinates::CENTER_X + (edge_length / 2)

        angle = 270
        x = right - map_menu_tile_height
        y = bottom - map_menu_tile_height
        tile_button_image_width = 0
        update_buttom_params = proc do
          case angle
          when 0
            x -= tile_button_image_width
          when 90
            y -= tile_button_image_width
          when 180
            x += tile_button_image_width
          when 270
            y += tile_button_image_width
          end
        end

        map_menu_buttons[:tiles] = tile_indexes.sort_by { |_, index| index }.map do |tile, index|
          tile_button_image_width = tile.corner? ? map_menu_tile_height : map_menu_tile_width
          tile_button_height = map_menu_tile_height
          tile_button_width = tile_button_image_width

          if angle % 180 == 0
            houses_height = map_menu_houses_button_params[:height]
            houses_width = map_menu_houses_button_params[:width]
          else
            houses_height = map_menu_houses_button_params[:width]
            houses_width = map_menu_houses_button_params[:height]
            tile_button_height, tile_button_width = tile_button_width, tile_button_height
          end

          update_buttom_params.call if angle < 180
          angle = (angle + 90) % 360 if index % 10 == 0

          action = proc do
            if current_map_tile == map_menu_tiles[index]
              self.current_map_tile = nil
            else
              display_tile(map_menu_tiles[index])
            end

            set_visible_map_menu_buttons
          end

          hash = {
            houses: Button.new(
              map_menu_houses_button_params.merge(
                actions: action,
                height: houses_height,
                image_angle: angle,
                text_angle: angle,
                width: houses_width,
                x: x + map_menu_offsets[:houses][angle][:x] - (houses_width / 2),
                y: y + map_menu_offsets[:houses][angle][:y] - (houses_height / 2)
              )
            ),
            mortgage_lock: CircularButton.new(
              map_menu_mortgage_lock_button_params.merge(
                actions: action,
                image_angle: angle,
                x: x + map_menu_offsets[:mortgage_lock][angle][:x],
                y: y + map_menu_offsets[:mortgage_lock][angle][:y]
              )
            ),
            owner: CircularButton.new(
              map_menu_owner_button_params
                .merge(map_menu_offsets[:owner][angle][:data])
                .merge(
                  actions: action,
                  image_angle: angle,
                  x: x + map_menu_offsets[:owner][angle][:x],
                  y: y + map_menu_offsets[:owner][angle][:y]
                )
            ),
            player_plus: CircularButton.new(
              map_menu_player_plus_button_params.merge(actions: action)
            ),
            player_plus_visiting_jail: CircularButton.new(
              map_menu_player_plus_button_params.merge(actions: action)
            ),
            tile: Button.new(
              map_menu_tile_button_params.merge(
                actions: action,
                height: tile_button_height,
                hover_image: tile.tile_image.clone,
                image: tile.tile_image.clone,
                image_angle: angle,
                image_width: tile_button_image_width,
                width: tile_button_width,
                x: x,
                y: y
              )
            )
          }

          update_buttom_params.call if angle >= 180

          hash
        end
      else
        map_menu_buttons[:left] = CircularButton.new(
          actions: [
            proc do
              return unless drawing_map_menu?

              self.map_menu_last_tile_index = nil
              self.map_menu_first_tile_index = (tile_indexes[map_menu_tiles.first] - 1) % tile_count
              set_visible_map_menu_buttons(refresh: true)
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::LEFT_X + DEFAULT_TILE_BUTTON_HEIGHT * 0.3 + 5,
          y: Coordinates::MAP_MENU_CENTER_Y - (DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )
        map_menu_buttons[:page_left] = CircularButton.new(
          actions: [
            proc do
              return unless drawing_map_menu?

              self.map_menu_last_tile_index = nil
              self.map_menu_first_tile_index =
                (tile_indexes[map_menu_tiles.first] - 10) % tile_count
              set_visible_map_menu_buttons(refresh: true)
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:double_arrow_left_hover]),
          image: Image.new(images[:double_arrow_left]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::LEFT_X + DEFAULT_TILE_BUTTON_HEIGHT * 0.3 + 5,
          y: Coordinates::MAP_MENU_CENTER_Y + (DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )
        map_menu_buttons[:page_right] = CircularButton.new(
          actions: [
            proc do
              return unless drawing_map_menu?

              self.map_menu_first_tile_index = nil
              self.map_menu_last_tile_index = (tile_indexes[map_menu_tiles.last] + 10) % tile_count
              set_visible_map_menu_buttons(refresh: true)
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:double_arrow_right_hover]),
          image: Image.new(images[:double_arrow_right]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::RIGHT_X - DEFAULT_TILE_BUTTON_HEIGHT * 0.3 - 5,
          y: Coordinates::MAP_MENU_CENTER_Y  + (DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )
        map_menu_buttons[:right] = CircularButton.new(
          actions: [
            proc do
              return unless drawing_map_menu?

              self.map_menu_first_tile_index = nil
              self.map_menu_last_tile_index = (tile_indexes[map_menu_tiles.last] + 1) % tile_count
              set_visible_map_menu_buttons(refresh: true)
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::RIGHT_X - DEFAULT_TILE_BUTTON_HEIGHT * 0.3 - 5,
          y: Coordinates::MAP_MENU_CENTER_Y - (DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )

        # Make enough buttons to handle the maximum amount that can fit on the screen
        map_menu_buttons[:tiles] =
          (MAP_MENU_TILES_MAX_WIDTH / map_menu_tile_width).floor.times.map do |number|
            action = proc do
              if current_map_tile == map_menu_tiles[number]
                self.current_map_tile = nil
              else
                display_tile(map_menu_tiles[number])
              end

              set_visible_map_menu_buttons
            end

            {
              houses: Button.new(
                map_menu_houses_button_params.merge(
                  actions: action,
                  y:
                    # TODO: Update this check once hotels are implemented
                    if max_house_count < DEFAULT_MAX_HOUSE_COUNT
                      Coordinates::MAP_MENU_CENTER_Y - (map_menu_tile_height * 0.45)
                    else
                      Coordinates::MAP_MENU_CENTER_Y - (map_menu_tile_height * 0.48)
                    end
                )
              ),
              mortgage_lock: CircularButton.new(
                map_menu_mortgage_lock_button_params.merge(
                  actions: action,
                  y: Coordinates::MAP_MENU_CENTER_Y + (map_menu_tile_height / 2) -
                    MAP_MENU_BUTTON_GAP - map_menu_mortgage_lock_button_params[:radius]
                )
              ),
              owner: CircularButton.new(
                map_menu_owner_button_params.merge(
                  actions: action,
                  image_position_y: 0.275,
                  y: Coordinates::MAP_MENU_CENTER_Y - (map_menu_tile_height / 2)
                )
              ),
              player_plus: CircularButton.new(
                map_menu_player_plus_button_params.merge(
                  actions: action,
                  y: Coordinates::MAP_MENU_CENTER_Y + (MAP_MENU_BUTTON_HEIGHT) + MAP_MENU_BUTTON_GAP
                )
              ),
              player_plus_visiting_jail: CircularButton.new(
                map_menu_player_plus_button_params.merge(
                  actions: action,
                  y: Coordinates::MAP_MENU_CENTER_Y
                )
              ),
              tile: Button.new(
                map_menu_tile_button_params.merge(
                  actions: action,
                  y: Coordinates::MAP_MENU_CENTER_Y - (map_menu_tile_height / 2),
                )
              )
            }
          end
      end

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
          actions: proc { toggle_group_menu(inspected_player.properties) },
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
                proc { toggle_group_menu(player_inspector_color_groups.items[number].tiles) },
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
          actions: proc { toggle_group_menu(inspected_player.properties.select(&:mortgaged?)) },
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
          actions: proc { toggle_group_menu(player_inspector_railroad_groups.items.first.tiles) },
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
            player_inspector_stats_button_args.merge(text: "#{data[:name]}:", x: x, y: y)
          )
          data[:value] = Button.new(player_inspector_stats_button_args.merge(y: y))

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
          actions: proc { toggle_group_menu(player_inspector_utility_groups.items.first.tiles) },
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

      player_list_menu_button_gap = DEFAULT_TILE_BUTTON_HEIGHT * 0.075
      player_list_menu_token_y = Coordinates::PLAYER_LIST_MENU_TOP_Y +
        (Coordinates::PLAYER_LIST_MENU_HEIGHT / 3)
      self.player_list_menu_buttons = {
        close: Button.new(
          actions: :toggle_player_list_menu,
          color: nil,
          game: self,
          height: 40,
          hover_color: nil,
          hover_image: Image.new(images[:x_hover]),
          image: Image.new(images[:x]),
          image_height: 40,
          width: 40,
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH + 5,
          y: Coordinates::PLAYER_LIST_MENU_TOP_Y + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH + 5,
          z: ZOrder::POP_UP_MENU_UI
        ),
        left: CircularButton.new(
          actions: [
            proc do
              player_list_menu_players.shift_back
              set_visible_player_list_menu_buttons if drawing_player_list_menu?
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:arrow_left_hover]),
          image: Image.new(images[:arrow_left]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.2,
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH +
            player_list_menu_button_gap + (DEFAULT_TILE_BUTTON_HEIGHT * 0.2),
          y: (Coordinates::PLAYER_LIST_MENU_BOTTOM_Y + Coordinates::PLAYER_LIST_MENU_TOP_Y) / 2,
          z: ZOrder::POP_UP_MENU_UI
        ),
        right: CircularButton.new(
          actions: [
            proc do
              player_list_menu_players.shift_forward
              set_visible_player_list_menu_buttons if drawing_player_list_menu?
            end
          ],
          color: colors[:tile_button],
          game: self,
          hover_color: colors[:tile_button],
          hover_image: Image.new(images[:arrow_right_hover]),
          image: Image.new(images[:arrow_right]),
          image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.2,
          x: Coordinates::PLAYER_LIST_MENU_RIGHT_X - Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH -
            player_list_menu_button_gap - (DEFAULT_TILE_BUTTON_HEIGHT * 0.2),
          y: (Coordinates::PLAYER_LIST_MENU_BOTTOM_Y + Coordinates::PLAYER_LIST_MENU_TOP_Y) / 2,
          z: ZOrder::POP_UP_MENU_UI
        ),
        players: (0...8).map do |number|
          {
            message: CircularButton.new(
              actions: nil,
              color: colors[:tile_button],
              game: self,
              hover_color: colors[:neutral_blue],
              hover_image: Image.new(images[:message]),
              image: Image.new(images[:message]),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.26,
              radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
              x: 0,
              y: player_list_menu_token_y + (DEFAULT_TILE_BUTTON_HEIGHT * 1.8) +
                (player_list_menu_button_gap * 2),
              z: ZOrder::POP_UP_MENU_UI
            ),
            name: Button.new(
              actions: nil,
              color: nil,
              font: fonts[:default][:type],
              font_color: colors[:clickable_text],
              game: self,
              height: DEFAULT_TILE_BUTTON_HEIGHT * 0.5,
              hover_color: nil,
              width: DEFAULT_TILE_BUTTON_HEIGHT * 2,
              x: 0,
              y: player_list_menu_token_y + DEFAULT_TILE_BUTTON_HEIGHT +
                player_list_menu_button_gap,
              z: ZOrder::POP_UP_MENU_UI
            ),
            token: CircularButton.new(
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
              radius: DEFAULT_TILE_BUTTON_HEIGHT,
              x: 0,
              y: player_list_menu_token_y,
              z: ZOrder::POP_UP_MENU_UI
            ),
            trade: CircularButton.new(
              actions: nil,
              color: colors[:tile_button],
              game: self,
              hover_color: colors[:neutral_yellow],
              hover_image: Image.new(images[:handshake]),
              image: Image.new(images[:handshake]),
              image_height: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
              radius: DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
              x: 0,
              y: player_list_menu_token_y + (DEFAULT_TILE_BUTTON_HEIGHT * 1.8) +
                (player_list_menu_button_gap * 2),
              z: ZOrder::POP_UP_MENU_UI
            )
          }
        end
      }

      self.player_list_menu_data = {
        initial_x: Coordinates::PLAYER_LIST_MENU_LEFT_X +
          Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH + player_list_menu_button_gap +
          (DEFAULT_TILE_BUTTON_HEIGHT * 1.475),
        offset: (DEFAULT_TILE_BUTTON_HEIGHT * 2) + (DEFAULT_TILE_BUTTON_BORDER_WIDTH * 2) +
          player_list_menu_button_gap
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
          actions: proc { toggle_group_menu(current_player.properties) },
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
              actions: proc { toggle_group_menu(player_menu_color_groups.items[number].tiles) },
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
          actions: proc { toggle_group_menu(current_player.properties.select(&:mortgaged?)) },
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
          actions: proc { toggle_group_menu(player_menu_railroad_groups.items.first.tiles) },
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
          actions: proc { toggle_group_menu(player_menu_utility_groups.items.first.tiles) },
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

      player_menu_buttons[:jail_turns] = CircularButton.new(jail_turns_button_params)

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

      self.clock_data = {
        font: fonts[:small][:type],
        text_params: {
          color: colors[:default_text],
          rel_x: 1,
          rel_y: 0.5,
          x: options_button.x - (DEFAULT_TILE_BUTTON_HEIGHT / 2),
          y: options_button.y + (HEADER_HEIGHT / 2),
          z: ZOrder::MENU_UI
        }
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

      self.deed_data = {}
      self.deed_rent_line_index = 1

      self.eliminated_players = []

      self.group_menu_tiles = ScrollingList.new(items: [], view_size: 4)
      self.group_menu_alt_button_positions = false
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
      self.player_list_menu_players = ScrollingList.new(items: [], view_size: 8)
      self.drawing_action_menu = true
      self.drawing_compass_menu = true
      self.drawing_game_menu = true
      self.drawing_player_menu = true
      self.next_players = ScrollingList.new(items: players[1..-1], view_size: 4)
      self.visible_card_menu_buttons = []
      self.visible_deed_menu_buttons = []
      self.visible_event_history_menu_buttons = []
      self.visible_group_menu_buttons = []
      self.visible_map_menu_buttons = []
      self.visible_player_inspector_buttons = []
      self.visible_player_list_menu_buttons = []
      set_next_action(:roll_dice_for_move)
      set_visible_compass_menu_buttons
      set_visible_tile_menu_buttons
      set_visible_player_menu_buttons

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
      action_menu
      card_menu
      compass_menu
      deed_menu
      dialogue_box
      event_history_menu
      game_menu
      group_menu
      map_menu
      options_menu
      player_inspector
      player_list_menu
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

      if drawing_dialogue_box?
        temp_buttons += dialogue_box_buttons.values
      else
        temp_buttons = [options_button]
        temp_buttons += options_menu_buttons.values.reverse if drawing_options_menu?

        if drawing_event_history_menu?
          temp_buttons += visible_event_history_menu_buttons.reverse
        elsif drawing_group_menu?
          temp_buttons += visible_group_menu_buttons.reverse
        elsif drawing_deed_menu?
          temp_buttons += visible_deed_menu_buttons.reverse
        elsif drawing_player_list_menu?
          temp_buttons += visible_player_list_menu_buttons.reverse
        elsif drawing_player_inspector?
          temp_buttons += visible_player_inspector_buttons.reverse
        elsif drawing_map_menu?
          temp_buttons += visible_map_menu_buttons.reverse
        else
          temp_buttons +=
            (drawing_card_menu? ? visible_card_menu_buttons : visible_tile_menu_buttons).reverse

          if drawing_action_menu?
            temp_buttons << action_menu_buttons[:minimap] if standard_board?
            temp_buttons += visible_action_menu_buttons.reverse
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
      drawing_deed_menu? || drawing_event_history_menu? || drawing_group_menu? ||
        drawing_player_inspector? || drawing_player_list_menu?
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
          toggle_dialogue_box if drawing_dialogue_box?
          move(spaces: -1, collect: false)
          land
          set_visible_map_menu_buttons if drawing_map_menu?
        end

      # FOR DEVELOPMENT: Make current player re-land on current tile
      when Gosu::KB_R
        if ctrl_cmd_down?
          return_new_card if current_card
          close_pop_up_menus
          toggle_dialogue_box if drawing_dialogue_box?
          land
          set_visible_map_menu_buttons if drawing_map_menu?
        end

      # FOR DEVELOPMENT: Make current player land exactly 1 tile forward
      when Gosu::KB_N
        if ctrl_cmd_down?
          return_new_card if current_card
          close_pop_up_menus
          toggle_dialogue_box if drawing_dialogue_box?
          move(spaces: 1, collect: false)
          land
          set_visible_map_menu_buttons if drawing_map_menu?
        end

      # FOR DEVELOPMENT: Take $100 away from current player
      when Gosu::KB_MINUS
        if ctrl_cmd_down?
          current_player.money -= 100
          current_player.money = 0 if current_player.money.negative?
          drawing_map_menu? ? set_visible_map_menu_buttons : set_visible_player_menu_buttons
        end

      # FOR DEVELOPMENT: Give current player $100
      when Gosu::KB_EQUALS
        if ctrl_cmd_down?
          current_player.money += 100 if ctrl_cmd_down?
          drawing_map_menu? ? set_visible_map_menu_buttons : set_visible_player_menu_buttons
        end
      end

      super
    end

    def close
      toggle_dialogue_box(actions: :exit_game, button_text: 'Exit')
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

    def generate_minimap_image
      action_menu_data[:minimap_coordinates] = {}
      Gosu.render(Coordinates::THUMBNAIL_HEIGHT * 11, Coordinates::THUMBNAIL_HEIGHT * 11) do
        x = Coordinates::THUMBNAIL_HEIGHT * 10
        y = Coordinates::THUMBNAIL_HEIGHT * 10

        x_offsets = [-Coordinates::THUMBNAIL_HEIGHT, 0, Coordinates::THUMBNAIL_HEIGHT, 0]
        y_offsets = [0, -Coordinates::THUMBNAIL_HEIGHT, 0, Coordinates::THUMBNAIL_HEIGHT]

        tiles_to_draw = tile_indexes.keys
        tiles_to_draw.each_slice(10).with_index do |sub_tiles_to_draw, index|
          sub_tiles_to_draw.each do |tile|
            action_menu_data[:minimap_coordinates][tile] = { x: x, y: y }
            tile.thumbnail.draw(x: x, y: y, z: 0)
            x += x_offsets[index]
            y += y_offsets[index]
          end
        end
      end
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
      action_menu_data[:message] = message
      action_menu_data[:message_color] = warning ? colors[:warning] : colors[:default_text]

      self.next_action = action
      set_visible_action_menu_buttons
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

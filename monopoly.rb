require 'gosu'
require 'byebug'
require 'active_support'
require 'active_support/core_ext/numeric/conversions'
require 'rb-readline'
require 'securerandom'

require_relative 'gosu/image'

require_relative 'button'
require_relative 'card'
require_relative 'game_actions'
require_relative 'player'
require_relative 'player_actions'
require_relative 'tile'
require_relative 'tile_group'
require_relative 'user_interface'

module Coordinates
  TOP_Y = 0
  BOTTOM_Y = 1080
  LEFT_X = 0
  RIGHT_X = 1920
  CENTER_X = 960
  CENTER_Y = 540

  DIALOGUE_BOX_TOP_Y = 390
  DIALOGUE_BOX_BOTTOM_Y = 690
  DIALOGUE_BOX_LEFT_X = 660
  DIALOGUE_BOX_RIGHT_X = 1260
  DIALOGUE_BOX_HEIGHT = DIALOGUE_BOX_BOTTOM_Y - DIALOGUE_BOX_TOP_Y
  DIALOGUE_BOX_WIDTH = DIALOGUE_BOX_RIGHT_X - DIALOGUE_BOX_LEFT_X

  INSPECTOR_TOP_Y = 275
  INSPECTOR_BOTTOM_Y = 965
  INSPECTOR_LEFT_X = 480
  INSPECTOR_RIGHT_X = 1440
  INSPECTOR_HEIGHT = INSPECTOR_BOTTOM_Y - INSPECTOR_TOP_Y
  INSPECTOR_WIDTH = INSPECTOR_RIGHT_X - INSPECTOR_LEFT_X

  BUTTON_1_X = RIGHT_X - Button::DEFAULT_WIDTH
  BUTTON_1_Y = BOTTOM_Y - Button::DEFAULT_HEIGHT
  BUTTON_2_X = RIGHT_X - Button::DEFAULT_WIDTH
  BUTTON_2_Y = BOTTOM_Y - (Button::DEFAULT_HEIGHT * 2 + 1)
end

module ZOrder
  MAIN_BACKGROUND,
    MAIN_UI,
    MENU_BACKGROUND,
    MENU_UI,
    BLUR,
    DIALOGUE_BACKGROUND,
    DIALOGUE_UI = *0..6
end

class Monopoly < Gosu::Window
  include GameActions
  include PlayerActions
  include UserInterface

  BUILDING_SELL_PERCENTAGE = 0.5
  GO_MONEY_AMOUNT = 200
  JAIL_TIME = 3

  attr_accessor :buttons
  attr_accessor :cards
  attr_accessor :color_groups
  attr_accessor :colors
  attr_accessor :current_card
  attr_accessor :current_player
  attr_accessor :current_player_cache
  attr_accessor :current_player_index
  attr_accessor :current_tile
  attr_accessor :current_tile_cache
  attr_accessor :dialogue_box_buttons
  attr_accessor :die_a
  attr_accessor :die_b
  attr_accessor :draw_dialogue_box
  attr_accessor :draw_inspector
  attr_accessor :draw_options_menu
  attr_accessor :fonts
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
  attr_accessor :tiles
  attr_accessor :turn
  attr_accessor :utilities_group
  attr_accessor :visible_buttons_cache
  attr_accessor :visible_buttons

  def initialize
    super(1920, 1080, fullscreen: ARGV.include?('-f'))

    self.caption = 'Monopoly'

    self.fonts = {
      dialogue: { type: Gosu::Font.new(50), offset: 55 },
      default: { type: Gosu::Font.new(DEFAULT_FONT_SIZE), offset: 35 },
      title: { type: Gosu::Font.new(50), offset: 55 }
    }

    self.colors = {
      blur: Gosu::Color.new(200, 200, 200, 200),
      default_button: Gosu::Color::WHITE,
      default_button_hover: Gosu::Color.new(255, 219, 219, 219),
      default_text: Gosu::Color::YELLOW,
      dialogue_box_background: Gosu::Color::BLACK,
      dialogue_box_text: Gosu::Color::WHITE,
      inspector_background: Gosu::Color.new(255, 192, 206, 193),
      inspector_text: Gosu::Color::BLACK,
      options_menu_button: Gosu::Color.new(255, 153, 153, 153),
      options_menu_button_hover: Gosu::Color.new(255, 95, 95, 95),
      property_button_selected: Gosu::Color.new(255, 127, 158, 209),
      property_button_selected_hover: Gosu::Color.new(255, 105, 130, 170),
      warning: Gosu::Color.new(255, 214, 19, 19)
    }

    self.color_groups = {
      brown: ColorGroup.new(
        color: Gosu::Color.new(255, 149, 84, 54),
        house_cost: 50,
        name: 'brown'
      ),
      light_blue: ColorGroup.new(
        color: Gosu::Color.new(255, 0, 114, 187),
        house_cost: 200,
        name: 'light blue'
      )
    }

    self.railroads_group = TileGroup.new(name: 'Railroads')
    self.utilities_group = TileGroup.new(name: 'Utilities')

    self.tile_count = 0
    self.tiles = {}
    self.tile_indexes = {}
    [
      GoTile.new(
        name: 'Go',
        tile_image: Gosu::Image.new('images/tiles/go.jpg')
      ),
      StreetTile.new(
        deed_image: Gosu::Image.new('images/deeds/mediterranean_avenue.jpg'),
        group: color_groups[:brown],
        name: 'Mediterranean Avenue',
        purchase_price: 60,
        rent_scale: [2, 10, 30, 90, 160, 250],
        tile_image: Gosu::Image.new('images/tiles/mediterranean_avenue.png'),
        window: self
      ),
      StreetTile.new(
        deed_image: Gosu::Image.new('images/deeds/baltic_avenue.jpg'),
        group: color_groups[:brown],
        name: 'Baltic Avenue',
        purchase_price: 60,
        rent_scale: [4, 20, 60, 180, 320, 450],
        tile_image: Gosu::Image.new('images/tiles/baltic_avenue.png'),
        window: self
      ),
      RailroadTile.new(
        deed_image: Gosu::Image.new('images/deeds/reading_railroad.jpg'),
        group: railroads_group,
        name: 'Reading Railroad',
        purchase_price: 200,
        rent_scale: [25, 50, 100, 200],
        tile_image: Gosu::Image.new('images/tiles/reading_railroad.png'),
        window: self
      ),
      CardTile.new(
        card_type: :chance,
        name: 'Chance',
        tile_image: Gosu::Image.new('images/tiles/chance_1.jpg')
      ),
      JailTile.new(
        name: 'Jail',
        tile_image: Gosu::Image.new('images/tiles/jail.jpg')
      ),
      UtilityTile.new(
        deed_image: Gosu::Image.new('images/deeds/electric_company.jpg'),
        group: utilities_group,
        name: 'Electric Company',
        purchase_price: 150,
        rent_multiplier_scale: [4, 10],
        tile_image: Gosu::Image.new('images/tiles/electric_company.png'),
        window: self
      ),
      RailroadTile.new(
        deed_image: Gosu::Image.new('images/deeds/pennsylvania_railroad.jpg'),
        group: railroads_group,
        name: 'Pennsylvania Railroad',
        purchase_price: 200,
        rent_scale: [25, 50, 100, 200],
        tile_image: Gosu::Image.new('images/tiles/pennsylvania_railroad.png'),
        window: self
      ),
      CardTile.new(
        card_type: :community_chest,
        name: 'Community Chest',
        tile_image: Gosu::Image.new('images/tiles/community_chest.jpg')
      ),
      FreeParkingTile.new(
        name: 'Free Parking',
        tile_image: Gosu::Image.new('images/tiles/free_parking.jpg')
      ),
      UtilityTile.new(
        deed_image: Gosu::Image.new('images/deeds/water_works.jpg'),
        group: utilities_group,
        name: 'Water Works',
        purchase_price: 150,
        rent_multiplier_scale: [4, 10],
        tile_image: Gosu::Image.new('images/tiles/water_works.png'),
        window: self
      ),
      GoToJailTile.new(
        name: 'Go To Jail',
        tile_image: Gosu::Image.new('images/tiles/gotojail.jpg')
      ),
      StreetTile.new(
        group: color_groups[:light_blue],
        deed_image: Gosu::Image.new('images/deeds/park_place.jpg'),
        name: 'Park Place',
        purchase_price: 350,
        rent_scale: [35, 175, 500, 1100, 1300, 1500],
        tile_image: Gosu::Image.new('images/tiles/park_place.png'),
        window: self
      ),
      TaxTile.new(
        name: 'Luxury Tax',
        tax_amount: 75,
        tile_image: Gosu::Image.new('images/tiles/luxury_tax.jpg')
      ),
      StreetTile.new(
        group: color_groups[:light_blue],
        deed_image: Gosu::Image.new('images/deeds/boardwalk.jpg'),
        name: 'Boardwalk',
        purchase_price: 400,
        rent_scale: [50, 200, 600, 1400, 1700, 2000],
        tile_image: Gosu::Image.new('images/tiles/boardwalk.png'),
        window: self
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
          actions: [:display_property, tile],
          font: fonts[:default][:type],
          text: tile.name,
          width: Button::DEFAULT_WIDTH + (Button::DEFAULT_WIDTH / 3.to_f),
          window: self
        )
      end
    end

    self.players = [
      Player.new(name: 'Tom', number: 1, money: 200, tile: tiles[:go], window: self),
      Player.new(name: 'Jerry', number: 2, money: 200, tile: tiles[:go], window: self),
      Player.new(name: 'Marahz', number: 3, money: 200, tile: tiles[:go], window: self)
    ]
    self.current_player_index = 0
    self.previous_player_number = -1
    self.current_player = players.first

    dialogue_box_button_width =
      (Coordinates::DIALOGUE_BOX_WIDTH - (DIALOGUE_BOX_BUTTON_GAP * 3)) / 2

    self.buttons = {
      build_house: Button.new(
        actions: :build_house,
        font: fonts[:default][:type],
        text: 'Build House',
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT * 3 + 5),
        z: ZOrder::MENU_UI
      ),
      buy: Button.new(
        actions: :buy,
        font: fonts[:default][:type],
        text: 'Buy',
        window: self,
        x: Coordinates::BUTTON_2_X,
        y: Coordinates::BUTTON_2_Y
      ),
      card_continue: Button.new(
        actions: :use_new_card,
        font: fonts[:default][:type],
        text: 'Continue',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      consecutive_charge: Button.new(
        actions: [],
        font: fonts[:default][:type],
        text: 'Pay',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      continue: Button.new(
        actions: :end_turn,
        font: fonts[:default][:type],
        text: 'Continue',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      draw_card: Button.new(
        actions: :draw_card,
        font: fonts[:default][:type],
        text: 'Draw Card',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      end_turn: Button.new(
        actions: :end_turn,
        font: fonts[:default][:type],
        text: 'End Turn',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      exit_inspector: Button.new(
        actions: :exit_inspector,
        font: fonts[:default][:type],
        text: 'Back',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      go_to_jail: Button.new(
        actions: :go_to_jail,
        font: fonts[:default][:type],
        text: 'Go To Jail',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      mortgage: Button.new(
        actions: :mortgage,
        font: fonts[:default][:type],
        text: 'Mortgage',
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT + 3),
        z: ZOrder::MENU_UI
      ),
      options: Button.new(
        actions: :toggle_options_menu,
        color: nil,
        font: fonts[:default][:type],
        height: 50,
        hover_color: nil,
        hover_image: Gosu::Image.new('images/user_interface/options_gear_hover.png'),
        image: Gosu::Image.new('images/user_interface/options_gear.png'),
        image_height: 45,
        image_width: 45,
        width: 50,
        window: self,
        x: Coordinates::RIGHT_X - 50,
        y: Coordinates::TOP_Y,
        z: ZOrder::MENU_UI
      ),
      pay_rent: Button.new(
        actions: :pay_rent,
        font: fonts[:default][:type],
        text: 'Pay Rent',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      pay_tax: Button.new(
        actions: :pay_tax,
        font: fonts[:default][:type],
        text: 'Pay Tax',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      roll_dice_for_move: Button.new(
        actions: [[:roll_dice], [:move], [:land]],
        font: fonts[:default][:type],
        text: 'Roll Dice',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      roll_dice_for_rent: Button.new(
        actions: [[:roll_dice], [:land]],
        font: fonts[:default][:type],
        text: 'Roll Dice',
        window: self,
        x: Coordinates::BUTTON_1_X,
        y: Coordinates::BUTTON_1_Y
      ),
      sell_house: Button.new(
        actions: :sell_house,
        font: fonts[:default][:type],
        text: 'Sell House',
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT * 2 + 4),
        z: ZOrder::MENU_UI
      ),
      unmortgage: Button.new(
        actions: :unmortgage,
        font: fonts[:default][:type],
        text: 'Unmortgage',
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT + 3),
        z: ZOrder::MENU_UI
      ),
      use_get_out_of_jail_free_card: Button.new(
        actions: :use_get_out_of_jail_free_card,
        font: fonts[:default][:type],
        text: 'Use Get Out Of Jail Free Card',
        window: self,
        x: Coordinates::BUTTON_2_X,
        y: Coordinates::BUTTON_2_Y
      )
    }

    self.options_menu_buttons = {
      save: Button.new(
        actions: :save_game,
        color: colors[:options_menu_button],
        font: fonts[:default][:type],
        hover_color: colors[:options_menu_button_hover],
        text: 'Save',
        window: self
      ),
      exit: Button.new(
        actions: [[:toggle_dialogue_box, actions: :exit_game, button_text: 'Exit']],
        color: colors[:options_menu_button],
        font: fonts[:default][:type],
        hover_color: colors[:options_menu_button_hover],
        text: 'Exit',
        window: self
      ),
      forfeit: Button.new(
        actions: [[:toggle_dialogue_box, actions: :forfeit, button_text: 'Forfeit']],
        color: colors[:options_menu_button],
        font: fonts[:default][:type],
        hover_color: colors[:warning],
        text: 'Forfeit',
        window: self
      )
    }

    set_options_menu_button_coordinates

    self.dialogue_box_buttons = {
      cancel: Button.new(
        actions: :toggle_dialogue_box,
        font: fonts[:default][:type],
        text: 'Cancel',
        width: dialogue_box_button_width,
        window: self,
        x: Coordinates::DIALOGUE_BOX_LEFT_X + DIALOGUE_BOX_BUTTON_GAP,
        y: Coordinates::DIALOGUE_BOX_BOTTOM_Y - Button::DEFAULT_HEIGHT - 10,
        z: ZOrder::DIALOGUE_UI
      ),
      action: Button.new(
        actions: :toggle_dialogue_box,
        font: fonts[:default][:type],
        text: 'Cancel',
        width: dialogue_box_button_width,
        window: self,
        x: Coordinates::DIALOGUE_BOX_RIGHT_X - DIALOGUE_BOX_BUTTON_GAP - dialogue_box_button_width,
        y: Coordinates::DIALOGUE_BOX_BOTTOM_Y - Button::DEFAULT_HEIGHT - 10,
        z: ZOrder::DIALOGUE_UI
      )
    }

    self.cards = {
      chance: [
        MoneyCard.new(
          amount: -50,
          every_other_player: true,
          image: Gosu::Image.new('images/cards/chairman_of_the_board.jpg'),
          type: :chance,
          window: self
        ),
        MoveCard.new(
          image: Gosu::Image.new('images/cards/go_back_3_spaces.jpg'),
          move_value: -3,
          type: :chance,
          window: self
        ),
        MoveCard.new(
          image: Gosu::Image.new('images/cards/nearest_utility.jpg'),
          move_value: UtilityTile,
          rent_multiplier: 10,
          type: :chance,
          window: self
        ),
        MoneyCard.new(
          amount: -15,
          image: Gosu::Image.new('images/cards/poor_tax.jpg'),
          type: :chance,
          window: self
        ),
        GetOutOfJailFreeCard.new(
          image: Gosu::Image.new('images/cards/get_out_of_jail_free.jpg'),
          type: :chance,
          window: self
        ),
        MoveCard.new(
          image: Gosu::Image.new('images/cards/advance_to_boardwalk.jpg'),
          type: :chance,
          go_money: true,
          move_value: tiles[:boardwalk],
          window: self
        )
      ],
      community_chest: [
        GoToJailCard.new(
          image: Gosu::Image.new('images/cards/go_to_jail_community_chest.jpg'),
          type: :community_chest,
          window: self
        ),
        PropertyRepairCard.new(
          cost_per_house: 40,
          image: Gosu::Image.new('images/cards/street_repairs.jpg'),
          type: :community_chest,
          window: self
        ),
        MoneyCard.new(
          amount: 50,
          every_other_player: true,
          image: Gosu::Image.new('images/cards/opera.jpg'),
          type: :community_chest,
          window: self
        ),
        MoneyCard.new(
          amount: 25,
          image: Gosu::Image.new('images/cards/receive_for_services.jpg'),
          type: :community_chest,
          window: self
        )
      ]
    }

    cards.values.each(&:shuffle!)

    self.current_tile = tiles[0]

    self.messages = []

    self.turn = 1
    add_message('Turn 1...')
    self.die_a = 1
    self.die_b = 1
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

  %i[dialogue_box inspector options_menu].each do |value|
    define_method(:"draw_#{value}?") do
      send(:"draw_#{value}")
    end
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      handle_click(mouse_x, mouse_y)
    when Gosu::KB_ESCAPE
      close

    # FOR DEVELOPMENT: Print out current state of the instance to STDOUT
    when Gosu::KB_P
      print_state if ctrl_cmd_down?

    # FOR DEVELOPMENT: Make current player land exactly 1 tile backward
    when Gosu::KB_B
      if ctrl_cmd_down?
        exit_inspector if draw_inspector?
        self.current_card = nil
        move(spaces: -1, collect: false)
        land
      end

    # FOR DEVELOPMENT: Make current player re-land on current tile
    when Gosu::KB_R
      if ctrl_cmd_down?
        exit_inspector if draw_inspector?
        self.current_card = nil
        land
      end

    # FOR DEVELOPMENT: Make current player land exactly 1 tile forward
    when Gosu::KB_N
      if ctrl_cmd_down?
        exit_inspector if draw_inspector?
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
    actions.each do |action|
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
    if actions.is_a?(Array) && actions.first.is_a?(Array)
      actions
    else
      [actions]
    end
  end

  def format_number(number)
    number.to_s(:delimited)
  end

  def handle_click(x, y)
    buttons_to_check =
      if draw_dialogue_box?
        dialogue_box_buttons.values
      else
        property_buttons = current_player.properties.map { |property| property.button }
        options_buttons = [buttons[:options]]
        options_buttons += options_menu_buttons.values if draw_options_menu?
        visible_buttons + property_buttons + options_buttons
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
end

monopoly = Monopoly.new.show

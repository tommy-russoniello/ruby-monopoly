module Monopoly
  class Button
    DEFAULT_COLOR = Gosu::Color::WHITE.freeze
    DEFAULT_HOVER_COLOR = Gosu::Color.new(255, 219, 219, 219).freeze
    DEFAULT_HEIGHT = 50
    DEFAULT_WIDTH = 275
    MINIMUM_FONT_SIZE = 20

    attr_accessor :actions
    attr_accessor :center_x
    attr_accessor :center_y
    attr_accessor :color
    attr_accessor :font
    attr_accessor :font_color
    attr_accessor :game
    attr_accessor :height
    attr_accessor :hover_color
    attr_accessor :hover_image
    attr_accessor :image
    attr_accessor :image_height
    attr_accessor :image_width
    attr_reader :text
    attr_accessor :width
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    def initialize(
      actions:,
      color: DEFAULT_COLOR,
      font_color: Gosu::Color::BLACK,
      font: nil,
      game:,
      height: DEFAULT_HEIGHT,
      hover_color: DEFAULT_HOVER_COLOR,
      hover_image: nil,
      image_height: nil,
      image_width: nil,
      image: nil,
      text: nil,
      width: DEFAULT_WIDTH,
      x: 0,
      y: 0,
      z: ZOrder::MAIN_UI
    )
      self.game = game

      self.actions = actions
      self.center_x = x + (width / 2.0)
      self.center_y = y + (height / 2.0)
      self.color = color
      self.font = font
      self.font_color = font_color
      self.height = height
      self.hover_color = hover_color
      self.hover_image = hover_image
      self.image = image
      self.image_height = image_height
      self.image_width = image_width
      self.width = width
      self.x = x
      self.y = y
      self.z = z

      self.text = text
    end

    def actions=(value)
      @actions = game.format_actions(value)
    end

    def draw(mouse_x = nil, mouse_y = nil)
      if mouse_x && mouse_y && within?(mouse_x, mouse_y)
        Gosu.draw_rect(color: hover_color, height: height, width: width, x: x, y: y, z: z) if
          hover_color
        hover_image&.draw(
          draw_height: image_height,
          draw_width: image_width,
          from_center: true,
          x: center_x,
          y: center_y,
          z: z
        )
        image&.tick
      else
        Gosu.draw_rect(color: color, height: height, width: width, x: x, y: y, z: z) if color
        image&.draw(
          draw_height: image_height,
          draw_width: image_width,
          from_center: true,
          x: center_x,
          y: center_y,
          z: z
        )
        hover_image&.tick
      end

      if text
        font&.draw_text(
          text,
          color: font_color,
          rel_x: 0.5,
          rel_y: 0.5,
          x: center_x,
          y: center_y,
          z: z
        )
      end
    end

    def perform_actions
      game.execute_actions(actions)
    end

    def perform_image_animation(animation_type, animation_args)
      animation_args = animation_args.merge(
        draw_height: image_height,
        draw_width: image_width,
        x: center_x,
        y: center_y,
        z: z
      )

      hover_image&.perform_animation(animation_type, **animation_args)
      image&.perform_animation(animation_type, **animation_args)
    end

    def text=(value)
      @text = value
      return text unless font

      # Find maximum font size (between set maximum and minimum)
      # usable while still fitting text on button
      font_size = (MINIMUM_FONT_SIZE..Game::UserInterface::DEFAULT_FONT_SIZE)
        .to_a
        .reverse
        .bsearch do |size|
          Gosu::Font.new(size).text_width(text) < width - 5
        end

      self.font = Gosu::Font.new(font_size || MINIMUM_FONT_SIZE)

      # If text doesn't fit on button even at minimum font size, truncate
      # text with ellipses beyond what can fit at minimum font size
      unless font_size
        length =
          (1..text.length).to_a.reverse.bsearch do |length|
            font.text_width(text[0...length]) < width - 20
          end

        length ||= 0
        @text = text[0...length] + '...'
      end

      text
    end

    def update_coordinates(new_x = nil, new_y = nil, new_z = nil)
      self.x = new_x if new_x
      self.y = new_y if new_y
      self.z = new_z if new_z

      self.center_x = x + (width / 2.0)
      self.center_y = y + (height / 2.0)
    end

    def within?(_x, _y)
      _x >= x && _x < (x + width) && _y >= y && _y < (y + height)
    end
  end
end

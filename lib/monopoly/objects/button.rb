module Monopoly
  class Button
    DEFAULT_COLOR = Gosu::Color::WHITE
    DEFAULT_HOVER_COLOR = Gosu::Color.new(255, 219, 219, 219).freeze
    DEFAULT_HEIGHT = 50
    DEFAULT_TEXT_COLOR = Gosu::Color::BLACK
    DEFAULT_WIDTH = 275
    MINIMUM_FONT_SIZE = 20

    attr_accessor :actions
    attr_reader :center_x
    attr_reader :center_y
    attr_accessor :color
    attr_accessor :font
    attr_accessor :font_color
    attr_accessor :game
    attr_reader :height
    attr_accessor :hover_color
    attr_accessor :hover_image
    attr_accessor :image
    attr_accessor :image_height
    attr_accessor :image_width
    attr_reader :text
    attr_reader :width
    attr_reader :x
    attr_reader :y
    attr_reader :z

    def initialize(
      actions:,
      color: DEFAULT_COLOR,
      font_color: DEFAULT_TEXT_COLOR,
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

      update_coordinates(x: x, y: y, z: z)

      self.text = text
    end

    def actions=(value)
      @actions = game.format_actions(value)
    end

    def draw(mouse_x = nil, mouse_y = nil)
      if mouse_x && mouse_y && within?(mouse_x, mouse_y)
        draw_shape(hover: true)

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
        draw_shape

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

    def height=(value)
      @height = value
      self.text = text
      update_coordinates
      height
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
      return text unless font && width

      # Find maximum font size (between set maximum and minimum)
      # usable while still fitting text on button
      font_size = (MINIMUM_FONT_SIZE..Game::UserInterface::DEFAULT_FONT_SIZE)
        .to_a
        .reverse
        .bsearch do |size|
          Gosu::Font.new(size).text_width(text) < width - 5
        end

      self.font = Gosu::Font.new(font_size || MINIMUM_FONT_SIZE, name: font.name)

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

    def update_coordinates(x: nil, y: nil, z: nil)
      @x = x if x
      @y = y if y
      @z = z if z

      @center_x = width && @x ? @x + (width / 2.0) : nil
      @center_y = height && @y ? @y + (height / 2.0) : nil
    end

    def width=(value)
      @width = value
      self.text = text
      update_coordinates
      width
    end

    def within?(_x, _y)
      _x >= x && _x < (x + width) && _y >= y && _y < (y + height)
    end

    protected

    def draw_shape(hover: false)
      color_to_draw = hover ? hover_color : color
      return unless color_to_draw

      Gosu.draw_rect(color: color_to_draw, height: height, width: width, x: x, y: y, z: z)
    end
  end

  class CircularButton < Button
    attr_accessor :circle
    attr_accessor :hover_circle
    attr_reader :radius

    def initialize(
      actions:,
      color: DEFAULT_COLOR,
      font_color: DEFAULT_TEXT_COLOR,
      font: nil,
      game:,
      hover_color: DEFAULT_HOVER_COLOR,
      hover_image: nil,
      image_height: nil,
      image_width: nil,
      image: nil,
      radius:,
      text: nil,
      x: 0,
      y: 0,
      z: ZOrder::MAIN_UI
    )
      self.game = game

      self.radius = radius

      self.actions = actions
      self.color = color
      self.font = font
      self.font_color = font_color
      self.hover_color = hover_color
      self.hover_image = hover_image
      self.image = image
      self.image_height = image_height
      self.image_width = image_width

      update_coordinates(x: x, y: y, z: z)

      self.text = text
    end

    def color=(value)
      @color = value
      self.circle = Gosu::Image.new(Gosu::Circle.new(color: color, radius: radius)) if color
      color
    end

    def hover_color=(value)
      @hover_color = value
      self.hover_circle = Gosu::Image.new(Gosu::Circle.new(color: hover_color, radius: radius)) if
        hover_color
      hover_color
    end

    def radius=(value)
      @radius = value
      self.height = self.width = radius * 2
      self.color = color
      self.hover_color = hover_color
      self.text = text
      radius
    end

    def update_coordinates(x: nil, y: nil, z: nil)
      @x = @center_x = x if x
      @y = @center_y = y if y
      @z = z if z
    end

    def within?(_x, _y)
      Math.sqrt((_x - x).abs**2 + (_y - y).abs**2) < radius
    end

    protected

    def draw_shape(hover: false)
      circle_to_draw = hover ? hover_circle : circle
      circle_to_draw&.draw(from_center: true, x: center_x, y: center_y, z: z)
    end
  end
end

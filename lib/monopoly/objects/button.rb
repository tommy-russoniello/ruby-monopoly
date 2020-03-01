module Monopoly
  class Button
    DEFAULT_COLOR = Gosu::Color::WHITE
    DEFAULT_HOVER_COLOR = Gosu::Color.new(255, 219, 219, 219).freeze
    DEFAULT_HEIGHT = 50
    DEFAULT_TEXT_COLOR = Gosu::Color::BLACK
    DEFAULT_WIDTH = 275
    MINIMUM_FONT_SIZE = 12

    attr_accessor :actions
    attr_accessor :border_color
    attr_accessor :border_hover_color
    attr_accessor :border_width
    attr_reader :center_x
    attr_reader :center_y
    attr_accessor :color
    attr_accessor :font
    attr_accessor :font_color
    attr_accessor :font_hover_color
    attr_accessor :game
    attr_reader :height
    attr_accessor :hover_color
    attr_accessor :hover_image
    attr_accessor :image
    attr_accessor :image_background_color
    attr_accessor :image_background_hover_color
    attr_accessor :image_height
    attr_accessor :image_position_x
    attr_accessor :image_position_y
    attr_accessor :image_width
    attr_reader :image_x
    attr_reader :image_y
    attr_accessor :maximum_font_size
    attr_reader :text
    attr_accessor :text_position_x
    attr_accessor :text_position_y
    attr_accessor :text_relative_position_x
    attr_accessor :text_relative_position_y
    attr_reader :text_x
    attr_reader :text_y
    attr_reader :width
    attr_reader :x
    attr_reader :y
    attr_reader :z

    def initialize(
      actions:,
      border_color: nil,
      border_hover_color: nil,
      border_width: nil,
      color: DEFAULT_COLOR,
      font: nil,
      font_color: DEFAULT_TEXT_COLOR,
      font_hover_color: nil,
      game:,
      height: DEFAULT_HEIGHT,
      hover_color: DEFAULT_HOVER_COLOR,
      hover_image: nil,
      image: nil,
      image_background_color: nil,
      image_background_hover_color: nil,
      image_height: nil,
      image_position_x: 0.5,
      image_position_y: 0.5,
      image_width: nil,
      text: nil,
      text_position_x: 0.5,
      text_position_y: 0.5,
      text_relative_position_x: 0.5,
      text_relative_position_y: 0.5,
      width: DEFAULT_WIDTH,
      x: 0,
      y: 0,
      z: ZOrder::MAIN_UI
    )
      self.game = game

      self.actions = actions
      self.border_color = border_color
      self.border_hover_color = border_hover_color
      self.border_width = border_width
      self.color = color
      self.font = font
      self.font_color = font_color
      self.font_hover_color = font_hover_color || font_color
      self.height = height
      self.hover_color = hover_color
      self.hover_image = hover_image
      self.image = image
      self.image_background_color = image_background_color
      self.image_background_hover_color = image_background_color
      self.image_height = image_height
      self.image_position_x = image_position_x
      self.image_position_y = image_position_y
      self.image_width = image_width
      self.text_position_x = text_position_x
      self.text_position_y = text_position_y
      self.text_relative_position_x = text_relative_position_x
      self.text_relative_position_y = text_relative_position_y
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

        draw_image_background(hover: true) if image_background_hover_color

        hover_image&.draw(
          draw_height: image_height,
          draw_width: image_width,
          from_center: true,
          x: image_x,
          y: image_y,
          z: z
        )
        image&.tick

        if text
          font&.draw_text(
            text,
            color: font_hover_color,
            rel_x: text_relative_position_x,
            rel_y: text_relative_position_y,
            x: text_x,
            y: text_y,
            z: z
          )
        end
      else
        draw_shape

        draw_image_background if image_background_color

        image&.draw(
          draw_height: image_height,
          draw_width: image_width,
          from_center: true,
          x: image_x,
          y: image_y,
          z: z
        )
        hover_image&.tick

        if text
          font&.draw_text(
            text,
            color: font_color,
            rel_x: text_relative_position_x,
            rel_y: text_relative_position_y,
            x: text_x,
            y: text_y,
            z: z
          )
        end
      end
    end

    def font=(value)
      @font = value
      self.maximum_font_size = font&.height
      font
    end

    %i[
      height
      image_position_x
      image_position_y
      text_position_x
      text_position_y
      width
    ].each do |attribute|
      define_method(:"#{attribute}=") do |value|
        instance_variable_set(:"@#{attribute}", value)
        self.text = text
        update_coordinates
        send(attribute)
      end
    end

    def maximize_image_in_square(size)
      return unless image

      self.image_height = self.image_width = nil
      if image.height > image.width
        self.image_height = size
      else
        self.image_width = size
      end
    end

    def perform_actions
      game.execute_actions(actions)
    end

    def perform_image_animation(animation_type, animation_args)
      animation_args = animation_args.merge(
        draw_height: image_height,
        draw_width: image_width,
        x: image_x,
        y: image_y,
        z: z
      )

      hover_image&.perform_animation(animation_type, **animation_args)
      image&.perform_animation(animation_type, **animation_args)
    end

    def text=(value)
      @text = value
      return text unless font && maximum_font_size && width

      # Find maximum font size (between set maximum and minimum)
      # usable while still fitting text on button
      font_size = (MINIMUM_FONT_SIZE..maximum_font_size)
        .to_a
        .reverse
        .bsearch do |size|
          Gosu::Font.new(size).text_width(text) < width - 5
        end

      @font = Gosu::Font.new(font_size || MINIMUM_FONT_SIZE, name: font.name)

      # If text doesn't fit on button even at minimum font size, truncate
      # text with ellipses beyond what can fit at minimum font size
      # unless font_size
      @text = font.truncate_text(text: text, trailing_text: '...', width: width - 20) unless
        font_size

      text
    end

    def update_coordinates(x: nil, y: nil, z: nil)
      @x = x if x
      @y = y if y
      @z = z if z

      @center_x = width && @x ? @x + (width / 2.0) : nil
      @center_y = height && @y ? @y + (height / 2.0) : nil

      @image_x = width && @x && image_position_x ? @x + (width * image_position_x) : nil
      @image_y = height && @y && image_position_y ? @y + (height * image_position_y) : nil

      @text_x = width && @x && text_position_x ? @x + (width * text_position_x) : nil
      @text_y = height && @y && text_position_y ? @y + (height * text_position_y) : nil
    end

    def within?(_x, _y)
      border = border_width || 0
      _x >= x - border && _x < (x + width + border) && _y >= y - border &&
        _y < (y + height + border)
    end

    protected

    def draw_image_background(hover: false)
      color_to_draw, image_drawn =
        hover ? [image_background_hover_color, hover_image] : [image_background_color, image]

      if image_height
        draw_height = image_height
        draw_width =
          image_width ? image_width : image_drawn.width * (image_height / image_drawn.height.to_f)
      elsif image_width
        draw_width = image_width
        draw_height = image_drawn.height * (image_width / image_drawn.width.to_f)
      end

      Gosu.draw_rect(
        color: color_to_draw,
        from_center: true,
        height: draw_height,
        width: draw_width,
        x: image_x,
        y: image_y,
        z: z
      )
    end

    def draw_shape(hover: false)
      color_to_draw, border_color_to_draw =
        hover ? [hover_color, border_hover_color] : [color, border_color]

      if border_color_to_draw
        Gosu.draw_rect(
          color: border_color_to_draw,
          height: height + border_width,
          width: width + border_width,
          x: x - border_width,
          y: y - border_width,
          z: z
        )
      end

      return unless color_to_draw

      Gosu.draw_rect(color: color_to_draw, height: height, width: width, x: x, y: y, z: z)
    end
  end

  class CircularButton < Button
    attr_accessor :border_circle
    attr_accessor :border_hover_circle
    attr_accessor :circle
    attr_accessor :hover_circle
    attr_reader :radius

    def initialize(
      actions:,
      border_color: nil,
      border_hover_color: nil,
      border_width: nil,
      color: DEFAULT_COLOR,
      font: nil,
      font_color: DEFAULT_TEXT_COLOR,
      font_hover_color: nil,
      game:,
      hover_color: DEFAULT_HOVER_COLOR,
      hover_image: nil,
      image: nil,
      image_background_color: nil,
      image_background_hover_color: nil,
      image_height: nil,
      image_position_x: 0.5,
      image_position_y: 0.5,
      image_width: nil,
      radius:,
      text: nil,
      text_position_x: 0.5,
      text_position_y: 0.5,
      text_relative_position_x: 0.5,
      text_relative_position_y: 0.5,
      x: 0,
      y: 0,
      z: ZOrder::MAIN_UI
    )
      self.game = game

      self.radius = radius
      self.border_width = border_width

      self.actions = actions
      self.border_color = border_color
      self.border_hover_color = border_hover_color
      self.color = color
      self.font = font
      self.font_color = font_color
      self.font_hover_color = font_hover_color || font_color
      self.hover_color = hover_color
      self.hover_image = hover_image
      self.image = image
      self.image_background_color = image_background_color
      self.image_background_hover_color = image_background_hover_color
      self.image_height = image_height
      self.image_position_x = image_position_x
      self.image_position_y = image_position_y
      self.image_width = image_width
      self.text_position_x = text_position_x
      self.text_position_y = text_position_y
      self.text_relative_position_x = text_relative_position_x
      self.text_relative_position_y = text_relative_position_y

      update_coordinates(x: x, y: y, z: z)

      self.text = text
    end

    def border_color=(value)
      @border_color = value
      if border_color
        self.border_circle =
          Image.new(Gosu::Circle.new(color: border_color, radius: radius + border_width))
      end

      border_color
    end

    def border_hover_color=(value)
      @border_hover_color = value
      if border_hover_color
        self.border_hover_circle = Image.new(
          Gosu::Circle.new(color: border_hover_color, radius: radius + border_width)
        )
      end

      border_hover_color
    end

    def border_width=(value)
      @border_width = value
      self.border_color = border_color
      self.border_hover_color = border_hover_color
      border_width
    end

    def color=(value)
      @color = value
      self.circle = Image.new(Gosu::Circle.new(color: color, radius: radius)) if color
      color
    end

    def hover_color=(value)
      @hover_color = value
      self.hover_circle = Image.new(Gosu::Circle.new(color: hover_color, radius: radius)) if
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

      @image_x =
        radius && @x && image_position_x ? @x - radius + (radius * image_position_x * 2) : nil
      @image_y =
        radius && @y && image_position_y ? @y - radius + (radius * image_position_y * 2) : nil

      @text_x = radius && @x && text_position_x ? @x - radius + (radius * text_position_x * 2) : nil
      @text_y = radius && @y && text_position_y ? @y - radius + (radius * text_position_y * 2) : nil
    end

    def within?(_x, _y)
      Math.sqrt((_x - x).abs**2 + (_y - y).abs**2) < (radius + (border_width || 0))
    end

    protected

    def draw_shape(hover: false)
      if hover
        border_hover_circle&.draw(from_center: true, x: center_x, y: center_y, z: z)
        hover_circle&.draw(from_center: true, x: center_x, y: center_y, z: z)
      else
        border_circle&.draw(from_center: true, x: center_x, y: center_y, z: z)
        circle&.draw(from_center: true, x: center_x, y: center_y, z: z)
      end
    end
  end
end

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
    attr_accessor :highlight_color
    attr_accessor :hover_color
    attr_accessor :highlight_hover_color
    attr_reader :hover_image
    attr_reader :hover_image_height
    attr_reader :hover_image_width
    attr_reader :image
    attr_accessor :image_background_color
    attr_accessor :image_background_hover_color
    attr_reader :image_height
    attr_accessor :image_position_x
    attr_accessor :image_position_y
    attr_reader :image_width
    attr_reader :image_x
    attr_reader :image_y
    attr_accessor :maximum_font_size
    attr_reader :text
    attr_accessor :text_position_x
    attr_accessor :text_position_y
    attr_accessor :text_relative_position_x
    attr_accessor :text_relative_position_y
    attr_reader :text_relative_width
    attr_reader :text_x
    attr_reader :text_y
    attr_reader :width
    attr_reader :x
    attr_reader :y
    attr_reader :z

    def initialize(
      actions:,
      color: DEFAULT_COLOR,
      font_color: DEFAULT_TEXT_COLOR,
      game:,
      height: DEFAULT_HEIGHT,
      hover_color: DEFAULT_HOVER_COLOR,
      image_position_x: 0.5,
      image_position_y: 0.5,
      text_position_x: 0.5,
      text_position_y: 0.5,
      text_relative_position_x: 0.5,
      text_relative_position_y: 0.5,
      text_relative_width: 1,
      width: DEFAULT_WIDTH,
      x: 0,
      y: 0,
      z: ZOrder::MAIN_UI,
      **options
    )
      self.game = game

      self.actions = actions
      self.border_color = options[:border_color]
      self.border_hover_color = options[:border_hover_color]
      self.border_width = options[:border_width]
      self.color = color
      self.font = options[:font]
      self.font_color = font_color
      self.font_hover_color = options[:font_hover_color] || font_color
      self.height = height
      self.highlight_color = options[:highlight_color]
      self.hover_color = hover_color
      self.highlight_hover_color = options[:highlight_hover_color]
      @hover_image = options[:hover_image]
      self.hover_image_height = options[:hover_image_height]
      self.hover_image_width ||= options[:hover_image_width]
      @image = options[:image]
      self.image_background_color = options[:image_background_color]
      self.image_background_hover_color = options[:image_background_color]
      self.image_height = options[:image_height]
      self.image_position_x = image_position_x
      self.image_position_y = image_position_y
      self.image_width ||= options[:image_width]
      self.text_position_x = text_position_x
      self.text_position_y = text_position_y
      self.text_relative_position_x = text_relative_position_x
      self.text_relative_position_y = text_relative_position_y
      self.text_relative_width = text_relative_width
      self.width = width

      @hover_image_height ||= @image_height
      @hover_image_width ||= @image_width

      update_coordinates(x: x, y: y, z: z)

      self.text = options[:text]
    end

    %i[height width].each do |attribute|
      define_method(:"#{attribute}=") do |value|
        instance_variable_set(:"@#{attribute}", value&.round)
        self.text = text
        update_coordinates
        send(attribute)
      end
    end

    %i[
      image_position_x
      image_position_y
      text_position_x
      text_position_y
      text_relative_width
    ].each do |attribute|
      define_method(:"#{attribute}=") do |value|
        instance_variable_set(:"@#{attribute}", value)
        self.text = text
        update_coordinates
        send(attribute)
      end
    end

    def actions=(value)
      @actions = game.format_actions(value)
    end

    def draw(mouse_x = nil, mouse_y = nil)
      if mouse_x && mouse_y && within?(mouse_x, mouse_y)
        draw_shape(hover: true)

        draw_image_background(hover: true) if image_background_hover_color

        hover_image&.draw(
          draw_height: hover_image_height,
          draw_width: hover_image_width,
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

        draw_highlight(hover: true) if highlight_hover_color
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

        draw_highlight if highlight_color
      end
    end

    def font=(value)
      @font = value
      self.maximum_font_size = font&.height
      font
    end

    def hover_image=(value)
      @hover_image = value
      if hover_image_height
        self.hover_image_height = hover_image_height unless hover_image_width
      elsif hover_image_width
        self.hover_image_width = hover_image_width
      end

      hover_image
    end

    def hover_image_height=(value)
      @hover_image_height = value&.round
      @hover_image_width ||= hover_image.width * (hover_image_height / hover_image.height.to_f) if
        hover_image && hover_image_height
      hover_image_height
    end

    def hover_image_width=(value)
      @hover_image_width = value&.round
      @hover_image_height ||= hover_image.height * (hover_image_width / hover_image.width.to_f) if
        hover_image && hover_image_width
      hover_image_width
    end

    def image=(value)
      @image = value
      if image_height
        self.image_height = image_height unless image_width
      elsif image_width
        self.image_width = image_width
      end

      image
    end

    def image_height=(value)
      @image_height = value&.round
      @image_width ||= (image.width * (image_height / image.height.to_f)).round if image &&
        image_height
      image_height
    end

    def image_width=(value)
      @image_width = value&.round
      @image_height ||= (image.height * (image_width / image.width.to_f)).round if image &&
        image_width
      image_width
    end

    def maximize_images_in_square(size)
      if image
        self.image_height = self.image_width = nil
        if image.height > image.width
          self.image_height = size
        else
          self.image_width = size
        end
      end

      return unless hover_image

      self.hover_image_height = self.hover_image_width = nil
      if hover_image.height > hover_image.width
        self.hover_image_height = size
      else
        self.hover_image_width = size
      end
    end

    def perform_actions
      game.execute_actions(actions)
    end

    def perform_image_animation(animation_type, animation_args)
      animation_args = animation_args.merge(x: image_x, y: image_y, z: z)

      hover_image&.perform_animation(
        animation_type,
        draw_height: hover_image_height,
        draw_width: hover_image_width,
        **animation_args
      )
      image&.perform_animation(
        animation_type,
        draw_height: image_height,
        draw_width: image_width,
        **animation_args
      )
    end

    def text=(value)
      @text = value
      return text unless font && maximum_font_size && width && text_relative_width

      # Find maximum font size (between set maximum and minimum) usable while still fitting
      # text on the button. Try skipping the binary search by checking the maximum
      # size first as this is the most common case.
      font_size = maximum_font_size if
        Gosu::Font.new(maximum_font_size).text_width(text) < (width * text_relative_width) - 5

      font_size ||= (MINIMUM_FONT_SIZE...maximum_font_size)
        .to_a
        .reverse
        .bsearch do |size|
          Gosu::Font.new(size).text_width(text) < (width * text_relative_width) - 5
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

    def draw_highlight(hover: false)
      color_to_draw = hover ? highlight_hover_color : highlight_color
      Gosu.draw_rect(color: color_to_draw, height: height, width: width, x: x, y: y, z: z)
    end

    def draw_image_background(hover: false)
      color_to_draw, drawn_height, drawn_width =
        if hover
          [image_background_hover_color, hover_image_height, hover_image_width]
        else
          [image_background_color, image_height, image_width]
        end

      Gosu.draw_rect(
        color: color_to_draw,
        from_center: true,
        height: drawn_height,
        width: drawn_width,
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
    attr_accessor :highlight_circle
    attr_accessor :hover_circle
    attr_accessor :hover_highlight_circle
    attr_reader :radius

    def initialize(
      actions:,
      color: DEFAULT_COLOR,
      font_color: DEFAULT_TEXT_COLOR,
      game:,
      hover_color: DEFAULT_HOVER_COLOR,
      image_position_x: 0.5,
      image_position_y: 0.5,
      radius:,
      text_position_x: 0.5,
      text_position_y: 0.5,
      text_relative_position_x: 0.5,
      text_relative_position_y: 0.5,
      x: 0,
      y: 0,
      z: ZOrder::MAIN_UI,
      **options
    )
      self.game = game

      self.radius = radius
      self.border_width = options[:border_width]

      self.actions = actions
      self.border_color = options[:border_color]
      self.border_hover_color = options[:border_hover_color]
      self.color = color
      self.font = options[:font]
      self.font_color = font_color
      self.font_hover_color = options[:font_hover_color] || font_color
      self.highlight_color = options[:highlight_color]
      self.highlight_hover_color = options[:highlight_hover_color]
      self.hover_color = hover_color
      @hover_image = options[:hover_image]
      self.hover_image_height = options[:hover_image_height]
      self.hover_image_width ||= options[:hover_image_width]
      @image = options[:image]
      self.image_background_color = options[:image_background_color]
      self.image_background_hover_color = options[:image_background_hover_color]
      self.image_height = options[:image_height]
      self.image_position_x = image_position_x
      self.image_position_y = image_position_y
      self.image_width ||= options[:image_width]
      self.text_position_x = text_position_x
      self.text_position_y = text_position_y
      self.text_relative_position_x = text_relative_position_x
      self.text_relative_position_y = text_relative_position_y

      @hover_image_height ||= @image_height
      @hover_image_width ||= @image_width

      update_coordinates(x: x, y: y, z: z)

      self.text = options[:text]
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
      @border_width = value&.round
      self.border_color = border_color
      self.border_hover_color = border_hover_color
      self.highlight_color = highlight_color
      self.highlight_hover_color = highlight_hover_color
      border_width
    end

    def color=(value)
      @color = value
      self.circle =
        if color
          Image.new(Gosu::Circle.new(color: color, radius: radius))
        else
          nil
        end

      color
    end

    def highlight_color=(value)
      @highlight_color = value
      self.highlight_circle = Image.new(Gosu::Circle.new(color: highlight_color, radius: radius)) if
        highlight_color

      highlight_color
    end

    def highlight_hover_color=(value)
      @highlight_hover_color = value
      if highlight_hover_color
        self.hover_highlight_circle =
          Image.new(Gosu::Circle.new(color: highlight_hover_color, radius: radius))
      end

      highlight_hover_color
    end

    def hover_color=(value)
      @hover_color = value
      self.hover_circle = Image.new(Gosu::Circle.new(color: hover_color, radius: radius)) if
        hover_color
      hover_color
    end

    def radius=(value)
      @radius = value.round
      self.height = self.width = radius * 2
      self.color = color
      self.highlight_color = highlight_color
      self.highlight_hover_color = highlight_hover_color
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

    def draw_highlight(hover: false)
      circle_to_draw = hover ? hover_highlight_circle : highlight_circle
      circle_to_draw&.draw(from_center: true, x: center_x, y: center_y, z: z)
    end

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

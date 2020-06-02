module Monopoly
  class Image
    attr_accessor :animation
    attr_accessor :image

    delegate :height, to: :image
    delegate :width, to: :image

    def initialize(source, options = {})
      self.image = source.is_a?(Gosu::Image) ? source : Gosu::Image.new(source, options)
    end

    def draw(*args)
      animation ? draw_from_animation : image.draw(*args)
    end

    def draw_rot(*args)
      animation ? draw_from_animation : image.draw_rot(*args)
    end

    def perform_animation(animation_type, **args)
      animation_class = Monopoly.const_get("#{animation_type}_animation".camelize)

      args[:scale_y] = args[:draw_height] / height.to_f if args[:draw_height]
      args[:scale_x] = args[:draw_width] / width.to_f if args[:draw_width]

      args[:angle] = 0 unless args.key?(:angle)
      args[:center_x] = 0.5 unless args.key?(:center_x)
      args[:center_y] = 0.5 unless args.key?(:center_y)
      args[:color] = 0xff_ffffff unless args.key?(:color)
      args.delete(:draw_height)
      args.delete(:draw_width)
      args[:mode] = :default unless args.key?(:mode)
      args[:scale_x] = 1 unless args.key?(:scale_x)
      args[:scale_y] = 1 unless args.key?(:scale_y)

      self.animation = animation_class.new(args)
    end

    def tick
      return unless animation

      self.animation = nil unless animation.tick
    end

    protected

    def draw_from_animation
      image._draw_rot(
        animation.x,
        animation.y,
        animation.z,
        animation.angle,
        animation.center_x,
        animation.center_y,
        animation.scale_x,
        animation.scale_y,
        animation.color,
        animation.mode
      )

      tick
    end
  end
end

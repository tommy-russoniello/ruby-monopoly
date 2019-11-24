module Gosu
  class Image
    attr_accessor :animation

    alias _draw draw
    def draw(
      color: 0xff_ffffff,
      draw_height: nil,
      draw_width: nil,
      from_center: false,
      mode: :default,
      scale_x: 1,
      scale_y: 1,
      x:,
      y:,
      z:
    )
      return draw_from_animation if animation

      scale_y = draw_height / height.to_f if draw_height
      scale_x = draw_width / width.to_f if draw_width

      if from_center
        x = x - ((width * scale_x) / 2.0)
        y = y - ((height * scale_y) / 2.0)
      end

      _draw(x, y, z, scale_x, scale_y, color, mode)
    end

    alias _draw_rot draw_rot
    def draw_rot(
      angle: 0,
      center_x: 0.5,
      center_y: 0.5,
      color: 0xff_ffffff,
      draw_height: nil,
      draw_width: nil,
      mode: :default,
      scale_x: 1,
      scale_y: 1,
      x:,
      y:,
      z:
    )
      scale_y = draw_height / height.to_f if draw_height
      scale_x = draw_width / width.to_f if draw_width

      _draw_rot(x, y, z, angle, center_x, center_y, scale_x, scale_y, color, mode)
    end

    # Make inspecting images quieter
    def inspect
      to_s
    end

    def perform_animation(animation_type, **args)
      animation_class = Gosu.const_get("#{animation_type}_animation".camelize)

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
      _draw_rot(
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

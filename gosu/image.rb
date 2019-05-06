module Gosu
  class Image
    alias _draw draw
    def draw(
      x,
      y,
      z,
      scale_x = 1,
      scale_y = 1,
      color = 0xff_ffffff,
      mode = :default,
      from_center: false,
      draw_height: nil,
      draw_width: nil
    )
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
      x,
      y,
      z,
      angle,
      center_x = 0.5,
      center_y = 0.5,
      scale_x = 1,
      scale_y = 1,
      color = 0xff_ffffff,
      mode = :default,
      from_center: false,
      draw_height: nil,
      draw_width: nil
    )
      scale_y = draw_height / height.to_f if draw_height
      scale_x = draw_width / width.to_f if draw_width

      if from_center
        x = x - ((width * scale_x) / 2.0)
        y = y - ((height * scale_y) / 2.0)
      end

      _draw_rot(x, y, z, angle, center_x, center_y, scale_x, scale_y, color, mode)
    end

    # Make inspecting images quieter
    def inspect
      to_s
    end
  end
end

module Gosu
  class Image
    def draw_from_center(x, y, z, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default)
      draw(
        x - ((width * scale_x) / 2.0),
        y - ((height * scale_y) / 2.0),
        z,
        scale_x,
        scale_y,
        color,
        mode
      )
    end

    def draw_rot_from_center(
      x,
      y,
      z,
      angle,
      center_x = 0.5,
      center_y = 0.5,
      scale_x = 1,
      scale_y = 1,
      color = 0xff_ffffff,
      mode = :default
    )
      draw_rot(
        x - ((width * scale_x) / 2.0),
        y - ((height * scale_y) / 2.0),
        z,
        angle,
        center_x,
        center_y,
        scale_x,
        scale_y,
        color,
        mode
      )
    end

    # Make inspecting images quieter
    def inspect
      to_s
    end
  end
end

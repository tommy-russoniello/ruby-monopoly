module Gosu
  class Animation
    attr_accessor :angle
    attr_accessor :center_x
    attr_accessor :center_y
    attr_accessor :color
    attr_accessor :length
    attr_accessor :mode
    attr_accessor :scale_x
    attr_accessor :scale_y
    attr_accessor :tick_count
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    def initialize(
      angle:,
      center_x:,
      center_y:,
      color:,
      length: nil,
      mode:,
      scale_x:,
      scale_y:,
      x:,
      y:,
      z:
    )
      self.angle = angle
      self.center_x = center_x
      self.center_y = center_y
      self.color = color
      self.length = length
      self.mode = mode
      self.scale_x = scale_x
      self.scale_y = scale_y
      self.x = x
      self.y = y
      self.z = z

      self.tick_count = 0
    end

    def tick
      self.tick_count += 1

      tick_count < length
    end
  end

  class SpinAnimation < Animation
    attr_accessor :angle_delta

    def initialize(
      angle:,
      center_x:,
      center_y:,
      counterclockwise: false,
      color:,
      length: nil,
      mode:,
      scale_x:,
      scale_y:,
      times:,
      x:,
      y:,
      z:
    )
      super(
        angle: angle,
        center_x: center_x,
        center_y: center_y,
        color: color,
        length: length,
        mode: mode,
        scale_x: scale_x,
        scale_y: scale_y,
        x: x,
        y: y,
        z: z
      )

      self.angle_delta = (times * 360) / length.to_f
      self.angle_delta *= -1 if counterclockwise
    end

    def tick
      self.angle += angle_delta

      super
    end
  end
end

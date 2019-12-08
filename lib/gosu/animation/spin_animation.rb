module Gosu
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

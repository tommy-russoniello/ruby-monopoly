class Duration
  SECONDS_IN_HOUR = 3_600
  SECONDS_IN_MINUTE = 60

  attr_accessor :hours
  attr_accessor :minutes
  attr_accessor :seconds

  def initialize(seconds)
    self.hours = seconds / SECONDS_IN_HOUR
    seconds %= SECONDS_IN_HOUR
    self.minutes = seconds / SECONDS_IN_MINUTE
    self.seconds = seconds % SECONDS_IN_MINUTE
  end

  def to_numbers
    [hours, minutes, seconds].map { |number| number.to_s.rjust(2, '0') }.join(':')
  end

  def to_words
    words = []
    words << "#{hours} hour#{'s' unless hours == 1}" if hours.positive?
    words << "#{minutes} minute#{'s' unless minutes == 1}" if minutes.positive?
    words << "#{seconds} second#{'s' unless seconds == 1}"
    words.join(', ')
  end
end

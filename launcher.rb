require 'active_support'
require 'active_support/core_ext/numeric/conversions'
require 'active_support/core_ext/string/inflections'
require 'active_support/number_helper/number_to_currency_converter'
require 'byebug'
require 'gosu'
require 'rb-readline'
require 'securerandom'

# TODO: Remove when other resolutions are fully supported
# (this is just for quickly testing a different resolution)
if ARGV.include?('-z')
  ENV['RESOLUTION_HEIGHT'] = '1600'
  ENV['RESOLUTION_WIDTH'] = '2560'
else
  ENV['RESOLUTION_HEIGHT'] = '1080'
  ENV['RESOLUTION_WIDTH'] = '1920'
end

require_relative 'lib/gosu'
require_relative 'lib/monopoly'

Monopoly::Game.new.show

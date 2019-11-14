require 'active_support'
require 'active_support/core_ext/numeric/conversions'
require 'byebug'
require 'gosu'
require 'rb-readline'
require 'securerandom'

require_relative 'lib/gosu'
require_relative 'lib/monopoly'

Monopoly::Game.new.show

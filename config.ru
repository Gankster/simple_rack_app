# frozen_string_literal: true

require_relative 'app'
require_relative 'middleware/time_middleware'

use TimeMiddleware
run App.new

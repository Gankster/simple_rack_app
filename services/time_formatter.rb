# frozen_string_literal: true

class TimeFormatter
  AVAILABLE_FORMATS = {
    'year' => '%Y',
    'month' => '%m',
    'day' => '%d',
    'hour' => '%H',
    'minute' => '%M',
    'second' => '%S'
  }.freeze

  def initialize(params = {})
    @format_data = Array(params[:format_data])
    @formats = []
    @wrong_formats = []
  end

  def call
    parse_format
    return unknown_format unless valid_format?

    Time.now.strftime(@formats.join('-'))
  end

  def valid_format?
    @wrong_formats.empty?
  end

  private

  def unknown_format
    "Unknown time formats: #{@wrong_formats}"
  end

  def parse_format
    return if @format_data.empty?

    @format_data.each do |f|
      if AVAILABLE_FORMATS.key?(f)
        @formats << AVAILABLE_FORMATS[f]
      else
        @wrong_formats << f
      end
    end
  end
end

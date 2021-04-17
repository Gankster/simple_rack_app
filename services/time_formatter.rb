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
    @format_data = parse_format(params[:format])
  end

  def call
    return unknown_format unless valid_format?

    message = Time.now.strftime(@format_data[:formats].join('-'))
    { message: message, status: 200 }
  end

  private

  def valid_format?
    return false if @format_data[:wrong_formats].any?

    true
  end

  def unknown_format
    {
      message: "Unknown time formats: #{@format_data[:wrong_formats]}",
      status: 400
    }
  end

  def parse_format(format)
    result = { formats: [], wrong_formats: [] }
    return result if format.nil?

    format.split(',').each do |f|
      if AVAILABLE_FORMATS.key?(f)
        result[:formats] << AVAILABLE_FORMATS[f]
      else
        result[:wrong_formats] << f
      end
    end

    result
  end
end

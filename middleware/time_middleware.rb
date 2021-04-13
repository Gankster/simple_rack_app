# frozen_string_literal: true

class TimeMiddleware
  class NotFound < StandardError; end

  class UnknownTimeFormat < StandardError; end

  AVAILABLE_HTTP_METHODS = ['GET'].freeze
  AVAILABLE_PATHS = ['/time'].freeze
  PERMIT_PARAMS = [:format].freeze

  AVAILABLE_FORMATS = {
    'year' => '%Y',
    'month' => '%m',
    'day' => '%d',
    'hour' => '%H',
    'minute' => '%M',
    'second' => '%S'
  }.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request_with_error_handling do
      @response = @app.call(env)
      raise NotFound, 'Not Found' unless valid_route?(env)

      params = permit_params(env)
      format_time(params)
    end

    @response.finish
  end

  private

  def request_with_error_handling
    raise ArgumentError, 'No block given' unless block_given?

    yield
  rescue NotFound => e
    error!(e.message, 404)
  rescue UnknownTimeFormat => e
    error!(e.message, 400)
  rescue StandardError
    error!('Internal server error', 500)
  end

  def error!(message, status)
    @response.status = status
    @response.body = [message]
  end

  def valid_route?(env)
    return false unless AVAILABLE_HTTP_METHODS.include?(env['REQUEST_METHOD'])
    return false unless AVAILABLE_PATHS.include?(env['REQUEST_PATH'])

    true
  end

  def permit_params(env)
    query = CGI.unescape(env['QUERY_STRING'])
    params = {}

    query.split('&').each do |pair|
      key, value = pair.split('=')
      params[key.to_sym] = value if PERMIT_PARAMS.include?(key.to_sym)
    end

    params
  end

  def format_time(params)
    time_formats = parse_format(params[:format])

    if time_formats[:wrong_formats].any?
      raise UnknownTimeFormat, "Unknown time formats: #{time_formats[:wrong_formats]}"
    end

    @response.body = [Time.now.strftime(time_formats[:formats].join('-'))]
  end

  def parse_format(str)
    result = { formats: [], wrong_formats: [] }
    return result if str.nil?

    str.split(',').each do |f|
      if AVAILABLE_FORMATS.key?(f)
        result[:formats] << AVAILABLE_FORMATS[f]
      else
        result[:wrong_formats] << f
      end
    end

    result
  end
end

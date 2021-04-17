# frozen_string_literal: true

require_relative 'services/time_formatter'

require 'pry'
class App
  AVAILABLE_HTTP_METHODS = ['GET'].freeze
  AVAILABLE_PATHS = ['/time'].freeze
  PERMIT_PARAMS = [:format].freeze

  def call(env)
    response = make_response(env)
    response.finish
  end

  private

  def response(message: 'Internal server error', status: 500)
    Rack::Response.new(message, status, { 'Content-Type' => 'text/plain' })
  end

  def make_response(env)
    data = if valid_route?(env)
             params = permit_params(env)
             tf = TimeFormatter.new(params)
             result = tf.call
             status = tf.valid_format? ? 200 : 400
             { message: result, status: status }
           else
             { message: 'Not Found', status: 404 }
           end

    response(data)
  rescue StandardError
    response
  end

  def valid_route?(env)
    return false unless AVAILABLE_HTTP_METHODS.include?(env['REQUEST_METHOD'])
    return false unless AVAILABLE_PATHS.include?(env['REQUEST_PATH'])

    true
  end

  def permit_params(env)
    request = Rack::Request.new(env)
    { format_data: request.params['format']&.split(',') }
  end
end

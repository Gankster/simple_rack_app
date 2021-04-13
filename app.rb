# frozen_string_literal: true

class App
  def call(_env)
    Rack::Response.new('Bazinga', 200, { 'Content-Type' => 'text/plain' })
  end
end

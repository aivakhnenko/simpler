require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request
    attr_accessor :response
    alias :headers :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @request.env['simpler.render_option'] = {}
    end

    def make_response(action, variables)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action
      initialize_variables(variables)

      set_default_headers
      send(action)

      write_response_body

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def initialize_variables(variables)
      @request.env['simpler.params'] = @request.params
      variables.each { |key, value| @request.env['simpler.params'][key] = value }
    end

    def set_default_headers
      headers['Content-Type'] = 'text/html'
    end

    def write_response_body
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.env['simpler.params']
    end

    def render(template = nil, plain: nil)
      return @request.env['simpler.render_option'][:plain] = plain if plain
      @request.env['simpler.render_option'][:template] = template
    end

    def status(code)
      @response.status = code
    end
  end
end

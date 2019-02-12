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

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)

      write_response_body

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
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
      @request.params.merge(@request.env['simpler.params'])
    end

    def render(template)
      if (template.is_a?(Hash))
        headers['Content-Type'] = "text/#{template.keys.first}"
        @request.env['simpler.render_option'][template.keys.first] = template.values.first
      else
        headers['Content-Type'] = 'text/html'
        @request.env['simpler.render_option'][:template] = template
      end
    end

    def status(code)
      @response.status = code
    end
  end
end

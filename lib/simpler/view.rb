require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      if plain
        controller.headers['Content-Type'] = 'text/plain'
        template = plain
      else
        controller.headers['Content-Type'] = 'text/html'
        template = File.read(template_path)
      end
      ERB.new(template).result(binding)
    end

    private

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.render_option'][:template]
    end

    def plain
      @env['simpler.render_option'][:plain]
    end

    def template_path
      path = template || [controller.name, action].join('/')
      name = "#{path}.html.erb"
      @env['simpler.template_name'] = name

      Simpler.root.join(VIEW_BASE_PATH, name)
    end

  end
end

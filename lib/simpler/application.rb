require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'

module Simpler
  class Application

    include Singleton

    attr_reader :db

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      route = @router.route_for(env)
      path = env['PATH_INFO']

      return response_404 unless route

      controller = route.controller.new(env)
      action = route.action
      variables = route.variables(path)

      make_response(controller, action, variables)
    end

    private

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action, variables)
      controller.make_response(action, variables)
    end

    def response_404
      [
        404, 
        { 'Content-Type' => 'text/plain' }, 
        ["Error 404: Not found"]
      ]
    end
  end
end

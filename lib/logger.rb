require 'logger'
require 'http'

class AppLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:log_file] || STDOUT)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    log(env, status, headers)
    [status, headers, body]
  end

  private

  def log(env, status, headers)
    request = Rack::Request.new(env)
    controller = request.env['simpler.controller']
    @logger.info("Request: #{request.request_method} #{request.fullpath}")
    @logger.info("Handler: #{controller.class.name if controller}##{request.env['simpler.action']}")
    @logger.info("Parameters: #{controller.request.params if controller}")
    @logger.info("Response: #{status} #{HTTP::Response::Status::REASONS[status]} [#{headers['Content-Type']}] #{request.env['simpler.template_name']}")
  end
end

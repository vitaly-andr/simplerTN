require 'logger'
require 'fileutils'

module Simpler
  class LoggerMiddleware
    def initialize(app)
      @app = app
      ensure_log_directory_exists
      @logger = Logger.new(Simpler.root.join('log/app.log'))
    end

    def call(env)
      # Передаем управление основному приложению (маршрутизация и обработка)
      status, headers, response = @app.call(env)

      # Логируем запрос и ответ после выполнения маршрутизации
      log_request(env)
      log_response(env, status, headers, response)

      [status, headers, response]
    end

    private

    def ensure_log_directory_exists
      log_dir = Simpler.root.join('log')
      FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
    end
    def log_request(env)
      request = Rack::Request.new(env)
      controller = env['simpler.controller'] ? env['simpler.controller'].class.name : 'UnknownController'
      action = env['simpler.action'] || 'unknown'
      params = request.params.merge(env['simpler.route_params'] || {})

      @logger.info("Request: #{request.request_method} #{request.fullpath}")
      @logger.info("Handler: #{controller}##{action}")
      @logger.info("Parameters: #{params.inspect}")
    end

    def log_response(env, status, headers, response)
      content_type = headers['Content-Type']
      template = env['simpler.template']

      @logger.info("Response: #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} [#{content_type}] #{template ? template_path(env) : ''}")
    end

    def template_path(env)
      controller_name = env['simpler.controller'].class.name.gsub('Controller', '').downcase
      "#{controller_name}/#{env['simpler.template']}.html.erb"
    end
  end
end

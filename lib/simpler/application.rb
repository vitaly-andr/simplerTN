require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'
require_relative 'errors/route_not_found_error'
require_relative 'database_initialization' # Модуль создания таблиц и seed


module Simpler
  class Application

    include Singleton
    include DatabaseInitialization

    attr_reader :db

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      create_tables_if_not_exists
      seed_data_if_needed
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      route = @router.route_for(env)
      env['simpler.route_params'] = route.params(env['PATH_INFO'])

      controller = route.controller.new(env)
      action = route.action

      make_response(controller, action)
    rescue RouteNotFoundError
      not_found_response(env)
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

    def make_response(controller, action)
      controller.make_response(action)
    end
  def not_found_response(env)
    response = Rack::Response.new
    response.status = 404
    response['Content-Type'] = 'text/plain'
    response.write("404 Not Found: The requested URL #{env['PATH_INFO']} was not found on this server.")
    response.finish
  end

  end
end

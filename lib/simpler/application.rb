require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'
require_relative 'errors/route_not_found_error'

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
      create_tables_if_not_exists
      seed_data_if_needed
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      route = @router.route_for(env)
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

    def create_tables_if_not_exists
      puts 'Creating tables...'
      @db.drop_table?(:tests)
      @db.drop_table?(:categories)

      @db.create_table(:categories) do
        primary_key :id
        String :title, null: false
      end

      @db.create_table(:tests) do
        primary_key :id
        String :title, null: false
        Integer :level, default: 0
        foreign_key :category_id, :categories, on_delete: :cascade
      end
    end
    def seed_data_if_needed
      return if Test.count > 0

      create_category('Backend')
      create_category('Frontend')
      create_category('DevOps')

      create_test('Ruby Basics', 1, 'Backend')
      create_test('Ruby Advanced', 2, 'Backend')
      create_test('JavaScript Basics', 1, 'Frontend')
      create_test('JavaScript Advanced', 2, 'Frontend')
      create_test('Docker Basics', 1, 'DevOps')
      create_test('Kubernetes Advanced', 2, 'DevOps')

      # Устанавливаем ID для одного из тестов
      test = Test.find(title: 'Ruby Basics')
      if test
        @db.run("UPDATE tests SET id = 101 WHERE title = 'Ruby Basics'")
      end
    end

    def create_category(title)
      Category.find_or_create(title: title)
    rescue Sequel::ValidationFailed => e
      puts "Category creation failed: #{e.message}"
    end

    def create_test(title, level, category_title)
      category = Category.find(title: category_title)
      unless category
        puts "Category with title '#{category_title}' not found."
        return
      end
      Test.find_or_create(title: title, level: level, category: category)
    rescue Sequel::ValidationFailed => e
      puts "Test creation failed: #{e.message}"
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

require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      template = File.read(template_path)

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
      @env['simpler.template']
    end

    def template_path
      path = if template
               [controller.name, template].join('/')
             else
               [controller.name, action].join('/')
             end

      full_path = Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")

      unless File.exist?(full_path)
        # Если файл не существует, переключаемся на index
        puts "Template not found: #{full_path}, rendering index instead."
        path = [controller.name, 'index'].join('/')
        full_path = Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
      end

      puts "Template path: #{path}"
      full_path
    end


  end
end

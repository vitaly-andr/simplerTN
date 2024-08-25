require 'rack'
require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    RENDER_METHODS = {
      plain: ->(controller, content) { controller.send(:render_plain, content) },
      json:  ->(controller, content) { controller.send(:render_json, content) },
      html:  ->(controller, content) { controller.send(:render_html, content) }
    }.freeze


    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      unless @response.body.any?
        body = render_body
        @response.write(body)
      end
    end

    def render_body
      template = @request.env['simpler.template']
      if template
        View.new(@request.env).render(binding)
      else
        @response.body.first
      end
    end

    def params
      @request.params
    end

    def render(options = {})
      if options.is_a?(Hash)
        format = options.keys.first
        content = options.values.first

        if RENDER_METHODS.key?(format)
          RENDER_METHODS[format].call(self, content)
          @request.env['simpler.template'] = nil # Отменяем рендеринг шаблона
        else
          raise "Unknown format: #{format}"
        end
      else
        @request.env['simpler.template'] = options
      end
    end

    def render_plain(text)
      @response['Content-Type'] = 'text/plain'
      @response.write(text)
    end

    def render_json(data)
      @response['Content-Type'] = 'application/json'
      @response.write(data.to_json)
    end

    def render_html(html)
      @response['Content-Type'] = 'text/html'
      @response.write(html)
    end

  end
end

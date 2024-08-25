module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path_to_regexp(path)
        @controller = controller
        @action = action
      end

      def match?(method, path)
        @method == method && @path[:regexp].match(path)
      end
      def params(path)
        match_data = @path[:regexp].match(path)
        keys = @path[:keys]

        keys.zip(match_data.captures).to_h
      end
      private
      def path_to_regexp(path)
        keys = []
        regexp = path.gsub(/:([a-zA-Z_]\w*)/) do
          keys << $1.to_sym
          "([^/?#]+)"
        end
        regexp = /^#{regexp}$/

        { regexp: Regexp.new(regexp), keys: keys }
      end
    end
  end
end

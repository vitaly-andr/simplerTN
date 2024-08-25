require_relative 'config/environment'
require_relative 'lib/middleware/logger_middleware'

use Simpler::LoggerMiddleware

run Simpler.application

require 'logging'

require 'ezlog/version'
require 'ezlog/railtie' if defined? Rails

module Ezlog
  autoload :LoggingLayout, 'ezlog/logging_layout'
  autoload :Sidekiq, 'ezlog/sidekiq'

  def self.logger(name)
    Logging::Logger[name]
  end
end

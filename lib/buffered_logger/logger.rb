require 'forwardable'
require 'rubygems'
require 'active_support/buffered_logger'

class BufferedLogger
  extend  Forwardable
  include Indentation
  include Formatting

  def_delegators *ActiveSupport::BufferedLogger.public_instance_methods(false).unshift(:@logger) 

  SEVERITY_MODULE = ActiveSupport::BufferedLogger::Severity
  SEVERITY_LEVELS = SEVERITY_MODULE.constants.map { |c| c.downcase.to_sym }.freeze
  SEVERITY_MAP    = SEVERITY_MODULE.constants.inject({}) do |h,c| 
                      h[c.downcase.to_sym] = SEVERITY_MODULE.const_get(c); h
                    end.freeze

  attr_reader :master_thread
  private :master_thread

  def initialize(log_file, severity = 0, params = {})
    super()
    @log_file = log_file
    @master_thread = Thread.current
    @logger = ActiveSupport::BufferedLogger.new(log_file, severity_to_const(severity))
    params.each { |k,v| SEVERITY_LEVELS.include?(k) ? set_formatter(k, v) : next }
  end

  def buffer_text
    buffer.join('')
  end

  # create the logging methods
  class_eval do
    SEVERITY_LEVELS.each do |severity|
      define_method(severity) do |message|
        @logger.send(severity, padding % (formatter(severity) % message.to_s))
        nil
      end
    end
  end

private

  def color?
    @log_file == STDOUT
  end

  def severity_to_const(severity)
    case severity
    when Integer
      severity
    when Symbol
      SEVERITY_MAP[severity]
    else
      severity.to_i
    end
  end

end


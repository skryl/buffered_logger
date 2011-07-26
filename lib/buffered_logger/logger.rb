require 'thread'
require 'active_support/core_ext/class'

class BufferedLogger
  include Indentation
  include Formatting
  include Buffering

  module Severity
    DEBUG   = 0
    INFO    = 1
    WARN    = 2
    ERROR   = 3
    FATAL   = 4
    UNKNOWN = 5
  end
  include Severity

  SEVERITY_LEVELS = Severity.constants.map { |c| c.downcase.to_sym }.freeze
  SEVERITY_MAP    = Severity.constants.inject({}) do |h,c| 
                      h[c.downcase.to_sym] = Severity.const_get(c); h
                    end.freeze


  ##
  # :singleton-method:
  # Set to false to disable the silencer
  cattr_accessor :silencer
  self.silencer = true

  attr_accessor :level
  attr_reader :master_thread
  private :master_thread

  def initialize(log, level = DEBUG, params = {})
    @master_thread = Thread.current
    @level = severity_to_const(level)
    if log.respond_to?(:write)
      @log = log
    elsif File.exist?(log)
      @log = open_log(log, (File::WRONLY | File::APPEND))
    else
      FileUtils.mkdir_p(File.dirname(log))
      @log = open_log(log, (File::WRONLY | File::APPEND | File::CREAT))
    end
    super()
    params.each { |k,v| SEVERITY_LEVELS.include?(k) ? set_formatter(k, v) : next }
  end

  def open_log(log, mode)
    open(log, mode).tap do |open_log|
      open_log.set_encoding(Encoding::BINARY) if open_log.respond_to?(:set_encoding)
      open_log.sync = true
    end
  end

  def add(severity, message = nil, progname = nil, &block)
    return if @level > severity
    message = (message || (block && block.call) || progname).to_s
    # If a newline is necessary then create a new message ending with a newline.
    # Ensures that the original message is not mutated.
    message = "#{message}\n" unless message[-1] == ?\n
    buffer << message
    auto_flush
    message
  end

  for severity in SEVERITY_LEVELS
    class_eval <<-EOT, __FILE__, __LINE__ + 1
      def #{severity}(message = nil, progname = nil, &block)
        add(#{SEVERITY_MAP[severity]}, formatter(:#{severity}) % (padding % message.to_s), progname, &block)                  
        nil
      end                                                            

      def #{severity}?                                      
        #{SEVERITY_MAP[severity]} >= @level                                        
      end                                                            
    EOT
  end

  def print_blank_line
    add(0, "\n")
  end

  # Silences the logger for the duration of the block.
  def silence(temporary_level = ERROR)
    if silencer
      begin
        old_logger_level, self.level = level, temporary_level
        yield self
      ensure
        self.level = old_logger_level
      end
    else
      yield self
    end
  end

private

  def stdout?
    @log == STDOUT
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


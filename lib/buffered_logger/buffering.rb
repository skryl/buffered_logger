module BufferedLogger::Buffering
  MAX_BUFFER_SIZE = 1000

  def initialize
    @buffer        = Hash.new { |h,k| h[k] = [] }
    @auto_flushing = BufferedLogger::ThreadHash.new
    @auto_flushing[master_thread] = 1
    @guard = Mutex.new
    super()
  end

  def buffer_text
    buffer.join('')
  end

  def auto_flushing
    @auto_flushing[Thread.current] || @auto_flushing[master_thread]
  end

  # Set the auto-flush period. Set to true to flush after every log message,
  # to an integer to flush every N messages, or to false, nil, or zero to
  # never auto-flush. If you turn auto-flushing off, be sure to regularly
  # flush the log yourself -- it will eat up memory until you do.
  def auto_flushing=(period)
    @auto_flushing[Thread.current] =
      case period
      when true;                1
      when false, nil, 0;       MAX_BUFFER_SIZE
      when Integer;             period
      else raise ArgumentError, "Unrecognized auto_flushing period: #{period.inspect}"
      end
  end

  def flush
    @guard.synchronize do
      buffer.each do |content|
        @log.write(content)
      end

      # Important to do this even if buffer was empty or else @buffer will
      # accumulate empty arrays for each request where nothing was logged.
      clear_buffer
    end
  end

  def close
    flush
    @log.close if @log.respond_to?(:close)
    @log = nil
  end

private
    
  def auto_flush
    flush if buffer.size >= auto_flushing
  end

  def buffer
    @buffer[Thread.current]
  end

  def clear_buffer
    @buffer.delete(Thread.current)
  end

end

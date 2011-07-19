require 'term/ansicolor'

module BufferedLogger::Formatting
  DEFAULT_LEVEL = :default

private

  def initialize
    @formatter = BufferedLogger::ThreadHash.new { |h,k| h[k] = {} }
    super()
  end

  def formatter(severity = DEFAULT_LEVEL)
    @formatter[Thread.current][severity] || @formatter[master_thread][severity] || default_formatter
  end

  def set_formatter(severity = DEFAULT_LEVEL, format = nil)
    @formatter[Thread.current][severity] = BufferedLogger::Formatter.new(:format => format, :color => color?)
  end

  def default_formatter
    @formatter[master_thread][DEFAULT_LEVEL] ||= BufferedLogger::Formatter.new(:color => color?)
  end

# magic format getters/setters

  def method_missing(method, *args, &block)
    case method.to_s
    when /^(#{BufferedLogger::SEVERITY_LEVELS.join('|')})_formatter(=)?$/
      $2 ? set_formatter($1.to_sym, args[0]) : formatter($1.to_sym)
    else
      super(method, *args, &block)
    end
  end

end


class BufferedLogger::Formatter
  include ::Term::ANSIColor

  FORMAT = "%s"
  COLOR = true

  def initialize(params = {})
    @format = params[:format] || FORMAT
    @color = params[:color] == false ? false : COLOR
  end

# format accessors

  def to_s 
    @format 
  end

  def format=(format)
    @format = format.to_s 
  end

# color accessors

  def color?
    @color 
  end

  def toggle_color
    @color = !@color
  end

# formatting

  def %(message)
    formatted_message = @format % message.to_s
    color? ? parse_color(formatted_message) : formatted_message
  end

private

  def parse_color(message)
    color_methods = Term::ANSIColor.instance_methods
    color_matcher = /#{color_methods.map {|m| "\\$#{m}\\s?"}.join('|')}/

    strings = message.split(color_matcher)
    colors = message.scan(color_matcher).map { |c| c[1..-1].strip }

    colored_message = ''
    strings[1..-1].each_with_index { |s,i| colored_message << self.send(colors[i], s) }
    strings[0] + colored_message
  end

end


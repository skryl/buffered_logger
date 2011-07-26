module BufferedLogger::Indentation
  INDENT_LEVEL = 2

  def initialize
    @padding = BufferedLogger::ThreadHash.new { |h,k| h[k] = BufferedLogger::Padding.new }
    super()
  end

  def padding
    @padding[Thread.current]
  end

  def indent(level = INDENT_LEVEL, &block)
    if block_given?
      padding.indent(level)
      ret_val = block.call
      padding.indent(-level)
      return ret_val
    else
      padding.indent(level)
    end
  end

end

class BufferedLogger::Padding
  PADDING_CHAR = ' '
  PADDING_RESET= :reset
  attr_reader :padding_char

  def initialize(params = {})
    @padding = ''
    @padding_char = params[:padding_char] || PADDING_CHAR
    indent(params[:indent] || 0)
  end

  def padding_char=(char)
    @padding_char = char.to_s[0..1]
  end

  def to_s
    @padding 
  end

  def indent(indent_level)
    @padding = \
      if indent_level == PADDING_RESET
        ''
      elsif indent_level > 0
        @padding + (@padding_char * indent_level)
      else
        @padding[0..(-1+indent_level)]
      end
    indent_level
  end

  def %(message)
    @padding + message.to_s 
  end

end

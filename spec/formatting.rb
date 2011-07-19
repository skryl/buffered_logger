require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe BufferedLogger::Formatter do
  before :each do
    @f = BufferedLogger::Formatter.new
  end

  describe 'initialization and accessors' do
    it "should init a new formatter object" do
      @f.should be_an_instance_of BufferedLogger::Formatter
    end

    it "should return the default format string" do
      @f.to_s.should == '%s'
    end

    it "should set the format string" do
      @f.format = '%d'
      @f.to_s.should == '%d'
    end

    it 'should check if color is enabled by default' do
      @f.color?.should be_true
    end

    it 'should toggle the color setting' do
      @f.toggle_color
      @f.color?.should be_false
      @f.toggle_color
      @f.color?.should be_true
    end

    it 'should construct a formatter object based on params' do
      f = BufferedLogger::Formatter.new(:format => '%s%s%s', :color => false)
      f.to_s.should == '%s%s%s'
      f.color?.should be_false
    end
  end

  describe 'formatting' do
    it 'should parse color codes' do
      s = "$blue blue $green green $red red"
      @f.send(:parse_color, s).should == "\e[34mblue \e[0m\e[32mgreen \e[0m\e[31mred\e[0m"
    end

    it 'should format an input string' do
      s = 'text'
      (@f % s).should == 'text'
      @f.format = '### %s ###'
      (@f % s).should == '### text ###'
      @f.format = '$blue ### $red %s $blue ###'
      (@f % s).should == "\e[34m### \e[0m\e[31mtext \e[0m\e[34m###\e[0m"
    end
  end
end

describe BufferedLogger do
  before :each do
    @f = StringIO.new
    @l = BufferedLogger.new(@f)
  end

  describe 'formatting' do
    it 'should use appropriate formatting for each thread' do
      @l.send(:set_formatter, :info, "$blue %s")
      @l.info "oh"

      t = Thread.new do
        @l.send(:set_formatter, :info, "$red %s")
        @l.info 'blah'
      end; t.join

      t = Thread.new do
        @l.info 'hey'
      end; t.join

      @l.info "haha"

      # colors are off so the keywords won't be parsed
      @f.string.should == "$blue oh\n$red blah\n$blue hey\n$blue haha\n"
    end

    it 'should use appropriate formatting for each severity level' do
      @l.send(:set_formatter, :error, "$red %s")
      @l.send(:set_formatter, :info, "$blue %s")
      @l.error 'error'
      @l.info 'info'
      @f.string.should == "$red error\n$blue info\n"
    end

    it 'should use the master thread formatter if one isnt set' do
      @l.send(:set_formatter, :error, "$red %s")
      @l.error 'test'

      t = Thread.new do
        @l.error 'blah'
      end; t.join
      @f.string.should == "$red test\n$red blah\n"
    end

    it 'should use the master thread default formatter if one isnt set' do
      t_formatter = nil
      t = Thread.new do
        t_formatter = @l.send(:formatter, :info)
      end; t.join

      t_formatter.should == @l.send(:formatter, :info)
      t_formatter.should == @l.send(:formatter, :error)
    end

    it 'should allow syntactic sugar to get/set formatters' do
      BufferedLogger::SEVERITY_LEVELS.each do |s|
        @l.send("#{s}_formatter=", "$green #{s}: $white %s")
        @l.send("#{s}_formatter").to_s.should == "$green #{s}: $white %s"
      end
    end

  end

end

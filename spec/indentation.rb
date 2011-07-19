require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe BufferedLogger::Padding do

  before :each do
    @p = BufferedLogger::Padding.new
  end

  describe 'initialization and accessors' do
    it "should initialize a new padding object" do
      @p.should be_an_instance_of BufferedLogger::Padding
    end

    it "should set padding character" do
      @p.padding_char = '#'
      @p.padding_char.should == '#'
    end

    it "should return the padding string" do
      @p.to_s.should == ''
    end

    it "should construct pre-padded strings" do
      p = BufferedLogger::Padding.new(:indent => 4, :padding_char => '#')
      p.to_s.should == '####'
    end
  end

  describe 'indentation' do
    it "should indent padding a positive amount" do
      @p.indent(2)
      @p.to_s.should == '  '
    end

    it "should indent padding a negative amount" do
      @p.indent(3)
      @p.indent(-2)
      @p.to_s.should == ' '
    end

    it "should reset padding indentation" do
      @p.indent(10)
      @p.indent(:reset)
      @p.to_s.should == ''
    end
  end
  
  describe 'formatting' do
    it "should apply padding to any input string" do
      s = 'text'
      @p.indent(4)
      (@p % s).should == '    text'
    end
  end

end


describe BufferedLogger do
  before :each do
    @f = StringIO.new
    @l = BufferedLogger.new(@f)
  end

  describe 'indentation' do
    it 'should use appropriate indentation for each thread' do
      @l.indent(4)
      @l.info 'hello'

      t = Thread.new do
        @l.indent(2)
        @l.info 'blah'
      end; t.join

      t = Thread.new do
        @l.info 'hey'
      end; t.join

      @l.info 'hi'

      @f.string.should == "    hello\n  blah\nhey\n    hi\n"
    end

    it 'should temporarily indent any logging in an indent block' do
      @l.indent(4) do
        @l.info 'blah'
      end
      @l.info 'blah'
      @f.string.should == "    blah\nblah\n"
    end
  end
end

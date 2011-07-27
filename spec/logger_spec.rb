require File.join(File.dirname(__FILE__), "spec_helper.rb")
require 'rubygems'
require 'active_support/buffered_logger'

describe BufferedLogger do
  before :each do
    @f = StringIO.new
    @l = BufferedLogger.new(@f)
  end

  describe 'initialization and accessors' do
    it 'should initialize a new logger object' do
      @l.should be_an_instance_of BufferedLogger
    end

    it 'should initialize a logger object using a severity level symbol' do
      l = BufferedLogger.new(@f, :info)
      l.info  "info"
      l.debug "debug"
      l.warn  "warn"
      @f.string.should == "info\nwarn\n"
    end

    it 'should be able to toggle color' do
      @l.color?.should == false
      @l.enable_color
      @l.color?.should == true
      @l.disable_color
      @l.color?.should == false
      @l.toggle_color
      @l.color?.should == true
    end

    it 'should support color for STDOUT unless forced' do
      l = BufferedLogger.new(STDOUT)
      l.send(:stdout?).should == true
      l.color?.should == true
    end

    it 'should not support color when not printing to STDOUT unless forced' do
      @l.color?.should == false
      @l.toggle_color
      @l.color?.should == true
    end

    it 'should autoset formatters during init' do
      l = BufferedLogger.new(STDOUT, 0, {:info => '$green INFO: $white %s', :warn => '$yellow WARNING: $white %s', :error => '$red ERROR: $white %s'})
      l.send(:formatter, :info).to_s.should == '$green INFO: $white %s'
      l.send(:formatter, :warn).to_s.should == '$yellow WARNING: $white %s'
      l.send(:formatter, :error).to_s.should == '$red ERROR: $white %s'
    end
  end

  describe 'delegation and magic methods' do
    it 'should maintain backwards compatibility with buffered_logger interface' do
      delegated = ActiveSupport::BufferedLogger.public_instance_methods(false)
      delegated.each { |method| @l.should respond_to(method) }
    end

    it 'should respond to magic methods' do
      magic = BufferedLogger::SEVERITY_LEVELS
      magic.each { |method| @l.should respond_to(method) }
    end
  end

  describe 'logging' do
    it 'should log to a IO object' do
      severities = BufferedLogger::SEVERITY_LEVELS
      severities.each do |s|
        f = StringIO.new
        l = BufferedLogger.new(f)
        l.send(s, "#{s}_message")
        f.string.should == "#{s}_message\n"
      end
    end

    it 'should buffer unflushed statements' do
      @l.auto_flushing = 0
      @l.info 'test'
      @l.info 'test2'
      @l.buffer_text.should == "test\ntest2\n"
      @f.string.should == ''
      @l.flush
      @f.string.should == "test\ntest2\n"
    end

    it 'should insert a blank line' do
      @l.print_blank_line
      @f.string.should == "\n"
    end

    it 'should log an empty string' do
      @l.info
      @f.string.should == "\n"
    end
  end

end

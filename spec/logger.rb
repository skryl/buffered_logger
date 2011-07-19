require File.join(File.dirname(__FILE__), "spec_helper.rb")

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

    it 'should support color when printing to STDOUT' do
      l = BufferedLogger.new(STDOUT)
      l.send(:color?).should == true
    end

    it 'should not support color when not printing to STDOUT' do
      @l.send(:color?).should == false
    end

    it 'should autoset formatters during init' do
      l = BufferedLogger.new(STDOUT, 0, {:info => '$green INFO: $white %s', :warn => '$yellow WARNING: $white %s', :error => '$red ERROR: $white %s'})
      l.send(:formatter, :info).to_s.should == '$green INFO: $white %s'
      l.send(:formatter, :warn).to_s.should == '$yellow WARNING: $white %s'
      l.send(:formatter, :error).to_s.should == '$red ERROR: $white %s'
    end
  end

  describe 'delegation and magic methods' do
    it 'should respond to delegated methods' do
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
  end

end

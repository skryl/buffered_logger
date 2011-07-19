require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe BufferedLogger do
  before :each do
    @f = StringIO.new
    @l = BufferedLogger.new(@f)
  end

  describe 'buffering' do
  end

end

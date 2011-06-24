spec = Gem::Specification.new do |s|
  s.name = 'buffered_logger'
  s.version = '0.0.2'

  s.summary = "Extending ActiveSupport's BufferedLogger"
  s.description = %{ActiveSupport's BufferedLogger with a few enhancements}
  s.files = ['lib/buffered_logger.rb']
  s.require_path = 'lib'
  s.author = "Alex Skryl"
  s.email = "rut216@gmail.com"
  s.homepage = "http://github.com/skryl"

  s.add_dependency(%q<activesupport>, [">= 0"])
end

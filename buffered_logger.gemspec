spec = Gem::Specification.new do |s|
  s.name = 'buffered_logger'
  s.version = '0.0.2'

  s.summary = "Extensions to ActiveSupport::BufferedLogger"
  s.description = %{ActiveSupport's BufferedLogger with a few enhancements}
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + ["README", "TODO"]
  s.require_path = 'lib'
  s.author = "Alex Skryl"
  s.email = "rut216@gmail.com"
  s.homepage = "http://github.com/skryl"

  s.add_dependency(%q<activesupport>, [">= 0"])
end

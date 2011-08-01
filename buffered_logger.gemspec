spec = Gem::Specification.new do |s|
  s.name = 'buffered_logger'
  s.version = '0.1.2'

  s.summary = "A flexible, thread safe logger with custom formatting and ANSI color support" 
  s.description = %{A thread safe logger with formatting extensions. Based on active_support/buffered_logger.}
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + ["README", "TODO"]
  s.require_path = 'lib'
  s.author = "Alex Skryl"
  s.email = "rut216@gmail.com"
  s.homepage = "http://github.com/skryl"

  s.add_dependency(%q<term-ansicolor>, [">= 0"])
  s.add_dependency(%q<activesupport>, [">= 0"])
  s.add_dependency(%q<i18n>, [">= 0"])
end

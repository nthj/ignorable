Gem::Specification.new do |s|
  s.name        = "ignorable"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nathaniel Jones", "Mando Escamilla"]
  s.email       = ["hello@nthj.me", ""]
  s.homepage    = "http://github.com/nthj/ignorable"
  s.summary     = "Ignore columns in ActiveRecord models"
  s.description = "Ignore problematic column names (like 'attributes' or 'class') in ActiveRecord models for legacy database schemas"
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "ignorable"
 
  s.add_dependency("rails", ">= 3")

  s.files        = Dir.glob("{lib}/**/*") + %w(README.md)
  s.require_path = 'lib'
end

Gem::Specification.new do |s|
  s.name        = "ignorable"
  s.version     = "0.4.0"
  s.authors     = ["Nathaniel Jones", "Mando Escamilla"]
  s.email       = ["nj@third.io", ""]
  s.homepage    = "http://github.com/nthj/ignorable"
  s.summary     = "Ignore columns in ActiveRecord models"
  s.description = "Ignore problematic column names (like 'attributes' or 'class') in ActiveRecord models for legacy database schemas"

  s.add_runtime_dependency 'activerecord', '>= 3', '< 5'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 2'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'appraisal'

  s.files        = Dir.glob("{lib}/**/*") + %w(README.md)
  s.license      = "MIT"
end

require 'active_record'
puts "Testing Against ActiveRecord #{ActiveRecord::VERSION::STRING}"

ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => ":memory:")

require File.expand_path("../../lib/ignorable.rb", __FILE__)

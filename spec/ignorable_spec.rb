require 'spec_helper'

describe Ignorable do
  
  class TestModel < ActiveRecord::Base
    connection.create_table :test_models do |t|
      t.string :name
      t.string :attributes
      t.integer :legacy
    end unless table_exists?
    
    ignore_columns :legacy, :attributes
    has_many :things
  end
  
  class Thing < ActiveRecord::Base
    connection.create_table :things do |t|
      t.integer :test_model_id
      t.integer :value
      t.datetime :updated_at
      t.datetime :created_at
    end unless table_exists?
    
    ignore_column :updated_at, :created_at
    belongs_to :test_model
  end
  
  around :each do |example|
    ActiveRecord::Base.transaction do
      example.call
      raise ActiveRecord::Rollback
    end
  end

  it "should remove the columns from the class" do
    TestModel.column_names.sort.should == ["id", "name"]
    Thing.column_names.sort.should == ["id", "test_model_id", "value"]
  end
  
  it "should remove the columns from the attribute names" do
    TestModel.new.attribute_names.sort.should == ["id", "name"]
    Thing.new.attribute_names.sort.should == ["id", "test_model_id", "value"]
  end
  
  it "should remove the accessor methods" do
    TestModel.new.should_not respond_to(:updated_at)
    TestModel.new.should_not respond_to(:updated_at=)
  end
  
  it "should not override existing methods with ignored column accessors" do
    model = TestModel.new
    model.attributes.should == {"id" => nil, "name" => nil}
    model.attributes = {:name => "test"}
    model.name.should == "test"
  end
  
  it "should not affect inserts" do
    model = TestModel.create!(:name => "test")
    model.reload
    model.name.should == "test"
    model.attributes["legacy"].should == nil
  end
  
  it "should not affect selects" do
    TestModel.connection.insert("INSERT INTO test_models (name, legacy, attributes) VALUES ('test', 1, 'woo')")
    model = TestModel.where(:name => "test").first
    model.name.should == "test"
    model.attributes["legacy"].should == nil
    model.attributes["attributes"].should == nil
  end
  
  it "should not affect updates" do
    TestModel.connection.insert("INSERT INTO test_models (name, legacy, attributes) VALUES ('test', 1, 'woo')")
    model = TestModel.where(:name => "test").first
    model.name = "test2"
    model.save!
    results = TestModel.connection.select_one("SELECT name, legacy, attributes from test_models where name = 'test2'")
    results.should == {"name"=>"test2", "legacy" => 1, "attributes" => "woo"}
  end
  
  it "should work with associations" do
    TestModel.connection.insert("INSERT INTO test_models (id, name, legacy, attributes) VALUES (1, 'test', 1, 'woo')")
    Thing.connection.insert("INSERT INTO things (id, test_model_id, value, updated_at, created_at) VALUES (1, 1, 10, '#{Time.now.to_formatted_s(:db)}', '#{Time.now.to_formatted_s(:db)}')")
    model = TestModel.create!(:name => "test")
    thing = Thing.create!(:test_model_id => model.id, :value => 10)
    model.things.first.value.should == 10
    thing.test_model.name.should == "test"
  end
  
  it "should work with magic timestamp columns" do
    thing = Thing.create!(:test_model_id => 1, :value => 10)
    results = Thing.connection.select_one("SELECT id, value, test_model_id, updated_at, created_at FROM things where id = #{thing.id}")
    results.should == {"id" => 1, "value" => 10, "test_model_id" => 1, "updated_at" => nil, "created_at" => nil}
  end
end

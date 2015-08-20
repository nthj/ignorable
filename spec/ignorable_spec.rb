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

  class SubclassTestModel < TestModel
  end

  around :each do |example|
    ActiveRecord::Base.transaction do
      example.call
      raise ActiveRecord::Rollback
    end
  end

  it "should remove the columns from the class" do
    expect(TestModel.column_names.sort).to eql ["id", "name"]
    expect(Thing.column_names.sort).to eql ["id", "test_model_id", "value"]
  end

  it 'removes columns from the subclass' do
    expect(SubclassTestModel.column_names).to match_array(['id', 'name'])
  end

  context 'when ignore_columns is called after the columns are loaded' do
    before do
      @test_model = Class.new(ActiveRecord::Base) do
        self.table_name = 'test_models'
      end
      @subclass = Class.new(@test_model)

      # Force columns to load
      @test_model.columns
      @subclass.columns

      @test_model.ignore_columns :attributes, :legacy
    end

    it 'removes columns from the class' do
      expect(@test_model.column_names).to match_array(['id', 'name'])
    end

    it 'removes columns from the subclass' do
      expect(@subclass.column_names).to match_array(['id', 'name'])
    end
  end

  it "should remove the columns from the attributes hash" do
    expect(TestModel.new.attributes.keys.sort).to eql ["id", "name"]
    expect(Thing.new.attributes.keys.sort).to eql ["id", "test_model_id", "value"]
  end

  it "should remove the columns from the attribute names" do
    expect(TestModel.new.attribute_names.sort).to eql ["id", "name"]
    expect(Thing.new.attribute_names.sort).to eql ["id", "test_model_id", "value"]
  end

  it "should remove the accessor methods" do
    expect(TestModel.new).to_not respond_to(:updated_at)
    expect(TestModel.new).to_not respond_to(:updated_at=)
  end

  it "should not override existing methods with ignored column accessors" do
    model = TestModel.new
    expect(model.attributes).to eql({"id" => nil, "name" => nil})
    model.attributes = {:name => "test"}
    expect(model.name).to eql "test"
  end

  it "should not affect inserts" do
    model = TestModel.create!(:name => "test")
    model.reload
    expect(model.name).to eql "test"
    expect(model.attributes["legacy"]).to be_nil
  end

  it "should not affect selects" do
    TestModel.connection.insert("INSERT INTO test_models (name, legacy, attributes) VALUES ('test', 1, 'woo')")
    model = TestModel.where(:name => "test").first
    expect(model.name).to eql "test"
    expect(model.attributes["legacy"]).to eql nil
    expect(model.attributes["attributes"]).to eql nil
  end

  it "should not affect updates" do
    TestModel.connection.insert("INSERT INTO test_models (name, legacy, attributes) VALUES ('test', 1, 'woo')")
    model = TestModel.where(:name => "test").first
    model.name = "test2"
    model.save!
    results = TestModel.connection.select_one("SELECT name, legacy, attributes from test_models where name = 'test2'")
    expect(results).to eql({"name"=>"test2", "legacy" => 1, "attributes" => "woo"})
  end

  it "should work with associations" do
    TestModel.connection.insert("INSERT INTO test_models (id, name, legacy, attributes) VALUES (1, 'test', 1, 'woo')")
    Thing.connection.insert("INSERT INTO things (id, test_model_id, value, updated_at, created_at) VALUES (1, 1, 10, '#{Time.now.to_formatted_s(:db)}', '#{Time.now.to_formatted_s(:db)}')")
    model = TestModel.create!(:name => "test")
    thing = Thing.create!(:test_model_id => model.id, :value => 10)
    expect(model.things.first.value).to eql 10
    expect(thing.test_model.name).to eql "test"
  end

  it "should work with magic timestamp columns" do
    thing = Thing.create!(:test_model_id => 1, :value => 10)
    results = Thing.connection.select_one("SELECT id, value, test_model_id, updated_at, created_at FROM things where id = #{thing.id}")
    expect(results).to eql({"id" => 1, "value" => 10, "test_model_id" => 1, "updated_at" => nil, "created_at" => nil})
  end
end

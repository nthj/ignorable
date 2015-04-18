require 'active_record'
require 'active_support/core_ext/class/attribute'

module Ignorable
  module InstanceMethods
    def attribute_names # :nodoc:
      super.reject{|col| self.class.ignored_column?(col)}
    end
  end

  module ClassMethods
    def columns # :nodoc:
      @columns ||= super.reject{|col| ignored_column?(col)}
    end

    # Prevent Rails from loading a table column.
    # Useful for legacy database schemas with problematic column names,
    # like 'class' or 'attributes'.
    #
    #   class Topic < ActiveRecord::Base
    #     ignore_columns :attributes, :class
    #   end
    #
    #   Topic.new.respond_to?(:attributes) => false
    def ignore_columns(*columns)
      self.ignored_columns ||= []
      self.ignored_columns += columns.map(&:to_s)
      reset_column_information
      descendants.each(&:reset_column_information)
      self.ignored_columns.tap(&:uniq!)
    end
    alias ignore_column ignore_columns

    # Has a column been ignored?
    # Accepts both ActiveRecord::ConnectionAdapter::Column objects,
    # and actual column names ('title')
    def ignored_column?(column)
      self.ignored_columns.present? && self.ignored_columns.include?(
        column.respond_to?(:name) ? column.name : column.to_s
      )
    end

    def reset_ignored_columns
      self.ignored_columns = []
      reset_column_information
    end
  end
end

unless ActiveRecord::Base.include?(Ignorable::InstanceMethods)
  ActiveRecord::Base.send :include, Ignorable::InstanceMethods
  ActiveRecord::Base.send :extend, Ignorable::ClassMethods
  ActiveRecord::Base.send :class_attribute, :ignored_columns
end

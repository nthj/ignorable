require 'active_record'

module Ignorable
  extend ActiveSupport::Concern
  
  def attribute_names # :nodoc:
    super.reject{|col| self.class.ignored_column?(col)}
  end

  module ClassMethods
    def columns # :nodoc:
      @columns ||= super.reject{|col| ignored_column?(col)}
    end

    attr_reader :ignored_columns

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
      @ignored_columns ||= []
      @ignored_columns += columns.map(&:to_s)
      reset_column_information
      @ignored_columns.tap(&:uniq!)
    end
    alias ignore_column ignore_columns

    # Has a column been ignored?
    # Accepts both ActiveRecord::ConnectionAdapter::Column objects,
    # and actual column names ('title')
    def ignored_column?(column)
      ignored_columns.present? && ignored_columns.include?(
        column.respond_to?(:name) ? column.name : column.to_s
      )
    end

    def reset_ignored_columns
      @ignored_columns = []
      reset_column_information
    end
  end
end

if defined?(ActiveRecord::Base) && !ActiveRecord::Base.include?(Ignorable)
  ActiveRecord::Base.send :include, Ignorable
end

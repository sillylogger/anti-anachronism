require 'active_support'

module ActiveRecord
  extend ActiveSupport::Concern

  class_methods do

    def table
      @table ||= {}
    end

    def all
      @table.values
    end

    def count
      @table.values.size
    end

    def first
      @table.values.first
    end

    def find_by_id id
      # all.find{|r| r.id == id }
      @table[id]
    end

  end

  included do

    def save
      self.class.table[self.id] = self
    end
  end

end

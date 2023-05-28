require 'active_support'

module ActiveRecord
  extend ActiveSupport::Concern

  class_methods do
    def all
      @all ||= []
    end

    def all= all
      @all = all
    end

    def exists? instance
      all.include? instance
    end

    def count
      all.size
    end

    def first
      all.first
    end

    def find_by_id id
      all.find{|o| o.id == id }
    end

  end

  included do
    def save
      self.class.all << self unless self.class.exists?(self)
    end
  end

end

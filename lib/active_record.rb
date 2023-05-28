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

    def count
      all.size
    end

    def first
      all.first
    end

  end

  included do
    def save
      self.class.all << self
    end
  end

end

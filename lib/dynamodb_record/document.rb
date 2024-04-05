# frozen_string_literal: true

module DynamodbRecord
  module Document
    extend ActiveSupport::Concern
    include DynamodbRecord::Fields
    include DynamodbRecord::Persistence
    include DynamodbRecord::Finders
    include DynamodbRecord::Query
    include DynamodbRecord::Associations

    included do
      class_attribute :base_class
      self.base_class = self
    end

    module ClassMethods
      def from_database(attrs)
        new(attrs, true).tap { |r| r.new_record = false }
      end
    end

    attr_accessor :new_record

    def initialize(params = {}, ignore_unknown_field = false)
      @new_record = true
      @attributes = {} # Validar esta linea

      # Set default
      self.class.attributes.each do |key, value|
        send("#{key}=", value[:options][:default]) if value[:options][:default]
      end

      load(params, ignore_unknown_field)
    end

    def load(params, ignore_unknown_field = false)
      params.each do |key, value|
        next if ignore_unknown_field && !respond_to?("#{key}=")

        send("#{key}=", value)
      end
    end
  end
end

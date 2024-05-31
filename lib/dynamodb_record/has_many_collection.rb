# frozen_string_literal: true

module DynamodbRecord
  # +Dynamodb::ManyToManyCollection+ is a class that represent a ManyToManyCollection
  class HasManyCollection
    include Enumerable

    def initialize(pager, base_object)
      @base_object = base_object
      @pager = pager
      @klass = @pager.klass
      @options = @pager.options
      @foreign_key = @options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }
      @items = []
      @pager.items.each do |object|
        @items << @klass.send(:from_database, object)
      end
      
    end

    def each(&)
      @items.each(&)
    end

    def last_evaluated_key
      @pager.last_evaluated_key
    end

    def next_page?
      @pager ? @pager.next_page? : false
    end

    def next_page
      self.class.new(@pager.next_page, @base_object)
    end

    def page(last_key)
      self.class.new(@pager.next_page(last_key), @base_object) if last_key
    end

    def create!(params = {})
      raise "#{@base_object.class} must be saved" if @base_object.new_record

      params.merge!(@foreign_key)
      object = @klass.send(:from_database, params)
      object.save!
      @items << object
      object
    end

    def << (object)

      raise "#{@object.class} must be saved" if @base_object.new_record

      foreign_key = @options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }

      table_name = @options[:table_name]

      item = foreign_key.merge(object.attributes)

      
      key = {table_name:, item:}
      
      res = @items.none? { |data| data.id == object.id }
      
      if res
        item[:updated_at] = DateTime.now.to_s
        item[:created_at] = object.created_at.to_s
        @klass.client.put_item(key)
        @items << object
      end

      @items

    end
  end
end

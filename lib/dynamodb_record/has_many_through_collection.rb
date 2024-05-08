# frozen_string_literal: true

module DynamodbRecord
  # +Dynamodb::HasManyThroughCollection+ is a class that represent a ManyToManyCollection
  class HasManyThroughCollection
    include Enumerable

    def initialize(pager, base_object)
      @base_object = base_object
      @pager = pager
      @klass = @pager.klass
      @options = @pager.options
      @items = []
      @pager.items.each do |item|
        # p item
        object = @klass.client.get_item(
          table_name: @klass.table_name,
          key: {id: item["#{@klass.to_s.downcase}_id"]}
        )
        @items << @klass.send(:from_database, object.item)
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
  end
end

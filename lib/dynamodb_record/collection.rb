# frozen_string_literal: true

module DynamodbRecord
  class Collection
    include Enumerable

    # attr_reader :last_evaluated_key

    def initialize(pager, base_object)
      @base_object = base_object
      @pager = pager
      @klass = @pager.klass
      @options = @pager.options
      items = @pager.items
      @items = items.map { |item| @klass.send(:from_database, item) }
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

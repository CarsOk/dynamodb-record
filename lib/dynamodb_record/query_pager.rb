# frozen_string_literal: true

module DynamodbRecord
  # +Dynamodb::Page+ is a class that include logic business from paginate
  class QueryPager < Pager
    attr_reader :last_evaluated_key, :items, :options

    def initialize(options, klass)
      super(options, klass)
      response = @klass.client.query(@options)
      @items = response.items
      @last_evaluated_key = response.last_evaluated_key
    end

    def next_page?
      last_evaluated_key ? true : false
    end

    def next_page(last_key = nil)
      return nil unless next_page?

      @last_evaluated_key = last_key if last_key.present?

      @options.merge!(exclusive_start_key: last_evaluated_key) if next_page?
      self.class.new(@options, @klass)
    end
  end
end

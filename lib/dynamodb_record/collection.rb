# frozen_string_literal: true

module DynamodbRecord
  class Collection
    include Enumerable

    # attr_reader :last_evaluated_key

    def initialize(pager, klass, options = {})
      @klass = klass
      @table_name = options[:table_name]
      @foreign_key = options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }
      @items = pager.items.map { |item| klass.send(:from_database, item) }
      @last_evaluated_key = pager.last_evaluated_key
    end

    def last_evaluated_key
      if @last_evaluated_key.nil?
        nil
      else
        json_string = JSON.dump(@last_evaluated_key)
        Base64.urlsafe_encode64(json_string)
      end
    end

    def each(&)
      @items.each(&)
    end

    def next_page?
      last_evaluated_key ? true : false
    end

    def create!(items = {})
      items.merge!(@foreign_key)
      object = @klass.create!(items)
      unless @klass.to_s.pluralize.downcase == @table_name.to_s

        client = @klass.client
        @foreign_key.merge!({ "#{@klass.to_s.downcase}_id": object.id, created_at: Time.now.to_i })
        client.put_item({ table_name: @table_name, item: @foreign_key })
      end
      @items << object
      object
    end
  end
end

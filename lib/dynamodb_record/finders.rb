# frozen_string_literal: true

module DynamodbRecord
  module Finders
    extend ActiveSupport::Concern

    class_methods do
      def find(id, range_key = nil)
        key = { 'id' => id }

        key[self.range_key] = range_key if self.range_key
        puts table_name
        response = client.get_item(
          table_name:,
          key:
        )
        response.item ? from_database(response.item) : nil
      end
    end
  end
end

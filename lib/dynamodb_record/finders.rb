# frozen_string_literal: true

module DynamodbRecord
  module Finders
    extend ActiveSupport::Concern

    class_methods do
      def find(id, range_key = nil)
        find!(id, range_key)
      rescue StandardError
        nil
      end

      def find!(id, range_key = nil)
        key = {}
        key[hash_key] = id
        key[self.range_key] = range_key if self.range_key

        response = client.get_item(
          table_name:,
          key:
        )
        response.item ? from_database(response.item) : raise('Record Not Found')
      end
    end
  end
end

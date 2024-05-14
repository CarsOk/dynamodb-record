# rubocop:disable Style/FrozenStringLiteralComment

module DynamodbRecord
  # Query Module
  module Query
    extend ActiveSupport::Concern

    # Module that provides class methods for queries against the DynamoDB database.
    module ClassMethods
      def all(opts = {})
        options = default_options
        options.merge!(opts.slice(:limit))
        scan_pager = ScanPager.new(options, self)
        Collection.new(scan_pager, self)
      end

      # search table
      # @param opts [Hash] Limit of record and exclusive_start_key
      def where(opts = {})
        limit = opts.delete(:limit)
        exclusive_start_key = opts.delete(:exclusive_start_key)

        expression_attribute_names = {}
        expression_attribute_values = {}
        filter_expression = ''
        opts.each do |key, value|
          expression_attribute_names[:"##{key}"] = key.to_s
          expression_attribute_values[":#{key}"] = value
          filter_expression << if filter_expression.empty?
                                 "##{key} = :#{key}"
                               else
                                 " And ##{key} = :#{key}"
                               end
        end

        options = default_options
        options.merge!(limit:) if limit
        options.merge!(expression_attribute_names:) if expression_attribute_names.present?
        options.merge!(expression_attribute_values:) if expression_attribute_values.present?
        options.merge!(filter_expression:) if filter_expression.present?

        options.merge!(exclusive_start_key:) if exclusive_start_key
        # p options

        scan_pager = ScanPager.new(options, self)
        Collection.new(scan_pager, self)

        # DynamodbRecord::Collection.new(client.scan(options), self)
      end
    end
  end
end
# rubocop:enable Style/FrozenStringLiteralComment

# frozen_string_literal: true

module DynamodbRecord
  # Persistence Module
  module Persistence
    extend ActiveSupport::Concern

    class_methods do
      def table_name
        name = ActiveSupport::Inflector.tableize(base_class.name).split('/').last
        @table_name ||= DynamodbRecord::Config.namespace ? "#{DynamodbRecord::Config.namespace}-#{name}" : name
      end

      def client
        opts = {region: DynamodbRecord::Config.region}
        opts[:endpoint] = DynamodbRecord::Config.endpoint if DynamodbRecord::Config.endpoint
        opts[:access_key_id] = DynamodbRecord::Config.access_key_id if DynamodbRecord::Config.access_key_id
        opts[:secret_access_key] = DynamodbRecord::Config.access_key_id if DynamodbRecord::Config.secret_access_key
        @client ||= Aws::DynamoDB::Client.new(opts)
      end

      def default_options
        {table_name:}
      end

      def describe_table
        client.describe_table(default_options)
      end

      def create_table(opts = {})
        table_name = opts[:table_name] || self.table_name
        read_capacity = opts[:read_capacity] || DynamodbRecord::Config.read_capacity_units
        write_capacity = opts[:write_capacity] || DynamodbRecord::Config.write_capacity_units

        attribute_definitions = []
        key_schema = []

        # Default id hash key
        attribute_definitions << {attribute_name: 'id',
                                  attribute_type: 'S'}
        key_schema << {attribute_name: 'id',
                       key_type: 'HASH'}

        if range_key
          attribute_definitions << {attribute_name: range_key.to_s,
                                    attribute_type: dynamodb_type(attributes[range_key][:type])}
          key_schema << {attribute_name: range_key.to_s,
                         key_type: 'RANGE'}
        end

        # Global secondary indexes
        indexes = []
        attributes.each do |key, value|
          indexes << key if value[:options][:index]
        end

        # global_secoglobal_secondary_indexesndary_indexes = []
        indexes.each do |index|
          index_definition = {}
          index_definition[:index_name] = "#{index}_index"
          index_definition[:key_schema] = [{attribute_name: index, key_type: 'HASH'},
                                           {attribute_name: 'id', key_type: 'RANGE'}]
          index_definition[:projection] = {projection_type: 'ALL'}
          index_definition[:provisioned_throughput] = {
            read_capacity_units: 1,
            write_capacity_units: 1
          }
          global_secondary_indexes << index_definition
          attribute_definitions << {attribute_name: index.to_s,
                                    attribute_type: dynamodb_type(attributes[index][:type])}
        end

        options = {
          attribute_definitions:,
          table_name:,
          key_schema:,
          provisioned_throughput: {
            read_capacity_units: read_capacity,
            write_capacity_units: write_capacity
          }
        }

        options.merge!(global_secondary_indexes:) unless global_secondary_indexes.empty?
        client.create_table(options)
      end

      def create(key = {})
        create!(key)
      rescue StandardError
        nil
      end

      def create!(key = {})
        object = new(key)
        object.save!
        object
      end
    end

    def save
      save!
      true
    rescue StandardError
      false
    end

    def save!
      options = self.class.default_options

      self.id = SecureRandom.uuid if id.nil?
      time = Time.now
      self.created_at = time if created_at.nil?
      self.updated_at = time

      if @new_record # New item. Don't overwrite if id exists
        options.merge!(condition_expression: 'id <> :s', expression_attribute_values: {':s' => id})
      end

      options.merge!(item: self.class.unload(attributes))
      # puts options
      self.class.client.put_item(options)
      @new_record = false
    end

    def destroy
      options = self.class.default_options
      hash_key = self.class.hash_key
      range_key = self.class.range_key
      key = {}
      key[hash_key] = self.class.dump_field(read_attribute(hash_key), self.class.attributes[hash_key])

      if range_key.present?
        key[range_key] = self.class.dump_field(read_attribute(range_key), self.class.attributes[range_key])
      end

      self.class.client.delete_item(options.merge(key:))
    end
  end
end

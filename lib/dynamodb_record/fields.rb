# frozen_string_literal: true

module DynamodbRecord
  module Fields
    extend ActiveSupport::Concern

    included do
      class_attribute :attributes, instance_writer: true
      self.attributes = {}
      # self.hash_key = nil

      # default hash key
      field :id, :string
      field :created_at, :datetime
      field :updated_at, :datetime
    end

    class_methods do
      def field(name, type = :string, opts = {})
        named = name.to_s
        # Add attributes
        attributes.merge!(name => {type:, options: opts})

        # self.hash_key = name if opts[:hash_key]
        # self.range_key = name if opts[:range_key]

        # Generate methods to field
        define_method("#{named}=") { |value| write_attribute(named, value) }
        define_method(name.to_s) { read_attribute(named) }
        define_method("#{name}?") do
          value = read_attribute(named)
          return value != 'false' if value.is_a?(String)

          !!value
        end
      end

      def undump_field(value, options)
        return nil if options.nil?

        case options[:type]
        when :integer
          value.to_i
        when :string
          value.to_s
        when :big_decimal
          value.to_d
        when :boolean
          if ['true', true].include?(value)
            true
          elsif ['false', false].include?(value)
            false
          else
            raise ArgumentError, 'Boolean column neither true nor false'
          end
        when :datetime
          if value.is_a?(Date) || value.is_a?(DateTime) || value.is_a?(Time)
            value
          else
            DateTime.parse(value)
          end
        when :array
          raise ArgumentError, 'Array column' unless value.is_a?(Array)

          value

        else
          raise ArgumentError, "Unknown type #{options[:type]}"
        end
      end

      def dump_field(value, options)
        return value if options.nil?

        case options[:type]
        when :datetime
          value.iso8601
        else
          value # aws-sdk supports the rest of data Types
        end
      end

      def unload(attrs)
        {}.tap do |hash|
          attrs.each do |key, value|
            hash[key] = dump_field(value, attributes[key.to_sym])
          end
        end
      end

      def hash_key
        @hash_key = attributes.select { |_k, v| v[:options][:hash_key] }.keys.first || :id
      end

      def range_key
        @range_key ||= begin
          attributes.select { |_k, v| v[:options][:range_key] }.keys.first
        rescue StandardError
          nil
        end
      end

      def secondary_indexes
        @secondary_indexes ||= begin
          attributes.select { |_k, v| v[:options][:index] }.keys
        rescue StandardError
          nil
        end
      end

      def dynamodb_type(type)
        case type
        when :integer, :big_decimal
          'N'
        when :string, :datetime
          'S'
          # else
          #   'S'
        end
      end
    end

    # Return a value
    def write_attribute(name, value)
      attributes[name.to_sym] = self.class.undump_field(value, self.class.attributes[name.to_sym])
    end

    def read_attribute(name)
      attributes[name.to_sym]
    end
  end
end

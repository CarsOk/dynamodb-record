# frozen_string_literal: true

module DynamodbRecord
  module Associations
    extend ActiveSupport::Concern

    class_methods do
      def has_many(associations)
        model = associations.to_s.upcase.chop
        define_method(associations) do
          # options = self.class.default_options
          field = self.class.to_s.downcase
          options = { table_name: associations }
          options.merge!(key_condition_expression: "##{field}_id = :#{field}_id")
          options.merge!(expression_attribute_names: { "##{field}_id": "#{field}_id" })
          options.merge!(expression_attribute_values: { ":#{field}_id" => id })

          options.merge!(index_name: "#{self.class.to_s.downcase}_id_index")

          klass = Object.const_get(model.capitalize)
          # puts options
          response = self.class.client.query(options)

          # pager = DynamodbRecord::Pager.new(self.class.client, options, clase)
          DynamodbRecord::Collection.new(response, klass, options)
        end
      end

      def has_and_belongs_to_many(associations)
        base_model = to_s.downcase
        relation_model = associations.to_s.chop
        list = []
        list << base_model
        list << relation_model
        sorted_list = list.sort
        table = sorted_list.map(&:pluralize).join('_')

        define_method(associations) do
          options = { table_name: table }

          if sorted_list.first == base_model
            field = sorted_list.first
          else
            field = sorted_list.last
            options.merge!(index_name: "#{table}_index")
          end
          options.merge!(key_condition_expression: "##{field}_id = :#{field}_id")
          options.merge!(expression_attribute_names: { "##{field}_id": "#{field}_id" })
          options.merge!(expression_attribute_values: { ":#{field}_id" => id })

          klass = Object.const_get(relation_model.capitalize)
          response = self.class.client.query(options)

          DynamodbRecord::Collection.new(response, klass, options)
        end
      end
    end
  end
end

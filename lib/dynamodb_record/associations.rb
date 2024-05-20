# frozen_string_literal: true

module DynamodbRecord
  module Associations
    extend ActiveSupport::Concern

    class_methods do
      def belongs_to(association)
        association = association.to_s

        define_method(association) do
          id = send("#{association}_id")
          klass = Object.const_get(association.capitalize)
          klass.find!(id)
        end
      end

      # rubocop:disable Naming/PredicateName
      def has_many(associations)
        base_model = to_s.downcase.split('::').last
        model = associations.to_s.chop

        define_method(associations) do
          table = Config.namespace ? "#{Config.namespace}-#{associations}" : associations

          options = {table_name: table}
          options.merge!(key_condition_expression: "##{base_model}_id = :#{base_model}_id")
          options.merge!(expression_attribute_names: {"##{base_model}_id": "#{base_model}_id"})
          options.merge!(index_name: "#{base_model}_id_index")

          options.merge!(expression_attribute_values: {":#{base_model}_id" => id})
          klass = Object.const_get(model.capitalize)
          query = QueryPager.new(options, klass)
          HasManyCollection.new(query, self)
        end
      end

      def has_many_through(associations, table)
        base_model = to_s.downcase.split('::').last
        relation_model = associations.to_s.chop
        list = []
        list << base_model
        list << relation_model
        sorted_list = list.sort
        options = {table_name: table.to_s}

        define_method(associations) do
          field = if sorted_list.first == base_model
                    sorted_list.first
                  else
                    sorted_list.last
                  end
          options.merge!(index_name: "#{field}_id_index")
          options.merge!(key_condition_expression: "##{field}_id = :#{field}_id")
          options.merge!(expression_attribute_names: {"##{field}_id": "#{field}_id"})

          options.merge!(expression_attribute_values: {":#{field}_id" => id})
          # p options

          klass = Object.const_get(relation_model.capitalize)

          # options.merge!(limit: 1)
          # p options

          query = QueryPager.new(options, klass)

          HasManyThroughCollection.new(query, self)
        end
      end

      def has_and_belongs_to_many(associations)
        base_model = to_s.downcase.split('::').last
        relation_model = associations.to_s.singularize
        list = []
        list << base_model
        list << relation_model
        sorted_list = list.sort

        define_method(associations) do
          if @collection.nil?
            options = {}
            pluralize_name = sorted_list.map(&:pluralize).join('-')
            table = Config.namespace ? "#{Config.namespace}-#{pluralize_name}" : pluralize_name
            options[:table_name] = table
            if sorted_list.first == base_model
              field = sorted_list.first
            else
              field = sorted_list.last
              options.merge!(index_name: "#{table}-index")
            end

            options.merge!(key_condition_expression: "##{field}_id = :#{field}_id")
            options.merge!(expression_attribute_names: {"##{field}_id": "#{field}_id"})

            options.merge!(expression_attribute_values: {":#{field}_id" => id})

            klass = Object.const_get(relation_model.capitalize)
            # options.merge!(limit: 1)
            # p options
            query = QueryPager.new(options, klass)
            @collection = HasAndBelongsToManyCollection.new(query, self)
          else
            @collection
          end
        end
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end

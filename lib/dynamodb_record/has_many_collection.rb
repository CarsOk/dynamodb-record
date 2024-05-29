# frozen_string_literal: true

module DynamodbRecord
  # +Dynamodb::ManyToManyCollection+ is a class that represent a ManyToManyCollection
  class HasManyCollection
    include Enumerable

    def initialize(pager, base_object)
      puts "entre al contructor de HasManyCollection"
      @base_object = base_object
      @pager = pager
      @klass = @pager.klass
      @options = @pager.options
      @foreign_key = @options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }
      @items = []
      @pager.items.each do |object|
        @items << @klass.send(:from_database, object)
      end
      
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

    def create!(params = {})
      raise "#{@base_object.class} must be saved" if @base_object.new_record

      params.merge!(@foreign_key)
      object = @klass.send(:from_database, params)
      object.save!
      @items << object
      object
    end


    # def <<(object)
    #   table_name = @options[:table_name]
    #   item = @options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }
    #   item[:"#{@base_model}_id"] = object.id
    #   item[:created_at] = DateTime.now.to_s
    #   key = {table_name:, item:}

    #   res = @items.none? { |data| data.id == object.id }
    #   if res
    #     @klass.client.put_item(key)
    #     @items << object
    #   end
    #   @items
    # end


    def << (object)
      puts "@base_object"
      p @base_object
      puts "@pager"
      p @pager
      puts "@klass"
      p @klass.class
      puts "@options"
      p @options
      puts "@foreign_key"
      p @foreign_key
      puts "@items"
      p @items
      puts "object"
      p object

      puts 'object.new_record'
      p object.new_record

      raise "#{@object.class} must be saved" if @base_object.new_record

      foreign_key = @options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }

      table_name = @options[:table_name]

      item = foreign_key.merge(object.attributes)

      
      key = {table_name:, item:}
      
      res = @items.none? { |data| data.id == object.id }
      
      puts "res #{res}"
      
      puts "key #{key}"
      
      if res
        item[:updated_at] = DateTime.now.to_s
        item[:created_at] = object.created_at.to_s
        puts "antes de guardar objeto"
        @klass.client.put_item(key)
        puts "guarde el objeto"
        @items << object
      end

      puts "res #{res}"
      
      puts "key #{key}"
      @items

      # update = @klass.send(:from_database, item)

      # if object.new_record
        # foreign_key = @options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }
        
        

        

        # current = @klass.send(:from_database, item)

        # p 'objectR'
        # p objectR
        # item[:id] = SecureRandom.uuid
        
        # table_name = @options[:table_name]
  
  
        # key = {table_name:, item:}
  
        # puts "key #{key}"
  
        # @klass.client.put_item(key)
      # else
        # foreign_key = @options[:expression_attribute_values].transform_keys { |k| k.delete_prefix(':').to_sym }
        # table_name = @options[:table_name]
        # key = {table_name:, item:}
      # end

      # p @options[:expression_attribute_values][":car_id"]
      # object.car_id = @options[:expression_attribute_values][:car_id]

    end
  end
end

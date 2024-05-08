module DynamodbRecord
  # +Dynamodb::Pager+ is a abstract class to paginate
  class Pager
    attr_reader :klass

    def initialize(options, klass)
      @options = options
      @klass = klass
    end

    def last_evaluated_key
      raise NotImplementedError, 'Este método debe ser implementado por las subclases'
    end
  end
end

# frozen_string_literal: true

class User
  include DynamodbRecord::Document

  field :balance, :integer, default: 0
end

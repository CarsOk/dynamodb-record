# frozen_string_literal: true

class Person
  include DynamodbRecord::Document

  field :name, :string
  field :activated, :boolean
  field :created_at, :datetime
end

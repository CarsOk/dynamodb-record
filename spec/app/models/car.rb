# frozen_string_literal: true

class Car
  include DynamodbRecord::Document

  field :marca, :string
  has_and_belongs_to_many :users
  has_many :insurances
end

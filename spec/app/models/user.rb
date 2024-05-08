# frozen_string_literal: true

class User
  include DynamodbRecord::Document

  field :balance, :integer, default: 0
  has_and_belongs_to_many :cars
  has_many_through :services, :authorizations
end

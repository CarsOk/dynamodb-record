# frozen_string_literal: true

class Service
  include DynamodbRecord::Document

  field :service_price, :integer, default: 0
  has_many_through :users, :authorizations
end

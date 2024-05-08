# frozen_string_literal: true

class Insurance
  include DynamodbRecord::Document

  field :name, :string
  field :car_id, :string, index: true
  belongs_to :car
end

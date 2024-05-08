# frozen_string_literal: true

class Authorization
  include DynamodbRecord::Document

  field :user_id, :string, hash_key: true
  field :service_id, :string, range_key: true
end

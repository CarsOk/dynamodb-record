# frozen_string_literal: true

module DynamodbRecord
  module Config
    extend self

    attr_accessor :access_key_id, :secret_access_key, :region, :namespace, :endpoint, :read_capacity_units,
                  :write_capacity_units, :compute_checksums

    def set_defaults
      self.region = 'us-east-1'
      self.read_capacity_units = 20
      self.write_capacity_units = 20
      self.namespace = nil
    end
    set_defaults
  end
end

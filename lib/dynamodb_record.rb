# frozen_string_literal: true

require 'securerandom'
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext'

require 'aws-sdk-dynamodb'

require 'dynamodb_record/version'
require 'dynamodb_record/config'
require 'dynamodb_record/collection'
require 'dynamodb_record/fields'
require 'dynamodb_record/persistence'
require 'dynamodb_record/associations'
require 'dynamodb_record/finders'
require 'dynamodb_record/query'
require 'dynamodb_record/document'

module DynamodbRecord
  extend self

  def configure
    block_given? ? yield(DynamodbRecord::Config) : DynamodbRecord::Config
  end
  alias config configure
end

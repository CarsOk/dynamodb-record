# frozen_string_literal: true

require 'bundler/setup'
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
require 'dynamodb_record/pager'
require 'dynamodb_record/query_pager'
require 'dynamodb_record/scan_pager'
require 'dynamodb_record/has_and_belongs_to_many_collection'
require 'dynamodb_record/has_many_through_collection'
require 'dynamodb_record/has_many_collection'

module DynamodbRecord
  extend self

  def configure
    block_given? ? yield(DynamodbRecord::Config) : DynamodbRecord::Config
  end
  alias config configure
end

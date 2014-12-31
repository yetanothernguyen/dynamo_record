require 'securerandom'
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext'

require 'aws-sdk'

require 'dynamo_record/version'
require 'dynamo_record/config'
require 'dynamo_record/collection'
require 'dynamo_record/fields'
require 'dynamo_record/persistence'
require 'dynamo_record/finders'
require 'dynamo_record/query'
require 'dynamo_record/document'

module DynamoRecord
  extend self

  def configure
    block_given? ? yield(DynamoRecord::Config) : DynamoRecord::Config
  end
  alias :config :configure

end


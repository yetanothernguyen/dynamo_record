module DynamoRecord
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def table_name
        name = ActiveSupport::Inflector.tableize(base_class.name)
        @table_name ||= DynamoRecord::Config.namespace ? "#{DynamoRecord::Config.namespace}_#{name}" : name
      end

      def client
        @client ||= Aws::DynamoDB::Client.new(
                      access_key_id: DynamoRecord::Config.access_key_id,
                      secret_access_key: DynamoRecord::Config.secret_access_key,
                      region: DynamoRecord::Config.region,
                      compute_checksums: DynamoRecord::Config.compute_checksums
                    )
      end

      def default_options
        { table_name: self.table_name }
      end

      def describe_table
        self.client.describe_table(default_options)
      end

      def create_table(opts = {})
        table_name = opts[:table_name] || self.table_name
        read_capacity = opts[:read_capacity] || DynamoRecord::Config.read_capacity_units
        write_capacity = opts[:write_capacity] || DynamoRecord::Config.write_capacity_units

        attribute_definitions = []
        key_schema = []

        # Default id hash key
        attribute_definitions << {attribute_name: 'id', 
                                  attribute_type: 'S'}
        key_schema << {attribute_name: 'id',
                        key_type: "HASH"}

        if range_key
          attribute_definitions << {attribute_name: range_key.to_s, 
                                    attribute_type: dynamodb_type(attributes[range_key][:type])}
          key_schema << {attribute_name: range_key.to_s,
                          key_type: "RANGE"}
        end

        # Local secondary indexes
        indexes = []
        attributes.each do |key, value|
          indexes << key if value[:options][:index]
        end

        local_secondary_indexes = []
        indexes.each do |index|
          index_definition = {}
          index_definition[:index_name] = "#{index}-index"
          index_definition[:key_schema] = [{ attribute_name: 'id', key_type: 'HASH' },
                                           { attribute_name: index, key_type: 'RANGE' }]
          index_definition[:projection] = { projection_type: 'ALL'}
          local_secondary_indexes << index_definition
          attribute_definitions << {attribute_name: index.to_s, 
                                    attribute_type: dynamodb_type(attributes[index][:type])}
        end

        options = {
          attribute_definitions: attribute_definitions,
          table_name: table_name,
          key_schema: key_schema,
          provisioned_throughput: {
            read_capacity_units: read_capacity,
            write_capacity_units: write_capacity,
          }
        }

        options.merge!(local_secondary_indexes: local_secondary_indexes) unless local_secondary_indexes.empty?

        response = self.client.create_table(options)
      end

      def create(attrs)
        object = self.new(attrs)
        object.save
        object
      end
    end

    def save
      options = self.class.default_options
      if id.nil?
        self.id = SecureRandom.uuid
      elsif @new_record # New item. Don't overwrite if id exists
        options.merge!(condition_expression: 'id <> :s', expression_attribute_values: { ':s' => self.id })
      end

      options.merge!(item: self.class.unload(attributes))
      response = self.class.client.put_item(options)
      @new_record = false
      true
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      false
    end

    def destroy
      options = self.class.default_options
      key = { 'id' => self.id }
      if range_key = self.class.range_key
        key[range_key] = self.class.dump_field(self.read_attribute(range_key), self.class.attributes[range_key])
      end

      response = self.class.client.delete_item(
        options.merge(key: key )
      )
    end

  end
end
module DynamoRecord
  module Query
    extend ActiveSupport::Concern

    module ClassMethods
      def all(opts = {})
        options = self.default_options
        options.merge!(opts.slice(:limit))

        response = self.client.scan(options)
        DynamoRecord::Collection.new(response, self)
      end

      def where(opts={})
        limit = opts.delete(:limit)
        exclusive_start_key = opts.delete(:exclusive_start_key)

        key_conditions = {}
        opts.each do |key, value|
          key_conditions[key] = { attribute_value_list: [value], 
                                   comparison_operator: 'EQ' } 
        end

        options = self.default_options
        options.merge!(key_conditions: key_conditions)
        options.merge!(limit: limit) if limit
        options.merge!(exclusive_start_key: exclusive_start_key) if exclusive_start_key

        response = self.client.query(options)
        DynamoRecord::Collection.new(response, self)
      end
    end
  end
end
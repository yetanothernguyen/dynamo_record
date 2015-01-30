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

      def where(condition = {})
        attribute = condition.first.first.to_s
        value = condition.first.second
        key_conditions = {}
        key_conditions[attribute] = { attribute_value_list: [value], 
                                           comparison_operator: 'EQ' } 
        
        index_name = "#{attribute}-index"
        options = self.default_options
        options.merge!(key_conditions: key_conditions, index_name: index_name)

        response = self.client.query(options)
        DynamoRecord::Collection.new(response, self)
      end

      def find_by_hash_and_range(hash_key, range_key=nil)
        key_conditions = {}
        key_conditions[self.hash_key] = { attribute_value_list: [hash_key], 
                                           comparison_operator: 'EQ' }
        if range_key
          key_conditions[self.range_key] = { attribute_value_list: [range_key], 
                                              comparison_operator: 'EQ' } 
        end
        
        options = self.default_options
        options.merge!(key_conditions: key_conditions)

        response = self.client.query(options)
        DynamoRecord::Collection.new(response, self)
      end
    end
  end
end
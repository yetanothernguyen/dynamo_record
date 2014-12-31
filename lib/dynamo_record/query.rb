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
    end
  end
end
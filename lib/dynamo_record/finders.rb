module DynamoRecord
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def find(id, range_key=nil)
        key = { 'id' => id }
        if self.range_key
          key[self.range_key] = range_key
        end
        response = client.get_item(
                      table_name: table_name,
                      key: key
                  )
        response.item ? from_database(response.item) : nil
      end
    end
  end
end
module DynamoRecord
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def find(id)
        response = client.get_item(
                      table_name: table_name,
                      key: {
                        id: id
                      }
                  )
        response.item ? from_database(response.item) : nil
      end
    end
  end
end
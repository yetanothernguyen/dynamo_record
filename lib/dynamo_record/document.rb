module DynamoRecord
  module Document
    extend ActiveSupport::Concern
    include DynamoRecord::Fields
    include DynamoRecord::Persistence
    include DynamoRecord::Finders
    include DynamoRecord::Query

    included do
      class_attribute :base_class
      self.base_class = self
    end

    module ClassMethods
      def from_database(attrs)
        self.new(attrs).tap { |r| r.new_record = false}
      end
    end

    attr_accessor :new_record, :attributes

    def initialize(attrs = {})
      @new_record = true
      @attributes = {}

      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end

  end
end
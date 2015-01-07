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
        self.new(attrs, true).tap { |r| r.new_record = false}
      end
    end

    attr_accessor :new_record, :attributes

    def initialize(attrs = {}, ignore_unknown_field = false)
      @new_record = true
      @attributes = {}

      # Set default
      self.class.attributes.each do |key, value|
        send("#{key}=", value[:options][:default]) if value[:options][:default]
      end

      attrs.each do |key, value|
        next if ignore_unknown_field && !respond_to?("#{key}=")
        send("#{key}=", value)
      end
    end

  end
end
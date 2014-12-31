module DynamoRecord
  module Fields
    extend ActiveSupport::Concern

    included do
      class_attribute :attributes

      self.attributes = {}

      field :id # default primary key
    end

    module ClassMethods
      def field(name, type = :string, opts = {})
        named = name.to_s
        self.attributes = attributes.merge(name: {type: type, options: opts})

        define_method("#{named}=") { |value| write_attribute(named, value) }
        define_method("#{name}") { read_attribute(named) }
      end
    end

    def write_attribute(name, value)
      attributes[name.to_sym] = value
    end

    def read_attribute(name)
      attributes[name.to_sym]
    end
  end
end
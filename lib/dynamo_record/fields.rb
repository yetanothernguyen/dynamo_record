module DynamoRecord
  module Fields
    extend ActiveSupport::Concern

    included do
      class_attribute :attributes, instance_writer: false

      self.attributes = {}

      field :id, :string # default primary key
    end

    module ClassMethods
      def field(name, type = :string, opts = {})
        named = name.to_s
        self.attributes.merge!(name => {type: type, options: opts})

        define_method("#{named}=") { |value| write_attribute(named, value) }
        define_method("#{name}") { read_attribute(named) }
        define_method("#{name}?") do
          value = read_attribute(named)
          return value != 'false' if value.is_a?(String)
          !!value
        end
      end

      def undump_field(value, options)
        return nil if options.nil?
        case options[:type]
        when :integer
          value.to_i
        when :string
          value.to_s
        when :float
          value.to_f
        when :boolean
          if value == "true" || value == true
            true
          elsif value == "false" || value == false
            false
          else
            raise ArgumentError, "Boolean column neither true nor false"
          end
        when :datetime
          if value.is_a?(Date) || value.is_a?(DateTime) || value.is_a?(Time)
            value
          else
            DateTime.parse(value)
          end
        else
          raise ArgumentError, "Unknown type #{options[:type]}"
        end
      end

      def dump_field(value, options)
        return value if options.nil?
        case options[:type]
        when :datetime
          value.iso8601
        else
          value # aws-sdk supports the rest of data yptes
        end
      end

      def unload(attrs)
        Hash.new.tap do |hash|
          attrs.each do |key, value|
            hash[key] = dump_field(value, self.attributes[key.to_sym])
          end
        end
      end
    end

    def write_attribute(name, value)
      attributes[name.to_sym] = self.class.undump_field(value, self.class.attributes[name.to_sym])
    end

    def read_attribute(name)
      attributes[name.to_sym]
    end
  end
end
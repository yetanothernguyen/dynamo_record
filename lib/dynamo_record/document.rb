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
        send("#{key}=", undump_field(value, self.class.attributes[key.to_sym]))
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
  end
end
class Address
  include DynamoRecord::Document

  field :city, :string, index: true
end
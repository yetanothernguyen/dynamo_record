class PersonRange
  include DynamoRecord::Document

  field :name, :string
  field :activated, :boolean
  field :created_at, :datetime, range_key: true
end
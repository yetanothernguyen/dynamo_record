class Person
  include DynamoRecord::Document

  field :name, :string
  field :activated, :boolean
  field :created_at, :datetime
end
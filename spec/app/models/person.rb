class Person
  include DynamoRecord::Document

  field :name, :string
  field :activated, :boolean
end
class Person
  include DynamoRecord::Document

  field :name, :string
end
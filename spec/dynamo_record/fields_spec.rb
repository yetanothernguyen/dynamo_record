require 'spec_helper'

RSpec.describe DynamoRecord::Fields do

  it 'has default id primary key field' do
    person = Person.new
    expect(person.id).to be_nil
  end

  it 'accepts adding fields' do
    class Employee
      include DynamoRecord::Document

      field :first_name, :string
      field :last_name, :string
    end
    expect(Employee.attributes).to eq({id: {type: :string, options: {}},
                                     first_name: {type: :string, options: {}},
                                     last_name: {type: :string, options: {}}})
  end

  it 'accepts adding fields with index' do
    class City
      include DynamoRecord::Document

      field :name, :string, index: true
    end

    expect(City.attributes).to eq({id: {type: :string, options: {}},
                                   name: {type: :string, options: {index: true}}})
  end

  it 'initializes with field values' do
    person = Person.new(name: 'A person')
    expect(person.name).to eq('A person')
  end

end
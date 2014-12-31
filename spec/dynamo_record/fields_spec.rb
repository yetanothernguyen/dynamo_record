require 'spec_helper'

RSpec.describe DynamoRecord::Fields do

  it 'has default id primary key field' do
    person = Person.new
    expect(person.id).to be_nil
  end

  it 'accepts adding fields' do
    expect(Person.attributes).to eq({name: {type: :string, options: {}}})
  end

  it 'accepts adding fields with index' do
    class City
      include DynamoRecord::Document

      field :name, :string, index: true
    end

    expect(City.attributes).to eq({name: {type: :string, options: {index: true}}})
  end

  it 'initializes with field values' do
    person = Person.new(name: 'A person')
    expect(person.name).to eq('A person')
  end

end
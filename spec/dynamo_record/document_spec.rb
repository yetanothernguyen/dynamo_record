require 'spec_helper'

RSpec.describe DynamoRecord::Document do

  it 'initializes a new document' do
    class Person
      include DynamoRecord::Document
    end
    person = Person.new
    expect(person.new_record).to be_truthy
    expect(person.attributes).to be_empty
  end

  it 'initializes from database', :vcr do
    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    expect(person.new_record).to be_falsy
  end

  it 'raises error on unknown field' do
    expect{Person.new({unknown_field: 'unknown'})}.to raise_error
  end

  it 'can ignore unknown field' do
    expect{Person.new({unknown_field: 'unknown'}, true)}.to_not raise_error
  end

end
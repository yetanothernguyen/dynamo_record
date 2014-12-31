require 'spec_helper'

RSpec.describe DynamoRecord::Persistence, :vcr do
  
  it 'has table name' do
    expect(Person.table_name).to eq('people')
  end

  describe 'namespace' do
    before do
      DynamoRecord.configure do |config|
        config.namespace = 'namespace'
      end
    end

    after do
      DynamoRecord::Config.set_defaults
    end

    it 'has table name with namespace' do
      expect(Address.table_name).to eq('namespace_addresses')
    end
  end

  describe '#create_table' do
    context 'with index' do
      it 'creates table' do        
        class IndexCity
          include DynamoRecord::Document

          field :name, :string, index: true
        end

        IndexCity.create_table
      end
    end

    context 'without index' do
      it 'creates table' do
        class NoIndexCity
          include DynamoRecord::Document

          field :name, :string
        end

        NoIndexCity.create_table
      end
    end
  end

  it 'saves record' do
    expect(SecureRandom).to receive(:uuid).and_return('a uuid')
    client = spy('client')
    allow(Person).to receive(:client).and_return(client)

    person = Person.new(name: 'A person')
    person.save

    expect(client).to have_received(:put_item).
                        with({table_name: 'people', 
                              item: {id: 'a uuid', 
                                   name: 'A person'}})
    expect(person.new_record).to be_falsy
    expect(person.id).to eq('a uuid')
  end

  it 'does not overwrite existing record' do
    person = Person.new(id: 'f9b351b0-d06d-4fff-b8d4-8af162e2b8ba', name: 'New item')
    expect(person.save).to be_falsy

    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    expect(person.name).to_not eq('New item')
  end

  it 'updates record' do
    DynamoRecord.configure do |config|
      config.access_key_id = 'key'
      config.secret_access_key = 'TfWvbWtJ96DPM+QduJDXVkGKGbwhIyAYpPSnXad1'
    end

    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    person.name = 'New name'
    person.save

    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    expect(person.name).to eq('New name')
  end

end
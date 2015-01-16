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
    expect(SecureRandom).to receive(:uuid).and_return('de7551fa-17df-49d8-9dc0-c0266aeeab49')
    person = Person.new(name: 'A person')
    person.save
    expect(person.new_record).to be_falsy
    expect(person.id).to eq('de7551fa-17df-49d8-9dc0-c0266aeeab49')
  end

  it 'creates record' do
    expect(SecureRandom).to receive(:uuid).and_return('5831f7ba-3c5a-4bad-9a83-47712fe877e4')
    person = Person.create(name: 'A person')
    expect(person.new_record).to be_falsy
    expect(person.id).to eq('5831f7ba-3c5a-4bad-9a83-47712fe877e4')
  end

  it 'does not overwrite existing record' do
    person = Person.new(id: 'f9b351b0-d06d-4fff-b8d4-8af162e2b8ba', name: 'New item')
    expect(person.save).to be_falsy

    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    expect(person.name).to_not eq('New item')
  end

  it 'updates record' do
    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    person.name = 'New name'
    person.save

    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    expect(person.name).to eq('New name')
  end

  it 'destroys record' do
    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    person.destroy
    person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
    expect(person).to be_nil
  end

end
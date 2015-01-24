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

    context 'with default hash key' do
      it 'creates table' do
        class Thread
          include DynamoRecord::Document

          field :subject, :string
        end

        Thread.create_table
        key_schema = Thread.describe_table.table.key_schema.first
        expect(key_schema.attribute_name).to eq('id')
        expect(key_schema.key_type).to eq('HASH')
      end
    end

    context 'with range key' do
      it 'creates table' do
        class ThreadRange
          include DynamoRecord::Document

          field :subject, :string, range_key: true
        end

        ThreadRange.create_table
        key_schema = ThreadRange.describe_table.table.key_schema
        expect(key_schema.first.attribute_name).to eq('id')
        expect(key_schema.first.key_type).to eq('HASH')
        expect(key_schema.second.attribute_name).to eq('subject')
        expect(key_schema.second.key_type).to eq('RANGE')
      end
    end

    context 'with index' do
      it 'creates table' do        
        class ThreadIndex
          include DynamoRecord::Document

          field :subject, :string, range_key: true
          field :created_at, :datetime, index: true
        end

        ThreadIndex.create_table
        index = ThreadIndex.describe_table.table.local_secondary_indexes.first
        expect(index.index_name).to eq('created_at-index')
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

  describe '#destroy' do
    context 'when no range key' do
      it 'destroys record' do
        person = Person.find('278aaf78-2f71-467b-a711-658c3bd8cad2')
        person.destroy
        person = Person.find('278aaf78-2f71-467b-a711-658c3bd8cad2')
        expect(person).to be_nil
      end
    end

    context 'when there is range key' do
      it 'destroys record' do
        person = PersonRange.find('369a0862-5dee-441a-b438-1fb17af2d484', '2015-01-24T22:15:42+08:00')
        person.destroy
        person = PersonRange.find('369a0862-5dee-441a-b438-1fb17af2d484', '2015-01-24T22:15:42+08:00')
        expect(person).to be_nil
      end
    end
  end
  

end
require 'spec_helper'

RSpec.describe DynamoRecord::Query, :vcr do

  describe '#all' do
    it 'find all records' do
      people = Person.all
      expect(people.count).to eq(3)
      expect(people.map(&:name)).to eq(['Person 1', 'Person 2', 'Person 3'])
    end

    it 'find all records with limit' do
      people = Person.all(limit: 1)
      expect(people.count).to eq(1)
      expect(people.map(&:name)).to eq(['Person 1'])
    end

    describe 'pagination' do
      it 'tells if there is a next page' do
        people = Person.all(limit: 1)
        expect(people.next_page?).to be_truthy
      end

      it 'navigates to next page' do
        people = Person.all(limit: 1)
        next_page = people.next_page
        expect(next_page.count).to eq(1)
        expect(next_page.map(&:name)).to eq(['Person 2'])
      end

      it 'enumerates all pages' do
        records = []
        Person.all(limit: 1).each_page do |page|
          records << page
        end

        expect(records.first.map(&:name)).to eq(['Person 1'])
        expect(records.second.map(&:name)).to eq(['Person 2'])
        expect(records.third.map(&:name)).to eq(['Person 3'])
      end
    end
  end

  describe 'querying' do

    describe '#find_by_hash_and_range' do
      it 'returns a record by hash key and range key' do
        person = PersonRange.find_by_hash_and_range('1', '2015-01-28T14:37:01+08:00')
        expect(person.count).to eq(1)
      end

      it 'returns all records by hash key' do
        people = PersonRange.find_by_hash_and_range('1')
        expect(people.count).to eq(2)
      end
    end

    describe '#where' do
      it 'queries by condition' do
        people = Person.where(name: 'Person 2')
        expect(people.map(&:name)).to eq(['Person 2'])
      end
    end
  end
end
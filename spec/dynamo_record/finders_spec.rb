require 'spec_helper'

RSpec.describe DynamoRecord::Fields, :vcr do

  describe '#find' do
    it 'finds record' do
      person = Person.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
      expect(person.id).to eq('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
      expect(person.name).to eq('A person')
    end

    context 'when record doesn\'t exists' do
      it 'returns empty object' do
        person = Person.find('not here')
        expect(person).to be_nil
      end
    end
  end

end
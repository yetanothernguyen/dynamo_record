require 'spec_helper'

RSpec.describe DynamoRecord::Collection do

  let(:pager) { spy('pager', :items => items, :'next_page?' => false, :'last_page?' => true) }
  let(:items) {
    [
      { id: 'id1', name: 'Person 1' },
      { id: 'id2', name: 'Person 2' }
    ]
  }

  it 'initializes properly' do
    collection = DynamoRecord::Collection.new(pager, Person)
    expect(collection.count).to eq(2)
    expect(collection.map(&:name)).to eq(['Person 1','Person 2'])
    expect(collection.next_page?).to be_falsy
    expect(collection.last_page?).to be_truthy
  end

end
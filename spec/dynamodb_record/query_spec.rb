require 'spec_helper'

RSpec.describe DynamodbRecord::Query, :vcr do
  describe 'querying' do
    describe '#where' do
      it 'returns records where user balance = 0' do
        result = User.where(balance: 0, limit: 1)
        expect(result.count).to eq(1)
      end

      it 'returns records by limit' do
        result = User.where(balance: 0, limit: 1)
        expect(result.count).to eq(1)
        expect(result.last_evaluated_key).to eq('eyJpZCI6ImhndXptYW4yMEBnbWFpbC5jb20ifQ==')
      end
    end
  end
end
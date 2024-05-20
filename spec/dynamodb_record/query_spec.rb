# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe DynamodbRecord::Query, :vcr do
  describe '#all' do
    it 'find all records' do
      user = User.all
      expect(user.count).to eq(2)
      expect(user.map(&:id)).to eq(['hguzman20@gmail.com', 'hguzman30@gmail.com'])
    end
  end
  describe 'querying' do
    describe '#where' do
      it 'returns records where user balance = 0' do
        result = User.where(balance: 0, limit: 1)
        expect(result.count).to eq(1)
      end

      it 'returns records by limit' do
        result = User.where(balance: 0, limit: 1)
        expect(result.count).to eq(1)
        expect(result.last_evaluated_key).to eq({'id' => 'hguzman20@gmail.com'})
      end
    end
  end
end

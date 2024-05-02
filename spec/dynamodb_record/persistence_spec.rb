require 'spec_helper'

RSpec.describe DynamodbRecord::Persistence, :vcr do

  it 'saves record' do
    user = User.new(id: 'hguzman10@gmail.com')
    user.save
    expect(user.new_record).to be_falsy
    expect(user.id).to eq('hguzman10@gmail.com')
  end

  it 'does not overwrite existing record' do
    user = User.new(id: 'hguzman10@gmail.com', balance: 100)
    expect(user.save).to be_falsy

    user = User.find('hguzman10@gmail.com')
    expect(user.balance).to_not eq(100)
  end

  it 'updates record' do
    user = User.find('hguzman10@gmail.com')
    user.balance = 60
    user.save
    user = User.find('hguzman10@gmail.com')
    expect(user.balance).to eq(60)
  end

  describe '#destroy' do
    context 'when no range key' do
      it 'destroys record' do
        user = User.find('hguzman10@gmail.com')
        user.destroy
        user = User.find('hguzman10@gmail.com')
        expect(user).to be_nil
      end
    end

    context 'when there is range key' do
      it 'destroys record' do
        authorization = Authorization.find!('hguzman10@gmail.com', '1')
        authorization.destroy
        authorization = Authorization.find('hguzman10@gmail.com', '1')
        expect(authorization).to be_nil
      end
    end
  end
end
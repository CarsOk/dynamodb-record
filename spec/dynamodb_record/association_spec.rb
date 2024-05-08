# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe DynamodbRecord::Associations, :vcr do
  it 'has_and_belongs_to_many' do
    car = Car.find!('UVX455')
    users = car.users
    expect(users.count).to eq(1)
  end

  it 'has_many_through' do
    service = Service.find('c1')
    users = service.users
    expect(users).to be_an(DynamodbRecord::HasManyThroughCollection)
  end

  it 'has_and_belongs_to_many create' do
    car = Car.find!('UVX455')
    user = car.users.create!(id: 'hguzman50@gmail.com')
    expect(user).to be_an(User)
  end

  describe '#has_many' do
    it 'get collection' do
      car = Car.find!('UVX455')
      insurances = car.insurances
      expect(insurances).to be_an(DynamodbRecord::HasManyCollection)
    end

    it 'create item' do
      car = Car.find!('UVX455')
      insurance = car.insurances.create!(name: 'fasecolda')
      expect(insurance).to be_an(Insurance)
    end
  end

  describe '#belongs_to' do
    it 'get object' do
      insurance = Insurance.find!('12345')
      expect(insurance.car).to be_an(Car)
    end
  end
end

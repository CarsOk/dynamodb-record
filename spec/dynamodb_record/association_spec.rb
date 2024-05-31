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

  describe '#has_and_belongs_to_many' do
    it 'only one record' do
      car = Car.find!('UVX455')
      user = User.find!('hguzman10@gmail.com')
      expect(user.cars.count).to eq(0)
      user.cars << car
      expect(user.cars.count).to eq(1)
      user.cars << car
      expect(user.cars.count).to eq(1)
    end

    it 'create' do
      car = Car.find!('UVX455')
      user = car.users.create!(id: 'hguzman50@gmail.com')
      expect(user).to be_an(User)
    end

    it 'destroy' do
      car = Car.find!('UVX455')
      user = User.find('hguzman50@gmail.com')
      car.users.destroy(user)
      expect(car.users.count).to eq(2)
    end
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

    it 'create item with <<' do
      car = Car.find!('UVX455')
      insurance = Insurance.new(id: '1', name: 'Seguros ABC')
      car_insurances = car.insurances << insurance
      expect(car_insurances.any? { |item| item.id == insurance.id }).to eq(true)
    end
  end

  describe '#belongs_to' do
    it 'get object' do
      insurance = Insurance.find!('12345')
      expect(insurance.car).to be_an(Car)
    end
  end
end

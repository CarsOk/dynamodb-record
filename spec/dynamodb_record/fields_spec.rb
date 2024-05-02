# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DynamodbRecord::Fields do
  it 'has default id primary key field' do
    user = User.new
    expect(user.id).to be_nil
  end

  it 'accepts adding fields' do
    class Employee
      include DynamodbRecord::Document

      field :first_name, :string
      field :last_name, :string
    end
    expect(Employee.attributes).to eq({ id: { type: :string, options: {} },
                                        first_name: { type: :string, options: {} },
                                        last_name: { type: :string, options: {} },
                                        created_at: { type: :datetime, options: {} },
                                        updated_at: { type: :datetime, options: {} }
                                      })
  end


  it 'accepts default value' do
    class City
      include DynamodbRecord::Document

      field :population, :integer, default: 0
    end

    expect(City.new.population).to eq(0)
  end

  it 'coearce field to its data type when intializing' do
    class Record
      include DynamodbRecord::Document

      field :integer_field, :integer
      field :big_decimal_field, :big_decimal
      field :datetime_field, :datetime
      field :boolean_field, :boolean
      field :array_field, :array
    end

    expect(Record.new(integer_field: '1').integer_field).to be_a(Integer)
    expect(Record.new(big_decimal_field: '1').big_decimal_field).to be_a(BigDecimal)
    expect(Record.new(datetime_field: '2014-12-25T04:08:25Z').datetime_field).to eq(DateTime.parse('2014-12-25T04:08:25Z'))
    expect(Record.new(boolean_field: 'true').boolean_field).to be_truthy
    expect(Record.new(array_field: %w[admin assistant]).array_field).to be_truthy
  end

  it 'coearce field to its data type when calling writer' do
    person = Person.new
    person.created_at = '2015-01-23T04:27:21Z'
    expect(person.created_at).to eq(DateTime.parse('2015-01-23T04:27:21Z'))
  end

  describe 'predicate method' do
    specify { expect(Person.new(activated: false).activated?).to be_falsy }
    specify { expect(Person.new(activated: true).activated?).to be_truthy }
    specify { expect(Person.new(activated: 'true').activated?).to be_truthy }
    specify { expect(Person.new(activated: 'false').activated?).to be_falsy }
  end

  describe '#unload' do
    it 'unloads DateTime into String' do
      now = DateTime.now
      attrs = Person.unload({ created_at: now })
      expect(attrs[:created_at]).to eq(now.iso8601)
    end
  end

  describe '#attributes=' do
    it 'set attributes from hash' do
      person = Person.new(name: 'A Person', activated: true)
      person.attributes = { name: 'Updated Person', activated: false }
      expect(person.name).to eq('Updated Person')
      expect(person.activated).to eq(false)
    end
  end

  describe 'keys' do
    it 'returns table\'s range key' do
      class ThreadKey
        include DynamodbRecord::Document

        field :subject, :string, range_key: true
      end

      expect(ThreadKey.range_key).to eq(:subject)
    end
  end

  describe 'index' do
    it 'returns table\'s secondary index' do
      class ThreadKey
        include DynamodbRecord::Document

        field :name, :string, hash_key: true
        field :subject, :string, index: true
      end

      expect(ThreadKey.secondary_indexes).to eq([:subject])
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DynamodbRecord::Document do
  it 'initializes a new document' do
    class Person
      include DynamodbRecord::Document
    end
    person = Person.new
    expect(person.new_record).to be_truthy
    expect(person.attributes).to be_empty
  end

  it 'initializes from database', :vcr do
    user = User.find('hguzman20@gmail.com')
    expect(user.new_record).to be_falsy
  end

  it 'raises error on unknown field' do
    expect { User.new({unknown_field: 'unknown'}) }.to raise_error(NoMethodError)
  end

  it 'can ignore unknown field' do
    expect { User.new({unknown_field: 'unknown'}, true) }.to_not raise_error(NoMethodError)
  end
end

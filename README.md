# DynamoRecord

A simple DynamoDB ORM container on aws-sdk v3 forked from https://github.com/yetanothernguyen/dynamo_record

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dynamo_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamo_record

## Usage

### Models

To create a model with DynamoRecord, simply include the DynamoRecord::Document mixin in your class as such::

```ruby
class User
  include DynamoRecord::Document
end
```

### Fields
Declaring a field is done by using the `field` method. For example, the following defines a User model with a first and last name:

```ruby
class User
  include DynamoRecord::Document

  field :first_name, :string
  field :last_name, :string
end
```

`field` accepts the following options:
- :default to specify a default value
- :hash_key to specify a DynamoDB hash key
- :range_key to specify a DynamoDB range key
- :index to specify an index

### Persistence
DynamoRecord provides a similar persistence interface compared to other ORMs.

```ruby
user = User.new(first_name: 'John', last_name: 'Doe')
user.save

user = User.create(first_name: 'John', last_name: 'Doe')

user.destroy
```

### Querying

```ruby
users = User.all

users = User.where(first_name: 'John')

users = User.where(first_name: 'John', limit: 5)

user = User.find('f9b351b0-d06d-4fff-b8d4-8af162e2b8ba')
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/dynamo_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

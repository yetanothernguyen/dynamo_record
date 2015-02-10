# DynamoRecord

A simple DynamoDB ORM wrapper on top of aws-sdk v2

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

### Persistence
DynamoRecord provides a similar persistence interface compared to other ORMs.

```ruby
user = User.new(first_name: 'John', last_name: 'Doe')
user.save

user = User.create(first_name: 'John', last_name: 'Doe')

user.destroy
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dynamo_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

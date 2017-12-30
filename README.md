# **Lieutenant**

## **CQRS/ES Toolkit to command them all**

[![Gem Version](https://badge.fury.io/rb/lieutenant.svg)](https://badge.fury.io/rb/lieutenant)
[![Build Status](https://travis-ci.org/gabteles/lieutenant.svg?branch=master)](https://travis-ci.org/gabteles/lieutenant)
[![Coverage Status](https://coveralls.io/repos/github/gabteles/lieutenant/badge.svg?branch=master)](https://coveralls.io/github/gabteles/lieutenant?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/c96a6dd822547e657829/maintainability)](https://codeclimate.com/github/gabteles/lieutenant/maintainability)


Lieutenant is a toolkit that implements various of the components of Command & Query Responsability Segregation (CQRS) and Event Sourcing (ES). It means that your application can get rid of the "current" state of the entities you choose and store all the *changes* that led them to it.

This gem aims to be most independent as possible of your tecnological choices: it should work with Rails, Sinatra, pure Rack apps or whatever you want.

Not limited to the framework, you can also pick one of the event bus and/or event store that meets your needs, In Memory implementation of event bus, for example, can be the first step to start moving from the big monolith into some kind of distributed behaviour, until you get confident to replace it by some AWS SQS or Kafka implementation of the event bus.

If you are not familiarized, you may check this references:

- [CQRS Journey](https://msdn.microsoft.com/en-us/library/jj554200.aspx)
- [crqs.nu](http://cqrs.nu/)
- [Event Sourcing, by Martin Fowler](https://martinfowler.com/eaaDev/EventSourcing.html)
- [CQRS Documents, by Greg Young](https://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf)
- [Choosing an architecture, from TrustBK](https://blog.trustbk.com/choosing-an-architecture-85750e1e5a03)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lieutenant'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lieutenant

## Usage

By now, Lieutenant offer the components listed below. With each one, there's a description and example usage. If you cannot understand it, feel free to open an issue. Or if you think that it's not sufficient to other people, pull requests are welcome!

- [Commands](#commands)
- [Command Sender](#command-sender)
- [Command Handlers](#command-handlers)
- [Aggregate Repositories](#aggregate-repositories)
- [Aggregates](#aggregates)
- [Events](#events)
- [Event Store](#event-store)
- [Event Bus](#event-bus)
- [Configuration](#configuration)

### Commands

Commands are the representation of the system actions. They describe a **intention** to do something (e.g. `ScheduleMeeting`, `DisableProduct`).

This classes do not need any special methods, just define attributes and validations.

To use define them, just include `Lieutenant::Command` module. It'll allow you to use [ActiveModel Validations](http://guides.rubyonrails.org/active_record_validations.html).

```ruby
class ScheduleMeeting
    include Lieutenant::Command

    attr_accessor :description
    attr_accessor :location
    attr_accessor :date_start
    attr_accessor :date_end

    validates :description, presence: true, length: { minimum: 3 }
    validates :location, presence: true, length: { minimum: 5 }
    validates :date_start, presence: true
    validates :date_end, presence: true

    validate do
        date_start.is_a?(Time) && date_end.is_a?(Time) && date_start < date_end
    end
end
```

To instantiate commands you can use `.new` or helper method `.with`, that receives the parameters as a Hash:

```ruby
ScheduleMeeting.with(
    description: 'Annual planning',
    location: 'Meeting room 2C',
    date_start: Time.mktime(2017, 12, 15, 14, 0, 0),
    date_end: Time.mktime(2017, 12, 15, 18, 0, 0)
)
```

### Command Sender

Command sender is the component that receives commands and forward them to the right handlers. It also instantiate the aggregate repository's unit of work, in order to help persistence to save only the generated events in each command handling.

You can access the command sender throught Lieutenant's config:

```ruby
Lieutenant.config.command_sender
```

It dependes on all the configuration components, so be sure to config them before calling it. See [Configuration](#configuration).

Once with the Command Sender, dispatch events by using `#dispatch` (aliased as `#call`):

```ruby
Lieutenant.config.command_sender.dispatch(command)
```


### Command Handlers

Command Handlers are orchestrators to your business logic. They will receive a command and a aggregate repository then will call the needed operations, they can load a aggregate by the identifier or add a new one to the repository.

Handlers are simply objects that respond to `#call`. You can define them as [Proc's](https://ruby-doc.org/core-2.5.0/Proc.html), for example.

Lieutenant also defines a syntax sugar to help definition of them:

```ruby
module ScheduleHandler
    include Lieutenant::CommandHandler

    on(ScheduleMeeting) do |repository, command|
        # ...
    end
end
```

You can also register them directly on command sender:

```ruby
Lieutenant.config.command_sender.register(ScheduleMeeting) do |repository, command|
    # ...
end
```


### Aggregate Repositories

TODO


### Aggregates

TODO


### Events

TODO


### Event Store

TODO


### Event Bus

TODO


### Configuration

TODO


## Roadmap

In order to give some directions to the development of this gem, the roadmap below presents in a large picture of the plans to the future (more or less ordered).

- Projections
- Better documentation
- Command filters
- Command retry policies
- Sagas
- More implementations of event store
- More implementations of event bus

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

You can also use `bundle exec rake lint` to be sure that your code follows our policies. We currently use [rubocop](https://github.com/bbatsov/rubocop) and [reek](https://github.com/troessner/reek).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabteles/lieutenant.

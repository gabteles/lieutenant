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
- [Aggregate Repository](#aggregate-repository)
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

    attr_accessor :meeting_room_uuid
    attr_accessor :description
    attr_accessor :date_start
    attr_accessor :date_end

    validates :meeting_room_uuid, presence: true
    validates :description, presence: true, length: { minimum: 3 }
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
    meeting_room_uuid: '4bb0a8a0-9234-477d-8df4-5f10a2fb1faa',
    description: 'Annual planning',
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

It's important that command handlers do not have side-effects, since the commands **can** be retried (and eventually they will). If you, for example, send an email inside your handler, it may be sent twice in case of command retry.

### Aggregate Repository

The aggregate repository is responsible to control the changes in the application state. It means that it will collect events from created or modified aggregates.

It also implements the [Unit of Work Pattern](https://martinfowler.com/eaaCatalog/unitOfWork.html) for each dispatched command, meaning that it will know what new events where created when processing the command.

You'll interact only with the Repository Unit of Work, that is the `repository` parameter that command handlers receive. It allows you to:

#### Add an aggregate:
```ruby
aggregate = MeetingRoom.new
repository.add_aggregate(aggregate)
```

#### Load an aggregate:
```ruby
meeting_room = repository.load(MeetingRoom, command.meeting_room_uuid)
```


### Aggregates

Aggregates contain your business logic, rules between multiple entities are kept by them. Aggregates are all about the transaction consistency.

To define them, include `Lieutenant::Aggregate` into your class. When defining it's initializer, you'll need to also setup the instance, calling `#setup(id)`, where `id` is the identifier of the aggregates' instance (`SecureRandom.uuid` is encouraged).

```ruby
class MeetingRoom
    include Lieutenant::Aggregate

    def initialize(name)
        setup(SecureRandom.uuid)
    end
end
```

Aggregates' state should only be modified by events, that can be applied using `#apply`, that will instantiate the event with provided params and fire them to aggregate's internal handlers (registered with `.on`):

```ruby
class MeetingRoom
    include Lieutenant::Aggregate

    def initialize(name)
        setup(SecureRandom.uuid)
        apply(MeetingRoomCreated, name: name)
    end

    on(MeetingRoomCreated) do |event|
        @name = event.name
    end
end
```

To allow command handlers to modify aggregates, you can define handlers that also handles your business logic or throw errors:

```ruby
class MeetingRoom
    include Lieutenant::Aggregate

    def initialize(name)
        setup(SecureRandom.uuid)
        apply(MeetingRoomCreated, name: name)
    end

    def schedule_meeting(description, date_start, date_end)
        # Check if meeting room is available to needed dates

        raise(MeetingRoomNotAvailable) unless room_available

        apply(
            MeetingScheduled,
            description: description,
            date_start: date_start,
            date_end: date_end
        )
    end

    on(MeetingRoomCreated) do |event|
        @name = event.name
        @meetings = []
    end

    on(MeetingScheduled) do |event|
        # Note that we could push a PORO instead of a Hash
        # (and it wouldn't be a Lieutenant::Aggregate)
        @meetings.push({
            description: event.description,
            date_start: event.date_start,
            date_end: event.date_end
        })
    end
end
```

For the same reason of the command handlers, aggregates should not have side-effects inside them.

### Events

Events register what happened with aggregates since they were created. They have same features as `Commands`: you can use ActiveModel Validations and instantiate them using `#with` method.

Events exposes `aggregate_id` and `sequence_number`, that are used to know to which aggregate each event belongs to and it's order into the event stream. You should not worry about them, we use them internally ;)

```ruby
class MeetingScheduled
    include Lieutenant::Event

    attr_accessor :description
    attr_accessor :date_start
    attr_accessor :date_end
    # Implicity defined:
    # attr_accessor :aggregate_id (Meeting room's UUID)
    # attr_accessor :sequence_number
end
```

### Event Store

Event stores handles pushing and pulling events to/from the persistence. They are used by the Aggregate Repository to commit changes collected by one unit of work.

You need to set what implementation will be used, them Lieutenant will do the magic. Please refer to [Configuration](#configuration).


### Event Bus

The event bus publishes and receives messages from the aggregates updates. As event stores, you should only worry about setting the needed implementation.

You can also listen to it's events by subscribing to them:

```ruby
Lieutenant.config.event_bus.subscribe(MeetingScheduled) do |event|
  puts "Meeting scheduled on room #{event.aggregate_id}, starts at #{event.date_start.iso8601}, ends at #{event.date_end.iso8601}"
end
```


### Configuration

Lieutenant's configuration can be modified by using an structured or block way. By default, it uses InMemory implementations.

```ruby
Lieutenant.config do |configuration|
    configuration.event_bus(Lieutenant::EventBus::InMemory)
    configuration.event_store(Lieutenant::EventStore::InMemory)
end

# OR

Lieutenant.config.event_bus(Lieutenant::EventBus::InMemory)
Lieutenant.config.event_store(Lieutenant::EventStore::InMemory)
```

You can also access configuration the same way:

```ruby
Lieutenant.config do |configuration|
    configuration.event_bus # => Lieutenant::EventBus::InMemory
    configuration.event_store # => Lieutenant::EventStore::InMemory
    configuration.aggregate_repository # => Lieutentant::AggregateRepository
    configuration.command_sender # => Lieutenant::CommandSender
end

# OR

Lieutenant.config.event_bus # => Lieutenant::EventBus::InMemory
Lieutenant.config.event_store # => Lieutenant::EventStore::InMemory
Lieutenant.config.aggregate_repository # => Lieutentant::AggregateRepository
Lieutenant.config.command_sender # => Lieutenant::CommandSender
```

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

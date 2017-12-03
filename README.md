# **Lieutenant**

## **CQRS/ES Toolkit to command them all**

Lieutenant is a toolkit that implements various of the components of Command & Query Responsability Segregation (CQRS) and Event Sourcing (ES). It means that your application can get rid of the "current" state of the entities you choose and store all the *changes* that led them to it.

This gem aims to be most independent as possible of your tecnological choices, it means that it should work with Rails, Sinatra, pure Rack apps or whatever you want.

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

### Commands

TODO


### Command Sender

TODO


### Command Handlers

TODO


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

# Lightsaber

Welcome! Lightsaber is a small utility used to interact with Tor Trac installation.
You can easily customise it to interact with any Trac installation, although you
might have to change some of the HTML parsing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lightsaber'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lightsaber

## Usage

TODO: Write usage instructions here

You can use lightsaber as an installed gem or by its own directory by prepending:

    $ bundle exec bin/lightsaber

To get help:

    $ lightsaber help

Or to get help on a specific command:

    $ lightsaber ops help

    lightsaber operations create_ticket                               
    lightsaber operations create_ticket                               
    lightsaber operations filter_tickets --filter <filter> [OPTIONS]  
    lightsaber operations get_ticket --ticket <ticket number>         
    lightsaber operations help [COMMAND]                              


Or for a sub command:

    $ lightsaber ops help filter_tickets

To retrieve a ticket:

    $ lightsaber ops get_ticket --ticket 12412

To start using Lightsaber you need a file called `.cli.yml` under `config/`.
This file will contain username and password for Trac installation:

```
USERNAME: "username"
PASSWORD: "password"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lightsaber. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

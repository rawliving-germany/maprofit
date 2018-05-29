# Maprofit

Maprofit is a web-application written in Ruby, using the Roda framework and other fun Ruby gems to analyze profitability of orders done in your Magento2 online-shop.

It is more of a WIP and hack than anything close to production ready and likely has to be adapted to each installation of Magento2 individually.

It is released under the GPLv3 or any later version, Copyright 2018 Felix Wolfsteller.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'maprofit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maprofit

## Usage

Development: `rerun bundle exec rackup`.

## Configuration

Various spooky configurations can and have to be done in the configuration file `maprofit.yaml` .

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Typically you will start with a `bundle` or `bundle install`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Disclaimer

Thanks for the roda_bulma example (which I should link from here) which gave me a 10-minutes headstart.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rawliving-germany/maprofit.

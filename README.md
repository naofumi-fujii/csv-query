# Csv::Query

manage csv with ActiveRecord, Sqlite3(InMemory) via cli, terminal

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'csv-query'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csv-query

## Usage

    $ bundle exec csv-query --file ~/Downloads/your_file.csv
### --sql
    $ bundle exec csv-query --file ~/Downloads/your_file.csv --sql "select * from records limit 10;"
### --json
    $ bundle exec csv-query --file ~/Downloads/your_file.csv --json

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/csv-query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Csv::Query project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/csv-query/blob/master/CODE_OF_CONDUCT.md).


## Alternative/related projects
* [csvq.py - Python variant that does almost the same thing](http://www.gl1tch.com/~lukewarm/software/csvq/)
* [CSVql - A query language for CSV files](https://github.com/ondrasej/CSVql)
* koppen/csv_query: Command line tool to query CSV data using SQL https://github.com/koppen/csv_query

require "csv/query/version"
require 'csv'
require 'sqlite3'
require 'active_record'
require 'optparse'
require 'pp'
require 'charlock_holmes/string'
require 'terminal-table'

# usage: $ bundle exec csv-query --file ~/Downloads/head10.csv --query 'InMemoryAR::Record.all'
module Csv
  module Query
    # Your code goes here...
    def self.run!
      file_path, query =
        ARGV.getopts(nil, 'file:', 'query:').values

      InMemoryAR.new(file_path).run! {
        # InMemoryAR::Record.all
        eval(query)
      }
    end

    class InMemoryAR
      # temporary AR obj
      class Record < ActiveRecord::Base
      end

      # `LP(iphone)`みたいに
      # 半角カッコ内にアルファベットだと
      # Rubyのsyntax的にsetterと勘違いされるので対策
      def header_converter
        lambda do |h|
          h.gsub('(','（').gsub(')', '）')
        end
      end

      def csv
        contents = File.read(file_path)
        detection = contents.detect_encoding
        case detection[:encoding]
        when "Shift_JIS"
          CSV.read(file_path, encoding: "SJIS:UTF-8", headers: true, header_converters: header_converter)
        when "UTF-8"
          CSV.read(file_path, encoding: "UTF-8:UTF-8", headers: true, header_converters: header_converter)
        end
      end

      def csv_headers
        csv.headers
      end

      attr_reader :file_path

      def initialize file_path
        @file_path = file_path

        migration(csv_headers)
      end

      def migration csv_headers
        ActiveRecord::Migration.verbose = false

        ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

        ActiveRecord::Schema.define(:version => 1) do
          create_table :records do |t|
            csv_headers.map do |column_name|
              t.text column_name.to_sym
            end
          end
        end
      end

      def run!
        csv.each do |row|
          Record.create!(row.to_h)
        end
        records = yield
        rows = records.map { |e| e.attributes.values }
        puts Terminal::Table.new :headings => csv_headers, :rows => rows
      end
    end
  end
end

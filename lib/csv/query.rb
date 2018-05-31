require "csv/query/version"
require 'csv'
require 'sqlite3'
require 'active_record'
require 'optparse'
require 'charlock_holmes/string'
require 'terminal-table'

module Csv
  module Query
    # Your code goes here...
    def self.run!
      file_path, json =
        ARGV.getopts(nil, 'file:', 'json').values

      InMemoryAR.new(file_path, json).run!
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

      def initialize(file_path, json)
        @json = json
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

      def json_format?
        @json
      end

      def run!
        csv.each do |row|
          Record.create!(row.to_h)
        end

        render InMemoryAR::Record.all
      end

      def render records
        if json_format?
          puts records.map { |e| e.attributes }.to_json
        else
          rows = records.map { |e| e.attributes.values }
          puts Terminal::Table.new :headings => csv_headers, :rows => rows
        end
      end
    end
  end
end

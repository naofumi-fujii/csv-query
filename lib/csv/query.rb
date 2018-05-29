require "csv/query/version"
require 'csv'
require 'sqlite3'
require 'active_record'
require 'optparse'

module Csv
  module Query
    # Your code goes here...
    def self.run!
      file_path =
        ARGV.getopts(nil, 'file:').values[0]

      InMemoryAR.new(file_path).run! { pp InMemoryAR::Record.all }
    end

    class InMemoryAR
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
        CSV.read(file_path, encoding: "SJIS:UTF-8", headers: true, header_converters: header_converter)
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
        yield
      end
    end
  end
end

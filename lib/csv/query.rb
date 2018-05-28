require "csv/query/version"
require 'csv'
require 'sqlite3'
require 'active_record'

module Csv
  module Query
    # Your code goes here...
    def self.run!
      InMemoryAR.new.run! { pp InMemoryAR::Record.all }
    end

    class InMemoryAR
      class Record < ActiveRecord::Base
      end

      class CsvControl
        class << self
          def file_path
            '/Users/s01001/Downloads/head10.csv'
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
        end
      end


      def initialize
        ActiveRecord::Migration.verbose = false

        ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

        ActiveRecord::Schema.define(:version => 1) do
          create_table :records do |t|
            CsvControl.csv_headers.map do |column_name|
              t.text column_name.to_sym
            end
          end
        end
      end

      def run!
        CsvControl.csv.each do |row|
          Record.create!(row.to_h)
        end
        yield
      end
    end
  end
end

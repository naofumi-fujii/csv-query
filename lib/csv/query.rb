require "csv/query/version"
require 'csv'
require 'sqlite3'
require 'active_record'
require 'optparse'
require 'charlock_holmes/string'
require 'terminal-table'
require 'thor'

module Csv
  module Query
    class CLI < Thor
      # Your code goes here...
      method_option :file, type: :string, required: true
      method_option :json
      desc "main", "do something"
      def main
        file_path, json, sync =
          ARGV.getopts(nil, 'file:', 'json').values

        InMemoryAR.new(file_path, json).run!
      end
      default_task :main

      class InMemoryAR
        # temporary AR obj
        class Record < ActiveRecord::Base
          def to_h
            h = self.attributes
            h.delete("id")
            h
          end
        end

        # `LP(iphone)`みたいに
        # 半角カッコ内にアルファベットだと
        # Rubyのsyntax的にsetterと勘違いされるので対策
        def header_converter
          lambda do |h|
            h.gsub('(','（').gsub(')', '）')
          end
        end

        def encoding
          contents = File.read(file_path)
          detection = contents.detect_encoding
          detection[:encoding]
        end

        def csv
          case encoding
          when "Shift_JIS"
            CSV.read(file_path, encoding: "SJIS:UTF-8", headers: true, header_converters: header_converter)
          when "UTF-8"
            CSV.read(file_path, encoding: "UTF-8:UTF-8", headers: true, header_converters: header_converter)
          when "ISO-8859-1"
            CSV.read(file_path, encoding: "ISO8859-1:UTF-8", headers: true, header_converters: header_converter)
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

          records = InMemoryAR::Record.all

          render(records)
        end

        def render records
          if json_format?
            puts Array.wrap(records).map { |e| e.to_h }.to_json
          else
            rows = Array.wrap(records).map { |e| e.to_h.values }
            puts Terminal::Table.new :headings => csv_headers, :rows => rows
          end
        end
      end
    end
  end
end

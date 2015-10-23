# encoding: utf-8

require 'thor'

module Nexpose
  module CLI
    class Engine < Thor
      desc 'list', 'List engines'
      def list
        options[:connections].map do |connection|
          puts "#{connection.host}:"
          connection.engines .map do |engine_summary|
            puts "\t#{engine_summary.name}"
          end
        end
      end
    end
  end
end

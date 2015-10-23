# encoding: utf-8

require 'thor'

module Nexpose
  module CLI
    # Provides support for interacting with users on Nexpose Scan Consoles
    class User < Thor
      desc 'list', 'List users'
      def list
        options[:connections].map do |connection|
          puts "#{connection.host}:"
          connection.users.map do |user_summary|
            puts "\t#{user_summary.name}"
          end
        end
      end
    end
  end
end

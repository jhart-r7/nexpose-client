# encoding: utf-8

require 'thor'

module Nexpose
  class UserCLI < Thor

    desc 'list', 'List users'
    def list
      $connections.map do |connection|
        puts "#{connection.host}:"
        connection.users .map do |user_summary|
          puts "\t#{user_summary.name}"
        end
      end
    end
  end
end
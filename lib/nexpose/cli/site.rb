# encoding: utf-8

require 'thor'

module Nexpose
  class SiteCLI < Thor
    desc 'list', 'List sites'
    def list
      $connections.map do |connection|
        puts "#{connection.host}:"
        connection.list_sites.map do |site_summary|
          puts "\t#{site_summary.name}"
        end
      end
    end
  end
end

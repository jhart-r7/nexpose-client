# encoding: utf-8

require 'uri'

module Nexpose
  module CLI
    # Provides support for interacting with Nexpose Scan Engines
    class Configure < Thor
      desc 'list', 'List configured console(s)'
      def list
        puts options[:connections].map(&:host).join("\n")
      end

      desc 'add <CONSOLE_URI> [ALIAS]', 'Add Nexpose consoles'
      def add(uri, _console_alias = nil)
        uri = URI.parse(uri)
        options[:configuration].data['consoles'] ||= []
        options[:configuration].data['consoles'] << uri.to_s
        options[:configuration].save
      end
    end
  end
end

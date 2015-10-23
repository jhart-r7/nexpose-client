# encoding: utf-8

require 'thor'

module Nexpose
  module CLI
    class Console < Thor

      desc 'command', 'Run console commands'

      def command(command)
        $connections.map do |connection|
          puts "#{connection.host}:"
          puts connection.console_command(command)
        end
      end
    end
  end
end
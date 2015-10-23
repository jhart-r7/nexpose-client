# encoding: utf-8

require 'yaml'

module Nexpose
  module CLI
    # Provides support for interacting with the configuration file used to
    # configure the 'nexpose' executable that ships with the nexpose-client gem
    class Configuration
      attr_reader :data
      PATH = ::File.join(::File.expand_path('~'), '.nexpose-client')

      def initialize
        @data = load_file
      end

      def load_file
        save({ 'consoles' => [] }.to_yaml) unless ::File.exist?(PATH)
        YAML.load_file(PATH)
      end

      def save(data = @data.to_yaml)
        @data = data
        ::File.open(PATH, 'w') { |f| f.puts data }
      end

      def consoles
        @data['consoles']
      end
    end
  end
end

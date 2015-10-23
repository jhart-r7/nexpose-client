# encoding: utf-8

require 'yaml'

module Nexpose
  module CLI
    class ConfigFile
      attr_reader :path
      attr_reader :data
      FILENAME = '.nexpose-client'

      def initialize
        @path = ::File.join(::File.expand_path('~'), FILENAME)
        @data = load_file
      end

      def load_file
        save({ 'consoles' => [] }.to_yaml) unless ::File.exist?(@path)
        YAML.load_file(@path)
      end

      def save(data = @data.to_yaml)
        @data = data
        ::File.open(@path, 'w') { |f| f.puts data }
      end

      def consoles
        @data['consoles']
      end
    end
  end
end

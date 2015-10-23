# encoding: utf-8
require 'yaml'

module Nexpose
  class ConfigFile

    attr_reader :path
    attr_reader :data
    FILENAME = '.nexpose-client'

    def initialize
      @path = ::File.join(::File.expand_path('~'), FILENAME)
      @data = load_file
    end

    def create_file
      ::File.open(@path, 'w') do |f|
        f.puts('consoles:')
      end
    end

    def load_file
      create_file unless ::File.exists?(@path)
      YAML.load_file(@path)
    end

    def save(data = @data)
      ::File.open(@path, 'w') { |f| f.puts data.to_yaml }
    end
  end
end
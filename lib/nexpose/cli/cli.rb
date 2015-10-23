# encoding: utf-8

require 'thor'
require 'nexpose'
require_relative 'config_file'
require_relative 'configure'
require_relative 'site'

module Nexpose
  class CLI < Thor
    class_option :verbose, type: :boolean
    class_option 'configuration-path', aliases: '-c', type: :string, default: ::File.join(::File.expand_path('~'), Nexpose::ConfigureCLI::CONFIG_FILENAME),
                 desc: 'Path to nexpose-client configuration file', banner: 'FILE'

    def initialize(*)
      $config = Nexpose::ConfigFile.new
      super
    end

    desc 'configure CONFIGURE_COMMANDS ...ARGS', 'Configures nexpose-client'
    subcommand 'configure', ConfigureCLI

    desc 'site SITE_COMMANDS ...ARGS', 'Interact with sites'
    subcommand 'site', SiteCLI
  end
end

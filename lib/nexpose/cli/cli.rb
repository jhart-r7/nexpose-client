# encoding: utf-8

require 'thor'
require 'nexpose'
require_relative 'config_file'
require_relative 'configure'
require_relative 'console'
require_relative 'engine'
require_relative 'site'
require_relative 'user'

module Nexpose
  class CLI < Thor
    class_option :verbose, aliases: :v, type: :boolean, desc: 'Be verbose', default: 'true'
    class_option 'configuration-path', aliases: :c, type: :string, default: ::File.join(::File.expand_path('~'), Nexpose::ConfigureCLI::CONFIG_FILENAME),
                 desc: 'Path to nexpose-client configuration file', banner: 'FILE'

    def initialize(*)
      $config = Nexpose::ConfigFile.new
      super
      $connections = []
      $config.consoles.each do |console|
        console_uri = URI.parse(console)
        connection = Nexpose::Connection.new(console_uri.host, console_uri.user, console_uri.password, console_uri.port)
        connection.login
        $connections << connection
      end if $config.consoles
    end

    desc 'configure CONFIGURE_COMMANDS ...ARGS', 'Configures nexpose-client'
    subcommand 'configure', ConfigureCLI

    desc 'console CONSOLE_COMMANDS ...ARGS', 'Work with consoles'
    subcommand 'console', ConsoleCLI

    desc 'engine ENGINE_COMMANDS ...ARGS', 'Work with engines'
    subcommand 'engine', EngineCLI

    desc 'site SITE_COMMANDS ...ARGS', 'Work with sites'
    subcommand 'site', SiteCLI

    desc 'user USER_COMMANDS ...ARGS', 'Work with users'
    subcommand 'user', UserCLI
  end
end
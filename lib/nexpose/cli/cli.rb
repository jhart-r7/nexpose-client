# encoding: utf-8

require 'thor'
require 'nexpose'
require_relative 'site'

module Nexpose
  class CLI < Thor
    def initialize(*)
      @connection = Nexpose::Connection.new('localhost', 'nxadmin', 'nxadmin')
      super
    end

    desc 'site SITE_COMMANDS ...ARGS', 'Interact with sites'
    subcommand 'site', SiteCLI
  end
end

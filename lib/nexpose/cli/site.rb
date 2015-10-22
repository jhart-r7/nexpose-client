# encoding: utf-8

require 'thor'

module Nexpose
  class SiteCLI < Thor
    desc 'list', 'List sites'
    def list
      @connection = Nexpose::Connection.new('localhost', 'nxadmin', 'nxadmin')
      @connection.login
      puts @connection.list_sites
    end
  end
end

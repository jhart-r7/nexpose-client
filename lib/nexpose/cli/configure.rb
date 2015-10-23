require 'uri'

module Nexpose
  class ConfigureCLI < Thor

    CONFIG_FILENAME = '.nexpose-client'

    desc 'list', 'List configured console(s)'
    def list
      puts $config.consoles
    end

    desc 'add <CONSOLE_URI> [ALIAS]', 'Add Nexpose consoles'
    def add(uri, console_alias = nil)
      uri = URI.parse(uri)
      $config.data['consoles'] ||= []
      $config.data['consoles'] << uri.to_s
      $config.save
    end
  end
end
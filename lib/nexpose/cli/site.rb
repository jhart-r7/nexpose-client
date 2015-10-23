# encoding: utf-8

require 'securerandom'
require 'thor'

module Nexpose
  class SiteCLI < Thor

    desc 'add', 'Add a site'
    option :name
    option :template
    def add(*assets)
      assets = $stdin.readlines.map(&:strip) if assets.empty?
      name = options[:name] || SecureRandom.hex
      $connections.map do |connection|
        if options[:template]
          site = Site.new(name, options[:template])
        else
          site = Site.new(name)
        end
        assets.map do |asset|
          site.include_asset(asset)
        end
        site.save(connection)
        puts "Created #{name} on #{connection.host}"
      end
    end

    desc 'delete', 'Delete sites'
    option :all, :aliases => :a, :type => :boolean
    def delete(*site_names)
      $connections.map do |connection|
        if options[:all]
          connection.sites.map do |site_summary|
            puts "Deleting #{site_summary.name}/#{site_summary.id} on #{connection.host}"
            connection.delete_site(site_summary.id)
          end
        else
          site_names.each do |site_name|
            site = connection.sites.select { |site| site.name == site_name }.first
            fail "No site named #{site_name} on #{connection}" unless site
            puts "Deleting #{site_name}/#{site.id} on #{connection.host}"
            connection.delete_site(site.id)
          end
        end
      end
    end

    desc 'list', 'List sites'
    def list
      $connections.map do |connection|
        puts "#{connection.host}:"
        connection.sites.map do |site_summary|
          puts "\t#{site_summary.name}"
        end
      end
    end

    desc 'scan', 'Scan sites/assets'
    option :wait, aliases: :w, type: :boolean
    def scan(site_name, *assets)
      $connections.map do |connection|
        site = connection.sites.select { |site| site.name == site_name }.first
        fail "No site named #{site_name} on #{connection}" unless site
        puts "Scanning #{site_name}/#{site.id} on #{connection.host}"
        scan = connection.scan_site(site.id)
        if options[:wait]
          while true do
            status = connection.scan_status(scan.id)
            break if status == Nexpose::Scan::Status::FINISHED
            fail "Scan did not finish: #{status}" if [ Nexpose::Scan::Status::ABORTED, Nexpose::Scan::Status::ERROR, Nexpose::Scan::Status::PAUSED, Nexpose::Scan::Status::STOPPED ].include?(status)
          end
        end
      end
    end
  end
end
# encoding: utf-8

require 'securerandom'
require 'thor'

module Nexpose
  module CLI
    # Provides support for interacting with sites on Nexpose Scan Consoles
    class Site < Thor
      desc 'add', 'Add a site'
      option :name, aliases: '-v', desc: 'Name of the site', default: 'Randomly generated'
      option :template, aliases: '-t', desc: 'Scan template to use', default: 'full-audit-without-web-spider'
      def add(*assets)
        assets = $stdin.readlines.map(&:strip) if assets.empty?
        name = options[:name] || SecureRandom.hex
        options[:connections].map do |connection|
          site = Nexpose::Site.new(name, options[:template])
          assets.map do |asset|
            site.include_asset(asset)
          end
          site.save(connection)
          puts "Created #{name} on #{connection.host}" if options[:verbose]
        end
      end

      desc 'delete', 'Delete sites'
      option :all, aliases: '-a', type: :boolean, desc: 'Delete all sites', default: false
      def delete(*site_names)
        options[:connections].map do |connection|
          if options[:all]
            connection.sites.map do |site_summary|
              puts "Deleting #{site_summary.name}/#{site_summary.id} on #{connection.host}" if options[:verbose]
              connection.delete_site(site_summary.id)
            end
          else
            site_names.each do |site_name|
              site = connection.sites.find { |s| s.name == site_name }
              fail "No site named #{site_name} on #{connection}" unless site
              puts "Deleting #{site_name}/#{site.id} on #{connection.host}" if options[:verbose]
              connection.delete_site(site.id)
            end
          end
        end
      end

      desc 'list', 'List sites'
      def list
        options[:connections].map do |connection|
          puts "#{connection.host}:"
          connection.sites.map do |site_summary|
            puts "\t#{site_summary.name}"
          end
        end
      end

      desc 'scan', 'Scan sites/assets'
      option :wait, aliases: '-w', type: :boolean, desc: 'Wait until scan completes'
      option :log, aliases: '-l', type: :string, banner: '<log_path>', required: true, desc: 'Store scan logs here'
      def scan(site_name, *_assets)
        options[:connections].map do |connection|
          site = connection.sites.find { |s| s.name == site_name }
          fail "No site named #{site_name} on #{connection}" unless site
          puts "Scanning #{site_name}/#{site.id} on #{connection.host}" if options[:verbose]
          scan = connection.scan_site(site.id)
          if options[:wait]
            loop do
              status = connection.scan_status(scan.id)
              if status == Nexpose::Scan::Status::FINISHED
                if options[:log]
                  path = ::File.expand_path("#{options[:log]}-#{connection.host}")
                  connection.download("/data/scan/log?scan-id=#{scan.id}", path)
                  puts "Saved log for scan ID #{scan.id} of #{site_name} in #{path}" if options[:verbose]
                end
                break
              end
              fail "Scan did not finish: #{status}" if unfinished_status?(status)
            end
          end
        end
      end

      private

      def unfinished_status?(status)
        [
          Nexpose::Scan::Status::ABORTED,
          Nexpose::Scan::Status::ERROR,
          Nexpose::Scan::Status::PAUSED,
          Nexpose::Scan::Status::STOPPED
        ].include?(status)
      end
    end
  end
end

#!/usr/bin/env ruby

require 'erb'
require 'yaml'

# Just read from stdin
text = ARGF.read
template = ERB.new(text, trim_mode: '%<>')

config_yaml = YAML.load(File.read('services.yml'))
services = config_yaml['services']
config_base = config_yaml['config_base'] || '/config'
compose_file = config_yaml['compose_file'] || './docker-compose.yml'

# Expand ${config_base} in volume paths
services.each do |svc|
  svc['volumes'] = svc['volumes'].map { |v| v.gsub('${config_base}', config_base) } if svc['volumes']
end

# If SERVICE_NAME is set, expose the specific service for single-service templates
service_name = ENV['SERVICE_NAME']
service = services.find { |s| s['name'] == service_name } if service_name

# Helper: get all services that use VPN
vpn_services = services.select { |s| s['uses_vpn'] }

# Helper: get the VPN gateway service
vpn_gateway = services.find { |s| s['is_vpn_gateway'] }

puts template.result

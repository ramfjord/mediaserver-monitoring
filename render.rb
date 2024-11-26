#!/usr/bin/env ruby

require 'erb'
require 'pry'
require 'yaml'

# Just read from stdin
text = ARGF.read
template = ERB.new(text, trim_mode: "%<>")

config_yaml = YAML.load(File.read("services.yml"))
services = config_yaml["services"]

puts template.result

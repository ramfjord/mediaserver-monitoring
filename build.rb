#!/usr/bin/env ruby

require 'erb'
require 'pry'

# Just read from stdin
text = ARGF.read
template = ERB.new(text, trim_mode: "%<>")

services = [
  { name: 'Radarr',   unit: 'radarr', desc: "find movies - 7878" },
  # { name: 'Lidarr',   unit: 'lidarr', desc: 'music - 8686' },
  { name: 'Sonarr',   unit: 'sonarr', desc: 'shows'  },
  { name: 'Prowlarr', unit: 'prowlarr', desc: 'admin tool - 9696' },
  { name: 'VPN',      unit: 'wg-quick@america', desc: 'VPN' },
  { name: 'Plex',     unit: 'plexmediaserver', desc: 'Media streaming - 32400' },
  # { name: 'Deluge',   unit: 'deluged', desc: '8112' },
]

puts template.result

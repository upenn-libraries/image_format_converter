#!/bin/ruby

require 'mini_magick'
require 'yaml'
require 'pry'

def mogrify_actions(options = {}, image)
  mogrify = MiniMagick::Tool::Mogrify.new
  mogrify.resample(options['ppi']) unless options['ppi'].nil?
  mogrify << image
end

def populate_mogrify_options(config)
  options = {}
  mogrify_keys = ['ppi']
  mogrify_keys.each do |key|
    options[key] = config[key]
  end
  return options
end

relative_config_path = 'config.yml'

abort('Configuration file not present.  See README for instructions.') unless File.exist?(relative_config_path)

config = YAML.load_file(relative_config_path)

original_location = config['original_location']
converted_location = config['converted_location']

original_format = config['original_format']
converted_format = config['converted_format']

mogrify_options = populate_mogrify_options(config)

Dir.glob("#{original_location}/*.#{original_format}").each do |file|
  image = MiniMagick::Image.open(file)
  converted_image = "#{converted_location}/#{File.basename(file, '.*')}.#{converted_format}"
  image.format "#{converted_format}"
  image.write "#{converted_image}"
  mogrify_actions(mogrify_options, converted_image) unless mogrify_options.empty?
end

#!/bin/ruby

require 'mini_magick'
require 'yaml'
require 'logger'
require 'pry'


def missing_args?
  return ARGV[0].nil?
end

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


manifest = ARGV[0]
abort('Supply a manifest yml config') if missing_args?

abort("#{manifest} not found") unless File.exist?(manifest)

config = YAML.load_file(manifest)

logger = Logger.new('| tee logger.log')
logger.level = Logger::INFO
logger.info('Script run started')

original_location = config['original_location']
converted_location = config['converted_location']

original_format = config['original_format']
converted_format = config['converted_format']

mogrify_options = populate_mogrify_options(config)

Dir.glob("#{original_location}/*.#{original_format}").each do |file|
  logger.info("Opening #{file}")
  image = MiniMagick::Image.open(file)
  converted_image = "#{converted_location}/#{File.basename(file, '.*')}.#{converted_format}"
  logger.info("Converting #{file}")
  image.format "#{converted_format}"
  logger.info("Writing #{file}")
  image.write "#{converted_image}"
  logger.info("Mogrifying #{file}")
  mogrify_actions(mogrify_options, converted_image) unless mogrify_options.empty?
end

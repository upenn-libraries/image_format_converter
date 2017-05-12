#!/bin/ruby

require 'mini_magick'
require 'pry'


def mogrify_actions(options = {})
  mogrify = MiniMagick::Tool::Mogrify.new
  mogrify.resample(options[:ppi]) if options[:ppi].present?
  mogrify << converted_image
end

original_location = '/Users/kate/Documents/Projects/tifs'
coverted_location = '/Users/kate/Documents/Projects/jp2s'

original_format = 'tif'
converted_format = 'jp2'



Dir.glob("#{original_location}/*.#{original_format}").each do |file|
  image = MiniMagick::Image.open(file)
  converted_image = "#{coverted_location}/#{File.basename(file, '.*')}.#{converted_format}"
  image.format "#{converted_format}"
  image.write "#{converted_image}"
  mogrify_actions(mogrify_options) if mogrify_options.present?
end
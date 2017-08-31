#!/bin/ruby

require 'mini_magick'
require 'yaml'
require 'logger'
require 'readline'

def missing_args?
  return ARGV[0].nil?
end

def prompt(prompt='', newline=false)
  prompt += "\n" if newline
  Readline.readline(prompt, true).squeeze(' ').strip
end

def enumeration_check(input_files, original_format, logger)
  filenames = []
  input_files.each{ |f| filenames << File.basename(f).gsub(".#{original_format}",'')}
  file_ints = filenames.sort.collect { |i| i.to_i }
  correct_enumeration = (1..file_ints.last).to_a
  difference = correct_enumeration - file_ints
  return if difference.empty?
  continue = prompt("According to file enumeration pattern for HathiTrust, file(s) appear to be missing at #{difference.each{|x| puts x}}. Continue?")
  return if %w[y yes].include?(continue.downcase)
  abort('Cancelling script at user prompt') if %w[n no].include?(continue.downcase)
  abort('Please specify \'y\' or \'n\', aborting.')
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
    options[key] = config[key] unless config[key].nil?
  end
  return options
end

def move_and_log_problem(problem_file, logger, original_location)
  problem_location = "#{original_location}/problem"
  logger.warn("Problem detected for #{problem_file}, moving to #{problem_location}")
  FileUtils.mkdir_p(problem_location)
  FileUtils.mv(problem_file,problem_location)
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

FileUtils.mkdir_p(converted_location)

files = Dir.glob("#{original_location}/*.#{original_format}")

enumeration_check(files, original_format, logger)

mogrify_options = populate_mogrify_options(config)

files.each do |file|
  begin
    logger.info("Opening #{file}")
    image = MiniMagick::Image.open(file)
    converted_image = "#{converted_location}/#{File.basename(file, '.*')}.#{converted_format}"
    logger.info("Converting #{file}")
    image.format "#{converted_format}"
    logger.info("Writing #{file}")
    image.write "#{converted_image}"
  rescue => exception
    move_and_log_problem(file, logger, original_location) if exception.message.downcase.include?('failed with error')
    next
  end

  unless mogrify_options.empty?
    logger.info("Mogrifying #{file}")
    mogrify_actions(mogrify_options, converted_image)
  end
end

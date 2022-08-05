require 'marc'
require 'yaml'
require 'fileutils'
require 'date'
require_relative 'logging'

module GOBI
  include Logging

  DATA_DIR = File.expand_path(File.join(__dir__, '../data'))
  PROVIDER_PATH = File.expand_path(File.join(__dir__, '../config'))
  FIXTURES_DIR = File.expand_path(File.join(__dir__, '../spec/fixtures'))
  @out_dir = File.join(DATA_DIR, 'gobi_processed')
  @processed = File.join(DATA_DIR, 'incoming/processed')
  @input_dir = File.join(DATA_DIR, 'incoming')

  # get 3 letter Gobi providers
  @gobi_providers = YAML.load_file(File.join(PROVIDER_PATH, 'gobi_providers.yml'))

  def self.set_dirs(directory = nil, outdir = nil, processed = nil)
    @input_dir = directory unless directory.nil?
    @out_dir = outdir unless outdir.nil?
    @processed = processed unless processed.nil?
  end

  def self.watch!(directory = nil, outdir = nil, processed = nil, interval: 120)
    set_dirs(directory, outdir, processed)
    raise ArgumentError, "Watch directory '#{@input_dir}' is not a directory or symlink to a directory" \
      unless File.directory?(@input_dir) || \
        (File.symlink?(@input_dir) && File.directory?(File.readlink(@input_dir)))

    raise ArgumentError, 'interval must be a positive integer' \
      unless interval > 0 && interval.to_i == interval

    pattern = File.expand_path(File.join(@input_dir, '*.ord'))
    logger.info "GOBI: Watching #{pattern} for updates"

    process_dir(pattern, interval)
  end

  def self.process_dir(pattern, interval)
    loop do
      Dir.glob(pattern) do |filepath|
        logger.info "Processing file: #{filepath}"
        process!(filepath, @out_dir, @processed)
      rescue StandardError => e
        logger.info "Error processing #{filepath}: #{e}"
      end

      sleep interval
    end
  end

  # Copies fixtures files into the default data directory
  def self.seed!
    Dir.glob("#{FIXTURES_DIR}/*.ord") do |filepath|
      FileUtils.cp(filepath, File.join(@input_dir, File.basename(filepath)))
    end
  end

  # delete
  def self.clear!
    logger.info "Deleting .ord files under #{DATA_DIR}"
    FileUtils.rm_f(Dir.glob(File.join(DATA_DIR, '**/*.ord')))
  end

  # clear and reseed data directory
  def self.refresh!
    logger.info "Deleting .ord files under #{DATA_DIR}"
    clear!

    logger.info 'reseeding .ord files from fixtures'
    seed!
  end

  def self.write_marc(rec, outfile)
    logger.info 'GOBI: Going to write marc file'
    writer = MARC::Writer.new(outfile)
    writer.write(rec)
    writer.close
  end

  # Gobi provider code is the first 3 characters in the 961 $d
  def self.get_provider(rec)
    return unless rec['961'] && rec['961']['d']

    provider = rec['961']['d'][0, 3]
    logger.info "GOBI: Provider found #{provider}"
    provider
  end

  # output filehandle will be have the provider code or will be blank if the provider
  # 961 $d is blank or not defined in gobi_providers
  def self.get_output_filehandle(fname, provider)
    outfile = get_output_filename(provider, fname)
    File.open(outfile, 'a')
  end

  def self.move_file(from, to)
    FileUtils.mv from, to
    logger.info "GOBI: moved #{from} to #{to}"
  end

  def self.get_output_filename(provider, fname)
    file = if @gobi_providers.include?(provider)
             fname.gsub('ebook', "ebook#{provider}#{Date.today.year}")
           else
             fname.gsub('ebook', "ebookZZZ#{Date.today.year}")
           end

    "#{@out_dir}/#{File.basename(file)}"
  end

  def self.new_file?(provider, fname)
    file = get_output_filename(provider, fname)
    outputfile = "#{@out_dir}/#{File.basename(file)}"
    return true unless File.exist?(outputfile)
  end

  # Rubocop warnings due to logging statements. disabling
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.process!(fname, outdir, processed)
    set_dirs(nil, outdir, processed)
    providers = {}
    logger.info "GOBI: Going to process #{fname}"
    reader = MARC::Reader.new(fname, external_encoding: 'UTF-8')
    reader.each do |record|
      provider = get_provider(record)
      provider = 'ZZZ' unless @gobi_providers.include?(provider)
      providers.key?(provider) || providers[provider] = new_file?(provider, fname)
      if providers[provider]
        outfile = get_output_filehandle(File.basename(fname), provider)
        write_marc(record, outfile)
      end
    end

    logger.info "GOBI: Finished processing #{fname}"
    move_file(fname, File.join(@processed, File.basename(fname)))
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

end

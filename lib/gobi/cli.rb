require 'gobi'
require 'thor'
require 'getoptlong'

module GOBI
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    opts = GetoptLong.new(
      ['--interval', '-i', GetoptLong::REQUIRED_ARGUMENT],
      ['--input_dir', '-w', GetoptLong::REQUIRED_ARGUMENT],
      ['--out_dir', '-o', GetoptLong::REQUIRED_ARGUMENT],
      ['--done_dir', '-d', GetoptLong::REQUIRED_ARGUMENT]
    )

    opts.each do |opt, arg|
      case opt
      when '--input_dir'
        @directory = arg
      when '--out_dir'
        @out_dir = arg
      when '--done_dir'
        @done_dir = arg
      when '--interval'
        @interval = arg.to_i
      end
    end

    desc 'watch', 'Monitor a directory for new GOBI marc order files to process .'
    method_option :directory, desc: 'The directory to watch for new files', aliases: '-d', default: @directory
    method_option :interval, desc: 'Seconds to sleep between scanning for new files', aliases: '-i', default: @interval ||= 120, type: :numeric
    method_option :outdir, desc: 'The output directory for process Gobi files', aliases: '-o', default: @out_dir
    method_option :donedir, desc: 'The output directory for raw Gobi file to be move to after processing', aliases: '-d', default: @done_dir

    def watch
      GOBI.watch!(options[:directory], options[:outdir], options[:donedir], interval: options[:interval])
    end

    desc 'process FILEPATH', 'Process the specific GOBI file given by FILEPATH'
    method_option :outdir, desc: 'The output directory for process Gobi files', aliases: '-o', default: @out_dir
    method_option :donedir, desc: 'The output directory for raw Gobi file to be move to after processing', aliases: '-d', default: @done_dir
    def process(filepath)
      GOBI.process!(filepath, options[:outdir], options[:donedir])
    end

    desc 'clear', 'Deletes existing processed and error files'
    def clear
      GOBI.clear!
    end

    desc 'seed', 'Seeds the default data directory with fixture files'
    def seed
      GOBI.seed!
    end

    desc 'refresh', 'Deletes processed files and reseeds from fixtures'
    def refresh
      GOBI.refresh!
    end
  end
end

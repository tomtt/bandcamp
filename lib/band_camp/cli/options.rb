module BandCamp
  module Cli
    module Options
      require 'optparse'

      def self.extract_from_argv
        options = {}

        OptionParser.new do |opts|
          opts.banner = "Usage: example.rb [options]"

          opts.on("-t", "--true", "Do not download any mp3 files") do |v|
            options[:try] = v
          end

          opts.on("-d", "--[no-]debug", "Output debug information") do |v|
            options[:debug] = v
          end
        end.parse!
        options
      end
    end
  end
end

require 'net/http'
require 'uri'

module BandCamp
  class Song
    attr_reader :title, :title_link, :url

    def initialize(title, title_link, url, options = {})
      @title = title
      @title_link = title_link
      @url = url
      @options = options
    end

    def to_s
      "title: #{title}"
    end

    def download(band_path, index = nil)
      song_name = BandCamp::file_safe_string(title)
      if index
        song_name = "%02d-%s" % [index + 1, song_name]
      end
      file_name = File.join(band_path, song_name + ".mp3")
      print "[try] " if @options[:try]
      puts "Saving #{file_name}" if @options[:debug] || @options[:try]

      unless @options[:try]
        song_url = URI.parse(url)
        res = Net::HTTP.start(song_url.host, song_url.port) {|http|
          http.get("#{song_url.path}?#{song_url.query}")
        }

        File.open(file_name, "w") do |file|
          file.puts res.body
        end
      end
    end
  end
end

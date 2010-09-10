require 'net/http'
require 'uri'
require "id3lib"

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

    def download(band_path, options = {})
      song_name = BandCamp::file_safe_string(title)
      if options[:index]
        song_name = "%02d-%s" % [options[:index] + 1, song_name]
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

        id3_tag = ID3Lib::Tag.new(file_name)
        id3_tag.title = title
        id3_tag.artist = options[:band_name] if options[:band_name]
        id3_tag.album = options[:album_name] if options[:album_name]
        if options[:index]
          track = (options[:index] + 1).to_s
          if options[:number_of_tracks]
            track += "/%d" % options[:number_of_tracks]
          end
          id3_tag.track = track
        end
        id3_tag.update!
      end
    end
  end
end

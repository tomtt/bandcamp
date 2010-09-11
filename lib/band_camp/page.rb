require "band_camp/song"
require "band_camp/downloader"
require "harmony"
require "hpricot"

module BandCamp
  class Page
    def initialize(url, options = {})
      @options = options
      @url = url
    end

    def page_html
      unless @page_html
        puts "Getting content of \"#{@url}\"" if @options[:debug]
        @page_html = Net::HTTP.get(parsed_url)
      end
      @page_html
    end

    def parsed_url
      @parsed_url ||= URI.parse(@url)
    end

    def harmony_page
      unless @harmony_page
        # Assigning to a variable first to make the puts statements make sense
        html = page_html
        puts "Initializing headless browser" if @options[:debug]
        @harmony_page = Harmony::Page.new(html)
      end
      @harmony_page
    end

    def is_album?
      harmony_page.execute_js("TralbumData.current")
      return true
    rescue Johnson::Error
      return false
    end

    def songs
      @songs ||= harmony_page.execute_js("TralbumData.trackinfo").map do |song_object|
        Song.new(song_object.title.to_s, song_object.title_link.to_s, song_object.file.to_s, @options)
      end
    end

    def band_name
      @band_name ||= harmony_page.execute_js("BandData.name")
    end

    def album_name
      @album_name ||= harmony_page.execute_js("TralbumData.current.title")
    end

    def urls_of_albums_on_this_page
      hpricot.search(".ipCell h1 a").map { |a| extend_relative_url(a.attributes["href"]) }
    end

    def download
      if is_album?
        download_songs_for_this_album
      else
        download_albums_on_this_page
      end
    end

    def extend_relative_url(relative_url)
      url = URI.parse(relative_url)
      url.scheme = "http"
      url.host = parsed_url.host
      url.to_s
    end

    def path_for_download
      File.join("download",
                BandCamp::file_safe_string(band_name),
                BandCamp::file_safe_string(album_name))
    end

    def hpricot
      @hpricot ||= Hpricot.parse(page_html)
    end

    private

    def download_songs_for_this_album
      dir = path_for_download
      unless @options[:try]
        `mkdir -p #{dir}`
      end

      number_of_tracks = songs.size

      songs.each_with_index { |song, index|
        song.download(dir,
                      :index => index,
                      :number_of_tracks => number_of_tracks,
                      :band_name => band_name,
                      :album_name => album_name)
      }

      download_album_art
    end

    def download_albums_on_this_page
      if @options[:all]
        puts "Downloading all albums" if @options[:debug]
        urls_of_albums_on_this_page.sort.each do |album_url|
          puts "Now downloading: #{album_url}" if @options[:debug]
          Page.new(album_url, @options).download
        end
      else
        puts "This url does not contain songs, but only a list of albums/tracks:"
        urls_of_albums_on_this_page.sort.each { |u| puts "- #{u}" }
        puts "You can either download those urls individually or pass the -a flag to download them all"
      end
    end

    def download_album_art
      # Assumes the directory where the album is downloaded already exists
      url = hpricot.search("#tralbumArt img").first.attributes["src"]
      file_name = File.join(path_for_download, "album.jpg")
      if @options[:try]
        puts "[try] Saving #{file_name}"
      else
        Downloader.download(:url => url, :file_name => file_name, :debug => @options[:debug])
      end
    end
  end
end

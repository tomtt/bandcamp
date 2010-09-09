lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'band_camp/version'

Gem::Specification.new do |s|
  s.name        = "bandcamp"
  s.version     = BandCamp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tom ten Thij"]
  s.email       = ["ruby@tomtenthij.nl"]
  s.homepage    = "http://github.com/tomtt/bandcamp"
  s.summary     = "A utility to download the low quality mp3 files for a band on bandcamp.com"
  s.description = "A utility to download the low quality mp3 files for a band on bandcamp.com"

  s.files        = Dir.glob("{bin,lib}/**/*")
  s.executables  = ['band_camp_download']
  s.require_path = 'lib'
  s.add_runtime_dependency 'harmony'
end

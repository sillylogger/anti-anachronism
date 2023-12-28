#! /usr/bin/env ruby

require_relative File.join('..', 'setup')

if false
  Album.fetch_all
  CSVDatabase.create './data/albums.csv', Album

  Photo.fetch_all
  CSVDatabase.create './data/photos.csv', Photo
else
  CSVDatabase.read './data/albums.csv', Album
  CSVDatabase.read './data/photos.csv', Photo
end

debugger
puts "check that fetching, writing to csv, then reading from csv produce the same objects"
puts "waste a ton of time doing that... 😒"
puts "move on to update! 👊"


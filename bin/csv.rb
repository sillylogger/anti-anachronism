#! /usr/bin/env ruby

require_relative File.join('..', 'setup')

if true 
  CSVDatabase.read './data/albums.csv', Album
  CSVDatabase.read './data/photos.csv', Photo
else
  Album.fetch_all
  CSVDatabase.create './data/albums.csv', Album.all.map(&:csv)

  Photo.fetch_all
  CSVDatabase.create './data/photos.csv', Photo.all.map(&:csv)
end

debugger

puts "hi mom!"

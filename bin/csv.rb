#! /usr/bin/env ruby

require_relative File.join('..', 'setup')

Album.fetch_all
CSVDatabase.create './data/albums.csv', Album.all.map(&:csv)

Photo.fetch_all
CSVDatabase.create './data/photos.csv', Photo.all.map(&:csv)


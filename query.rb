#! /usr/bin/env ruby

require_relative 'setup'

data = Album.fetch_all.map(&:csv)
$log.info "Fetched #{data.size} albums"
CSVDatabase.create './data/albums.csv', data

data = Photo.fetch_all.map(&:csv)
$log.info "Fetched #{data.size} photos"
CSVDatabase.create './data/photos.csv', data


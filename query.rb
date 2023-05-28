#! /usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

require 'json'
require 'net/http'
require 'uri'
require 'ostruct'
require 'byebug'

require_relative 'lib/active_record'
require_relative 'lib/hash'
require_relative 'lib/terminal_table'
require_relative 'lib/vcr'

require_relative 'google_api'
require_relative 'album'
require_relative 'photo'

require_relative 'data/csv_database'


data = Album.fetch_all.map(&:csv)
CSVDatabase.create './data/albums.csv', data

data = Photo.fetch_all.map(&:csv)
CSVDatabase.create './data/photos.csv', data


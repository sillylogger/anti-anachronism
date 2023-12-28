#! /usr/bin/env ruby

require_relative File.join('..', 'setup')

if false
  Album.fetch_all
  CSVDatabase.create './data/albums.csv', Album::CSV_HEADERS, Album.all

  Photo.fetch_all
  CSVDatabase.create './data/photos.csv', Photo::CSV_HEADERS, Photo.all
else
  CSVDatabase.read './data/albums.csv', Album
  CSVDatabase.read './data/photos.csv', Photo
end

photos_by_diff = Photo.all.select{|p| 
  p.diff_in_hours.present?
}.sort_by{|p|
  p.diff_in_hours
}.reverse

photos_that_need_fixing = photos_by_diff.slice(0 .. 1000)
CSVDatabase.create  './photos-that-need-fixing.csv',
                    Photo::CSV_HEADERS,
                    photos_that_need_fixing

#! /usr/bin/env ruby

require_relative File.join('..', 'setup')

CSVDatabase.read './data/albums.csv', Album
CSVDatabase.read './data/photos.csv', Photo


headers = %w(Count Title Url)
data = Album.all.sort_by{|a|
  a.mediaItemsCount.to_i
}.reverse.map{|a|
  [a.mediaItemsCount,
   a.title,
   a.productUrl]
}
table = Terminal::Table.new headings: headers, rows: data
table.align_column 0, :right
$log.info "\n" + table.to_s + "\n"


hours = 7
photos_with_diff = Photo.all.select{|p| p.diff?(hours) }
$log.info "There are #{photos_with_diff.size} photos with a filename vs metadata diff over #{hours} hours:"

stats = Hash.new{|h, k| h[k] = Hash.new(0) }
photos_with_diff.each{|p|
  stats['mimeType'][p.mimeType&.strip] += 1
  stats['cameraMake'][p.mediaMetadata.dig('photo', 'cameraMake')&.strip] += 1
  stats['cameraModel'][p.mediaMetadata.dig('photo', 'cameraModel')&.strip] += 1
}

include Stats
print_stats "Mime Types", stats['mimeType'], photos_with_diff.size
print_stats "Camera Make", stats['cameraMake'], photos_with_diff.size
print_stats "Camera Model", stats['cameraModel'], photos_with_diff.size


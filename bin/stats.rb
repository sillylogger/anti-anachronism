#! /usr/bin/env ruby

require_relative File.join('..', 'setup')

CSVDatabase.read './data/albums.csv', Album
CSVDatabase.read './data/photos.csv', Photo

headers = %w(Count Title Url)
data = Album.all.sort_by{|a|
  a.media_items_count
}.reverse.map{|a|
  [a.media_items_count,
   a.title,
   a.url]
}
table = Terminal::Table.new headings: headers, rows: data
table.align_column 0, :right
$log.info "\n" + table.to_s + "\n"


photos_with_diff = Photo.all.select{|p| p.diff.present? && p.diff.abs > 0.5 }
$log.info "There are #{photos_with_diff.size} photos with a filename vs metadata diff over 12 hours:"

stats = Hash.new{|h, k| h[k] = Hash.new(0) }
photos_with_diff.each{|p|
  stats['mimeType'][p.mime_type&.strip] += 1
  stats['cameraMake'][p.camera_make&.strip] += 1
  stats['cameraModel'][p.camera_model&.strip] += 1
}

include Stats
print_stats "Mime Types", stats['mimeType'], photos_with_diff.size
print_stats "Camera Make", stats['cameraMake'], photos_with_diff.size
print_stats "Camera Model", stats['cameraModel'], photos_with_diff.size


#! /usr/bin/env ruby

require_relative File.join('..', 'setup')
include Stats

Album.fetch_all
Photo.fetch_all

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
$log.info "\n" + table.to_s


stats = Hash.new{|h, k| h[k] = Hash.new(0) }
data = Photo.all.each{|p|
  stats['mimeType'][p.mimeType&.strip] += 1
  stats['cameraMake'][p.mediaMetadata.dig('photo', 'cameraMake')&.strip] += 1
  stats['cameraModel'][p.mediaMetadata.dig('photo', 'cameraModel')&.strip] += 1
}
print_stats "Mime Types", stats['mimeType'], Photo.all.size
print_stats "Camera Make", stats['cameraMake'], Photo.all.size
print_stats "Camera Model", stats['cameraModel'], Photo.all.size

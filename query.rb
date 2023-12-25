#! /usr/bin/env ruby

require_relative 'setup'
include Stats

Album.fetch_all
Photo.fetch_all

hours = 7
photos_with_diff = Photo.all.select{|p| p.diff?(hours) }
$log.info "There are #{photos_with_diff.size} photos with a filename vs metadata diff over #{hours} hours."

stats = Hash.new{|h, k| h[k] = Hash.new(0) }
photos_with_diff.each{|p|
  stats['mimeType'][p.mimeType&.strip] += 1
  stats['cameraMake'][p.mediaMetadata.dig('photo', 'cameraMake')&.strip] += 1
  stats['cameraModel'][p.mediaMetadata.dig('photo', 'cameraModel')&.strip] += 1
}
print_stats "Mime Types", stats['mimeType'], photos_with_diff.size
print_stats "Camera Make", stats['cameraMake'], photos_with_diff.size
print_stats "Camera Model", stats['cameraModel'], photos_with_diff.size


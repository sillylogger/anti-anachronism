#! /usr/bin/env ruby

require_relative 'setup'
include Stats

Album.fetch_all
Photo.fetch_all

photos_with_diff = Photo.all.select{|p| p.diff? }
$log.info "There are #{photos_with_diff.size} photos with a filename vs metadata diff over 7 hours."

stats = Hash.new{|h, k| h[k] = Hash.new(0) }
data = photos_with_diff.each{|p|
  stats['mimeType'][p.mimeType&.strip] += 1
  stats['cameraMake'][p.mediaMetadata.dig('photo', 'cameraMake')&.strip] += 1
  stats['cameraModel'][p.mediaMetadata.dig('photo', 'cameraModel')&.strip] += 1
}
print_stats "Mime Types", stats['mimeType'], photos_with_diff.size
print_stats "Camera Make", stats['cameraMake'], photos_with_diff.size
print_stats "Camera Model", stats['cameraModel'], photos_with_diff.size

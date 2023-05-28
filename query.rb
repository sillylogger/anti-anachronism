#! /usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

require 'json'
require 'net/http'
require 'uri'

require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'byebug'
require_relative 'lib/hash'
require_relative 'lib/terminal_table'
require_relative 'lib/vcr'
require_relative 'data/csv_database'

# require_relative 'lib/active_record'
# class Camera < Struct.new(:make, :model, :aperture)
#   include ActiveRecord
#
# end

# Constants
API_BASE_URL = 'https://photoslibrary.googleapis.com/v1'
SCOPE = 'https://www.googleapis.com/auth/photoslibrary.readonly'

CREDENTIALS_PATH = 'credentials.json'
TOKEN_PATH = 'token.yaml'

ALBUMS_MAX_PAGE_SIZE = 50
ITEMS_MAX_PAGE_SIZE = 100

# Authorize the client using OAuth 2.0
client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

user_id = 'default'
@credentials = authorizer.get_credentials(user_id)

if @credentials.nil?
  url = authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
  puts 'Open the following URL in your browser and authorize the application:'
  puts url
  puts 'Enter the authorization code:'
  code = gets.chomp
  @credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: 'urn:ietf:wg:oauth:2.0:oob')
else
  puts 'Already had token / credentials, yay!'
end

if @credentials.expired?
  puts 'Expired :-('
  @credentials.refresh!

  if @credentials.expired?
    raise 'Having trouble refreshing, break.'
  else
    puts 'Refreshed, yay!'
  end
end

def get_albums pageToken
  uri = URI("#{API_BASE_URL}/albums")

  params = { page_size: ALBUMS_MAX_PAGE_SIZE }
  params[:pageToken] = pageToken unless pageToken.nil?
  uri.query = URI.encode_www_form params

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request['Content-type'] = 'application/json'
  request['Authorization'] = "Bearer #{@credentials.access_token}"

  response = http.request(request)
  unless response.code == '200'
    debugger
    return
  end

  json = JSON.parse(response.body)
  return [
    json['albums'],
    json['nextPageToken']
  ]
end

def get_all_albums
  all = []
  pageToken = nil

  VCR.use_cassette("get_all_albums", :record => :new_episodes) do
    loop do
      albums, pageToken = get_albums pageToken
      all.concat albums

      puts "albums: #{all.size}"
      break if pageToken.nil?
    end
  end

  all
end

def get_items pageToken
  uri = URI("#{API_BASE_URL}/mediaItems")

  params = { page_size: ITEMS_MAX_PAGE_SIZE }
  params[:pageToken] = pageToken unless pageToken.nil?
  uri.query = URI.encode_www_form params

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request['Content-type'] = 'application/json'
  request['Authorization'] = "Bearer #{@credentials.access_token}"

  response = http.request(request)
  unless response.code == '200'
    debugger
    return
  end

  json = JSON.parse(response.body)
  return [
    json['mediaItems'],
    json['nextPageToken']
  ]
end

def get_all_items
  all = []
  pageToken = nil

  VCR.use_cassette("get_all_items", :record => :new_episodes) do
    loop do
      items, pageToken = get_items pageToken
      all.concat items

      puts "items: #{all.size}"
      break if pageToken.nil? # || all.size > 1_000
    end
  end

  all
end

data = get_all_albums.map{|album|
  album.deep_slice('id', 'title', 'productUrl', 'mediaItemsCount')
}
CSVDatabase.create './data/albums.csv', data

data = get_all_items.map{|item|
  item.deep_slice('id', 'mimeType', 'filename', 'creationTime', 'cameraMake', 'cameraModel')
}
CSVDatabase.create './data/photos.csv', data

